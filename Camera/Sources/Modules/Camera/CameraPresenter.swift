//
//  CameraPresenter.swift
//  Camera
//
//  Created by Erik Kamalov on 11/11/20.
//

import Foundation
import Combine
import BBMetalImage

final class CameraPresenter: PresenterInterface {
    
    var router: CameraRouterPresenterInterface!
    var interactor: CameraInteractorPresenterInterface!
    weak var view: CameraViewPresenterInterface!
    
    private var timerCounter: Int = 0
    private var timerSubscription: AnyCancellable?
    
    private var captureState: CaptureState = .ready {
        willSet { view.updatedCaptureState(newValue) }
    }
}

extension CameraPresenter: CameraPresenterRouterInterface { }

extension CameraPresenter: CameraPresenterInteractorInterface {
    func captureStateCanged(_ state: CaptureState) {
        self.captureState = state
    }
    
    func cameraBottomMenuHeightChange(_ value: CGFloat) {
        view.updateFiltersMenuHeight(value)
    }
}

extension CameraPresenter: CameraPresenterViewInterface {
    func viewDidAppear() {
        if captureState == .ready {
            interactor.startCapturing()
        }
    }
    
    func viewDidDisappear() {
        print("viewDidDisappear")
    }

    func tapCaptureButton(type: CaptureType) {
        switch captureState {
        case .ready:
            if type != .video {
                interactor.takePhoto()
            } else {
                interactor.startVideoRecording()
                startRecordingTimer()
            }
        case .recording:
            stopRecordingTimer()
            interactor.stopVideoRecording()
        case .done:
            interactor.createBlurBackgroundImage()
            router.showPostVC()
            print("to publish")
        }
    }
    
    func viewDidLoad() {
        view.setupInitial()
        interactor.setCaptureView(view: view.captureView)
    }
}

extension CameraPresenter {
    private func startRecordingTimer()  {
        view.showTimerLabel()
        timerCounter = 0
        timerSubscription = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in
                self.timerCounter += 1
                self.view.updateRecordTimer("\(self.timerCounter)")
                if self.timerCounter >= 59 {
                    self.interactor.stopVideoRecording()
                    self.stopRecordingTimer()
                }
            })
    }
    
    private func stopRecordingTimer()  {
        self.view.updateRecordTimer("0:\(self.timerCounter)")
        timerSubscription?.cancel()
    }
}
