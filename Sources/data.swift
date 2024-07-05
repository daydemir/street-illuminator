//
//  data.swift
//
//
//  Created by Deniz Aydemir on 6/27/24.
//

import Foundation
import AsyncHTTPClient
import SwiftyJSON

protocol ImageData: Codable {
    func idString() -> String
    func location() -> Coordinates?
    func date() -> Date?
    func imageURL() throws -> URL
}

protocol MultiImageRequest {
    var box: BoundingBox { get }
    var limit: Int { get }
    
    func images(completion: @escaping (_ result: Result<[ImageData], Error>) -> Void) throws
}

@available(macOS 12.0, *)
enum Provider {
    case mapillary(box: BoundingBox, limit: Int)
//    case googleStreetView(box: BoundingBox)
    case amsterdamPanos(box: BoundingBox, after: Date, limit: Int)
    
    func fetchImages(completion: @escaping (_ result: Result<[ImageData], Error>) -> Void) throws {
        switch self {
        case .amsterdamPanos(let box, let after, let limit):
            try AmsterdamPanoramas.Request(box: box, after: after, limit: limit).images(completion: completion)
            
//        case .googleStreetView(let box):
            
//            let request = try HTTPClient.Request(url: "https://maps.googleapis.com/maps/api/streetview?\(parameters.queryParams())", method: .GET)
//            Network.run(request: request) { result in
//                switch result {
//                case .success(let response):
//                }
//            }
            
        case .mapillary(let box, let limit):
            try Mapillary.Request(box: box, limit: limit).images(completion: completion)
        }
    }
}


struct BoundingBox: Codable {
    let coordinate1: Coordinates
    let coordinate2: Coordinates
    
    func intoPoints(byMeters meters: Int) -> [Coordinates] {
        let edges = Edges(box: self)
        let degrees = BoundingBox.degrees(forMeters: meters)
        let latDivisions = (edges.maxLat - edges.minLat) / degrees
        var latitudes = [edges.minLat]
        for division in 0..<Int(latDivisions) {
            latitudes.append(latitudes.last! + Double(division)*degrees)
        }
        
        let longDivisions = (edges.maxLong - edges.minLong) / degrees
        var longitudes = [edges.minLong]
        for division in 0..<Int(longDivisions) {
            longitudes.append(longitudes.last! + Double(division)*degrees)
        }
        
        return latitudes.reduce([Coordinates]()) { combined, latitude in
            let longsForLat = longitudes.map { Coordinates(latitude: latitude, longitude: $0, altitude: nil) }
            return combined + longsForLat
        }
    }
    
    func cornersQuery() -> String {
        let edges = Edges(box: self)
        return "\(edges.minLong),\(edges.minLat),\(edges.maxLong),\(edges.maxLat)"
    }
    
    static func degrees(forMeters meters: Int) -> Double {
        Double(meters) / 50.0 * 0.0005
    }
    
    
    private struct Edges {
        let minLat: Double
        let maxLat: Double
        let minLong: Double
        let maxLong: Double
        
        init(box: BoundingBox) {
            let coordinate1 = box.coordinate1
            let coordinate2 = box.coordinate2
            
            self.minLong = min(coordinate1.longitude, coordinate2.longitude)
            self.minLat = min(coordinate1.latitude, coordinate2.latitude)
            self.maxLong = max(coordinate1.longitude, coordinate2.longitude)
            self.maxLat = max(coordinate1.latitude, coordinate2.latitude)
        }
    }
}

struct Size: Codable {
    let width: Int
    let height: Int
}

struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
    
    func getCoordinates() -> Coordinates? {
        var coordinates = coordinates
        guard let long = coordinates[safe: 0],
              let lat = coordinates[safe: 1] else {
            return nil
        }
        
        return Coordinates(latitude: lat, longitude: long, altitude: coordinates[safe: 2])
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
