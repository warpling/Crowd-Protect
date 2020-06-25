//
//  UIBezierPath+Normalize.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/18/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

extension UIBezierPath {

    func normalize(within boundingFrame: CGRect) -> UIBezierPath {
        let copy = UIBezierPath(cgPath: cgPath)
        copy.apply(CGAffineTransform(translationX: -boundingFrame.origin.x, y: -boundingFrame.origin.y))
        copy.apply(CGAffineTransform(scaleX: (1.0 / boundingFrame.width), y: (1.0 / boundingFrame.height)))
        return copy
    }

    func normalize(within boundingSize: CGSize) -> UIBezierPath {
        let copy = UIBezierPath(cgPath: cgPath)
        copy.apply(CGAffineTransform(scaleX: (1.0 / boundingSize.width), y: (1.0 / boundingSize.height)))
        return copy
    }

    func unnormalize(within boundingSize: CGSize) -> UIBezierPath {
        let copy = UIBezierPath(cgPath: cgPath)
        copy.apply(CGAffineTransform(scaleX: boundingSize.width, y: boundingSize.height))
        return copy
    }
}
