//
//  PostNavigationBar.swift
//  Camera
//
//  Created by Erik Kamalov on 11/12/20.
//

import UIKit
import Combine

class SendPostButtonView: UIButton {
    // MARK: - Attributes
    private lazy var titleLb: UILabel = .build {
        $0.font = UIFont.init(font: .avenirNextCyrDemi, size: 16.adaptive)
        $0.textColor = .white
    }
    
    private lazy var subTitle: UILabel = .build {
        $0.font = UIFont.init(font: .avenirNextCyrMedium, size: 12.adaptive)
        $0.textColor = .white
    }
    
    private var subTitleText: String? {
        didSet {
            if subTitleText != nil {
                self.subTitle.text = subTitleText
                subTitle.frame.origin.y = bounds.height
                self.addSubview(self.subTitle)
            } else {
                subTitle.removeFromSuperview()
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? UIColor.init(hexString: "FF3A72") : UIColor.init(hexString: "868F98")
        }
    }
    
    // MARK: - Initializers
    public init(titleText: String, subTitleText: String? = nil) {
        
        self.subTitleText = subTitleText
        super.init(frame: .zero)
        isEnabled = true
        
        self.titleLb.text = titleText
        addSubview(titleLb)
        
        if let subTitle = subTitleText {
            self.subTitle.text = subTitle
            addSubview(self.subTitle)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configutation
    func setSubtitle(_ text: String?) {
        subTitleText = text
    }

    // MARK: - Layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        if isEnabled { addInnerShadow() }
        if subTitleText != nil {
            titleLb.pin.hCenter().top(10).sizeToFit()
            subTitle.pin.below(of: titleLb, aligned: .center).marginTop(1).sizeToFit()
        } else {
            let topM = bounds.height > 0 ? (bounds.height - pin.safeArea.bottom).half : 0
            titleLb.pin.top(topM).hCenter().sizeToFit()
        }
    }
}
