//
//  NavigationBar.swift
//  Camera
//
//  Created by Erik Kamalov on 11/13/20.
//

import UIKit
import Combine

struct NavigationItem {
    let icon: UIImage? // uibutton icon
    let complition: () -> Void
}

class NavigationBar: UIView {
    // MARK: - Attributes
    private lazy var titleLb: UILabel = .build {
        $0.textColor = UIColor.NavigationBar.primary
        $0.font = UIFont.NavigationBar.primary
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var backBt: UIButton = .build {
        $0.setImage(UIImage.backButton, for: .normal)
    }
    
    private lazy var settingBt: UIButton = .build {
        $0.setImage(UIImage.settings, for: .normal)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    let title: String
    let leftItem: NavigationItem?
    let rightItem: NavigationItem?
    
    // MARK: - Initializers
    public init(title: String, leftItem: NavigationItem? = nil, rightItem: NavigationItem? = nil) {
        self.title = title
        self.leftItem = leftItem
        self.rightItem = rightItem
        super.init(frame: .zero)
        configuration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configuration() {
        if let lfItem = leftItem {
            backBt.setImage(lfItem.icon, for: .normal)
            addSubview(backBt)
            
            backBt.publisher(for: .touchUpInside).sink { [weak self] _ in
                self?.leftItem?.complition()
            }.store(in: &cancellables)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(closeAction))
            titleLb.addGestureRecognizer(tap)
        }
        if let rhItem = rightItem {
            settingBt.setImage(rhItem.icon, for: .normal)
            addSubview(settingBt)
            
            settingBt.publisher(for: .touchUpInside).sink { [weak self] _ in
                self?.rightItem?.complition()
            }.store(in: &cancellables)
        }
        
        self.addSubview(titleLb)
        self.titleLb.text = title
    }
    
    // MARK: - Layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        if leftItem == nil {
            titleLb.pin.left(20).vCenter(2).sizeToFit()
        } else {
            backBt.pin.left(14).vCenter().size(18.adaptive)
            titleLb.pin.after(of: backBt, aligned: .center).marginTop(1).marginLeft(2).sizeToFit()
        }
        if rightItem != nil {
            settingBt.pin.right(15).size(30).vCenter(to: titleLb.edge.vCenter)
        }
    }
    
    @objc private func closeAction(){
        leftItem?.complition()
    }
    
    deinit {
        cancellables.removeAll()
    }
}
