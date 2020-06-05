//
//  UIColor+Extensions.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

extension UIColor {
    public static func color(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { traits in
            return traits.userInterfaceStyle == .dark ? dark : light
        }
    }
}
