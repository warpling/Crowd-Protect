import AVFoundation
import CoreGraphics
import CoreImage.CIFilterBuiltins
import Vision

extension CGColorSpace {
    static var deviceGray: CGColorSpace {
        CGColorSpaceCreateDeviceGray()
    }
    
    static var deviceRGB: CGColorSpace {
        CGColorSpaceCreateDeviceRGB()
    }
}

extension CGBitmapInfo {
    func with(alphaInfo: CGImageAlphaInfo) -> CGBitmapInfo {
        return CGBitmapInfo(rawValue: rawValue | alphaInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue)
    }
}

extension CVPixelBuffer {
    struct Format {
        var bitsPerComponent: Int
        var bitmapInfo: CGBitmapInfo
        var colorSpace: CGColorSpace
        
        init(bitsPerComponent: Int, bitmapInfo: CGBitmapInfo, alphaInfo: CGImageAlphaInfo, colorSpace: CGColorSpace) {
            self.init(bitsPerComponent: bitsPerComponent, bitmapInfo: bitmapInfo.with(alphaInfo: alphaInfo), colorSpace: colorSpace)
        }
        
        init(bitsPerComponent: Int, bitmapInfo: CGBitmapInfo, colorSpace: CGColorSpace) {
            self.bitsPerComponent = bitsPerComponent
            self.bitmapInfo = bitmapInfo
            self.colorSpace = colorSpace
        }
        
        static var mask: Format {
            Format(bitsPerComponent: 8, bitmapInfo: CGBitmapInfo(rawValue: 0), colorSpace: .deviceGray)
        }
    }
    
    var baseAddress: UnsafeMutableRawPointer? {
        CVPixelBufferGetBaseAddress(self)
    }
    
    var width: Int {
        CVPixelBufferGetWidth(self)
    }
    
    var height: Int {
        CVPixelBufferGetHeight(self)
    }
    
    var bytesPerRow: Int {
        CVPixelBufferGetBytesPerRow(self)
    }
    
    var format: Format? {
        switch CVPixelBufferGetPixelFormatType(self) {
        case kCVPixelFormatType_32ARGB:
            return Format(bitsPerComponent: 8, bitmapInfo: .byteOrder32Little, alphaInfo: .premultipliedFirst, colorSpace: .deviceRGB)
        default:
            return nil
        }
    }
}

extension CGContext {
    static func context(buffer: CVPixelBuffer) -> CGContext? {
        guard let format = buffer.format else { return nil }
        return self.context(data: buffer.baseAddress, width: buffer.width, height: buffer.height, bytesPerRow: buffer.bytesPerRow, format: format)
    }
    
    static func context(data: UnsafeMutableRawPointer?, width: Int, height: Int, bytesPerRow: Int, format: CVPixelBuffer.Format) -> CGContext? {
        Self(data: data, width: width, height: height, bitsPerComponent: format.bitsPerComponent, bytesPerRow: bytesPerRow, space: format.colorSpace, bitmapInfo: format.bitmapInfo.rawValue)
    }
}

extension CVPixelBuffer {
    enum ConversionError: Error {
        case incompatibleWithContext
    }
    
    func draw(with block: (CGContext) throws -> Void) throws {
        CVPixelBufferLockBaseAddress(self, [])
        defer {
            CVPixelBufferUnlockBaseAddress(self, [])
        }
        
        guard let context = CGContext.context(buffer: self) else {
            throw ConversionError.incompatibleWithContext
        }
        
        try block(context)
    }
}

final class Compositor: NSObject, AVVideoCompositing {
    
    let context = CIContext()
    
    var sourcePixelBufferAttributes: [String : Any]? {
        requiredPixelBufferAttributesForRenderContext
    }
    
    var requiredPixelBufferAttributesForRenderContext: [String : Any] {
        [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
         kCVPixelBufferCGBitmapContextCompatibilityKey as String: true]
    }
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        
    }
    
    func mask(width: Int, height: Int, regions: [CGRect]) -> CIImage? {
        guard let context = CGContext.context(data: nil, width: width, height: height, bytesPerRow: width, format: .mask) else {
            return nil
        }
        
        context.setFillColor(.black)
        context.fill(CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        context.setFillColor(.white)
        context.fill(regions)
        
        guard let image = context.makeImage() else {
            return nil
        }
        
        return CIImage(cgImage: image)
    }
    
    func startRequest(_ compositionRequest: AVAsynchronousVideoCompositionRequest) {
        for trackID in compositionRequest.sourceTrackIDs.map({ CMPersistentTrackID(truncating: $0) }) {
            guard let frame = compositionRequest.sourceFrame(byTrackID: trackID) else {
                continue
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: frame, options: [:])
            
            let detectFacesRequest = VNDetectFaceRectanglesRequest { (detectFacesRequest, error) in
                guard let results = detectFacesRequest.results as? [VNFaceObservation] else {
                    fatalError()
                }
                
                let frames: [CGRect] = results.map { result in
                    let boundingBox = result.boundingBox
                    let width = CGFloat(frame.width)
                    let height = CGFloat(frame.height)
                    let frame = CGRect(x: boundingBox.minX * width, y: boundingBox.minY * height, width: width * boundingBox.width, height: height * boundingBox.height)
                    return frame
                }
                
                let inputImage = CIImage(cvPixelBuffer: frame)
                
                let pixellate = CIFilter.pixellate()
                pixellate.inputImage = inputImage
                pixellate.scale = 50
                
                let blendWithMask = CIFilter.blendWithMask()
                blendWithMask.backgroundImage = inputImage
                blendWithMask.inputImage = pixellate.outputImage
                blendWithMask.maskImage = self.mask(width: frame.width, height: frame.height, regions: frames)
                
                self.context.render(blendWithMask.outputImage!, to: frame)
//                try! frame.draw { context in
//                    context.setFillColor(CGColor.black)
//                    context.fill(frames)
//                }

                compositionRequest.finish(withComposedVideoFrame: frame)
            }
            detectFacesRequest.revision = VNDetectFaceRectanglesRequestRevision2
            
            try! handler.perform([detectFacesRequest])
        }
    }
}


let assetURL = URL(fileURLWithPath: "protest.mp4").resolvingSymlinksInPath()
let asset = AVURLAsset(url: assetURL)

guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
    fatalError()
}

let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
videoComposition.customVideoCompositorClass = Compositor.self

let outputURL = URL(fileURLWithPath: "protest2.mp4")
try? FileManager.default.removeItem(at: outputURL)

session.videoComposition = videoComposition
session.outputURL = outputURL
session.timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: 1, preferredTimescale: asset.duration.timescale))
session.exportAsynchronously {
    print("done! \(session.error)")
}

RunLoop.main.run()
