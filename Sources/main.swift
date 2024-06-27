import AWSLambdaRuntime
import CoreLocation
import AsyncHTTPClient




struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct Input: Codable {
    let coordinate1: Coordinates
    let coordinate2: Coordinates
}

struct Output: Codable {
    let result: String
}

enum SIError: Swift.Error {
    case requestError(_: String)
    case unknown
}

Lambda.run { (context, input: Input, callback: @escaping (Result<Output, Error>) -> Void) in
//    Task {
//        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
//        do {
//            let request = HTTPClientRequest(url: "https://maps.googleapis.com/maps/api/streetview?\(input.streetViewParameters.queryParams())")
//            let response = try await httpClient.execute(request, timeout: .seconds(30))
//            print("HTTP head", response)
//            let body = try await response.body.collect(upTo: 1024 * 1024) // 1 MB
//            
//            // we use an overload defined in `NIOFoundationCompat` for `decode(_:from:)` to
//            // efficiently decode from a `ByteBuffer`
//            //                    let comic = try JSONDecoder().decode(Comic.self, from: body)
//            dump(body)
//            callback(.success(Output(result: String(data: Data(buffer: body), encoding: .utf8)!)))
//        } catch {
//            print("request failed: " + error.localizedDescription)
//        }
//    }
    
    let baseURL = "https://graph.mapillary.com/images?"
    let params = MapillaryParameters(coordinate1: input.coordinate1, coordinate2: input.coordinate2)
    let fullRequest = baseURL + params.queryParams()
    print(fullRequest)
    
    
    HTTPClient.shared.get(url: fullRequest).whenComplete { result in
        switch result {
        case .failure(let error):
            print("request failed: " + error.localizedDescription)
            callback(.failure(SIError.requestError(error.localizedDescription)))
        case .success(let response):
            if response.status == .ok {
                let imageGroup = try! JSONDecoder().decode(MapillaryImageGroup.self, from: response.body!)
//                JSONSerialization.jsonObject(with: response.body!)
//                let bodyString = Data(buffer: response.body!), encoding: .utf8)
//                let body = response.body?.getString(at: 0, length: 1024*1024)
                //response.body.collect(upTo: 1024 * 1024) // 1 MB
//                dump(body)
                let urls = imageGroup
                    .data
                    .map { $0.thumb_2048_url ?? "no url" }
                print(imageGroup.data)
//                print(urls)
                
                let urlsString = urls
                    .reduce(String(), { return $0 + $1 + "," })
                
                let output = Output(result: urlsString)
                callback(.success(output))
            } else {
                print(response.status)
                let bodyString = String(data: Data(buffer: response.body!), encoding: .utf8)
                print(bodyString)
                callback(.failure(SIError.unknown))
            }

        }
    }
    
    
//    Task {
//        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
//        do {
//            let baseURL = "https://graph.mapillary.com/images"
//            let params = MapillaryParameters(coordinate1: input.coordinate1, coordinate2: input.coordinate2)
//            let request = HTTPClientRequest(url: baseURL + params.queryParams())
//            let response = try await httpClient.execute(request, timeout: .seconds(30))
//            let body = try await response.body.collect(upTo: 1024 * 1024) // 1 MB
//            dump(body)
//            callback(.success(Output(result: String(data: Data(buffer: body), encoding: .utf8)!)))
//
//        } catch {
//            print("request failed: " + error.localizedDescription)
//        }
//    }


}



struct StreetViewParameters: Codable {
    let size: Size
    let latitude: Double
    let longitude: Double
    let fieldOfView: Double
    let heading: Double
    let pitch: Double
    
    func queryParams() -> String {
        return "size=\(size.width)x\(size.height)&location=\(latitude),\(longitude)&fov=\(fieldOfView)&heading=\(heading)&pitch=\(pitch)&key=\(googleAPIKey)"
    }
}

struct Size: Codable {
    let width: Int
    let height: Int
}



struct MapillaryParameters: Codable {

    let minLong: Double
    let minLat: Double
    let maxLong: Double
    let maxLat: Double
    
//    let isPano: Bool?
//    let limit: Int?
//    
//    let startDate: Date
//    let endDate: Date
    
    init(coordinate1: Coordinates, coordinate2: Coordinates) {
        self.minLong = min(coordinate1.longitude, coordinate2.longitude)
        self.minLat = min(coordinate1.latitude, coordinate2.latitude)
        self.maxLong = max(coordinate1.longitude, coordinate2.longitude)
        self.maxLat = max(coordinate1.latitude, coordinate2.latitude)
    }
    
    func queryParams() -> String {
        return "access_token=\(mapillaryAPIKey)&bbox=\(minLong),\(minLat),\(maxLong),\(maxLat)&fields=id,thumb_2048_url,geometry"
    }
}


struct MapillaryImageGroup: Codable {
    let data: [MapillaryImage]
}


struct MapillaryImage: Codable {
    let id: String
    
    enum CameraType: String, Codable {
        case perspective, fisheye, equirectangular, spherical
    }
    
    let camera_parameters: [Double]?
    let camera_type: CameraType?
    let captured_at: TimeInterval?
    let compass_angle: Double?
    let thumb_2048_url: String?
    let geometry: Geometry?
    
    func imageURL() throws -> URL {
        guard let urlString = thumb_2048_url, let url = URL(string: urlString) else {
            throw Error.noImageURLFound
        }
        
        return url
    }
    
    enum Error: Swift.Error {
        case noImageURLFound
    }
}


struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}


