//
//  MenuCollectionViewCell.swift
//  Camera
//
//  Created by Erik Kamalov on 11/2/20.
//

import UIKit

class MenuCollectionViewCell: BaseCVCell {
    // MARK: - Attributes
    lazy var title: UILabel = .build {
        $0.font = UIFont.Camera.BottomMenu.cellTitle
        $0.textColor = UIColor.Camera.BottomMenu.primary
    }
    
    lazy var icon: UIImageView = .build {
        $0.tintColor = UIColor.Camera.BottomMenu.primary
    }
    
    override var isSelected: Bool {
        didSet {
            title.textColor = isSelected ? UIColor.Camera.BottomMenu.selected : UIColor.Camera.BottomMenu.primary
            icon.tintColor = isSelected ? UIColor.Camera.BottomMenu.selected : UIColor.Camera.BottomMenu.primary
        }
    }
    
    // MARK: - Configuration
    override func initialize() {
        addSubviews(title, icon)
    }
      
    // MARK: - Layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        title.pin.bottom().hCenter().sizeToFit()
        icon.pin.above(of: title, aligned: .center).marginBottom(6).size(24.adaptive)
    }
    
    // MARK: - Apply data
    func apply(_ data: AbstractFilter) {
        self.title.text = data.type.name
        self.icon.image = data.type.icon
    }
}
