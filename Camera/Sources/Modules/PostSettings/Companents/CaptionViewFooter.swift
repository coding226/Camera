//
//  CaptionViewFooter.swift
//  Camera
//
//  Created by Erik Kamalov on 11/13/20.
//

import UIKit
import PinLayout

final class CaptionViewFooter: UIView {
    // MARK: - Attributes
    private lazy var titleLb: UILabel = .build {
        $0.textColor = UIColor.Post.Settings.caption
        $0.font = UIFont.Post.Setting.caption
        $0.text = "Type a caption..."
        $0.numberOfLines = 0
    }
    
    // MARK: - Life cycle
    init() {
        super.init(frame: .zero)
        addSubview(titleLb)
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Apply data
    public func update(text: String) {
        titleLb.text = text.count > 0 ? text : "Type a caption..."
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLb.pin.left(19).bottom(20).top(18).right(19).sizeToFit(.width)
    }
}
