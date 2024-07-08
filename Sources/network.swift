//
//  network.swift
//
//
//  Created by Deniz Aydemir on 6/27/24.
//

import Foundation
import AsyncHTTPClient
import NIOFoundationCompat
import NIOCore
import AWSDynamoDB
import SotoDynamoDB

struct Network {
    
    static func run(request: HTTPClientRequest) async throws -> Data {
        print("request url: \(request.url)")
        let response = try await HTTPClient.shared.execute(request, timeout: .seconds(60))
        return Data(buffer: try await response.body.collect(upTo: 1024*1024*10)) //10mb
    }
}


protocol DynamoCodable: Codable {
    func writeable() throws -> [String: DynamoDB.AttributeValue]
}

struct Database {
    static let dynamo = DynamoDB(client: awsClient)
    
    static func batchWrite(toTable table: String, items: [DynamoCodable]) async throws {
        let putRequests = items.map { DynamoDB.WriteRequest.init(putRequest: .init(item: try! $0.writeable())) }
        
        do {
            let output = try await dynamo.batchWriteItem(DynamoDB.BatchWriteItemInput(requestItems: [table: putRequests]))
            print("output: \(output)")
        } catch {
            if (error as? SotoDynamoDB.DynamoDBErrorType)?.errorCode == "ProvisionedThroughputExceededException" {
//            if error.localizedDescription.contains("ProvisionedThroughputExceededException") {
                print("throughput exceeded, waiting 5 seconds...")
                try await Task.sleep(for: .seconds(5))
                try await batchWrite(toTable: table, items: items)
            } else {
                throw error
            }
        }
    }
}
