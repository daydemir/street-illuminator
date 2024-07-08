////
////  network.swift
////
////
////  Created by Deniz Aydemir on 6/27/24.
////
//
//import Foundation
//import AsyncHTTPClient
//import NIOFoundationCompat
//import NIOCore
//
//struct Network {
//    
//    static func run(request: HTTPClientRequest) async throws -> Data {
//        print("request url: \(request.url)")
//        let response = try await HTTPClient.shared.execute(request, timeout: .seconds(30))
//        return Data(buffer: try await response.body.collect(upTo: 1024*1024*10)) //10mb
//    }
//}
