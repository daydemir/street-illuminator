//
//  model.swift
//
//
//  Created by Deniz Aydemir on 6/27/24.
//

import Foundation
import AsyncHTTPClient
import SwiftyJSON


enum Model {
    case hiveAesthetics
    
    func run(withData data: ImageData, completion: @escaping (_ result: Result<Data, Swift.Error>) -> Void) throws {
        switch self {
        case .hiveAesthetics:
            
            var request = URLRequest(url: URL(string: "https://api.thehive.ai/api/v2/task/sync")!)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = ["accept": "application/json", "authorization": "token \(Keys().hiveAPIKey)"]
            let body = "url=\(try data.imageURL().absoluteString)"
            print(body)
            request.httpBody = body.data(using: .utf8)
            print(try data.imageURL().absoluteString)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard
                    error == nil,
                    let data = data,
                    let string = String(data: data, encoding: .utf8)
                else {
                    print(error ?? "Unknown error")
                    completion(.failure(error ?? Error.unknown))
                    return
                }

                print(string)
                completion(.success(data))
                
            }.resume()
            
            
//            var request = try HTTPClient.Request(url: "https://api.thehive.ai/api/v2/task/sync", method: .POST)
//            request.headers.add(name: "accept", value: "application/json")
//            request.headers.add(name: "authorization", value: "token \(Keys().hiveAPIKey)")
//            request.body = .data("url=\(try data.imageURL().absoluteString)".data(using: .utf8)!)
//            
//            Network.run(request: request, completion: completion)
        }
    }
    
    enum Error: String, Swift.Error {
        case unknown
    }
}
