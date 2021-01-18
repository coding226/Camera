//
//  PostCell.swift
//  Camera
//
//  Created by Erik Kamalov on 11/12/20.
//

import UIKit

class PostCell: BaseCVCell {
    // MARK: - Attributes
    private lazy var title: UILabel = .build {
        $0.font = UIFont.Post.cellTitle
        $0.textColor = UIColor.Post.primary
    }
    private lazy var subTitle: UILabel = .build {
        $0.font = UIFont.Post.cellSubtitle
        $0.textColor = UIColor.Post.cellSubtitle
    }
    
    private lazy var icon: UIImageView = .build {
        $0.tintColor = UIColor.Camera.BottomMenu.primary
    }
    
    private lazy var selectMark: UIImageView = .build {
        $0.image = UIImage.Post.selectMark
        $0.tintColor = UIColor.Post.cellUnselected
    }
    
    private lazy var textContainer: UIView = .init()
    
    private var imageHeight: CGFloat = 47
    
    override var isSelected: Bool {
        didSet {
            selectMark.tintColor = isSelected ? UIColor.Post.cellSelectedTint : UIColor.Post.cellUnselected
        }
    }
    
    // MARK: - Configuration
    override func initialize() {
        textContainer.addSubviews(title, subTitle)
        addSubviews(icon, textContainer, selectMark)
    }
    
    // MARK: - Layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        icon.pin.left().vCenter().size(imageHeight)
        title.pin.left().top().sizeToFit()
        subTitle.pin.below(of: title, aligned: .left).sizeToFit()
        textContainer.pin.wrapContent().after(of: icon, aligned: .center).marginLeft(14)
        selectMark.pin.right().vCenter().size(22.adaptive)
    }
    
    // MARK: - Apply data
    func apply(_ data: Item, imageHeight: CGFloat, selectMarkEnable: Bool) {
        self.selectMark.isHidden = selectMarkEnable
        self.imageHeight = imageHeight
        self.title.text = data.title
        self.subTitle.text = data.subtitle
        self.icon.image = UIImage(named: data.imageName)
    }
}
