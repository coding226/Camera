//
//  CameraModule.swift
//  Camera
//
//  Created by Erik Kamalov on 11/11/20.
//
import Foundation
import UIKit
import BBMetalImage

// MARK: - router

protocol CameraRouterPresenterInterface: RouterPresenterInterface {
    func showPostVC()  
}

// MARK: - presenter

protocol CameraPresenterRouterInterface: PresenterRouterInterface {

}

protocol CameraPresenterInteractorInterface: PresenterInteractorInterface {
    func cameraBottomMenuHeightChange(_ value:CGFloat)
    func captureStateCanged(_ state: CaptureState)
}

protocol CameraPresenterViewInterface: PresenterViewInterface {
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
    func tapCaptureButton(type: CaptureType)
}

// MARK: - interactor

protocol CameraInteractorPresenterInterface: InteractorPresenterInterface {
    func setCaptureView(view: CaptureView)
    func startCapturing()
    func stopCapturing()
    func takePhoto()
    func startVideoRecording()
    func stopVideoRecording()
    func createBlurBackgroundImage()
}

// MARK: - view

protocol CameraViewPresenterInterface: ViewPresenterInterface {
    var captureView: CaptureView { get set }
    func setupInitial()
    func updateRecordTimer(_ value: String)
    func showTimerLabel()
    func hideTimerLabel()
    func updatedCaptureState(_ state: CaptureState)
    func updateFiltersMenuHeight(_ height: CGFloat)
}


// MARK: - module builder

final class CameraModule: ModuleInterface {

    typealias View = CameraView
    typealias Presenter = CameraPresenter
    typealias Router = CameraRouter
    typealias Interactor = CameraInteractor

    func build() -> UIViewController {
        let startCaptureState: CaptureState = .ready
        
        let cameraService: CameraService = .init()
        let filterManager: FilterViewModel = .init()
        
        let topMenu = CameraTopMenuView(captureState: startCaptureState, cameraViewModel: cameraService)
        let bottomMenu = CameraFilterMenuView(manager: filterManager)
        
        let view = View(topMenuView: topMenu, bottomMenuView: bottomMenu)
        
        let interactor = Interactor(cameraService: cameraService, filterViewModel: filterManager)
        
        let presenter = Presenter()
        
        let router = Router()
        
        self.assemble(view: view, presenter: presenter, router: router, interactor: interactor)

        router.viewController = view

        return view
    }
}
