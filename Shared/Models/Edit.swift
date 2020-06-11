//
//  Edit.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import CoreGraphics
import Foundation

protocol Edit {
    
}

struct FaceBlurEdit : Edit {
    let id: UUID
    let isEnabled: Bool
}

struct DrawBlurEdit: Edit {
    let path: CGPath
}
