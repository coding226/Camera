//
//  TextViewWithPlaceholder.swift
//  Camera
//
//  Created by Erik Kamalov on 11/12/20.
//

import UIKit

class TextViewWithPlaceholder: UITextView {
    // MARK: - Attributes
    var placeholderText: String = "" {
        didSet {
            updatePlaceholderLabel()
        }
    }
    
    var placeholderFont: UIFont? = .systemFont(ofSize: 10) {
        didSet {
            updatePlaceholderLabel()
        }
    }
    
    var placeholderColor: UIColor? = .gray {
        didSet {
            updatePlaceholderLabel()
        }
    }
    
    override var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    private lazy var placeholderLabel: UILabel = .init()
    
    private let notificationName = UITextView.textDidChangeNotification
    
    // MARK: - Initializers
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    // MARK: - Configuration
    private func commonInit() {
        addSubview(placeholderLabel)
        updatePlaceholderLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: notificationName, object: nil)
 
    }
    
    private func updatePlaceholderLabel(){
        placeholderLabel.font = placeholderFont
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.text = placeholderText
    }
    
    // MARK: - Layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.pin.left(5).top(8).sizeToFit()
    }
    @objc func textDidChange(){
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
    
}

