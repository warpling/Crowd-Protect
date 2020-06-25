//
//  MarkupView.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/15/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

enum Markup : Equatable {
    case faceRedaction(id: UUID, normalizedFrame: CGRect),
    scribble(id: UUID, normalizedFrame: CGRect, normalizedPath: CGPath)
}

protocol MarkupVisual: UIView {
    var markup: Markup { get }
    var normalizedFrame: CGRect { get }
    var isEditing: Bool { get set }

    var minScale: CGFloat { get set }
    var scale: CGFloat { get set }

    func tapped()
}

class MarkupView: UIControl, MarkupVisual {
    var markup: Markup
    let normalizedFrame: CGRect

    var isEditing: Bool = true {
        didSet {
            hintingView.isHidden = !isEditing
        }
    }

    enum VisualHintingStyle {
        case glimmer, outline
    }

    var visualHintingStyle: VisualHintingStyle {
        didSet {
            updateHintingEffect()
        }
    }

    var minScale: CGFloat = 1
    var scale: CGFloat = 1 {
        didSet {
            updateHintingEffect()
        }
    }

    let hintingView = UIView()
    var hintingMaskPath: CGPath {
        didSet {
            // Only mask the hintingView for glimmer otherwise it will clip the marching ants
            if visualHintingStyle == .glimmer {
                let maskLayer = CAShapeLayer()
                maskLayer.path = hintingMaskPath
                hintingView.layer.mask = maskLayer
            } else {
                hintingView.layer.mask = nil
            }
            updateHintingEffect()
        }
    }

     let specularView = UIImageView(image: UIImage(named: "Specular"))

    func tapped() {
        fatalError("Subclasses must implement this function")
    }

    init(markup: Markup, normalizedFrame: CGRect) {
        self.markup = markup
        self.normalizedFrame = normalizedFrame
        visualHintingStyle = UIAccessibility.isReduceMotionEnabled ? .outline : .glimmer
        hintingMaskPath = UIBezierPath().cgPath

        super.init(frame: .zero)

        hintingView.isUserInteractionEnabled = false
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
        fatalError("updateHintingEffect must be implemented by subclasses")
    }
}

class FaceMarkupView: MarkupView {

    let faceShape = CAShapeLayer()

    override init(markup: Markup, normalizedFrame: CGRect) {
        super.init(markup: markup, normalizedFrame: normalizedFrame)
        layer.addSublayer(faceShape)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        faceShape.frame = bounds
        faceShape.path = UIBezierPath(ovalIn: bounds).cgPath
        faceShape.fillColor = nil

        hintingMaskPath = UIBezierPath(cgPath: faceShape.path!).cgPath
    }

    var isFilled = false {
        didSet {
//            faceShape.strokeColor = isFilled ? UIColor.systemGreen.cgColor : UIColor.systemPink.cgColor
        }
    }

    @objc override func updateHintingEffect() {


        specularView.motionEffects.forEach { motionEffect in
            specularView.removeMotionEffect(motionEffect)
        }
        specularView.removeFromSuperview()

        hintingView.layer.sublayers?.forEach { sublayer in
            guard sublayer is CAShapeLayer else { return } // We can crash if we remove layers other than our own somehow?
            sublayer.removeFromSuperlayer()
        }

        switch visualHintingStyle {
        case .outline:

            let multiplier = scale / minScale

            let dashLength: Double = Double(multiplier * 40.0)
            let dashWidth: CGFloat = CGFloat(dashLength) / 2.0
            print("scale: \(multiplier) - \(dashWidth)")

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


    override func tapped() {
        isFilled.toggle()
    }
}

class ScribbleMarkupView: MarkupView {

    var normalizedPath: CGPath {
        didSet {
            setNeedsLayout()
        }
    }

    let scribbleLayer = CAShapeLayer()

    init(markup: Markup, normalizedFrame: CGRect, normalizedPath: CGPath? = nil) {
        self.normalizedPath = normalizedPath ?? UIBezierPath().cgPath
        super.init(markup: markup, normalizedFrame: normalizedFrame)
        layer.addSublayer(scribbleLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Scaling and centering of the view is handled by AutoLayout but we still need to handle subviews
        let scribblePath = UIBezierPath(cgPath: normalizedPath).unnormalize(within: bounds.size).cgPath
        hintingMaskPath = scribblePath
    }

    @objc override func updateHintingEffect() {

        specularView.motionEffects.forEach { motionEffect in
            specularView.removeMotionEffect(motionEffect)
        }
        specularView.removeFromSuperview()

        hintingView.layer.sublayers?.forEach { sublayer in
            guard sublayer is CAShapeLayer else { return } // We can crash if we remove layers other than our own somehow?
            sublayer.removeFromSuperlayer()
        }

        switch visualHintingStyle {
        case .outline:

            let multiplier = scale / minScale

            let dashLength: Double = Double(multiplier * 40.0)
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

            [lightDashedLayer, darkDashedLayer].enumerated().forEach { (index, layer) in

                let fromValue = index == 0 ? 0 : dashLength
                let toValue = fromValue + (index == 0 ? 1 : -1) * 3 * dashLength
                // TODO: this isn't looping smoothly

                let spinAnimation = CABasicAnimation(keyPath: "lineDashPhase")
                spinAnimation.fromValue = fromValue
                spinAnimation.toValue = toValue
                spinAnimation.duration = 4
                spinAnimation.repeatCount = Float.greatestFiniteMagnitude
                spinAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
                layer.add(spinAnimation, forKey: "spin")
                layer.makeAnimationsPersistent()
            }

        case .glimmer:

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


    override func tapped() {
        //
    }
}
