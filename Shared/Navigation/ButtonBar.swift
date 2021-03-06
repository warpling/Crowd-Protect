//
//  ButtonBar.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/4/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit
import SnapKit

class ButtonBar: UIView {

    let blurView: UIVisualEffectView
    let vibrancyView: UIVisualEffectView

    override init(frame: CGRect) {

        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        blurView = UIVisualEffectView(effect: blurEffect)
        vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))

        super.init(frame: .zero)
        addSubview(blurView)
        blurView.contentView.addSubview(vibrancyView)

        blurView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        vibrancyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
