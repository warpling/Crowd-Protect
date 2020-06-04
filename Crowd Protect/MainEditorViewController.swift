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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let input = PHContentEditingInput()
        let image = UIImage(named: "testA")!

        editorVC.startContentEditing(with: input, placeholderImage: image)
    }
}

