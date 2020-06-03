//
//  PhotoEditingViewController.swift
//  editor extension
//
//  Created by Ryan McLeod on 6/2/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import SnapKit

class PhotoEditingViewController: UIViewController, PHContentEditingController {

    let editorVC = EditingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editorVC.willMove(toParent: self)
        view.addSubview(editorVC.view)
        addChild(editorVC)
        editorVC.didMove(toParent: self)

        editorVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        view.backgroundColor = .green
    }

    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        return true//editorVC.canHandle(adjustmentData)
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        editorVC.startContentEditing(with: contentEditingInput, placeholderImage: placeholderImage)
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        return editorVC.finishContentEditing(completionHandler: completionHandler)
    }
    
    var shouldShowCancelConfirmation: Bool {
        return true// editorVC.shouldShowCancelConfirmation
    }
    
    func cancelContentEditing() {
       return editorVC.cancelContentEditing()
    }
}
