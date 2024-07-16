//
//  core-model.swift
//  street-core
//
//  Created by Deniz Aydemir on 7/15/24.
//

import Foundation

public struct Coordinates: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
}

public struct StreetImage: Codable, Hashable {
    public static func == (lhs: StreetImage, rhs: StreetImage) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let location: Coordinates
    let date: Date?
    let url: URL
    let fov: Double
    let heading: Double
    
    init(_ pano: AmsterdamPanoramas.Image) throws {
        self.id = pano.pano_id
        self.location = pano.location()!
        self.fov = 360
        self.heading = pano.heading
        self.date = pano.date()!
        self.url = try pano.imageURL()
    }
    
    init(_ image: GoogleStreetView.Image) throws {
        self.id = image.pano_id
        self.url = URL(string: image.url)!
        self.date = image.date
        self.fov = image.fieldOfView
        self.heading = image.heading
        self.location = image.location
    }
}


public protocol ImageData: Codable {
    func idString() -> String
    func location() -> Coordinates?
    func date() -> Date?
    func imageURL() throws -> URL
}

public protocol MultiImageRequest {
    associatedtype T: ImageData
    
    var box: BoundingBox { get }
    var limit: Int { get }
    
    func images() async throws -> [T]
}


public struct BoundingBox: Codable {
    public let coordinate1: Coordinates
    public let coordinate2: Coordinates
    
    public func intoPoints(byMeters meters: Int) -> [Coordinates] {
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
    
    public func cornersQuery() -> String {
        let edges = Edges(box: self)
        return "\(edges.minLong),\(edges.minLat),\(edges.maxLong),\(edges.maxLat)"
    }
    
    public static func degrees(forMeters meters: Int) -> Double {
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

public struct Size: Codable {
    public let width: Int
    public let height: Int
}

public struct Geometry: Codable {
    public let type: String
    public let coordinates: [Double]
    
    public func getCoordinates() -> Coordinates? {
        guard let long = coordinates[safe: 0],
              let lat = coordinates[safe: 1] else {
            return nil
        }
        
        return Coordinates(latitude: lat, longitude: long, altitude: coordinates[safe: 2])
    }
}
