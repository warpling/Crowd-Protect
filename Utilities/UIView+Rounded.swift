import UIKit

extension CACornerMask {
    static let all: CACornerMask = [
        .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner
    ]
}

extension UIView {
    func roundCorners(by radius: CGFloat, corners: CACornerMask = .all) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners

        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }

        layer.masksToBounds = true
    }
}
