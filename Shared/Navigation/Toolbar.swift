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
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
    }

    let faceBlurButton: Button = {
        let button = Toolbar.newToolbarButton(iconName: "person.crop.circle.badge.xmark", title: "Face Blur")
        return button
    }()

    let drawBlurButton: Button = {
        let button = Toolbar.newToolbarButton(iconName: "scribble", title: "Draw Blur")
        return button
    }()

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

<<<<<<< HEAD
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
=======
        undoButton.addTarget(self, action: #selector(undo), for: .touchUpInside)
        faceBlurButton.addTarget(self, action: #selector(faceBlur), for: .touchUpInside)
        drawBlurButton.addTarget(self, action: #selector(drawBlur), for: .touchUpInside)
>>>>>>> More toolbar setup

        toolsStackView.addArrangedSubview(faceBlurButton)
        toolsStackView.addArrangedSubview(drawBlurButton)

        addSubview(toolsScrollView)
        toolsScrollView.addSubview(toolsStackView)
        addSubview(undoButton)

        toolsScrollView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().inset(Constants.Metrics.navInset)
            make.bottomMargin.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(Constants.Metrics.navInset).priority(499)
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

        toolsStackView.isUserInteractionEnabled = true
        toolsScrollView.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc func faceBlur() {
        faceBlurButton.isSelected = true
        drawBlurButton.isSelected = false
    }

    @objc func drawBlur() {
        faceBlurButton.isSelected = false
        drawBlurButton.isSelected = true
    }

    @objc func undo() {

    }


    class func newToolbarButton(iconName: String, title: String) -> Button {
        return Button { button in

            let config = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .bold, scale: .large)
            let icon = UIImage(systemName: iconName, withConfiguration: config)

            button.setImage(icon, for: .normal)
            button.setTitle(title, for: .normal)

            button.setBackgroundColor(Constants.Colors.Toolbar.Tool.activeBackground, for: .selected)
            button.setBackgroundColor(Constants.Colors.Toolbar.Tool.inactiveBackground, for: .normal)
            button.setBackgroundColor(.label, for: .highlighted)

            button.setTitleColor(Constants.Colors.Toolbar.Tool.activeText, for: .selected)
            button.setTitleColor(Constants.Colors.Toolbar.Tool.inactiveText, for: .normal)
            button.setTitleColor(Constants.Colors.Toolbar.Tool.activeText, for: .highlighted)

            button.tintColor = .label

            let contentPadding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
            button.setInsets(forContentPadding: contentPadding,
                             imageTitlePadding: 8)
        }
    }
}
