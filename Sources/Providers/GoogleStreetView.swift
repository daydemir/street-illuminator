////
////  GoogleStreetView.swift
////
////
////  Created by Deniz Aydemir on 7/4/24.
////
//
//import Foundation
//import AsyncHTTPClient
//import SwiftyJSON
//
//struct GoogleStreetView {
//    struct Image: Codable {
//        let date: Date
//        let location: Coordinates
//        let panoID: String
//        let status: String
//    }
//    
//    struct Request: MultiImageRequest {
//        let box: BoundingBox
//        let limit: Int
//        
//        func images(completion: (Result<[any ImageData], any Error>) -> Void) throws {
//            let urls = SingleRequest.fill(fromBox: box).map { $0.metadataURL() }
//            print("Locations: \(urls.count)")
//            
//            var panoIDs: [String] = []
//            for url in urls {
//                Task {
//                    try await withThrowingTaskGroup(of: String.self) { group in
//                    }
//                }
//                Network.run(request: try HTTPClient.Request(url: url, method: .GET)) { result in
//                    switch result {
//                    case .success(let data):
//                        if let panoID = JSON(data)["pano_id"].string {
//                            panoIDs.append(panoID)
//                            print("Images found: \(Set(panoIDs).count)")
//                        }
//                        print(String(data: data, encoding: .utf8))
//                    case .failure(let error): 
//                        completion(.failure(error))
//                    }
//                }
//            }
//        }
//        
//        
//    }
//
//    private struct SingleRequest: Codable {
//        let size: Size
//        let latitude: Double
//        let longitude: Double
//        let fieldOfView: Double
//        let heading: Double
//        let pitch: Double
//        
//        func queryParams() -> String {
//            return "size=\(size.width)x\(size.height)&location=\(latitude),\(longitude)&fov=\(fieldOfView)&heading=\(heading)&pitch=\(pitch)&key=\(Keys().googleAPIKey)"
//        }
//        
//        func url() -> URL {
//            return URL(string: "https://maps.googleapis.com/maps/api/streetview?\(queryParams())")!
//        }
//        
//        func metadataURL() -> URL {
//            return URL(string: "https://maps.googleapis.com/maps/api/streetview/metadata?\(queryParams())")!
//        }
//        
//        static func fill(fromBox box: BoundingBox) -> [SingleRequest] {
//            return box.intoPoints(byMeters: 25).map { coordinate in
//                return SingleRequest(size: Size(width: 640, height: 640), latitude: coordinate.latitude, longitude: coordinate.longitude, fieldOfView: 120, heading: 0, pitch: 0)
//            }
//        }
//    }
//
//    
//}
