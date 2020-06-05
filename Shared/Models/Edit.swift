//
//  Edit.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import CoreGraphics

protocol Edit {
    
}

struct FaceBlurEdit : Edit {
    let frame: CGRect
}

struct DrawBlurEdit: Edit {
    let path: CGPath
}
