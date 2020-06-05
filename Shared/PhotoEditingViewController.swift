//
//  PhotoEditingViewController.swift
//  crowd protect
//
//  Created by Ryan McLeod on 6/2/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class PhotoEditingViewController : UIViewController {

    var imageView: EditingImageView!
    let toolbar = Toolbar()

    init() {
        super.init(nibName: nil, bundle: nil)
        imageView = EditingImageView(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.addSubview(toolbar)

        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        toolbar.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(100)
        }
    }


    // MARK: -

    var imageEdits: ImageEdits? {
        didSet {
            imageView.image = imageEdits?.displayOutput
        }
    }

    var imageEditable: ImageEdits? {
        didSet {
            imageView.image = imageEdits?.displayOutput
         }
    }

    func startEditing(with image: UIImage) {
        imageEdits = ImageEdits(image)
    }
}
