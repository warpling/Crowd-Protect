//
//  Redactor.swift
//  Crowd Protect
//
//  Created by Conrad Kramer on 6/6/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import Foundation
import UIKit
import CoreVideo
import CoreGraphics
import CoreImage
import Vision

protocol Redactable {
    var integralSize: CVPixelBuffer.IntegralSize { get }
    var ciImage: CIImage { get }
    var requestHandler: VNImageRequestHandler { get }
    var orientation: CGImagePropertyOrientation { get }
}

extension CVPixelBuffer: Redactable {
    var ciImage: CIImage {
        CIImage(cvPixelBuffer: self)
    }

    var orientation: CGImagePropertyOrientation {
        return .up
    }

    var requestHandler: VNImageRequestHandler {
        VNImageRequestHandler(cvPixelBuffer: self, options: [:])
    }
}

extension UIImage: Redactable {
    var integralSize: CVPixelBuffer.IntegralSize {
        .init(width: cgImage!.width, height: cgImage!.height)
    }

    var orientation: CGImagePropertyOrientation {
        // Note: We currently require images to have their orientation baked in
        return .up
    }

    var ciImage: CIImage {
        CIImage(cgImage: cgImage!)
    }

    var requestHandler: VNImageRequestHandler {
        VNImageRequestHandler(cgImage: cgImage!, orientation: orientation, options: [:])
    }
}


extension CGImage: Redactable {
    var integralSize: CVPixelBuffer.IntegralSize {
        .init(width: width, height: height)
    }

    var orientation: CGImagePropertyOrientation {
        .up
    }
    
    var ciImage: CIImage {
        CIImage(cgImage: self)
    }
    
    var requestHandler: VNImageRequestHandler {
        VNImageRequestHandler(cgImage: self, options: [:])
    }
}

extension VNDetectFaceRectanglesRequest {
    convenience init(completionHandler: ((Result<VNDetectFaceRectanglesRequest, Error>) -> Void)? = nil) {
        self.init { (request, error) in
            if let error = error {
                completionHandler?(.failure(error))
            } else {
                completionHandler?(.success(request as! VNDetectFaceRectanglesRequest))
            }
        }
    }
}

final class Redactor {
    let context = CIContext()

    private static func mask(size: CVPixelBuffer.IntegralSize, regions: [CGRect]) -> CIImage? {
        guard let context = CGContext.context(data: nil, size: size, bytesPerRow: size.width, format: .mask) else {
            return nil
        }
        
        context.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(origin: .zero, size: CGSize(integralSize: size)))
        context.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
        context.fill(regions)
        
        guard let image = context.makeImage() else {
            return nil
        }
        
        return CIImage(cgImage: image)
    }
    
    func faces(in image: Redactable) throws -> [CGRect] {
        var result: Result<VNDetectFaceRectanglesRequest, Error>?
        let request = VNDetectFaceRectanglesRequest { detectResult in
            result = detectResult
        }
        try image.requestHandler.perform([request])
        let observations = try result!.get().results as! [VNFaceObservation]
        
        return observations.map { observation in
            let boundingBox = observation.boundingBox
            let width = CGFloat(image.integralSize.width)
            let height = CGFloat(image.integralSize.height)
            let frame = CGRect(x: boundingBox.minX * width, y: boundingBox.minY * height, width: width * boundingBox.width, height: height * boundingBox.height)
            return frame
        }
    }

    class func normalize(faceRect: CGRect, in size: CGSize) -> CGRect {
        let (width, height) = (Int(size.width), Int(size.height))
        return VNNormalizedRectForImageRect(faceRect, width, height)
    }
    
    func blur(regions: [CGRect], in image: Redactable) -> CIImage {
        let inputImage = image.ciImage

        let pixellate = CIFilter.pixellate()
        pixellate.inputImage = inputImage
        pixellate.scale = 50

        let blendWithMask = CIFilter.blendWithMask()
        blendWithMask.backgroundImage = inputImage
        blendWithMask.inputImage = pixellate.outputImage
        blendWithMask.maskImage = Self.mask(size: image.integralSize, regions: regions)
        
        return blendWithMask.outputImage!
    }
    
    func blurFaces(in image: Redactable) throws -> CIImage {
        try blur(regions: faces(in: image), in: image)
    }
}
