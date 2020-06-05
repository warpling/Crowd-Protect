import AVFoundation
import CoreGraphics
import Vision

let assetURL = URL(fileURLWithPath: "protest.mp4")
let asset = AVURLAsset(url: assetURL)

extension CVPixelBuffer {
    func draw(with block: (CGContext) -> Void) {
        let pixelFormat = CVPixelBufferGetPixelFormatType(self)
        guard pixelFormat == kCVPixelFormatType_32ARGB else {
            return
        }
        
        CVPixelBufferLockBaseAddress(self, [])
        defer {
            CVPixelBufferUnlockBaseAddress(self, [])
        }
        
        let baseAddress = CVPixelBufferGetBaseAddress(self)
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let bitsPerComponent = 8
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            fatalError()
        }
        block(context)
    }
}

final class Compositor: NSObject, AVVideoCompositing {
    
    var sourcePixelBufferAttributes: [String : Any]? {
        requiredPixelBufferAttributesForRenderContext
    }
    
    var requiredPixelBufferAttributesForRenderContext: [String : Any] {
        [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
         kCVPixelBufferCGBitmapContextCompatibilityKey as String: true]
    }
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        
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
                
                frame.draw { context in
                    context.setFillColor(CGColor.black)
                    
                    let frames: [CGRect] = results.map { result in
                        let boundingBox = result.boundingBox
                        let width = CGFloat(context.width)
                        let height = CGFloat(context.height)
                        let frame = CGRect(x: boundingBox.minX * width, y: boundingBox.minY * height, width: width * boundingBox.width, height: height * boundingBox.height)
                        return frame
                    }
                    
                    context.fill(frames)
                    
                    print("drawing in \(frames)")
                }
                
                compositionRequest.finish(withComposedVideoFrame: frame)
            }
            detectFacesRequest.revision = VNDetectFaceRectanglesRequestRevision2
            
            try! handler.perform([detectFacesRequest])
        }
    }
}


guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
    fatalError()
}

let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
videoComposition.customVideoCompositorClass = Compositor.self

session.videoComposition = videoComposition
session.outputURL = URL(fileURLWithPath: "protest2.mp4")
session.exportAsynchronously {
    print("done! \(session.error)")
}

RunLoop.main.run()
