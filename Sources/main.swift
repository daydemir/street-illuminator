import Foundation
import AWSLambdaRuntime
import SmithyIdentity
import AsyncHTTPClient

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
}

struct Input: Codable {
    let start_page: Int
//    let coordinate1: Coordinates
//    let coordinate2: Coordinates
}

struct Output: Codable {
    let result: String
}

Lambda.run { (context, input: Input, callback: @escaping (Result<Output, Swift.Error>) -> Void) in
    Task {
//        let box = BoundingBox(coordinate1: input.coordinate1, coordinate2: input.coordinate2)
        do {
            try await Provider.amsterdamPanos.loadImages(startPage: input.start_page, limit: nil)
            callback(.success(Output(result: "success! saved page \(input.start_page)")))
            
//            let data = try await Provider.amsterdamPanos(box: box, after: nil, limit: 2).fetchImages()
            //            try Provider.googleStreetView(box: box).fetchImages { result in
            //            try Provider.mapillary(box: box, limit: 5).fetchImages { result in
//            print(data.count)
//            print(data.map { $0.date() })
//            print(data)
//            
//            let results = try await data.asyncMap { try await Model.hiveAesthetics.run(with: $0) }
//            callback(.success(Output(result: results.joined(separator: "\n\n"))))
            
//            callback(.success(Output(result: data.description)))
        } catch {
            callback(.failure(Error.some(error: error, page: input.start_page)))
        }
    }
}

enum Error: Swift.Error {
    case some(error: Swift.Error, page: Int)
    
    var localizedDescription: String {
        switch self {
        case .some(let error, let page):
            return "Page \(page) failed. \(error.localizedDescription)"
        }
    }
}
