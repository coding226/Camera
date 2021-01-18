//
//  PostSettingCell.swift
//  Camera
//
//  Created by Erik Kamalov on 11/13/20.
//

import UIKit
import PinLayout

class PostSettingCell: BaseCVCell {
    // MARK: - Attributes
    private lazy var title: UILabel = .build {
        $0.font = UIFont.Post.cellTitle
        $0.textColor = UIColor.Post.primary
    }
    private lazy var subTitle: UILabel = .build {
        $0.font = UIFont.Post.cellSubtitle
        $0.textColor = UIColor.Post.cellSubtitle
        $0.numberOfLines = 0
    }
    
    private lazy var selectMark: UIImageView = .build {
        $0.image = UIImage.Post.selectMark
        $0.tintColor = UIColor.Post.cellUnselected
    }    
    // MARK: - Configuration
    override func initialize() {
        contentView.addSubviews(title, subTitle, selectMark)
    }
    
    // MARK: - Layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        title.pin.left(20).top().sizeToFit()
        subTitle.pin.below(of: title, aligned: .left).marginTop(6).width(64%).sizeToFit(.width)
        selectMark.pin.right(20).vCenter().size(22.adaptive)
    }
    
    // MARK: - Apply data
    func apply(_ item: PostSettingItem) {
        self.title.text = item.title
        self.subTitle.text = item.subTitle
        self.selectMark.tintColor = item.isSelected ? UIColor.Post.cellSelectedTint : UIColor.Post.cellUnselected
        
        if item.title == DefaultPostSettingsService.itemsEnum.activeTime.model.title {
            self.subTitle.textColor = UIColor.Post.cellSelectedTint
        }
    }
    
    override func reset() {
        self.subTitle.textColor = UIColor.Post.cellSubtitle
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layout()
        return .init(width: size.width, height: subTitle.frame.maxY)
    }
}
