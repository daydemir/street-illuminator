//
//  Mapillary.swift
//
//
//  Created by Deniz Aydemir on 7/4/24.
//

import Foundation
import AsyncHTTPClient

struct Mapillary {
    
    struct Request: MultiImageRequest {
        
        
        let box: BoundingBox
        let limit: Int
        
    //    let isPano: Bool?
    //
    //    let startDate: Date
    //    let endDate: Date
        
        func queryParams() -> String {
            return "access_token=\(Keys().mapillaryAPIKey)&bbox=\(box.cornersQuery())&limit=\(limit)&fields=id,thumb_2048_url,geometry,captured_at,detections"
        }
        
        
        func images() async throws -> [any ImageData] {
            let request = HTTPClientRequest(url: "https://graph.mapillary.com/images?\(queryParams())")
            return try await JSONDecoder().decode(ImageGroup.self, from: Network.run(request: request)).data
        }
    }


    struct ImageGroup: Codable {
        let data: [Image]
    }

    struct Image: Codable, ImageData {
        let id: String
        let captured_at: TimeInterval
        let geometry: Geometry
        let thumb_2048_url: String
        
        enum CameraType: String, Codable {
            case perspective, fisheye, equirectangular, spherical
        }
        
        let camera_parameters: [Double]?
        let camera_type: CameraType?
        
        let compass_angle: Double?
        
        func idString() -> String { return id }
        
        func imageURL() throws -> URL {
            guard let url = URL(string: thumb_2048_url) else {
                throw Error.noImageURLFound
            }
            
            return url
        }
        
        func location() -> Coordinates? {
            geometry.getCoordinates()
        }
        
        func date() -> Date? {
            return Date(timeIntervalSince1970: captured_at)
        }
        
        enum Error: Swift.Error {
            case noImageURLFound
        }
    }
    
}
