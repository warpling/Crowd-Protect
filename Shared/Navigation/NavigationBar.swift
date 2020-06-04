//
//  NavigationBar.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/4/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit
import SnapKit

class NavigationBar : ButtonBar {

    let buttonContainer = UIView()

    let backButton = UIButton { button in
        button.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        button.set
        button.setTitle("Library", for: .normal)
    }

    let shareButton = UIButton { button in
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.setTitle("Export", for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        vibrancyView.contentView.addSubview(buttonContainer)
        buttonContainer.addSubview(backButton)
        buttonContainer.addSubview(shareButton)

        buttonContainer.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.topMargin)
            make.bottom.equalTo(self.snp.bottomMargin)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }

        backButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }

        shareButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
