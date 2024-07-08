//
//  AmsterdamPanoramas.swift
//
//
//  Created by Deniz Aydemir on 7/4/24.
//

import Foundation
import AsyncHTTPClient
//import AWSDynamoDB
import SotoDynamoDB
import SotoS3

struct AmsterdamPanoramas {
    private static let base = "https://api.data.amsterdam.nl/panorama/panoramas/"
    
    struct Link: Codable {
        let href: String?
    }
    
    struct MultiImage: Codable {
        struct Links: Codable {
            let `self`: Link
            let next: Link
            let previous: Link
        }
        
        struct Embedded: Codable {
            let panoramas: [Image]
        }
        
        let _links: Links
        let count: Int
        let _embedded: Embedded
    }
    
    struct Image: ImageData, DynamoCodable {
        struct Links: Codable {
            let `self`: Link
            let equirectangular_full: Link
            let equirectangular_medium: Link
            let equirectangular_small: Link
            let cubic_img_preview: Link
            let thumbnail: Link
            let adjacencies: Link
        }
        
        let pano_id: String
        let _links: Links
        let geometry: Geometry
        let timestamp: String
        
        let filename: String
        let surface_type: String
        
        let mission_distance: Double
        let mission_type: String
        let mission_year: String
        let tags: [String]
        
        let roll: Double
        let pitch: Double
        let heading: Double
        
        let cubic_img_baseurl: String?
        let cubic_img_pattern: String?
        
        
        func idString() -> String {
            return pano_id
        }
        
        func location() -> Coordinates? {
            return geometry.getCoordinates()
        }
        
        func date() -> Date? {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime, .withDashSeparatorInDate]
            return formatter.date(from: timestamp)
        }
        
        func imageURL() throws -> URL {
            guard let link = _links.equirectangular_small.href,
                  let url = URL(string: link)
            else { throw Error.badLink }
            
            return url
        }
        
        func writeable() throws -> [String: DynamoDB.AttributeValue] {
            return try DynamoDBEncoder().encode(self)
        }
        
        enum Error: String, Swift.Error {
            case badLink
        }
    }
    
    struct AllRequest {
        let startPage: Int?
        let limit: Int?
        let selfPaginate: Bool
        
        private func startPageQuery() -> String {
            if let startPage {
                return "page=\(startPage)"
            } else {
                return ""
            }
        }
        
        private func limitQuery() -> String {
            if let limit {
                return "limit_results=\(limit)"
            } else {
                return ""
            }
        }
        
        func images() async throws {
            let url = AmsterdamPanoramas.base + "?\(startPageQuery())&\(limitQuery())"
            try await collectImagesAndWriteDB(url: url, selfPaginate: selfPaginate)
        }
        
    }
    
    struct BoxRequest: MultiImageRequest {
        
        let box: BoundingBox
        let after: Date?
        let limit: Int
        
        
        private func dateQuery() -> String {
            if let after {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let timestamp = formatter.string(from: after)
                return "&timestamp_after=\(timestamp)"
            } else {
                return ""
            }
        }
        
        func images() async throws -> [ImageData] {
            let url = AmsterdamPanoramas.base + "?bbox=\(box.cornersQuery())&limit_results=\(limit)\(dateQuery())"
            return try await collectImages(url: url, currentImages: [])
        }
    }
    
    
    private static func collectImages(url: String, currentImages: [ImageData]) async throws -> [ImageData] {
        let data = try await Network.run(request: HTTPClientRequest(url: url))
        let imageGroup = try JSONDecoder().decode(MultiImage.self, from: data)
        let updatedImages = currentImages + imageGroup._embedded.panoramas
        print("image count: \(imageGroup.count)")
        print("image actual count: \(imageGroup._embedded.panoramas.count)")
        print("next: \(imageGroup._links.next.href ?? "none")")
        
        if let next = imageGroup._links.next.href {
            try await Task.sleep(for: .seconds(1)) //delay to avoid over hitting the API
            return try await collectImages(url: next, currentImages: updatedImages)
        } else {
            return updatedImages
        }
    }
    
    private static func collectImagesAndWriteDB(url: String, selfPaginate: Bool) async throws {
        let data = try await Network.run(request: HTTPClientRequest(url: url))
        let imageGroup = try JSONDecoder().decode(MultiImage.self, from: data)
        let images = imageGroup._embedded.panoramas
        print("fetched url: \(url)")
        print("image count: \(imageGroup.count)")
        print("image actual count: \(imageGroup._embedded.panoramas.count)")
        print("next: \(imageGroup._links.next.href ?? "none")")
        
        try await Database.batchWrite(toTable: "amsterdam-panoramas", items: images)
        
        print("saved results of url: \(url)")
        print("---------------------")
        
        if let next = imageGroup._links.next.href, selfPaginate {
//            try await Task.sleep(for: .seconds(1)) //delay to avoid over hitting the API
            try await collectImagesAndWriteDB(url: next, selfPaginate: selfPaginate)
        }
    }
}
