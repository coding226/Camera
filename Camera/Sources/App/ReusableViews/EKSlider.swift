//
//  EKSlider.swift
//  Camera
//
//  Created by Erik Kamalov on 11/4/20.
//

import UIKit

class EKSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var customBounds = CGRect(x: bounds.minX, y: bounds.minY, width:  bounds.width, height: 10)
        customBounds.origin.y = bounds.midY -  (customBounds.height / 2)
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    private var maximumTrackImage: UIImage! {
        didSet {
            setMaximumTrackImage(maximumTrackImage, for: .normal)
        }
    }
    
    func applyCustomDesign() {
        self.minimumTrackTintColor = .init(hexString: "93A7B9")
        self.maximumTrackImage = createMaximumTrackImage(height: 10)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.frame.width != maximumTrackImage.size.width {
            self.maximumTrackImage = createMaximumTrackImage(height: maximumTrackImage.size.height)
        }
    }
    
    func applyThumbImageWith(size: CGFloat) {
        let thumb = createThumbImage(size: size)
        setThumbImage(thumb, for: .normal)
    }
    
    private func createMaximumTrackImage(height: CGFloat) -> UIImage {
        let thumb = UIView(frame: .init(x: 0, y: 0, width: self.bounds.width, height: height))
        thumb.backgroundColor = .init(hexString: "FFFFFF", transparency: 0.32)
        thumb.layer.borderWidth = 1
        thumb.layer.borderColor = UIColor.init(hexString: "FFFFFF", transparency: 0.42).cgColor
        thumb.layer.cornerRadius = height.half
        return thumb.screenshot
    }
    
    private func createThumbImage(size: CGFloat) -> UIImage {
        let thumb = UIView(frame: .init(x: 0, y: 0, width: size, height: size))
        thumb.backgroundColor = .init(hexString: "93A7B9")
        thumb.layer.borderWidth = 1
        thumb.layer.borderColor = UIColor.white.cgColor
        thumb.layer.cornerRadius = size.half
       return thumb.screenshot
    }
}

