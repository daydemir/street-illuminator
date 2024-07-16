//
//  GoogleStreetView.swift
//
//
//  Created by Deniz Aydemir on 7/4/24.
//

import Foundation
import AsyncHTTPClient


struct GoogleStreetView {
    struct ImageMetadata: Codable {
        struct Location: Codable {
            let lat: Double
            let lng: Double
            
            func coordinates() -> Coordinates {
                return Coordinates(latitude: lat, longitude: lng, altitude: nil)
            }
        }
        
        let copyright: String
        let date: String
        let location: Location
        let pano_id: String
        let status: String
        
        fileprivate func image(request: SingleRequest) async throws -> Image {
            Image(pano_id: pano_id, location: location.coordinates(), status: status, date: nil, fieldOfView: request.fieldOfView, heading: request.heading, size: request.size)
        }
    }
    
    struct Image: Codable {
        let pano_id: String
        let location: Coordinates
        let status: String
        let date: Date?
        
        let fieldOfView: Double
        let heading: Double
        let size: Size
        
        var url: String {
            return "https://maps.googleapis.com/maps/api/streetview?pano=\(pano_id)&size=\(size.width)x\(size.height)&key=\(Keys().googleAPIKey)"
        }
    }
    
    struct Request {
        
        let box: BoundingBox
        let limit: Int
        
        func images() async throws -> [Image] {
            let requests = SingleRequest.fill(fromBox: box)[0..<limit]
            print("Locations: \(requests.count)")
            
            return try await requests.asyncMap { request in
                let data = try await Network.run(request: HTTPClientRequest(url: request.metadataURL().absoluteString))
                if let metadata = try? JSONDecoder().decode(ImageMetadata.self, from: data) {
                    return try await metadata.image(request: request)
                } else {
                    return nil
                }
            }.compactMap { $0 }
        }
        
        
    }

    fileprivate struct SingleRequest: Codable {
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
                let size = Size(width: 640, height: 640)
                let first = SingleRequest(size: size, latitude: coordinate.latitude, longitude: coordinate.longitude, fieldOfView: 120, heading: 60, pitch: 0)
                let second = SingleRequest(size: size, latitude: coordinate.latitude, longitude: coordinate.longitude, fieldOfView: 120, heading: 180, pitch: 0)
                let third = SingleRequest(size: size, latitude: coordinate.latitude, longitude: coordinate.longitude, fieldOfView: 120, heading: 300, pitch: 0)
                return [first, second, third]
            }.flatMap { $0 }
        }
    }

    
}
