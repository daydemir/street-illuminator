// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
    
 let package = Package(
   name: "StreetIlluminator",
   products: [
     .executable(name: "StreetIlluminator", targets: ["StreetIlluminator"]),
   ],
   dependencies: [
     .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", .upToNextMajor(from:"0.3.0")),
     .package(url: "https://github.com/swift-server/async-http-client/", .upToNextMajor(from: "1.21.2")),
     .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
   ],
   targets: [
     .target(
       name: "StreetIlluminator",
       dependencies: [
         .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
         .product(name: "AsyncHTTPClient", package: "async-http-client"),
         .product(name: "SwiftyJSON", package: "SwiftyJSON"),
       ]
     ),
   ]
 )
