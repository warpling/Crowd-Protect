//
//  ImageEdits.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class ImageEdits: MediaEditable<UIImage> {

    let normalizedFaceRects: [UUID : CGRect]

    override init(_ media: UIImage) {
        do {
            let redactor = Redactor()
            let allNormalizedFaceRects = try redactor.normalizedFaces(in: media.cgImage!)
            normalizedFaceRects = Dictionary(uniqueKeysWithValues: allNormalizedFaceRects.map({ return (UUID(), $0) }))
        } catch let error {
            print(error)
            normalizedFaceRects = [:]
        }

        super.init(media)
    }

    override var displayOutput: UIImage {
        return media
    }

    override var finalOutput: UIImage {
        return media
    }

    // MARK: -

    func didEdit() {

    }
}
