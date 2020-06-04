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

    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))

    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(blurView)
        blurView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
