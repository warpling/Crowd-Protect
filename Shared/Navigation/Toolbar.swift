//
//  Toolbar.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class Toolbar: ButtonBar {

    let toolsScrollView = UIScrollView { scrollView in
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }

    let toolsStackView = UIStackView { stackView in
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
    }

    let undoButton = UIButton { button in

        let config = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .bold, scale: .large)
        let undoFilled = UIImage(systemName: "arrow.uturn.left.circle", withConfiguration: config)
        let undoFilledIcon = UIImage(systemName: "arrow.uturn.left.circle.fill", withConfiguration: config)

        button.setImage(undoFilledIcon, for: .normal)
        button.setImage(undoFilled, for: .disabled)
        button.tintColor = UIColor.label
    }

    init() {
        super.init(frame: .zero)

        let faceBlurButton = CustomButton { button in

            let config = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .bold, scale: .large)
            let icon = UIImage(systemName: "person.crop.circle.badge.xmark", withConfiguration: config)
            button.setImage(icon, for: .normal)

            button.setTitle("foo", for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.tintColor = .label
        }

        let drawBlurButton = CustomButton { button in

            let config = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .bold, scale: .large)
            let icon = UIImage(systemName: "scribble", withConfiguration: config)
            button.setImage(icon, for: .normal)

            button.setTitle("bar", for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.tintColor = .label
        }

        toolsStackView.addArrangedSubview(faceBlurButton)
        toolsStackView.addArrangedSubview(drawBlurButton)

        addSubview(toolsScrollView)
        toolsScrollView.addSubview(toolsStackView)
        addSubview(undoButton)

        toolsScrollView.backgroundColor = .magenta
        toolsScrollView.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview().inset(Constants.Metrics.navInset)
        }

        toolsStackView.snp.makeConstraints { (make) in
            make.height.equalTo(self).inset(Constants.Metrics.navInset)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }

        undoButton.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview().inset(Constants.Metrics.navInset)
            make.leading.equalTo(toolsScrollView.snp.trailing).offset(Constants.Metrics.navInset)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
