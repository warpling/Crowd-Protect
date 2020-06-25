//
//  Constants.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/4/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

struct Constants {
    struct Colors {
        struct Navigation {

        }

        struct Toolbar {
            struct Tool {

                static let activeText = UIColor.white.withAlphaComponent(0.9)
                static let inactiveText = UIColor.label
                static let disabledText = UIColor.label.withAlphaComponent(0.5)

                static let activeBackground = UIColor.systemIndigo
                static let inactiveBackground = UIColor.systemGray4
                static let disabledBackground = UIColor.systemGray4.withAlphaComponent(0.5)
            }
        }
    }

    struct Metrics {
        static let navInset: CGFloat = 24

        struct Buttons {
            static let iconTitleSpacing: CGFloat = 8
        }
    }
}

enum EditMode {
    case faceBlur, drawBlur
}
