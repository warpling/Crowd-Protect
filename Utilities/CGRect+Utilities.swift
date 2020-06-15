//
//  CGRect+Utilities.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/15/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import CoreGraphics

extension CGRect {

    static let normal = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))

    func flippedY(frameHeight: CGFloat) -> CGRect {
        return self.applying(CGAffineTransform(translationX: 0, y: frameHeight).scaledBy(x: 1, y: -1))
    }
}
