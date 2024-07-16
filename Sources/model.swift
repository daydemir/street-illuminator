//
//  model.swift
//
//
//  Created by Deniz Aydemir on 6/27/24.
//

import Foundation
import AsyncHTTPClient
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


enum Model {
    case hiveAesthetics
    
    func run(with data: ImageData) async throws -> String {
        switch self {
        case .hiveAesthetics:
            var request = URLRequest(url: URL(string: "https://api.thehive.ai/api/v2/task/sync")!)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = ["accept": "application/json", "authorization": "token \(Keys().hiveAPIKey)"]
            let body = "url=\(try data.imageURL().absoluteString)"
            request.httpBody = body.data(using: .utf8)
            
            //using this until we upgrade to Swift 6, where FoundationNetworking (used on Linux not macOS) should have the async/await functions available
            return try await withCheckedThrowingContinuation { continuation in
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data {
                        let string = String(data: data, encoding: .utf8)!
                        continuation.resume(returning: string)
                    } else if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: Error.unknown)
                    }
                }
            }
        }
    }
    
    enum Error: String, Swift.Error {
        case unknown
    }
}
