//
//  MarkupView.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/8/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

enum Markup {
    case faceRedaction(id: UUID, normalizedFrame: CGRect),
    scribble(id: UUID, normalizedFrame: CGRect, normalizedPath: CGPath)
}

protocol MarkupVisual: UIView {
    var id: UUID { get }
    var normalizedFrame: CGRect { get }

    func tapped()
}

class FaceMarkupView: UIView, MarkupVisual {

    let id: UUID
    let normalizedFrame: CGRect

    let faceShape = CAShapeLayer()

    init(id: UUID, faceRect: CGRect) {
        self.id = id
        self.normalizedFrame = faceRect
        super.init(frame: .zero)

        layer.addSublayer(faceShape)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        faceShape.frame = bounds
        faceShape.path = UIBezierPath(ovalIn: bounds).cgPath
        faceShape.strokeColor = UIColor.systemPink.cgColor
        faceShape.fillColor = nil
        faceShape.lineWidth = 14
        faceShape.lineDashPattern = [32, 32]
    }

    var isFilled = false {
        didSet {
            faceShape.strokeColor = isFilled ? UIColor.systemGreen.cgColor : UIColor.systemPink.cgColor
        }
    }

    func tapped() {
        isFilled.toggle()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        // TODO: Animation persistence
        let phaseAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        phaseAnimation.fromValue = 0
        phaseAnimation.toValue = 2*32
        phaseAnimation.repeatCount = Float.greatestFiniteMagnitude
        phaseAnimation.duration = 1
        phaseAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        faceShape.add(phaseAnimation, forKey: "phase")
    }
}

class ScribbleMarkupView: UIView, MarkupVisual {
    let id: UUID
    let normalizedFrame: CGRect
    let normalizedPath: CGPath

    let scribbleLayer = CAShapeLayer()

    init(id: UUID, scribbleRect: CGRect, normalizedPath: CGPath) {
        self.id = id
        self.normalizedFrame = scribbleRect
        self.normalizedPath = normalizedPath

        super.init(frame: .zero)

        layer.addSublayer(scribbleLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let superview = superview else { return }
        // Scaling and centering of the view is handled by AutoLayout but we still need to handle subviews
        scribbleLayer.frame = bounds
        let scaledPath = UIBezierPath(cgPath: normalizedPath)
        scaledPath.apply(CGAffineTransform(scaleX: superview.bounds.width, y: superview.bounds.height))
        scribbleLayer.path = scaledPath.cgPath
        scribbleLayer.fillColor = UIColor.clear.cgColor
        scribbleLayer.strokeColor = UIColor.magenta.cgColor
        scribbleLayer.lineWidth = 4
    }

    func tapped() {
        //
    }
}

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

                case .faceRedaction(let id, let frame):
                    let markupView = FaceMarkupView(id: id, faceRect: frame)
                    markupView.alpha = 0.5
                    markupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(markupTapped(_:))))
                    return markupView

                case .scribble(let id, let frame, let normalizedPath):
                    let markupView = ScribbleMarkupView(id: id, scribbleRect: frame, normalizedPath: normalizedPath)
                    markupView.alpha = 0.1
                    markupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(markupTapped(_:))))
                    markupEditsReceiver?.addedScribble(id: id, normalizedFrame: frame, normalizedPath: normalizedPath)
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
            let size: CGFloat = 88
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
