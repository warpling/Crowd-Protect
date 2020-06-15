//
//  UIImageScrollView.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/8/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit
import SnapKit

class UIImageScrollView: UIScrollView, UIScrollViewDelegate {

    let contentView: UIView
    var imageViewConstraintTop:      Constraint?
    var imageViewConstraintBottom:   Constraint?
    var imageViewConstraintLeading:  Constraint?
    var imageViewConstraintTrailing: Constraint?

    init(contentView: UIView) {

        self.contentView = contentView

        super.init(frame: .zero)

        delegate = self

        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            self.imageViewConstraintTop      = make.top.equalToSuperview().constraint
            self.imageViewConstraintBottom   = make.bottom.equalToSuperview().constraint
            self.imageViewConstraintLeading  = make.leading.equalToSuperview().constraint
            self.imageViewConstraintTrailing = make.trailing.equalToSuperview().constraint
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // If AL has finished and we haven't set out min zoom
        guard bounds.size != .zero,
            contentView.bounds.size != .zero,
            minimumZoomScale == 1 else { return }

        updateMinZoomScale()
    }

    func updateMinZoomScale() {

        // Only set this once
        guard minimumZoomScale == 1 else { return }

        let widthScale = bounds.size.width / contentView.bounds.width
        let heightScale = bounds.size.height / contentView.bounds.height
        let minScale = min(widthScale, heightScale)

        minimumZoomScale = minScale
        zoomScale = minScale
    }


    //MARK:- UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(bounds.size)
    }

    func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - contentView.frame.height) / 2)
        imageViewConstraintTop?.update(offset: yOffset)
        imageViewConstraintBottom?.update(offset: yOffset)

        let xOffset = max(0, (size.width - contentView.frame.width) / 2)
        imageViewConstraintLeading?.update(offset: xOffset)
        imageViewConstraintTrailing?.update(offset: xOffset)

        layoutIfNeeded()
    }
}
