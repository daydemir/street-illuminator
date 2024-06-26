import AWSLambdaRuntime

struct Input: Codable {
    let number: Double
}

struct Output: Codable {
    let result: String
}

Lambda.run { (context, input: Input, callback: @escaping (Result<Output, Error>) -> Void) in
    
    callback(.success(Output(result: "Hello World: \(input.number)")))
}
