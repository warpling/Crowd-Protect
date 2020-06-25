//
//  CGRect+Normalize.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/18/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import CoreGraphics

extension CGRect {

    static let normal = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))

    func flippedY(frameHeight: CGFloat) -> CGRect {
        return self.applying(CGAffineTransform(translationX: 0, y: frameHeight).scaledBy(x: 1, y: -1))
    }

    func normalize(within sourceSize: CGSize) -> CGRect {
        return CGRect(x: origin.x / sourceSize.width,
                      y: origin.y / sourceSize.height,
                      width: size.width / sourceSize.width,
                      height: size.height / sourceSize.height)
    }

    func unnormalize(using destinationSize: CGSize) -> CGRect {
        return CGRect(x: origin.x * destinationSize.width,
                      y: origin.y * destinationSize.height,
                      width: size.width * destinationSize.width,
                      height: size.height * destinationSize.height)
    }
}
