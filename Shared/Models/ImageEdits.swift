//
//  ImageEdits.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class ImageEdits: MediaEditable<UIImage> {

    override var displayOutput: UIImage {
        return media
    }

    override var finalOutput: UIImage {
        return media
    }
}
