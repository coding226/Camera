//
//  ReminderIndicatorView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/12/20.
//

import UIKit

class ReminderIndicatorView: UIView {
    // MARK: - Attributes
    private let placeholderShapeLayer = CAShapeLayer()
    private let progressShapeLayer = CAShapeLayer()
    
    private let progressNormalColor: UIColor
    private let progressWarningColor: UIColor
    private  let progressErrorColor: UIColor
    
    private  let placeholderColor: UIColor
    
    private let remainingTextWarning: UIColor
    private let remainingTextErrorColor: UIColor
    
    private let lineWidth: CGFloat
    let upperBound: CGFloat

    private lazy var counterLabel: UILabel = .build {
        $0.textColor = placeholderColor
        $0.font = UIFont.init(font: .avenirNextCyrBold, size: 10.adaptive)
        $0.textAlignment = .center
    }
    
    // MARK: - Initializers
    public init(progressNormalColor: UIColor = .init(hexString: "36D49E"),
                progressWarningColor: UIColor = .init(hexString: "FDAC36"),
                progressErrorColor: UIColor = .init(hexString: "FF3A72"),
                placeholderColor: UIColor = .init(hexString: "93A7B9"),
                remainingTextWarning: UIColor = .init(hexString: "93A7B9"),
                remainingTextErrorColor: UIColor = .init(hexString: "FF3A72"),
                lineWidth: CGFloat, upperBound: CGFloat ) {
        self.progressNormalColor = progressNormalColor
        self.progressWarningColor = progressWarningColor
        self.progressErrorColor = progressErrorColor
        self.placeholderColor = placeholderColor
        self.remainingTextWarning = remainingTextWarning
        self.remainingTextErrorColor = remainingTextErrorColor
        self.lineWidth = lineWidth
        self.upperBound = upperBound
        super.init(frame: .zero)
        configuration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configuration() {
        addSubview(counterLabel)
        layer.addSublayer(placeholderShapeLayer)
        layer.addSublayer(progressShapeLayer)
        
        placeholderShapeLayer.fillColor = UIColor.clear.cgColor
        placeholderShapeLayer.strokeColor = placeholderColor.cgColor
        placeholderShapeLayer.lineWidth = lineWidth
        
        progressShapeLayer.fillColor = UIColor.clear.cgColor
        progressShapeLayer.strokeStart = 0
        progressShapeLayer.strokeEnd = 0
        progressShapeLayer.lineCap = .round
        progressShapeLayer.lineWidth = lineWidth
    }
    
    // MARK: - Layouting
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        counterLabel.pin.all()
        placeholderShapeLayer.frame = layer.bounds
        progressShapeLayer.frame = layer.bounds
        
        let path = UIBezierPath(roundedRect: layer.bounds, cornerRadius: .infinity)
        placeholderShapeLayer.path = path.cgPath
        progressShapeLayer.path = path.cgPath
    }
    // MARK: - Apply data
    func updateValue(value: Int) {
        let v = CGFloat(value) / upperBound
        progressShapeLayer.strokeEnd = min(v, 1)
        
        switch value {
        case ..<100:
            progressShapeLayer.strokeColor = progressNormalColor.cgColor
            counterLabel.alpha = 0
        case 100...119:
            counterLabel.textColor = progressWarningColor
            progressShapeLayer.strokeColor = progressWarningColor.cgColor
            counterLabel.alpha = 1
            counterLabel.font = UIFont.init(font: .avenirNextCyrBold, size: 10.adaptive)
        case 120:
            [progressShapeLayer, placeholderShapeLayer].forEach { $0.lineWidth = lineWidth }
            progressShapeLayer.strokeColor = progressErrorColor.cgColor
            counterLabel.textColor = progressErrorColor
            counterLabel.font = UIFont.init(font: .avenirNextCyrBold, size: 10.adaptive)
        default:
            [progressShapeLayer, placeholderShapeLayer].forEach { $0.lineWidth = 0 }
            progressShapeLayer.strokeColor = progressErrorColor.cgColor
            counterLabel.font = UIFont.init(font: .avenirNextCyrBold, size: 16)
        }
        counterLabel.text = String(Int(upperBound) - value)
    }
}
