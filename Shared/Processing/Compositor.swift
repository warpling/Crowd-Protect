//
//  Compositor.swift
//  Crowd Protect
//
//  Created by Conrad Kramer on 6/6/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import AVFoundation

final class Compositor: NSObject, AVVideoCompositing {
    
    let redactor = Redactor()
    
    var sourcePixelBufferAttributes: [String : Any]? {
        requiredPixelBufferAttributesForRenderContext
    }
    
    var requiredPixelBufferAttributesForRenderContext: [String : Any] {
        [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
         kCVPixelBufferCGBitmapContextCompatibilityKey as String: true]
    }
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        
    }
    
    func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {
        guard
            let trackID = request.sourceTrackIDs.first.map({ CMPersistentTrackID(truncating: $0) }),
            let frame = request.sourceFrame(byTrackID: trackID) else {
            return request.finishCancelledRequest()
        }
        
        do {
            // TODO: Update to support arbitrary regions
            let regions = try redactor.faces(in: frame).map({ $0.frame })
            let image = redactor.blur(regions: regions, in: frame)
            redactor.context.render(image, to: frame)
        } catch let error {
            request.finish(with: error)
        }
    }
}


//let assetURL = URL(fileURLWithPath: "protest.mp4").resolvingSymlinksInPath()
//let asset = AVURLAsset(url: assetURL)
//
//guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
//    fatalError()
//}
//
//let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
//videoComposition.customVideoCompositorClass = Compositor.self
//
//let outputURL = URL(fileURLWithPath: "protest2.mp4")
//try? FileManager.default.removeItem(at: outputURL)
//
//session.videoComposition = videoComposition
//session.outputURL = outputURL
//session.timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: 1, preferredTimescale: asset.duration.timescale))
//session.exportAsynchronously {
//    print("done! \(session.error)")
//}
//
//RunLoop.main.run()
