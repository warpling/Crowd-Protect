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

    var imageScrollView: UIImageScrollView?

    let toolbar = Toolbar()
    let redactor = Redactor()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(toolbar)

        toolbar.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(100)
        }
    }


    // MARK: -

    var imageEdits: ImageEdits? {
        didSet {

            imageScrollView?.removeFromSuperview()
            imageScrollView = nil

            guard let imageEdits = imageEdits else { return }

//            if let input = imageEdits.displayOutput.cgImage {
//                guard
//                    let image = try? redactor.blurFaces(in: input),
//                    let cgImage = redactor.context.createCGImage(image, from: CGRect(origin: .zero, size: CGSize(width: input.width, height: input.height))) else { return }

                let compositeView = ImageMarkupCompositeView(imageEdits: imageEdits)
                compositeView.markupsView.editsReceiver = self
                imageScrollView = UIImageScrollView(contentView: compositeView)
                view.insertSubview(imageScrollView!, belowSubview: toolbar)
                imageScrollView!.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
//            }

            toolbar.isEnabled = true
            toolbar.isUndoPossible = !imageEdits.edits.isEmpty
        }
    }

    func startEditing(with image: UIImage) {
        let normalizedImage = image.normalized(orientation: image.imageOrientation)!
        imageEdits = ImageEdits(normalizedImage)
    }
}

protocol EditsReceiver {
    func changedRedactedFace(id: UUID, isRedacted: Bool)
}

extension PhotoEditingViewController : EditsReceiver {

    func changedRedactedFace(id: UUID, isRedacted: Bool) {
        guard let imageEdits = imageEdits else {
            fatalError("Can't handle edits without an image")
        }

        imageEdits.edits.append(FaceBlurEdit(id: id, isEnabled: isRedacted))
    }
}
