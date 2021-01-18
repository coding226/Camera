//
//  FilterCollectionViewCell.swift
//  Camera
//
//  Created by Erik Kamalov on 11/5/20.
//

import UIKit
import BBMetalImage

class FilterCollectionViewCell: BaseCVCell {
    // MARK: - Attributes
    private lazy var container: UIView = .build {
        $0.layer.cornerRadius = 10.adaptive
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.pin.size(.init(width: 82.adaptive, height: 102.adaptive))
    }
    
    private lazy var imageView: UIImageView = .build {
        $0.layer.cornerRadius = 10.adaptive
        $0.clipsToBounds = true
        $0.image = UIImage.filterbg
    }
    
    // MARK: - Configuration
    override func initialize() {
        addSubview(container)
        container.addSubview(imageView)
    }
    
    // MARK: - Layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        container.pin.vCenter().hCenter()
        imageView.pin.all()
    }
    
    // MARK: - Apply data
    func apply(_ data: String) {
//        guard let currentImage = self.imageView.image,
//              let url = Bundle.main.url(forResource: data, withExtension: "png"),
//              let data = try? Data(contentsOf: url).bb_metalTexture else { return  }
//        imageView.image = BBMetalLookupFilter(lookupTable: data).filteredImage(with: currentImage)
    }
    
}

extension FilterCollectionViewCell: TransformableView {
    
    func transform(progress: CGFloat) {
        var transform = CGAffineTransform.identity
        
        let minScaleX: CGFloat = 0.803
        
        let absProgress = abs(progress)
        let normalizedProgress = 1 - absProgress
        
        let scaleX = (minScaleX..<1).clamp(1 - absProgress * 0.25)
        let scaleY = (0.745..<1).clamp(1 - absProgress * 0.25)
        
        var xAdjustment = ((1 - scaleX) * container.bounds.width) / 2
        
        if progress > 0 { xAdjustment *= -1 }
        
        let multiplr = absProgress * (progress < 0 ? -1 : 1)
        let lineSpace:CGFloat = 15 / container.bounds.width
        
        let translateX = (container.bounds.width * multiplr * (minScaleX + lineSpace) ) - xAdjustment
        let translateY = (5 * (0..<1).clamp(absProgress))
        
        transform = transform
            .translatedBy(x: translateX, y: translateY)
            .scaledBy(x: scaleX, y: scaleY)
        container.transform = transform
        
        let imageViewScale = calcRangePercent(min: 1, max: 0.91, percentage: normalizedProgress)
        let borderOpacity = calcRangePercent(min: 0, max: 0.42, percentage: normalizedProgress)
        
        imageView.transform = CGAffineTransform(scaleX: imageViewScale, y: imageViewScale)
        container.layer.borderColor = UIColor.white.withAlphaComponent(borderOpacity).cgColor
    }
    
}
