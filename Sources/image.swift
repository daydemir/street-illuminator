//
//  image.swift
//
//
//  Created by Deniz Aydemir on 7/9/24.
//

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct Image {
    
    let image: AmsterdamPanoramas.Image
    
    func download() async throws {
        let url = try image.imageURL()
        let coordinates = image.location()!
        let id = image.idString()
        
        //        let data = try Data(contentsOf: url)
        if let image = CGImage(jpegDataProviderSource: CGDataProvider(url: url as CFURL)!, decode: nil, shouldInterpolate: false, intent: .defaultIntent) {
            
            
            var data = NSMutableData()
            let destinationDataRef = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)!
            
            let exif = self.image.toExif() as CFDictionary
            print(exif)
            CGImageDestinationAddImage(destinationDataRef, image, exif)
            CGImageDestinationFinalize(destinationDataRef)
            print(url.absoluteString)
            let path = FileManager.default.currentDirectoryPath
            print("save path " + path)
//            try FileManager.default.createDirectory(at: URL(string: path)!, withIntermediateDirectories: true)
            FileManager.default.createFile(atPath: path + "/" + id + ".jpeg", contents: data as Data)
        } else {
            print("no image at url")
        }
    }
}

extension AmsterdamPanoramas.Image {
    func toExif() -> [String: Any] {
        let location = location()!.toExif()
        let orientation: [String: Any] = [
            "Pitch": pitch,
            "Roll": roll,
            String(kCGImagePropertyGPSImgDirection): heading,
            String(kCGImagePropertyGPSImgDirectionRef): "N",
        ]
        return [String(kCGImagePropertyGPSDictionary): location.merging(orientation) { current, _ in current }]
        
    }
}



//func saveImageWithImageData(data: NSData, properties: NSDictionary, completion: (data: NSData, path: NSURL) -> Void) {
//
//    let imageRef: CGImageSourceRef = CGImageSourceCreateWithData((data as CFDataRef), nil)!
//    let uti: CFString = CGImageSourceGetType(imageRef)!
//    let dataWithEXIF: NSMutableData = NSMutableData(data: data)
//    let destination: CGImageDestinationRef = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableDataRef), uti, 1, nil)!
//
//    CGImageDestinationAddImageFromSource(destination, imageRef, 0, (properties as CFDictionaryRef))
//    CGImageDestinationFinalize(destination)
//
//    var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//    let savePath: String = paths[0].stringByAppendingPathComponent("exif.jpg")
//
//    let manager: NSFileManager = NSFileManager.defaultManager()
//    manager.createFileAtPath(savePath, contents: dataWithEXIF, attributes: nil)
//
//    completion(data: dataWithEXIF,path: NSURL(string: savePath)!)
//
//    print("image with EXIF info converting to NSData: Done! Ready to upload! ")
//
//}

extension Coordinates {
    func toExif() -> [String: Any] {
        
        let altitudeProperties: [String: Any]
        if let altitude {
            altitudeProperties = [
                String(kCGImagePropertyGPSAltitudeRef): Int(altitude < 0.0 ? 1 : 0),
                String(kCGImagePropertyGPSAltitude): abs(altitude)
            ]
        } else {
            altitudeProperties = [:]
        }
        
        let latitudeRef = latitude < 0.0 ? "S" : "N"
        let longitudeRef = longitude < 0.0 ? "W" : "E"
        
        return [
            
            String(kCGImagePropertyGPSLatitude): abs(latitude),
            String(kCGImagePropertyGPSLongitude): abs(longitude),
//            String(kCGImagePropertyGPSLatitude): abs(latitude),
//            String(kCGImagePropertyGPSLongitude): abs(longitude),
            String(kCGImagePropertyGPSLatitudeRef): latitudeRef,
            String(kCGImagePropertyGPSLongitudeRef): longitudeRef,
        ].merging(altitudeProperties) { current, _ in current }
    }
}
