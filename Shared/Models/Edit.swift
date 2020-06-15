//
//  Edit.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import CoreGraphics
import UIKit

enum Edit {
    case faceRedactionToggle(_ id: UUID, isEnabled: Bool)
    case addScribble(_ id: UUID, normalizedFrame: CGRect, normalizedPath: CGPath)
}
