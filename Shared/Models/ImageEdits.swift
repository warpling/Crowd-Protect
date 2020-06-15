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
        for edit in edits {
            switch edit {
            case .faceBlur(let id, let isEnabled):
                blurredFaces[id] = isEnabled

            default:
                fatalError()
            }
        }

        let regionsToBlur = faces.compactMap { (key, faceInfo) -> CGRect? in
            return blurredFaces[key]! ? faceInfo.frame : nil
        }

        let ciImage = redactor.blur(regions: regionsToBlur, in: media)
        let image = UIImage(ciImage: ciImage)
        return image
    }

    override var finalOutput: UIImage {
        return media
    }
}
