//
//  CameraInteractor.swift
//  Camera
//
//  Created by Erik Kamalov on 11/11/20.
//

import Foundation
import BBMetalImage
import Combine

final class CameraInteractor: InteractorInterface {
    
    weak var presenter: CameraPresenterInteractorInterface! {
        didSet { bindViewModel() }
    }
    
    var cameraService: CameraService
    var filterViewModel: FilterViewModel
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(cameraService: CameraService, filterViewModel: FilterViewModel) {
        self.cameraService = cameraService
        self.filterViewModel = filterViewModel
    }
    
    private func bindViewModel(){
        filterViewModel.buttonViewHeightWillChange.sink { [weak self] value in
            self?.presenter.cameraBottomMenuHeightChange(value)
        }.store(in: &cancellables)
        
        filterViewModel.applyFilterChanged.sink { [weak self] value in
            let base = self?.filterCasting(filter: value)
            self?.cameraService.addFilters(base ?? [])
        }.store(in: &cancellables)
        
        cameraService.$state.receive(on: DispatchQueue.main)
            .sink { [weak self] state in
            self?.presenter.captureStateCanged(state)
        }.store(in: &cancellables)
    }
    
    deinit {
        cancellables.removeAll()
    }
}

extension CameraInteractor: CameraInteractorPresenterInterface {
    func setCaptureView(view: CaptureView) {
        cameraService.setupCameraTo(view)
    }
    
    func startCapturing() {
        cameraService.startCapturing()
    }
    
    func startVideoRecording() {
        filterViewModel.removeCurrentEditingFilter()
        cameraService.take(type: .video)
    }
    
    func stopVideoRecording() {
        filterViewModel.removeApplyFilters()
        cameraService.stopRecodingVideo()
    }
        
    func takePhoto() {
        filterViewModel.removeCurrentEditingFilter()
        filterViewModel.removeApplyFilters()
        cameraService.take(type: .photo)
    }

    func stopCapturing() {
        cameraService.stopCapturing()
    }
    
    func createBlurBackgroundImage() {
        cameraService.createBlurBackgroundImage()
    }
    
}

extension CameraInteractor {
    private func filterCasting(filter: FilterDictionary) -> [BBMetalBaseFilter] {
        var baseFilters: [BBMetalBaseFilter] = []
        filter.forEach { (key, value) in
//            print(value, key)
            switch key {
            case .brightness: // BBMetalBrightnessFilter
                guard let vl = value as? SliderFilterModel else { return }
                let filter = BBMetalBrightnessFilter(brightness: vl.currentValue)
                baseFilters.append(filter)
            case .contrast: // BBMetalContrastFilter
                guard let vl = value as? SliderFilterModel else { return }
                let filter = BBMetalContrastFilter(contrast: vl.currentValue)
                baseFilters.append(filter)
            case .blur: // BBMetalGaussianBlurFilter
                guard let vl = value as? SliderFilterModel else { return }
                let filter = BBMetalGaussianBlurFilter(sigma: vl.currentValue)
                baseFilters.append(filter)
            case .sharpness: // BBMetalSharpenFilter
                guard let vl = value as? SliderFilterModel else { return }
                let filter = BBMetalSharpenFilter(sharpeness: vl.currentValue)
                baseFilters.append(filter)
            case .temperature: // BBMetalWhiteBalanceFilter
                guard let vl = value as? SliderFilterModel else { return }
                let filter = BBMetalWhiteBalanceFilter(temperature: vl.currentValue, tint: 0)
                baseFilters.append(filter)
            case .saturation:  // BBMetalSaturationFilter
                guard let vl = value as? SliderFilterModel else { return }
                let filter = BBMetalSaturationFilter(saturation: vl.currentValue)
                baseFilters.append(filter)
            case .fade:  // check
                guard let vl = value as? SliderFilterModel else { return }
                var matrix: matrix_float4x4 = .identity
                matrix[0][1] = 1
                matrix[2][1] = 1
                matrix[3][1] = 1
                let filter = BBMetalColorMatrixFilter(colorMatrix: matrix, intensity: vl.currentValue)
                baseFilters.append(filter)
            case .highlights: // BBMetalHighlightShadowFilter
                guard let vl = value as? SliderFilterModel else { return }
                let filter = BBMetalHighlightShadowFilter(shadows: 0, highlights: vl.currentValue)
                baseFilters.append(filter)
            case .shadow: // BBMetalHighlightShadowFilter
                guard let vl = value as? SliderFilterModel else { return }
                let filter = BBMetalHighlightShadowFilter(shadows: vl.currentValue, highlights: 0)
                baseFilters.append(filter)
            case .vignette: // BBMetalVignetteFilter
                guard let vl = value as? SliderFilterModel else { return }
                let filter = BBMetalVignetteFilter(center: .center, color: .black, start: 1 - vl.currentValue, end: 1)
                baseFilters.append(filter)
            case .clarity: // BBMetalUnsharpMaskFilter
                guard let vl = value as? SliderFilterModel else { return }
                let filter = BBMetalUnsharpMaskFilter(sigma: 4, intensity: vl.currentValue)
                baseFilters.append(filter)
            case .filters:
                guard let vl = value as? LookupFilterModel,
                      let url = Bundle.main.url(forResource: vl.filter, withExtension: "png"),
                      let data = try? Data(contentsOf: url).bb_metalTexture else { return }
                let filter = BBMetalLookupFilter(lookupTable: data, intensity: 1)
                baseFilters.append(filter)
            case .rotate:
                guard let vl = value as? RotateFilterModel else { return }
                let filter = BBMetalRotateFilter(angle: Float(vl.angle), fitSize: false)
                baseFilters.append(filter)
            case .brush: break
            }
        }
        return baseFilters
    }
}
