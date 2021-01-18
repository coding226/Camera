//
//  PostCellHeader.swift
//  Camera
//
//  Created by Erik Kamalov on 11/12/20.
//

import UIKit

class PostCellHeader: UICollectionReusableView {
    // MARK: - Attributes
    static let reuseIdentifier = "PostCellHeader"
    
    private lazy var title: UILabel = .build {
        $0.font = UIFont.Post.cellHeader
        $0.textColor = UIColor.Post.cellHeader
    }
    
    // MARK: - Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    // MARK: - Configuration
    open func initialize() {
        addSubview(title)
    }
    
    // MARK: - Layouting
    
    override func layoutSubviews() {
        super.layoutSubviews()
        title.pin.left(20).minWidth(150).bottom().sizeToFit()
    }
    
    // MARK: - Apply data
    func apply(_ data: String) {
        self.title.text = data
    }
}

class PostSearchBarHeader: UICollectionReusableView {
    // MARK: - Attributes
    static let reuseIdentifier = "PostSearchbarHeader"
    
    private lazy var textField: SearchBarTextField = .build {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        $0.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "939597")])
        $0.textColor = .white
        $0.font = UIFont.init(font: .avenirNextCyrRegular, size: 15.adaptive)
        $0.leftImage = UIImage.search
    }
    
    // MARK: - Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    // MARK: - Configuration
    open func initialize() {
        addSubview(textField)
    }
    
    // MARK: - Layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.pin.all(.init(top: 15, left: 20, bottom: 0, right: 20))
        textField.layer.cornerRadius = textField.bounds.height.half
    }
}

fileprivate class SearchBarTextField: UITextField {

    public var leftImage: UIImage? { didSet { update() } }
    
    private var textPaddingFromLeftView: CGFloat = 12
    private var leftViewPadding: CGFloat = 14
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let leftViewFrame = self.leftView?.frame ?? .zero
        let width = bounds.size.width - (leftViewFrame.maxX + textPaddingFromLeftView + leftViewPadding)
        return .init(x: leftViewFrame.maxX + textPaddingFromLeftView, y: 0, width: width, height: bounds.size.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var viewRect = super.leftViewRect(forBounds: bounds)
        viewRect.origin.x += leftViewPadding
        return viewRect
    }

    func update() {
        if let image = leftImage {
            leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
            imageView.image = image
            leftView = imageView
        }
    }
}

