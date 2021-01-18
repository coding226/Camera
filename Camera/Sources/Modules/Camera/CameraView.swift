//
//  CameraView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/11/20.
//

import Combine
import UIKit
import AVFoundation
import BBMetalImage
import PinLayout

final class CaptureView: UIView {
    // MARK: - Attributes
    private(set) var metalView: BBMetalView
    private(set) lazy var canvasView: CanvasView = .build {
        $0.isUserInteractionEnabled = false
    }
    
    // MARK: - Life cycle
    init() {
        self.metalView = .init(frame: .zero)
        super.init(frame: .zero)
        addSubviews(metalView, canvasView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Layouting
    public override func layoutSubviews() {
        super.layoutSubviews()
        metalView.frame = bounds
        canvasView.frame = bounds
    }
}

final class CameraView: UIViewController, ViewInterface {
    // MARK: - Attributes
    var presenter: CameraPresenterViewInterface!
    
   private lazy var topGradient: GradientView = .build {
        $0.setColors(UIColor.Gradients.topToBottom)
    }

   private lazy var captureButton: UIButton =  {
        let bt = UIButton()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedCaptureButton))
        bt.isUserInteractionEnabled = true
        bt.addGestureRecognizer(panGesture)
        bt.setImage(CaptureState.ready.icon, for: .normal)
        return bt
    }()
    
   private lazy var captureButtonMock: UIButton = .build {
        $0.setImage(UIImage.Camera.Capture.mock, for: .normal)
        $0.isHidden = true
    }
    
    private lazy var downCountTimer: UILabel = .build {
        $0.textColor = .white
        $0.font = UIFont.Camera.downCount
        $0.textAlignment = .center
        $0.alpha = 0
    }
    
    private lazy var verticalLine: UIView = .build {
        $0.backgroundColor = .white
    }
    
    var captureView: CaptureView = .init()
    
    private var topMenuView: CameraTopMenuView
    private var bottomMenuView: CameraFilterMenuView
    private var filterViewHeight: CGFloat = filterMenuDefaultHeight
    
    // MARK: - Initializers
    public init(topMenuView: CameraTopMenuView, bottomMenuView: CameraFilterMenuView) {
        self.topMenuView = topMenuView
        self.bottomMenuView = bottomMenuView
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }
    
    // MARK: - Layouting
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeArea = self.view.pin.safeArea
        
        topGradient.pin.left().right().top().height(120.adaptive)
        captureView.pin.all()
        
        topMenuView.pin.top(safeArea.top + 15).right(13).width(35.43.adaptive).height(150.adaptive)
        downCountTimer.pin.hCenter().top(safeArea.top + 8).minHeight(22).minWidth(35)
        bottomMenuView.pin.bottom().left().right().height(safeArea.bottom + filterViewHeight)
        
        captureButton.pin.right(9).vCenter().size(72.adaptive)
        captureButtonMock.pin.center(to: captureButton.anchor.center).size(44.adaptive)
        verticalLine.pin.vCenter().hCenter().width(2).height(100%)
    }
    
    // MARK: - Binding
    private var cancellables: Set<AnyCancellable> = []
    
    func bindTargets() {
        captureButtonMock.publisher(for: .touchUpInside).sink { _ in
            UIView.animate(withDuration: 0.3) {
                self.captureButton.center = self.captureButtonMock.center
            } completion: { _ in
                self.captureButtonMock.hideWithAnimation()
            }
        }.store(in: &cancellables)
        
        captureButton.publisher(for: .touchUpInside).sink { bt in
            self.presenter.tapCaptureButton(type: .photo)
        }.store(in: &cancellables)
        
        let doubleTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(long))
        captureButton.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func long(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            presenter.tapCaptureButton(type: .video)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
// MARK: - VIPER
extension CameraView: CameraViewPresenterInterface {
    func showTimerLabel() {
        downCountTimer.showWithAnimation()
    }
    
    func hideTimerLabel() {
        downCountTimer.hideWithAnimation()
    }
    
    func setupInitial() {
        self.view.addSubviews(captureView ,topGradient, captureButtonMock, captureButton, downCountTimer) // verticalLine
        self.view.addSubviews(topMenuView, bottomMenuView)
        bindTargets()
    }
    
    func updateFiltersMenuHeight(_ height: CGFloat) {
        self.filterViewHeight = height
        UIView.animate(withDuration: 0.3) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    func updatedCaptureState(_ state: CaptureState) {
        self.topMenuView.captureState = state
        self.captureButton.setImage(state.icon, for: .normal)
        self.timerCounterSetupFor(state: state)
    }
    
    func updateRecordTimer(_ value: String) {
        self.downCountTimer.text = value
    }
}
// MARK: - INTERNAL
extension CameraView {
    @objc func draggedCaptureButton(_ sender:UIPanGestureRecognizer) {
        self.view.bringSubviewToFront(captureButton)
        let translation = sender.translation(in: self.view)
        captureButton.center = CGPoint(x: captureButton.center.x + translation.x, y: captureButton.center.y + translation.y)
        
        captureButtonMock.frame.intersects(captureButton.frame) ? captureButtonMock.hideWithAnimation() : captureButtonMock.showWithAnimation()
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func timerCounterSetupFor(state: CaptureState) {
        if state == .ready {
            hideTimerLabel()
        } else {
            let point = CGPoint(x: topMenuView.frame.midX - downCountTimer.frame.midX, y: topMenuView.frame.midY - downCountTimer.frame.midY)
            UIView.animate(withDuration: 0.3) {
                self.downCountTimer.transform = state == .done  ? CGAffineTransform(translationX: point.x, y: point.y) : .identity
                self.downCountTimer.font =  state == .done ? UIFont.Camera.downCount?.withSize(15) : UIFont.Camera.downCount
            }
        }
    }
}
