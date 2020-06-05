//
//  Editable.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/5/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import Foundation

protocol Editable {
    associatedtype MediaType

    var media: MediaType { get }
    var edits: [Edit] { get set }

    var displayOutput: MediaType { get }
    var finalOutput: MediaType { get }
}
