//
//  model.swift
//
//
//  Created by Deniz Aydemir on 6/27/24.
//

import Foundation
import AsyncHTTPClient
//import SwiftyJSON


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
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let string = String(data: data, encoding: .utf8)!
            return string
        }
    }
}
