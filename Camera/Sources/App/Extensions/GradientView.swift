//
//  GradientView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/2/20.
//

import UIKit

@objc
public enum GradientPoint: Int {
    case left
    case top
    case right
    case bottom
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    var point: CGPoint {
        switch self {
        case .left: return CGPoint(x: 0.0, y: 0.5)
        case .top: return CGPoint(x: 0.5, y: 0.0)
        case .right: return CGPoint(x: 1.0, y: 0.5)
        case .bottom: return CGPoint(x: 0.5, y: 1.0)
        case .topLeft: return CGPoint(x: 0.0, y: 0.0)
        case .topRight: return CGPoint(x: 1.0, y: 0.0)
        case .bottomLeft: return CGPoint(x: 0.0, y: 1.0)
        case .bottomRight: return CGPoint(x: 1.0, y: 1.0)
        }
    }
}

open class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    //MARK: - Custom Direction
    open var startPastelPoint = GradientPoint.top {
        didSet {
            gradientLayer.startPoint = startPastelPoint.point
        }
    }
    
    open var endPastelPoint = GradientPoint.bottom {
        didSet {
            gradientLayer.endPoint = endPastelPoint.point
        }
    }
    
    open private(set) var colors: [UIColor] = [.red, .yellow] {
        didSet {
            gradientLayer.colors = currentGradientSet()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setup() {
        gradientLayer.frame = bounds
        gradientLayer.colors = currentGradientSet()
        gradientLayer.startPoint = startPastelPoint.point
        gradientLayer.endPoint = endPastelPoint.point
        gradientLayer.drawsAsynchronously = true
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func currentGradientSet() -> [CGColor] {
        return colors.map { $0.cgColor }
    }
    
    public func setColors(_ colors: [UIColor]) {
        guard colors.count > 0 else { return }
        self.colors = colors
    }
    
    public func setLocation(_ locations: [NSNumber]) {
        gradientLayer.locations = locations
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        gradientLayer.removeAllAnimations()
        gradientLayer.removeFromSuperlayer()
    }
}
