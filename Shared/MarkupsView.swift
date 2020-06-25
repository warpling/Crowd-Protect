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

    var currentEditMode: EditMode {
        didSet {
            for markupView in markupViews {
                switch markupView.markup {
                case .faceRedaction:
                    markupView.isEditing = currentEditMode == .faceBlur
                case .scribble:
                    markupView.isEditing = currentEditMode == .drawBlur
                }
            }

            isDrawingEnabled = currentEditMode == .drawBlur
        }
    }

    init(size: CGSize, faces: [UUID : Redactor.FaceInfo], editMode: EditMode) {

        markups = faces.map { (id, faceInfo) -> Markup in
            // Flip to the UI coordinate system
            let uiFrame = faceInfo.normalizedFrame.flippedY(frameHeight: 1)
            return Markup.faceRedaction(id: id, normalizedFrame: uiFrame)
        }

        self.currentEditMode = editMode
        isDrawingEnabled = editMode == .drawBlur

        super.init(frame: CGRect(origin: .zero, size: size))

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

                case .faceRedaction(_, let normalizedFrame):
                    let markupView = FaceMarkupView(markup: markup, normalizedFrame: normalizedFrame)
                    markupView.alpha = 0.5
                    markupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(markupTapped(_:))))
                    markupView.isEditing = currentEditMode == .faceBlur
                    return markupView

                case .scribble(_, let normalizedFrame, let normalizedPath):
                    let markupView = ScribbleMarkupView(markup: markup, normalizedFrame: normalizedFrame, normalizedPath: normalizedPath)
                    markupView.alpha = 0.5
                    markupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(markupTapped(_:))))
                    markupView.isEditing = currentEditMode == .drawBlur
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
        removeMarkups([markup])
    }

    func removeMarkups(_ markups: [Markup]) {
        self.markups.removeAll(where: { markups.contains($0) })

        let visualsToRemove = markupViews.filter { (visual) -> Bool in
            markups.contains(visual.markup)
        }

        for visual in visualsToRemove {
            visual.removeFromSuperview()
        }
    }

    func setContentScale(_ scale: CGFloat, minScale: CGFloat) {
        for markup in markupViews {
            markup.minScale = minScale
            markup.scale = scale
        }
    }

    // MARK: - Drawing

    var isDrawing = false {
        didSet {
            if isDrawing {
                tempScribbleLayer.frame = bounds
                tempScribbleLayer.masksToBounds = true
                tempScribbleLayer.path = tempScribblePath.cgPath
                tempScribbleLayer.strokeColor = UIColor.systemIndigo.cgColor
                tempScribbleLayer.lineWidth = 44
                tempScribbleLayer.fillColor = UIColor.clear.cgColor

                layer.addSublayer(tempScribbleLayer)
            } else {
                tempScribbleLayer.removeFromSuperlayer()
            }
        }
    }
    var lastPoint: CGPoint?
    var tempScribbleLayer = CAShapeLayer()
    var tempScribblePath = UIBezierPath()

    var isDrawingEnabled = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawingEnabled, let touch = touches.first else { return }
        lastPoint = touch.location(in: self)
        startDrawing(at: lastPoint!)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawingEnabled else { return }

        guard let lastPoint = lastPoint, let touch = touches.first else {
            return
        }

        isDrawing = true
        let currentPoint = touch.location(in: self)
        drawLine(from: lastPoint, to: currentPoint)

        self.lastPoint = currentPoint
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawingEnabled else { return }
        endDrawing(at: lastPoint)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawingEnabled else { return }
        endDrawing(at: lastPoint)
    }

    func startDrawing(at startPoint: CGPoint) {
        tempScribblePath = UIBezierPath()
        tempScribblePath.move(to: startPoint)
        isDrawing = true
    }

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        tempScribblePath.addLine(to: toPoint)
    }

    func endDrawing(at lastPoint: CGPoint?) {
        isDrawing = false
        // draw a single point
        if let finalPoint = lastPoint {
            drawLine(from: finalPoint, to: finalPoint)
        }

        let normalizedFrame = tempScribblePath.bounds.normalize(within: bounds.size)
        let normalizedPath = tempScribblePath.normalize(within: tempScribblePath.bounds).cgPath
        markupEditsReceiver?.addedScribble(id: UUID(), normalizedFrame: normalizedFrame, normalizedPath: normalizedPath)
    }
}

extension MarkupsView {
    @objc func markupTapped(_ sender: UITapGestureRecognizer) {
        switch sender.view {
        case let faceMarkupView as FaceMarkupView:
            faceMarkupView.tapped()
            guard case .faceRedaction(let id, _) = faceMarkupView.markup else { fatalError() }
            markupEditsReceiver?.changedRedactedFace(id: id, isRedacted: faceMarkupView.isFilled)

        default: break
        }
    }
}
