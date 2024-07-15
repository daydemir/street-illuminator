import Foundation
import AWSLambdaRuntime
import SmithyIdentity
import AsyncHTTPClient

struct Input: Codable {
    let body: String
}

struct Output: Codable {
    let result: String
}



Lambda.run { (context, input: Input, callback: @escaping (Result<Output, Swift.Error>) -> Void) in
    Task {
        
        
//        let box = BoundingBox(coordinate1: input.coordinate1, coordinate2: input.coordinate2)
        
        do {
            let panoRequest: AmsterdamPanoramas.BoxRequest = try JSONDecoder().decode(AmsterdamPanoramas.BoxRequest.self, from: input.body)
            try await panoRequest.saveImages()
            callback(.success(Output(result: "success! saved:\n\(panoRequest.url)")))
        } catch {
            callback(.failure(error))
        }
        
        

//        for page in startPage..<startPage+10 {
//            do {
//                try await Provider.amsterdamPanos.loadImages(startPage: page, limit:
//                callback(.success(Output(result: "success! saved page \(startPage)")))
//            } catch {
//                callback(.failure(Error.some(error: error, page: page)))
//            }
//        }
        
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
    
    var localizedDescription: String {
        switch self {
        case .some(let error, let page):
            return "Page \(page) failed. \(error.localizedDescription)"
        case .noStartPage:
            return "No start page found in body JSON"
        }
    }
}
