//
//  MarkupView.swift
//  Crowd Protect
//
//  Created by Ryan McLeod on 6/8/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

enum Markup {
    case faceRedaction(id: UUID, frame: CGRect)//, drawnRedaction
}

protocol MarkupVisual: UIView {
    var id: UUID { get }
    var normalizedFrame: CGRect { get }
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

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        faceShape.frame = bounds
        faceShape.path = UIBezierPath(ovalIn: bounds).cgPath
        faceShape.strokeColor = UIColor.magenta.cgColor
        faceShape.fillColor = nil
        faceShape.lineWidth = 14
        faceShape.lineDashPattern = [32, 32]
    }

    var isFilled = false {
        didSet {
            faceShape.strokeColor = isFilled ? nil : UIColor.magenta.cgColor
            faceShape.fillColor = isFilled ? UIColor.black.cgColor : nil
        }
    }

    @objc func tap(_ sender: UIGestureRecognizer) {
        isFilled.toggle()
    }
}

class MarkupsView: UIView {

    private var markups: [Markup]
    var markupViews = [MarkupVisual]()

    init(size: CGSize, faces: [UUID : CGRect]) {

        markups = faces.map { (id, faceRect) -> Markup in
            let uiFrame = faceRect.applying(CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1))
            return Markup.faceRedaction(id: id, frame: uiFrame)
        }

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

                case .faceRedaction(let id, let frame):
                    return FaceMarkupView(id: id, faceRect: frame)
                }
            }()

            markupViews.append(markupView)
            addSubview(markupView)
            print(markupView.normalizedFrame)
            markupView.snp.makeConstraints { (make) in
                // To use AL to align rects we have to use origins to do math based on centering
                make.centerX.equalToSuperview().multipliedBy(2.0*markupView.normalizedFrame.origin.x + markupView.normalizedFrame.width)
                make.centerY.equalToSuperview().multipliedBy(2.0*markupView.normalizedFrame.origin.y + markupView.normalizedFrame.height)
                make.width.equalToSuperview().multipliedBy(markupView.normalizedFrame.width)
                make.height.equalToSuperview().multipliedBy(markupView.normalizedFrame.height)
            }
        }
    }
}
