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

    var edits = [Edit]()

    public init(_ media: MediaType) {
        self.media = media
    }

    var displayOutput: MediaType {
        get {
            // use CI pipeline to render display image/video
            return media
        }
    }

    var finalOutput: MediaType {
        get {
            // use CI pipeline to render final image/video
            return media
        }
    }


}
