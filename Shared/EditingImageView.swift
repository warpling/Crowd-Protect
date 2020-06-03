//
//  EditingImageView.swift
//  editor extension
//
//  Created by Ryan McLeod on 6/3/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class EditingImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFit
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
