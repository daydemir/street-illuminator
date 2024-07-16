// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
    
 let package = Package(
   name: "StreetIlluminator",
   platforms: [
           .macOS(.v13)
    ],
   products: [
     .executable(name: "StreetIlluminator", targets: ["StreetIlluminator"]),
   ],
   dependencies: [
     .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", .upToNextMajor(from:"0.3.0")),
     .package(url: "https://github.com/swift-server/async-http-client/", .upToNextMajor(from: "1.21.2")),
     .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "0.16.0"),
     .package(url: "https://github.com/soto-project/soto.git", from: "6.0.0"),

   ],
   targets: [
     .executableTarget(
       name: "StreetIlluminator",
       dependencies: [
         .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
         .product(name: "AsyncHTTPClient", package: "async-http-client"),
         .product(name: "AWSS3", package: "aws-sdk-swift"),
         .product(name: "AWSDynamoDB", package: "aws-sdk-swift"),
         .product(name: "SotoS3", package: "soto"),
         .product(name: "SotoDynamoDB", package: "soto"),
       ]
     ),
   ]
 )
