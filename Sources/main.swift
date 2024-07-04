import AWSLambdaRuntime
import CoreLocation
import AsyncHTTPClient

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
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

if #available(macOS 12.0, *) {
    Lambda.run { (context, input: Input, callback: @escaping (Result<Output, Error>) -> Void) in
        
        let box = BoundingBox(coordinate1: input.coordinate1, coordinate2: input.coordinate2)
        do {
//            try Provider.amsterdamPanos(box: box, limit: 5).fetchImages { result in    
//            try Provider.googleStreetView(box: box).fetchImages { result in
            try Provider.mapillary(box: box, limit: 5).fetchImages { result in
                
                switch result {
                case .success(let data):
                    print(data.count)
                    print(data.map { $0.date() })
                    print(data)
                    for datum in data {
                        do {
                            var results: [String] = []
                            try Model.hiveAesthetics.run(withData: datum) { result in
    
                                print("hive result")
                                print(result)
                                switch result {
                                case .success(let success):
                                    let resultString = String(data: success, encoding: .utf8)!
                                    print(resultString)
                                    results.append(resultString)
                                case .failure(let failure):
                                    results.append(failure.localizedDescription)
                                }
                            }
    
                            let fullMessage = results.joined(separator: "\n\n")
                            callback(.success(Output(result: fullMessage)))
                        } catch {
                            callback(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    callback(.failure(error))
                }
            }
        } catch {
            callback(.failure(error))
        }
    }
}
