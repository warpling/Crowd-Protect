//
//  MediaEditable.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class MediaEditable<MediaType> : Editable {

    let media: MediaType

    public init(_ media: MediaType) {
        self.media = media
    }

    var displayOutput: MediaType {
        get {
            // use CI pipeline to render display image/video
            return media
//            return Compositor().
        }
    }

    var finalOutput: MediaType {
        get {
            // use CI pipeline to render final image/video
            return media
        }
    }

    // MARK: - Edits

    var editsDelegate: EditsDelegate?

    // TODO: Find a way to make this private(set)
    var edits = [Edit]()

    func addEdit(_ edit: Edit) {
        edits.append(edit)
        editsDelegate?.didAddEdit(edit)
    }

    func removeLastEdit() {
        let removedEdit = edits.removeLast()
        editsDelegate?.didRemoveEdit(removedEdit)
    }
}

protocol EditsDelegate {
    func didRemoveEdit(_ edit: Edit)
    func didAddEdit(_ edit: Edit)
}
