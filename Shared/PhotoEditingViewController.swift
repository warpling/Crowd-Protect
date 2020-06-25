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

    var compositeView: ImageMarkupCompositeView?
    var imageScrollView: UIImageScrollView? {
        didSet {
            imageScrollView?.didZoom = { [weak self] scrollView in
                self?.compositeView?.markupsView.setContentScale(scrollView.zoomScale, minScale: scrollView.minimumZoomScale)
            }
        }
    }

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // TODO: Try to ensure the bottom of the photo can be edited and doesn't get stuck behind the toolbar
//        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: toolbar.bounds.height, right: 0)
    }


    // MARK: -

    var imageEdits: ImageEdits? {
        didSet {

            imageScrollView?.removeFromSuperview()
            imageScrollView = nil

            guard let imageEdits = imageEdits else { return }

            compositeView = ImageMarkupCompositeView(imageEdits: imageEdits, editMode: toolbar.currentMode)
            compositeView!.markupsView.markupEditsReceiver = self
            imageEdits.editsDelegate = self

            imageScrollView = UIImageScrollView(contentView: compositeView!)
            view.insertSubview(imageScrollView!, belowSubview: toolbar)
            imageScrollView!.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }

            toolbar.isFaceToolEnabled = !imageEdits.faces.isEmpty
            toolbar.isUndoPossible = !imageEdits.edits.isEmpty
            toolbar.drawBlurSelected()
            toolbar.receiver = self
        }
    }

    func startEditing(with image: UIImage) {
        let normalizedImage = image.normalized(orientation: image.imageOrientation)!
        imageEdits = ImageEdits(normalizedImage)
    }
}

// MARK: - EditsDelegate

extension PhotoEditingViewController : EditsDelegate {
    func didRemoveEdit(_ edit: Edit) {
        if let markup: Markup = {
            switch edit {
            case .addScribble(let id, let normalizedFrame, let normalizedPath):
                return .scribble(id: id, normalizedFrame: normalizedFrame, normalizedPath: normalizedPath)
            default:
                return nil
            }
            }() {
            compositeView?.markupsView.removeMarkup(markup)
        }
        editsDidChange()
    }

    func didAddEdit(_ edit: Edit) {
        if let markup: Markup = {
            switch edit {
            case .addScribble(let id, let normalizedFrame, let normalizedPath):
                return .scribble(id: id, normalizedFrame: normalizedFrame, normalizedPath: normalizedPath)
            default:
                return nil
            }
            }() {
            compositeView?.markupsView.addMarkup(markup)
        }
        editsDidChange()
    }

    func editsDidChange() {
        guard let imageEdits = imageEdits else { return }
        toolbar.isUndoPossible = !imageEdits.edits.isEmpty
        compositeView?.refresh()
    }
}

// MARK: - MarkupEditsReceiver

protocol MarkupEditsReceiver {
    func changedRedactedFace(id: UUID, isRedacted: Bool)
    func addedScribble(id: UUID, normalizedFrame: CGRect, normalizedPath: CGPath)
}

extension PhotoEditingViewController : MarkupEditsReceiver {

    func changedRedactedFace(id: UUID, isRedacted: Bool) {
        guard let imageEdits = imageEdits else {
            fatalError("Can't handle edits without an image")
        }

        imageEdits.addEdit(.faceRedactionToggle(id, isEnabled: isRedacted))
    }

    func addedScribble(id: UUID, normalizedFrame: CGRect, normalizedPath: CGPath) {
        guard let imageEdits = imageEdits else {
            fatalError("Can't handle edits without an image")
        }

        imageEdits.addEdit(.addScribble(id, normalizedFrame: normalizedFrame, normalizedPath: normalizedPath))
    }
}

// MARK: - ToolbarReceiver

extension PhotoEditingViewController : ToolbarReceiver {
    func undo() {
        imageEdits?.removeLastEdit()
    }

    func modeDidChange(_ mode: EditMode) {
        imageScrollView?.isScrollEnabled = mode != .drawBlur
        compositeView?.currentEditMode = mode
    }
}
