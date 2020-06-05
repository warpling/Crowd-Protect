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

        let libraryButton = UIButton { button in
            button.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
            button.setTitle("Library", for: .normal)
        }

        let shareButton = UIButton { button in
            button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
            button.setTitle("Export", for: .normal)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: libraryButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        
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
    
    func presentImagePicker() {
//        let status = PHPhotoLibrary.authorizationStatus()
//        guard status == .authorized else {
//            if status == .notDetermined {
//                PHPhotoLibrary.requestAuthorization { _ in
//                    DispatchQueue.main.async {
//                        self.presentImagePicker()
//                    }
//                }
//            }
//            return
//        }
        
        let imagePickerController = UIImagePickerController { controller in
            controller.sourceType = .photoLibrary
            controller.videoQuality = .typeHigh
            controller.allowsEditing = false
            controller.imageExportPreset = .current
            controller.delegate = self
        }
        
        present(imagePickerController, animated: true)
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

