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
                let frame = normalizedFrame.unnormalize(using: media.size).flippedY(frameHeight: media.size.height)
                let scaledPath = UIBezierPath(cgPath: normalizedPath).unnormalize(within: frame.size)
                // Flip path because flipped coordinate system
                scaledPath.apply(CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -scaledPath.bounds.height))
                scribbles.append((frame, scaledPath))
                break
            }
        }

        var pathsToBlur = faces.compactMap { (key, faceInfo) -> CGPath? in
            return blurredFaces[key]! ? UIBezierPath(ovalIn: faceInfo.frame).cgPath : nil
        }

        pathsToBlur.append(contentsOf: scribbles.map({
            let path = UIBezierPath(cgPath: $0.1.cgPath)
            // Draw the path absolutely rather than relative to a frame we're not passing along
            path.apply(CGAffineTransform(translationX: $0.0.origin.x, y: $0.0.origin.y))
            return path.cgPath
        }))

        let ciImage = redactor.blur(paths: pathsToBlur, in: media)
        let image = UIImage(ciImage: ciImage)
        return image
    }

    override var finalOutput: UIImage {
        return displayOutput
    }
}
