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
    let faceRects: [UUID : CGRect]

    override init(_ media: UIImage) {
        do {
            let redactor = Redactor()
            let allNormalizedFaceRects = try redactor.faces(in: media)
            faceRects = Dictionary(uniqueKeysWithValues: allNormalizedFaceRects.map({ return (UUID(), $0) }))
        } catch let error {
            print(error)
            faceRects = [:]
        }

        super.init(media)
    }

    override var displayOutput: UIImage {
        let ciImage = redactor.blur(regions: [], in: media)
        let image = UIImage(ciImage: ciImage)
        return image
    }

    override var finalOutput: UIImage {
        return media
    }
}
