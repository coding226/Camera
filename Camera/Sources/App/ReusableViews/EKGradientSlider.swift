//
//  EKGradientSlider.swift
//  Camera
//
//  Created by Erik Kamalov on 11/4/20.
//

import UIKit

public extension Range {
    /// Constrain a `Bound` value by `self`.
    /// Equivalent to max(lowerBound, min(upperBound, value)).
    /// - parameter value: The value to be clamped.
    func clamp(_ value: Bound) -> Bound {
        return lowerBound > value ? lowerBound : upperBound < value ? upperBound : value
    }
}

class EKGradientSlider: UIControl {
    open var trackLineHeight: CGFloat = 12 {
        didSet {
            setNeedsLayout()
        }
    }
    open var thumbViewSize: CGFloat = 23 {
        didSet {
            setNeedsLayout()
        }
    }
    
    lazy var trackLayer: CAGradientLayer = .build { track in
        track.startPoint = CGPoint(x: 0.0, y: 0.5)
        track.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
        
    lazy var trackLayerBorder: CALayer = .build {
        $0.borderWidth = 2
        $0.borderColor = UIColor.gray.cgColor
    }
    
    
    private(set) var value: CGFloat = 0
    
    lazy var thumbView: UIView = .build {
        //        $0.layer.shadowColor = UIColor.black.cgColor
        //        $0.layer.shadowRadius = 3
        //        $0.layer.shadowOpacity = 0.2
        //        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.isUserInteractionEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonSetup() {
        self.layer.addSublayer(trackLayer)
        self.layer.addSublayer(trackLayerBorder)
        setTrackColors()
        addSubviews(thumbView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = thumbViewSize.half
     
        trackLayer.frame = .init(x: inset, y: 0, width: bounds.width - thumbViewSize, height: trackLineHeight)
        trackLayer.position.y = self.bounds.midY
        trackLayer.cornerRadius = trackLineHeight.half
        
        thumbView.frame.size = .init(width: thumbViewSize, height: thumbViewSize)
        thumbView.layer.cornerRadius =  thumbViewSize.half
        
        let borderInset: CGFloat = 8
        
        trackLayerBorder.frame = .init(x: inset - borderInset.half, y: 0,
                                       width: trackLayer.frame.width + borderInset, height: trackLineHeight + borderInset)
                
        trackLayerBorder.position.y = self.bounds.height.half
        trackLayerBorder.cornerRadius = trackLayerBorder.frame.height.half
        
        setCenterThumbView(at: .init(x: trackLayer.frame.midX, y: 0))

    }
}

extension EKGradientSlider {
    
    private func setCenterThumbView(at point: CGPoint)  {
        let boundedTouchX = (trackLayer.frame.minX..<trackLayer.frame.maxX).clamp(point.x)
        thumbView.center = CGPoint(x: boundedTouchX, y: bounds.midY)
        updateThumbColor(thumbView.center.x)
    }
    
    private func updateThumbColor(_ xLocation: CGFloat) {
        let progress = (xLocation - trackLayer.frame.minX) / trackLayer.bounds.width
        self.value = progress
        self.thumbView.backgroundColor = UIColor(hue: progress, saturation: 1, brightness: 1, alpha: 1)
    }
    
    private func setTrackColors() {
        let gradient = createGradientColorHue(saturation: 1)
        trackLayer.colors = gradient.colors
        trackLayer.locations = gradient.locations
    }
    
    private func createGradientColorHue(saturation: CGFloat) -> (colors: [CGColor], locations: [NSNumber]) {
        // Values from 0 to 1 at intervals of 0.1
        let values: [CGFloat] = [0.01, 0.2, 0.4, 0.6, 0.8, 0.99]
    
        let nonGrayscaleColors = values.map { hue -> CGColor in
            return UIColor(hue: hue, saturation: saturation, brightness: 1, alpha: 1).cgColor
        }
        
        return (colors: nonGrayscaleColors, locations: values as [NSNumber])
    }
}

// MARK: - UIControlEvents
extension EKGradientSlider {
    /// Begins tracking a touch when the user starts dragging.
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        let touchLocation = touch.location(in: self)
        setCenterThumbView(at: touchLocation)
        sendActions(for: .touchDown)
        sendActions(for: .valueChanged)
        return true
    }
    /// Continues tracking a touch as the user drags.
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        let touchLocation = touch.location(in: self)
        setCenterThumbView(at: touchLocation)
        sendActions(for: .valueChanged)
        return true
    }
}


//
//  ColorSlider.swift
//
//  Created by Sachin Patel on 1/11/15.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-Present Sachin Patel (http://gizmosachin.com/)
