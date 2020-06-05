//
//  ToolBar.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class ToolBar: ButtonBar {

    let toolsScrollView = UIScrollView { scrollView in

    }

    let toolsStackView = UIStackView { stackView in
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
    }

    let undoButton = UIButton { button in

        let config = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .bold, scale: .medium)

        let undoFilled = UIImage(systemName: "arrow.uturn.left.circle", withConfiguration: config)
        let undoFilledIcon = UIImage(systemName: "arrow.uturn.left.circle.fill", withConfiguration: config)

        button.setImage(undoFilledIcon, for: .normal)
        button.setImage(undoFilled, for: .disabled)
    }

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
