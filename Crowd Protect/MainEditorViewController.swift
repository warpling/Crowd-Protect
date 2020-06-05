//
//  ViewController.swift
//  crowd protect
//
//  Created by Ryan McLeod on 6/2/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit
import Photos

class MainEditorViewController: UIViewController {

    let editorVC = PhotoEditingViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        editorVC.willMove(toParent: self)
        view.addSubview(editorVC.view)
        addChild(editorVC)
        editorVC.didMove(toParent: self)

        let libraryButton = CustomButton { button in
            let config = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .semibold, scale: .large)
            let image = UIImage(systemName: "photo.on.rectangle", withConfiguration: config)

            button.setImage(image, for: .normal)
            button.setTitle("Library", for: .normal)

            button.setImageColor(.label, for: .normal)
            button.setImageColor(.secondaryLabel, for: .highlighted)

            button.setTitleColor(.label, for: .normal)
            button.setTitleColor(.secondaryLabel, for: .highlighted)

            button.setInsets(forContentPadding: .zero, imageTitlePadding: Constants.Metrics.Buttons.iconTitleSpacing)
        }

        let shareButton = CustomButton { button in
            let config = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: .semibold, scale: .large)
            let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: config)

            button.setImage(image, for: .normal)
            button.setTitle("Export", for: .normal)

            button.setImageColor(.label, for: .normal)
            button.setImageColor(.secondaryLabel, for: .highlighted)

            button.setTitleColor(.label, for: .normal)
            button.setTitleColor(.label, for: .highlighted)

            button.setInsets(forContentPadding: .zero, imageTitlePadding: Constants.Metrics.Buttons.iconTitleSpacing)
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: libraryButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)

        libraryButton.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presentImagePicker()
    }
}

private extension MainEditorViewController {
    
    @objc func presentImagePicker() {

        let imagePickerController = UIImagePickerController { controller in
            controller.sourceType = .photoLibrary
            controller.videoQuality = .typeHigh
            controller.allowsEditing = false
            controller.imageExportPreset = .current
            controller.delegate = self
        }
        
        present(imagePickerController, animated: true)
    }

    @objc func share() {

        guard let image = editorVC.imageEdits?.finalOutput else {
            print("Failed to export image")
            return
        }

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true) {
            //
        }
    }
}

extension MainEditorViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            dismiss(animated: true)
        }
        guard /*let asset = info[.phAsset] as? PHAsset,*/
            let image = info[.originalImage] as? UIImage else {
                print("No image selected")
            return
        }
        self.editorVC.startEditing(with: image)
        
//        let requestOptions = PHContentEditingInputRequestOptions()
//        requestOptions.isNetworkAccessAllowed = true
//        requestOptions.progressHandler = { progress, stop in
//            print("Download progress: \(progress)")
//        }
//
//        asset.requestContentEditingInput(with: requestOptions) { (input, info) in
//            guard let input = input else {
//                print("Content editing input unavailable")
//                return
//            }
//            print("Content editing input retrieved with: \(info)")
//        }
    }
}

