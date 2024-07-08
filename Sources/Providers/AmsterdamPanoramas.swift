////
////  AmsterdamPanoramas.swift
////
////
////  Created by Deniz Aydemir on 7/4/24.
////
//
//import Foundation
//import AsyncHTTPClient
//
//struct AmsterdamPanoramas {
//    struct Link: Codable {
//        let href: String?
//    }
//    
//    struct MultiImage: Codable {
//        struct Links: Codable {
//            let `self`: Link
//            let next: Link
//            let previous: Link
//        }
//        
//        struct Embedded: Codable {
//            let panoramas: [Image]
//        }
//        
//        let _links: Links
//        let count: Int
//        let _embedded: Embedded
//    }
//    
//    struct Image: ImageData {
//        struct Links: Codable {
//            let equirectangular_small: Link
//        }
//        
//        let pano_id: String
//        let _links: Links
//        let geometry: Geometry
//        let timestamp: String
//        let roll: Double
//        let pitch: Double
//        let heading: Double
//        
//        
//        func idString() -> String {
//            return pano_id
//        }
//        
//        func location() -> Coordinates? {
//            return geometry.getCoordinates()
//        }
//        
//        func date() -> Date? {
//            let formatter = ISO8601DateFormatter()
//            formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime, .withDashSeparatorInDate]
//            return formatter.date(from: timestamp)
//        }
//        
//        func imageURL() throws -> URL {
//            guard let link = _links.equirectangular_small.href,
//                    let url = URL(string: link)
//            else { throw Error.badLink }
//            
//            return url
//        }
//        
//        enum Error: String, Swift.Error {
//            case badLink
//        }
//    }
//    
//    struct Request: MultiImageRequest {
//        
//        let box: BoundingBox
//        let after: Date?
//        let limit: Int
//        
//        private let base = "https://api.data.amsterdam.nl/panorama/panoramas/"
//        
//        private func dateQuery() -> String {
//            if let after {
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd"
//                let timestamp = formatter.string(from: after)
//                return "&timestamp_after=\(timestamp)"
//            } else {
//                return ""
//            }
//        }
//        
//        func images() async throws -> [ImageData] {
//            let url = base + "?bbox=\(box.cornersQuery())&limit_results=\(limit)\(dateQuery())"
//            return try await collectImages(url: url, currentImages: [])
//        }
//        
//        private func collectImages(url: String, currentImages: [ImageData]) async throws -> [ImageData] {
//            let data = try await Network.run(request: HTTPClientRequest(url: url))
//            let imageGroup = try JSONDecoder().decode(MultiImage.self, from: data)
//            let updatedImages = currentImages + imageGroup._embedded.panoramas
//            print("image count: \(imageGroup.count)")
//            print("image actual count: \(imageGroup._embedded.panoramas.count)")
//            print("next: \(imageGroup._links.next.href)")
//            
//            if let next = imageGroup._links.next.href {
//                try await Task.sleep(for: .seconds(1)) //delay to avoid over hitting the API
//                return try await collectImages(url: next, currentImages: updatedImages)
//            } else {
//                return updatedImages
//            }
//        }
//    }
//}
