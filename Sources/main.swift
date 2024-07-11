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
    let body: String
}

struct Output: Codable {
    let result: String
}


let start = 1
let longStride = 0.01
let latStride = 0.01
for long in stride(from: 4.88, through: 5.2, by: longStride) {
    for lat in stride(from: 52.39, through: 52.9, by: latStride) {
        print("will try region \(long), \(lat)")
        let first = (long, lat)
        let second = (long + longStride + 0.000001, lat + latStride + 0.000001)
        
        for i in start..<start+10000 {
            let start = Date()
                do {
                    var request = URLRequest(url: URL(string: "https://ybmnk2jka2yqq52bxmbwmdau640slvva.lambda-url.us-east-1.on.aws/invoke")!)
                    request.httpMethod = "POST"
                    request.httpBody = "{\"box\": {\"coordinate1\": {\"longitude\": \(first.0), \"latitude\": \(first.1)},\"coordinate2\": {\"longitude\": \(second.0), \"latitude\": \(second.1)}},\"selfPaginate\": false,\"page\":\(i),\"limit\":100000000}".data(using: .utf8)!
                    request.allHTTPHeaderFields = ["accept": "application/json", "Content-Type": "application/json"]
                    print("starting request for page \(i)...")
                    let response = try await URLSession.shared.data(for: request)
                    let serverMessage = String(data: response.0, encoding: .utf8)
                    if serverMessage?.lowercased() == "Internal Server Error".lowercased() {
                        print("reached end of list, will try to break out")
                        break
                    }
                    print(serverMessage ?? response)
                } catch {
                    print("page \(i) failed: " + error.localizedDescription)
                }
            print("took \(Date().timeIntervalSince(start))\n-------------")
        }
    }
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
