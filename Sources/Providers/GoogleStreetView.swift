//
//  GoogleStreetView.swift
//
//
//  Created by Deniz Aydemir on 7/4/24.
//

import Foundation
import AsyncHTTPClient

struct GoogleStreetView {
    struct Image: Codable {
        
//        let date: Date
//        let location: Coordinates
        let pano_id: String
//        let status: String
    }
    
    struct Request {
        
        let box: BoundingBox
        let limit: Int
        
        func images() async throws -> [Image] {
            let urls = SingleRequest.fill(fromBox: box).map { $0.metadataURL() }
            print("Locations: \(urls.count)")
            
            return try await urls.asyncMap { url in
                let data = try await Network.run(request: HTTPClientRequest(url: url.absoluteString))
                return try JSONDecoder().decode(Image.self, from: data)
            }
        }
        
        
    }

    private struct SingleRequest: Codable {
        let size: Size
        let latitude: Double
        let longitude: Double
        let fieldOfView: Double
        let heading: Double
        let pitch: Double
        
        func queryParams() -> String {
            return "size=\(size.width)x\(size.height)&location=\(latitude),\(longitude)&fov=\(fieldOfView)&heading=\(heading)&pitch=\(pitch)&key=\(Keys().googleAPIKey)"
        }
        
        func url() -> URL {
            return URL(string: "https://maps.googleapis.com/maps/api/streetview?\(queryParams())")!
        }
        
        func metadataURL() -> URL {
            return URL(string: "https://maps.googleapis.com/maps/api/streetview/metadata?\(queryParams())")!
        }
        
        static func fill(fromBox box: BoundingBox) -> [SingleRequest] {
            return box.intoPoints(byMeters: 25).map { coordinate in
                return SingleRequest(size: Size(width: 640, height: 640), latitude: coordinate.latitude, longitude: coordinate.longitude, fieldOfView: 120, heading: 0, pitch: 0)
            }
        }
    }

    
}
