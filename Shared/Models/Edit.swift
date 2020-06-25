//
//  Edit.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import CoreGraphics
import UIKit

enum Edit : Hashable {
    case faceRedactionToggle(_ id: UUID, isEnabled: Bool)
    case addScribble(_ id: UUID, normalizedFrame: CGRect, normalizedPath: CGPath)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .faceRedactionToggle(let id, _),
             .addScribble(let id, _, _):
            hasher.combine(id)
        }
    }
}
