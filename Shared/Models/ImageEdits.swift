//
//  ImageEdits.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class ImageEdits: MediaEditable<UIImage> {

    let redactor = Redactor()
    let faces: [UUID : Redactor.FaceInfo]

    override init(_ media: UIImage) {
        do {
            let redactor = Redactor()
            let allFaces = try redactor.faces(in: media)
            faces = Dictionary(uniqueKeysWithValues: allFaces.map({ return (UUID(), $0) }))

        } catch let error {
            print(error)
            faces = [:]
        }

        super.init(media)
    }

    override var displayOutput: UIImage {

        var blurredFaces = Dictionary(uniqueKeysWithValues: faces.keys.map({ ($0, false) }))
        var scribbles = [(CGRect, UIBezierPath)]()

        for edit in edits {
            switch edit {
            case .faceRedactionToggle(let id, let isEnabled):
                blurredFaces[id] = isEnabled

            case .addScribble(_, let normalizedFrame, let normalizedPath):
                let frame = Redactor.unnormalize(normalizedFrame, in: media.size).flippedY(frameHeight: media.size.height)
                let scaledPath = UIBezierPath(cgPath: normalizedPath) // Copy
                scaledPath.apply(CGAffineTransform(scaleX: media.size.width, y: media.size.height))
                scribbles.append((frame, scaledPath))
                break
            }
        }

        var regionsToBlur = faces.compactMap { (key, faceInfo) -> CGRect? in
            return blurredFaces[key]! ? faceInfo.frame : nil
        }

        regionsToBlur.append(contentsOf: scribbles.map({ $0.0 }))

        let ciImage = redactor.blur(regions: regionsToBlur, in: media)
        let image = UIImage(ciImage: ciImage)
        return image
    }

    override var finalOutput: UIImage {
        return media
    }
}
