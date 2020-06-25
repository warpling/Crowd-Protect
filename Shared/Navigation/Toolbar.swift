//
//  Toolbar.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class Toolbar: ButtonBar {

    var currentMode: EditMode = .drawBlur {
        didSet {
            switch currentMode {
            case .faceBlur:
                faceBlurButton.isSelected = true
                drawBlurButton.isSelected = false
            case .drawBlur:
                faceBlurButton.isSelected = false
                drawBlurButton.isSelected = true
            }

            receiver?.modeDidChange(currentMode)
        }
    }

    var receiver: ToolbarReceiver?

    init() {
        super.init(frame: .zero)

        undoButton.addTarget(self, action: #selector(undo), for: .touchUpInside)
        faceBlurButton.addTarget(self, action: #selector(faceBlurSelected), for: .touchUpInside)
        drawBlurButton.addTarget(self, action: #selector(drawBlurSelected), for: .touchUpInside)

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
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }

        undoButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(Constants.Metrics.navInset)
            make.centerY.equalTo(toolsScrollView)
            make.leading.equalTo(toolsScrollView.snp.trailing).offset(Constants.Metrics.navInset)
        }

        faceBlurButton.isEnabled = false
        drawBlurButton.isEnabled = true
        undoButton.isEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    var isFaceToolEnabled = false {
        didSet {
            faceBlurButton.isEnabled = isFaceToolEnabled
        }
    }

    var isUndoPossible = false {
        didSet {
            undoButton.isEnabled = isUndoPossible
        }
    }

    @objc func faceBlurSelected() {
        currentMode = .faceBlur
    }

    @objc func drawBlurSelected() {
        currentMode = .drawBlur
    }

    @objc func undo() {
        receiver?.undo()
    }

    class func newToolbarButton(iconName: String, title: String) -> CustomButton {
        return CustomButton { button in

            let config = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .semibold, scale: .large)
            let icon = UIImage(systemName: iconName, withConfiguration: config)

            button.cornerRadius = 12

            button.setImage(icon, for: .normal)
            button.setTitle(title, for: .normal)

            button.setBackgroundColor(Constants.Colors.Toolbar.Tool.activeBackground,   for: .selected)
            button.setBackgroundColor(Constants.Colors.Toolbar.Tool.inactiveBackground, for: .normal)
            button.setBackgroundColor(Constants.Colors.Toolbar.Tool.inactiveBackground, for: .highlighted)
            button.setBackgroundColor(Constants.Colors.Toolbar.Tool.disabledBackground, for: .disabled)

            button.setTitleColor(Constants.Colors.Toolbar.Tool.activeText,   for: .selected)
            button.setTitleColor(Constants.Colors.Toolbar.Tool.inactiveText, for: .normal)
            button.setTitleColor(Constants.Colors.Toolbar.Tool.activeText,   for: .highlighted)
            button.setTitleColor(Constants.Colors.Toolbar.Tool.disabledText, for: .disabled)

            button.setImageColor(Constants.Colors.Toolbar.Tool.activeText,   for: .selected)
            button.setImageColor(Constants.Colors.Toolbar.Tool.inactiveText, for: .normal)
            button.setImageColor(Constants.Colors.Toolbar.Tool.activeText,   for: .highlighted)
            button.setImageColor(Constants.Colors.Toolbar.Tool.disabledText, for: .disabled)

            let contentPadding = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 12)
            button.setInsets(forContentPadding: contentPadding,
                             imageTitlePadding: Constants.Metrics.Buttons.iconTitleSpacing)
        }
    }

    // MARK: - Views

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

    let faceBlurButton: CustomButton = {
        let button = Toolbar.newToolbarButton(iconName: "person.crop.circle.badge.xmark", title: "Faces")
        return button
    }()

    let drawBlurButton: CustomButton = {
        let button = Toolbar.newToolbarButton(iconName: "scribble", title: "Draw")
        return button
    }()

    let undoButton = CustomButton { button in

        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let undoIcon = UIImage(systemName: "arrow.uturn.left.circle", withConfiguration: config)
        let undoFilledIcon = UIImage(systemName: "arrow.uturn.left.circle.fill", withConfiguration: config)

        button.setImage(undoFilledIcon, for: .normal)
        button.setImage(undoIcon, for: .disabled)

        button.setImageColor(Constants.Colors.Toolbar.Tool.activeText,   for: .selected)
        button.setImageColor(Constants.Colors.Toolbar.Tool.inactiveText, for: .normal)
        button.setImageColor(Constants.Colors.Toolbar.Tool.activeText,   for: .highlighted)
        button.setImageColor(Constants.Colors.Toolbar.Tool.disabledText, for: .disabled)
    }

}

protocol ToolbarReceiver {
    func modeDidChange(_ mode: EditMode)
    func undo()
}
