//
//  CaptionView.swift
//  Caption
//
//  Created by Erik Kamalov on 11/11/20.
//

import Combine
import UIKit
import PinLayout

final class CaptionView: UIViewController, ViewInterface {
    
    lazy var bgImageView = UIImageView.build {
        $0.image = temporaryBgImage
    }
    
    // MARK: - Attributes
    var presenter: CaptionPresenterViewInterface!
    
    private lazy var titleText: UILabel = .build {
        $0.text = "Caption"
        $0.textColor = UIColor.Caption.primary
        $0.font = UIFont.Caption.primary
    }
    
    private lazy var closeBt: UIButton = .build {
        $0.setImage(UIImage.cancel, for: .normal)
    }
    
    private lazy var captionTextView: TextViewWithPlaceholder = .build {
        $0.font = UIFont.Caption.textView
        $0.textColor = UIColor.Caption.primary
        $0.backgroundColor = .clear
        $0.placeholderText = "Type a caption..."
        $0.placeholderFont = UIFont.Caption.textView
        $0.tintColor = UIColor.Caption.primary.withAlphaComponent(0.5)
    }
    
    private lazy var indicator: ReminderIndicatorView = .init(lineWidth: 3, upperBound: CGFloat(captionTextLimit))
    
    var captionTextLimit: Int
    
    // MARK: - Initializers
    init(captionTextLimit: Int) {
        self.captionTextLimit = captionTextLimit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        bindTargets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captionTextView.becomeFirstResponder()
    }
    
    // MARK: - Layouting
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgImageView.pin.all()
        
        titleText.pin.left(19).top(self.view.safeAreaInsets.top + 26).sizeToFit()
        closeBt.pin.right(21).vCenter(to: titleText.edge.vCenter).size(17.adaptive)
        captionTextView.pin.below(of: titleText, aligned: .left).marginLeft(-4).marginTop(7).right(21).height(30%)
        indicator.pin.right(20).bottom(keyboardHeight + 19).size(24.adaptive)
    }
    
    // MARK: - Binding
    private var cancellables: Set<AnyCancellable> = []
    
    private var keyboardHeight: CGFloat = 0  {
        didSet {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    func bindTargets(){
        Publishers.Merge(
            NotificationCenter
                .default.publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height },
            NotificationCenter
                .default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in 0 }
        ).assign(to: \.keyboardHeight, on: self)
        .store(in: &cancellables)
        
        closeBt.publisher(for: .touchUpInside).sink { [weak self] _ in
            self?.presenter.saveCaption(text: self?.captionTextView.text ?? "")
            self?.presenter.tappedCloseButton()
        }.store(in: &cancellables)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension CaptionView: CaptionViewPresenterInterface {
    // MARK: - Configuration
    func setupInitial(captionText: String) {
        self.view.addSubviews(bgImageView, titleText, closeBt, captionTextView, indicator)
        self.setupTextView(text: captionText)
    }
}

extension CaptionView: UITextViewDelegate {
    
    private func setupTextView(text: String) {
        self.captionTextView.delegate = self
        captionTextView.text = text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count =  textView.text.count
        indicator.updateValue(value: count)
        closeBt.isEnabled = count > captionTextLimit ? false : true
        if count > captionTextLimit {
            let boundsRange = NSRange(location: captionTextLimit, length: count - captionTextLimit)
            let anotherAttribute = [NSAttributedString.Key.backgroundColor: UIColor.Caption.textViewErrorBg]
            let textWithAttribute =  NSMutableAttributedString(attributedString: textView.attributedText)
            textWithAttribute.addAttributes(anotherAttribute, range: boundsRange)
            textView.attributedText = textWithAttribute
        }
    }
}
