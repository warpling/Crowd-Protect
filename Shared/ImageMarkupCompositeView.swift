//
//  EditingImageView.swift
//  editor extension
//
//  Created by Ryan McLeod on 6/3/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class ImageMarkupCompositeView: UIView {

    let imageEdits: ImageEdits
    let imageView = UIImageView()
    let markupsView: MarkupsView

    init(imageEdits: ImageEdits) {

        self.imageEdits = imageEdits
        let image = imageEdits.media

        imageView.image = imageEdits.displayOutput
        markupsView = MarkupsView(size: image.size, faces: imageEdits.faces)

        super.init(frame: .zero)

        addSubview(imageView)
        addSubview(markupsView)

        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        markupsView.snp.makeConstraints { (make) in
            make.edges.equalTo(imageView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refresh() {
        imageView.image = imageEdits.displayOutput
    }

}
