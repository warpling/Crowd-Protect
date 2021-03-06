//
//  EditingImageView.swift
//  editor extension
//
//  Created by Ryan McLeod on 6/3/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class ImageMarkupCompositeView: UIView {

    let imageScrollView: UIImageScrollView
    let markupsView: MarkupsView

    init(imageEdits: ImageEdits) {

        let image = imageEdits.media
        imageScrollView = UIImageScrollView(image: image)
        markupsView = MarkupsView(size: image.size, faces: imageEdits.normalizedFaceRects)

        super.init(frame: .zero)

        addSubview(imageScrollView)
        addSubview(markupsView)

        imageScrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        markupsView.isUserInteractionEnabled = false
        markupsView.snp.makeConstraints { (make) in
            make.edges.equalTo(imageScrollView.imageView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
