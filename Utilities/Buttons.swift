//
//  Buttons.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class Button: UIButton {

    let backgroundView = UIView()

    var backgroundColors = [UIControl.State : UIColor]()

    init() {
        super.init(frame: .zero)
        backgroundView.roundCorners(by: 12)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.removeFromSuperview()
        backgroundView.frame = bounds
        insertSubview(backgroundView, at: 0)
    }

    // MARK: - Background Colors
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        backgroundColors[state] = color
        updateAppearance()
    }

    // MARK: - State Management

    override var isHighlighted: Bool { didSet {
        updateAppearance()
    }}

    override var isEnabled: Bool { didSet {
        updateAppearance()
    }}

    override var isSelected: Bool { didSet {
        updateAppearance()
    }}

    func updateAppearance() {
        updateBackgroundColor()
//        updateImageColor()
//        updateTitleFont()
//        stateChanged?(self, state)
    }

    // MARK: -

    func updateBackgroundColor() {
        backgroundView.backgroundColor = backgroundColors[state] ?? backgroundColors[.normal]
    }
}

// MARK: - Inset Adjustment Extension

// Source: https://noahgilmore.com/blog/uibutton-padding/
extension UIButton {
    func setInsets(
        forContentPadding contentPadding: UIEdgeInsets,
        imageTitlePadding: CGFloat
    ) {
        self.contentEdgeInsets = UIEdgeInsets(
            top: contentPadding.top,
            left: contentPadding.left,
            bottom: contentPadding.bottom,
            right: contentPadding.right + imageTitlePadding
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: imageTitlePadding,
            bottom: 0,
            right: -imageTitlePadding
        )
    }
}

// MARK: - UIControl.State Hashable

extension UIControl.State : Hashable {}
