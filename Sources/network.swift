//
//  network.swift
//
//
//  Created by Deniz Aydemir on 6/27/24.
//

import Foundation
import AsyncHTTPClient
import NIOFoundationCompat

struct Network {
    static func run(request: HTTPClient.Request, completion: @escaping (_ result: Result<Foundation.Data, Swift.Error>) -> Void) {
        print(request.url)
        HTTPClient.shared.execute(request: request).whenComplete { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                if let body = response.body {
                    completion(.success(Foundation.Data(buffer: body)))
                } else {
                    completion(.failure(Error.unknown))
                }
            }
        }
    }
    
    enum Error: Swift.Error {
        case unknown
    }
}
