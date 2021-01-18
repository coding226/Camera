//
//  UIView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/1/20.
//

import UIKit

extension UIView {
    func addSubviews(_ views:UIView...) {
        views.forEach { [weak self] eachView in
            self?.addSubview(eachView)
        }
    }
    func removeWithAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
//    /// Remove all subview
//    func removeAllSubviews() {
//        subviews.forEach { $0.removeFromSuperview() }
//    }
//
//    /// Remove all subview with specific type
//    func removeAllSubviews<T: UIView>(type: T.Type) {
//        subviews
//            .filter { $0.isMember(of: type) }
//            .forEach { $0.removeFromSuperview() }
//    }
}

extension UIView {
    func hideWithAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (finished) in
            self.isHidden = true
        }
    }
    func showWithAnimation() {
        self.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        })
    }
    
    public func addInnerShadow(topColor: UIColor = UIColor.black.withAlphaComponent(0.3)) {
        layer.sublayers?.first(where: {$0.name == "shadowLayer" })?.removeFromSuperlayer()
        let shadowLayer = CAGradientLayer()
        shadowLayer.name = "shadowLayer"
        shadowLayer.cornerRadius = layer.cornerRadius
        shadowLayer.frame = bounds
        shadowLayer.frame.size.height = bounds.height * 0.75
        shadowLayer.colors = [topColor.cgColor, UIColor.clear.cgColor]
        layer.insertSublayer(shadowLayer, at: 0)
    }
}

extension UIView {
    var screenshot: UIImage {
        return UIGraphicsImageRenderer(bounds: self.bounds).image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
    }
    
    func screenshotV2() -> UIImage? {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, UIScreen.main.scale)
        drawHierarchy(in: frame, afterScreenUpdates: true)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIView {
    var globalFrame: CGRect? {
        guard let rootView = UIApplication.shared.windows.first?.rootViewController?.view else { return .zero }
        return self.superview?.convert(self.frame, to: rootView)
    }
}
