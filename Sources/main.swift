import Foundation
import AWSLambdaRuntime
import SmithyIdentity
import AsyncHTTPClient

struct Input: Codable {
    let body: String
}

struct Output: Codable {
    let result: [AmsterdamPanoramas.Image]
}


struct RegionRequest: Codable {
    
    enum Provider: String, Codable {
        case amsterdam_panoramas
        case google
        case mapillary
    }
    
    let provider: Provider
    let box: BoundingBox
    let limit: Int
    
//    let after: Date?
//    let page: Int?
}


Lambda.run { (context, input: Input, callback: @escaping (Result<Output, Swift.Error>) -> Void) in
    Task {
        
        do {
            let regionRequest: RegionRequest = try JSONDecoder().decode(RegionRequest.self, from: input.body)
            switch regionRequest.provider {
            case .amsterdam_panoramas:
                let panoRequest = AmsterdamPanoramas.BoxRequest(regionRequest: regionRequest)
                let images = try await panoRequest.images()
                callback(.success(Output(result: images)))
//                callback(.failure(Error.unsupportedProvider))
            case .google:
                callback(.failure(Error.unsupportedProvider))

//                let request = GoogleStreetView.Request(box: regionRequest.box, limit: regionRequest.limit)
//                let images = try await request.images()
//                print(images.count)
//                callback(.success(Output(result: images)))
                callback(.failure(Error.unsupportedProvider))
            case .mapillary:
                callback(.failure(Error.unsupportedProvider))

//                let mapillaryRequest = Mapillary.Request(regionRequest: regionRequest)
//                let images = try await mapillaryRequest.images()
//                callback(.success(Output<Mapillary.Image>(result: images)))
                
            }
        } catch {
            callback(.failure(error))
        }
        
//        let date = Date("1/1/2022, 12:00 PM", strategy: .dateTime)
        
//        let data = try await Provider.amsterdamPanos.fetchImages(box: box, after: nil, limit: 1000000000)
        //            try Provider.googleStreetView(box: box).fetchImages { result in
        //            try Provider.mapillary(box: box, limit: 5).fetchImages { result in
//        data
//            .compactMap { $0 as? AmsterdamPanoramas.Image }
//            .map { Image(image: $0) }
//            .forEach { image in
//                Task { try! await image.download() }
//            }
        
        
        
//            print(data.count)
//            print(data.map { $0.date() })
//            print(data)
//
//            let results = try await data.asyncMap { try await Model.hiveAesthetics.run(with: $0) }
//            callback(.success(Output(result: results.joined(separator: "\n\n"))))
        
//            callback(.success(Output(result: data.description)))
    }
}




enum Error: Swift.Error {
    case some(error: Swift.Error, page: Int)
    case noStartPage
    case unsupportedProvider
    
    var localizedDescription: String {
        switch self {
        case .some(let error, let page):
            return "Page \(page) failed. \(error.localizedDescription)"
        case .noStartPage:
            return "No start page found in body JSON"
        case .unsupportedProvider:
            return "This data provider is currently unsupported"
        }
    }
}
