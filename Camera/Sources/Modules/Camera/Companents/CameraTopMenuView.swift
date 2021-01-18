//
//  CameraTopMenuView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/2/20.
//

import UIKit
import Combine

open class CameraTopMenuView: UIView {
    // MARK: - Attributes
    private lazy var switchCamera: UIButton = .build {
        $0.pin.size(35)
        $0.setImage(UIImage.Camera.TopMenu.rotate, for: .normal)
    }
    
    private lazy var cameraTorch: UIButton = .build {
        $0.pin.size(35)
        $0.setImage(UIImage.Camera.TopMenu.cameraTorch, for: .normal)
    }
    
    private lazy var cancelButton: UIButton = .build {
        $0.frame.size = .init(lenght: 35)
        $0.setImage(UIImage.Camera.cancel, for: .normal)
        $0.isHidden = true
    }
    
    private lazy var gallery: UIButton = .build {
        $0.pin.size(35)
        $0.setImage(UIImage.Camera.TopMenu.gallery, for: .normal)
    }
    
    private  lazy var stackView: UIStackView = {
        return UIStackView(arrangedSubviews: [switchCamera, cameraTorch, gallery], axis: .vertical, spacing: 25, alignment: .top, distribution: .fillEqually)
    }()
    
    var captureState: CaptureState {
        didSet {
            switch captureState {
            case .done: self.hideAll()
            case .recording: self.hideGallery()
            default: self.show()
            }
        }
    }
    
    let cameraViewModel: CameraService
    
    // MARK: - Initializers
    init(captureState: CaptureState, cameraViewModel: CameraService) {
        self.captureState = captureState
        self.cameraViewModel = cameraViewModel
        super.init(frame: .zero)
        setup()
        bindViewModel()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func setup() {
        addSubviews(stackView, cancelButton)
    }
    
    // MARK: - Layouting
    open override func layoutSubviews() {
        super.layoutSubviews()
        stackView.pin.all(0)
        cancelButton.pin.top().vCenter().size(35)
    }
    private var cancellables: Set<AnyCancellable> = []
    // MARK: - Binding
    private func bindViewModel() {
        self.switchCamera.publisher(for: .touchUpInside).sink { _ in
            self.cameraViewModel.switchCameraPosition()
        }.store(in: &cancellables)
        
        self.gallery.publisher(for: .touchUpInside).sink { _ in
            print("gallery tap")
        }.store(in: &cancellables)
        
        self.cameraTorch.publisher(for: .touchUpInside).sink { button in
            button.isSelected = !button.isSelected
            self.cameraViewModel.toggleTorch(on: button.isSelected)
        }.store(in: &cancellables)
        
        self.cancelButton.publisher(for: .touchUpInside).sink { _ in
            self.cameraViewModel.clearCaptureView()
        }.store(in: &cancellables)
    }
}

extension CameraTopMenuView {
    private func hideGallery() {
        UIView.animate(withDuration: 0.3) {
            self.gallery.transform = CGAffineTransform(translationX: 0, y: -self.cameraTorch.frame.origin.y)
            self.gallery.alpha = 0
        }
    }
    private func hideAll(){
        stackView.animation(show: false) { _ in
            self.cancelButton.showWithAnimation()
        }
    }
    
    private func show() {
        self.cancelButton.hideWithAnimation()
        stackView.animation(show: true)
    }
}

