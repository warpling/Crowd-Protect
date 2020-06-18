//
//  MarkupView.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/15/20.
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

class MarkupView: UIView, MarkupVisual {
    let id: UUID
    let normalizedFrame: CGRect

    enum VisualHintingStyle {
        case glimmer, outline
    }

    var visualHintingStyle: VisualHintingStyle {
        didSet {
            updateHintingEffect()
        }
    }

    let hintingView = UIView()
    var hintingMaskPath: CGPath {
        didSet {
            let maskLayer = CAShapeLayer()
            maskLayer.path = hintingMaskPath
            hintingView.layer.mask = maskLayer
            updateHintingEffect()
        }
    }

    let specularView = UIImageView(image: UIImage(named: "Specular"))

    func tapped() {
        fatalError("Subclasses must implement this function")
    }

    init(id: UUID, normalizedFrame: CGRect) {
        self.id = id
        self.normalizedFrame = normalizedFrame
        visualHintingStyle = UIAccessibility.isReduceMotionEnabled ? .outline : .glimmer
        hintingMaskPath = UIBezierPath().cgPath

        super.init(frame: .zero)

        addSubview(hintingView)
        specularView.contentMode = .scaleToFill

        hintingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(reducedMotionStatusDidChange), name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        specularView.frame = CGRect(origin: .zero, size: CGSize(width: 2*hintingView.bounds.width, height: 2*hintingView.bounds.height))
        specularView.center = CGPoint(x: hintingView.bounds.midX, y: hintingView.bounds.midY)
        updateHintingEffect()
    }

    @objc func reducedMotionStatusDidChange() {
        visualHintingStyle = UIAccessibility.isReduceMotionEnabled ? .outline : .glimmer
    }

    @objc func updateHintingEffect() {

        switch visualHintingStyle {
        case .outline:

            specularView.motionEffects.forEach { motionEffect in
                specularView.removeMotionEffect(motionEffect)
            }
            specularView.removeFromSuperview()

            let dashLength: Double = 0.1 * Double(layer.bounds.width)
            let dashWidth: CGFloat = CGFloat(dashLength) / 2.0

            let lightDashedLayer = CAShapeLayer()
            lightDashedLayer.frame = hintingView.bounds
            lightDashedLayer.path = hintingMaskPath
            lightDashedLayer.strokeColor = UIColor.white.cgColor
            lightDashedLayer.fillColor = nil
            lightDashedLayer.lineDashPattern = [NSNumber(floatLiteral: dashLength), NSNumber(floatLiteral: dashLength)]
            lightDashedLayer.lineWidth = dashWidth

            let darkDashedLayer = CAShapeLayer()
            darkDashedLayer.frame = hintingView.bounds
            darkDashedLayer.path = hintingMaskPath
            darkDashedLayer.strokeColor = UIColor.black.cgColor
            darkDashedLayer.fillColor = nil
            darkDashedLayer.lineDashPattern = lightDashedLayer.lineDashPattern
            darkDashedLayer.lineWidth = lightDashedLayer.lineWidth
            darkDashedLayer.lineDashPhase = CGFloat(dashLength)

            hintingView.layer.addSublayer(darkDashedLayer)
            hintingView.layer.addSublayer(lightDashedLayer)
            hintingView.layer.masksToBounds = false

            [lightDashedLayer, darkDashedLayer].forEach { (layer) in

                let rotationAngle = (CGFloat(dashLength) / (layer.bounds.width * CGFloat.pi)) * CGFloat.pi

                let spinAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                spinAnimation.toValue = 4 * rotationAngle * (layer == lightDashedLayer ? 1 : -1)
                spinAnimation.duration = 2
                spinAnimation.repeatCount = Float.greatestFiniteMagnitude
                spinAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
                layer.add(spinAnimation, forKey: "spin")
                layer.makeAnimationsPersistent()
            }

        case .glimmer:

            hintingView.layer.sublayers?.forEach { sublayer in
                guard sublayer is CAShapeLayer else { return } // We can crash if we remove layers other than our own somehow?
                sublayer.removeFromSuperlayer()
            }

            let motionMultiplier: CGFloat = 1.8
            let (min, max) = (CGFloat(-motionMultiplier * bounds.width), CGFloat(motionMultiplier * bounds.height))

            let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
            xMotion.minimumRelativeValue = min
            xMotion.maximumRelativeValue = max

            let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
            yMotion.minimumRelativeValue = min
            yMotion.maximumRelativeValue = max

            let motionEffectGroup = UIMotionEffectGroup()
            motionEffectGroup.motionEffects = [xMotion,yMotion]

            hintingView.addSubview(specularView)
            specularView.addMotionEffect(motionEffectGroup)
            hintingView.layer.masksToBounds = true
        }
    }
}

class FaceMarkupView: MarkupView {

    let faceShape = CAShapeLayer()

    override init(id: UUID, normalizedFrame: CGRect) {
        super.init(id: id, normalizedFrame: normalizedFrame)
        layer.addSublayer(faceShape)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        faceShape.frame = bounds
        faceShape.path = UIBezierPath(ovalIn: bounds).cgPath
//        faceShape.strokeColor = UIColor.systemPink.cgColor
        faceShape.fillColor = nil
//        faceShape.lineWidth = 14
//        faceShape.lineDashPattern = [32, 32]

        hintingMaskPath = UIBezierPath(cgPath: faceShape.path!).cgPath
    }

    var isFilled = false {
        didSet {
//            faceShape.strokeColor = isFilled ? UIColor.systemGreen.cgColor : UIColor.systemPink.cgColor
        }
    }

    override func tapped() {
        isFilled.toggle()
    }
}

class ScribbleMarkupView: MarkupView {

    let normalizedPath: CGPath
    let scribbleLayer = CAShapeLayer()

    init(id: UUID, normalizedFrame: CGRect, normalizedPath: CGPath) {
        self.normalizedPath = normalizedPath
        super.init(id: id, normalizedFrame: normalizedFrame)
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
//        scribbleLayer.strokeColor = UIColor.magenta.cgColor
        scribbleLayer.lineWidth = 4

        hintingMaskPath = UIBezierPath(cgPath: scribbleLayer.path!).cgPath
    }

    override func tapped() {
        //
    }
}
