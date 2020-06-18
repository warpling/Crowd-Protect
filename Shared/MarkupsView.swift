//
//  MarkupView.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/8/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

class MarkupsView: UIView {

    private var markups: [Markup]
    var markupViews = [MarkupVisual]()
    var markupEditsReceiver: MarkupEditsReceiver?

    init(size: CGSize, faces: [UUID : Redactor.FaceInfo]) {

        markups = faces.map { (id, faceInfo) -> Markup in
            // Flip to the UI coordinate system
            let uiFrame = faceInfo.normalizedFrame.flippedY(frameHeight: 1)
            return Markup.faceRedaction(id: id, normalizedFrame: uiFrame)
        }

        super.init(frame: CGRect(origin: .zero, size: size))

        drawingGesture = UITapGestureRecognizer(target: self, action: #selector(drawing))
        addGestureRecognizer(drawingGesture)

        addMarkups(markups)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addMarkup(_ markup: Markup) {
        addMarkups([markup])
    }

    func addMarkups(_ markups: [Markup]) {
        self.markups.append(contentsOf: markups)

        for markup in markups {

            let markupView = { () -> MarkupVisual in
                switch markup {

                case .faceRedaction(let id, let normalizedFrame):
                    let markupView = FaceMarkupView(id: id, normalizedFrame: normalizedFrame)
                    markupView.alpha = 0.5
                    markupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(markupTapped(_:))))
                    return markupView

                case .scribble(let id, let normalizedFrame, let normalizedPath):
                    let markupView = ScribbleMarkupView(id: id, normalizedFrame: normalizedFrame, normalizedPath: normalizedPath)
                    markupView.alpha = 0.5
                    markupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(markupTapped(_:))))
                    markupEditsReceiver?.addedScribble(id: id, normalizedFrame: normalizedFrame, normalizedPath: normalizedPath)
                    return markupView
                }
            }()

            markupViews.append(markupView)
            addSubview(markupView)

            markupView.snp.makeConstraints { (make) in
                // To use AL to align rects we have to use origins to do math based on centering
                make.centerX.equalToSuperview().multipliedBy(2.0*markupView.normalizedFrame.origin.x + markupView.normalizedFrame.width)
                make.centerY.equalToSuperview().multipliedBy(2.0*markupView.normalizedFrame.origin.y + markupView.normalizedFrame.height)
                make.width.equalToSuperview().multipliedBy(markupView.normalizedFrame.width)
                make.height.equalToSuperview().multipliedBy(markupView.normalizedFrame.height)
            }
        }
    }

    func removeMarkup(_ markup: Markup) {
//        removeMarkups([markup])
    }

    func removeMarkups(_ markups: [Markup]) {
//        self.markups.
    }

    // MARK: - Drawing

    var drawingGesture: UITapGestureRecognizer!

    var isDrawingEnabled = false {
        didSet {

        }
    }

    @objc func drawing(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .ended:
            let location = gesture.location(in: self)
            let size: CGFloat = 132
            let frame = CGRect(x: location.x - size/2, y: location.y - size/2, width: size, height: size)
            let normalizedFrame = Redactor.normalize(frame, in: bounds.size)
            let normalizedPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: normalizedFrame.size)).cgPath
            addMarkup(.scribble(id: UUID(), normalizedFrame: normalizedFrame, normalizedPath: normalizedPath))

        default:
            break
        }
    }
}

extension MarkupsView {
    @objc func markupTapped(_ sender: UITapGestureRecognizer) {
        switch sender.view {
        case let faceMarkupView as FaceMarkupView:
            faceMarkupView.tapped()
            markupEditsReceiver?.changedRedactedFace(id: faceMarkupView.id, isRedacted: faceMarkupView.isFilled)

        default: break
        }
    }
}
