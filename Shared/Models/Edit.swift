//
//  Edit.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import CoreGraphics
import Foundation

enum Edit {
    case faceBlur(id: UUID, isEnabled: Bool)
    case path(id: UUID, path: CGPath)
}
