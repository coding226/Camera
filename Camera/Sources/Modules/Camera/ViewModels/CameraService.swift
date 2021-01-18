//
//  CameraViewModel.swift
//  Camera
//
//  Created by Erik Kamalov on 11/11/20.
//

import BBMetalImage
import AVFoundation
import Combine

enum CaptureState {
    case ready, recording, done
    
    var icon: UIImage? {
        switch self {
        case .ready: return UIImage.Camera.Capture.ready
        case .recording: return UIImage.Camera.Capture.stop
        case .done: return UIImage.Camera.Capture.finishing
        }
    }
}

enum CaptureType {
    case photo, video
}

class CameraService {
    private(set) var outputUrl: URL
    private(set) var videoWriter: BBMetalVideoWriter!
    private(set) var camera: BBMetalCamera?
    private(set) var captureView: CaptureView!
    private(set) var preview: CameraPreview?
    
    @Published var state: CaptureState
    
    init() {
        state = .ready
        outputUrl = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString.appending(".mp4"))
    }
    
    private var appliedFilters: [BBMetalBaseFilter] = []
    
    func addFilters(_ filters: [BBMetalBaseFilter]) {
        guard state != .done else {
            preview?.applyNewFilter(filters: filters)
            return
        }
        
        camera?.removeAllConsumers()
        guard let chainedFilter = chainingFilters(filters),
              let input = chainedFilter.input,
              let output = chainedFilter.output else {
            camera?.add(consumer: captureView.metalView)
            return
        }
        
        appliedFilters = filters
        
        camera?.add(consumer: input)
        output.add(consumer: captureView.metalView)
    }
    
    func setupCameraTo(_ metalView: CaptureView) {
        self.captureView = metalView
        camera = BBMetalCamera(sessionPreset: .high)
        camera?.add(consumer: self.captureView.metalView)
    }
    
    func clearCaptureView() {
        if let blendFilterIndex = appliedFilters.firstIndex(where: { $0.name == "normalBlendKernel" }) { // if we have previously used an overlay we need to delete it
            appliedFilters.remove(at: blendFilterIndex)
        }
        
        try? FileManager.default.removeItem(at: outputUrl)
        preview?.clear()
        
        startCapturing()
        addFilters(appliedFilters)
        camera?.willTransmitTexture = nil
    }
    
    func take(type: CaptureType) {
        self.preview = CameraPreview(captureType: type, captureView: captureView)
        switch type {
        case .photo: takePhoto()
        case .video: recordVideo()
        }
    }
    
    func stopRecodingVideo() {
        guard let pv = preview else { return }
        videoWriter.finish { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.stopCapturing()
                pv.setVideo(self.outputUrl)
            }
        }
    }
    
    private func recordVideo() {
        videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: 1080, height: 1920))
        camera?.audioConsumer = videoWriter
        
        let canvasSnapshot = captureView.canvasView.snapshot
        
        if canvasSnapshot != nil {
            let filter = BBMetalNormalBlendFilter()
            appliedFilters.append(filter)
            addFilters(appliedFilters)
        }
        
        if let filter = appliedFilters.last {
            filter.add(consumer: videoWriter)
            
            if let cvs = canvasSnapshot {
                let blendFilter = BBMetalStaticImageSource(image: cvs)
                camera?.willTransmitTexture = { [weak self] _, _ in
                    guard self != nil else { return }
                    blendFilter.transmitTexture()
                }
                blendFilter.add(consumer: filter)
                captureView.canvasView.clear()
            }
            
        } else {
            camera?.add(consumer: videoWriter)
        }
        
        videoWriter.start()
        state = .recording
    }
    
    private func takePhoto() {
        guard let pv = preview else { return }
        
        let completion: BBMetalFilterCompletion = { [weak self] info in
            guard info.isCameraPhoto else { return }
            switch info.result {
            case let .success(texture):
                let image = texture.bb_image
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.stopCapturing()
                    pv.setImage(image)
                    
                }
            case .failure: break
            }
        }
        
        state = .recording
        if let filter = appliedFilters.last {
            filter.addCompletedHandler(completion)
            camera?.capturePhoto()
        } else {
            camera?.capturePhoto(completion: completion)
        }
    }
}

// MARK: - Basic functionallity final
extension CameraService {
    final func startCapturing()  {
        try? AVAudioSession.sharedInstance().setCategory(.record, mode: .videoRecording, options: [])
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        self.camera?.start()
        state = .ready
    }
    
    final func stopCapturing()  {
        self.camera?.stop()
        state = .done
    }
    
    final func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ?.on :.off
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
    
    final func switchCameraPosition() {
        self.camera?.switchCameraPosition()
    }
    
    final func createBlurBackgroundImage() {
        guard let screenshot = preview?.bgThumbnailImage() else { return }
        let view = UIView(frame: captureView.bounds)
        let imageView = UIImageView(frame: captureView.bounds)
        imageView.image = screenshot
        imageView.contentMode = .scaleAspectFill
        
        let gradientTop = GradientView(frame: .init(origin: captureView.frame.origin, size: .init(width: captureView.frame.width,
                                                                                                  height: 167.adaptive)))
        gradientTop.setColors([UIColor.black.withAlphaComponent(0.5), UIColor.clear])
        
        let gradientBottom = GradientView(frame: captureView.bounds)
        gradientBottom.setColors([UIColor.clear, UIColor.black.withAlphaComponent(0.5)])
        view.addSubviews(imageView, gradientTop, gradientBottom)
        
        let views = UIView(frame: captureView.bounds)
        views.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        view.addSubview(views)
        
        temporaryBgImage = BBMetalGaussianBlurFilter(sigma: 15).filteredImage(with: view.screenshot) ?? .background
    }
}

// MARK: - Preview
extension CameraService {
    final class CameraPreview {
        // MARK: - Attributes
        private var captureType: CaptureType
        private var captureView: CaptureView
        
        // MARK: - Initializers
        public init(captureType: CaptureType,  captureView: CaptureView) {
            self.captureType = captureType
            self.captureView = captureView
        }
        
        // MARK: - Apply new filters
        func applyNewFilter(filters: [BBMetalBaseFilter]) {
            switch self.captureType {
            case .photo: applyNewFilterImage(filters)
            case .video: applyNewFiltersForVideo(filters)
            }
        }
        
        // MARK: - Image proccess
        private lazy var imageView: UIImageView = .build {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        private var imageSource: BBMetalStaticImageSource?
        private var originalImage: UIImage?
        
        func setImage(_ image: UIImage?) {
            guard let img = image else { return }
            if let canvasImage = captureView.canvasView.snapshot {
                originalImage = BBMetalNormalBlendFilter().filteredImage(with: img, canvasImage)
                captureView.canvasView.clear()
            } else {
                originalImage = img
            }
            imageView.frame = captureView.metalView.frame
            captureView.metalView.addSubview(imageView)
            self.imageView.image = originalImage
        }
        
        private func applyNewFilterImage(_ filters: [BBMetalBaseFilter]) {
            imageSource = BBMetalStaticImageSource(image: originalImage!)
            
            guard let chainedFilter = chainingFilters(filters), let input = chainedFilter.input else {
                imageView.image = originalImage
                return
            }
            weak var output = chainedFilter.output
            
            imageSource?.add(consumer: input)
            chainedFilter.output?.addCompletedHandler { [weak self] _ in
                if let filteredImage = output?.outputTexture?.bb_image {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.imageView.image = filteredImage
                    }
                }
            }
            imageSource?.transmitTexture()
        }
        
        func bgThumbnailImage() -> UIImage? {
            return captureView.screenshotV2()
        }
        
        // MARK: - Video proccess
        private lazy var playBt: UIButton = .build {
            $0.setImage(UIImage.Camera.playbt, for: .normal)
            $0.frame.size = .init(lenght: 100.adaptive)
            $0.addTarget(self, action: #selector(play), for: .touchUpInside)
        }
        
        private var videoSource: BBMetalVideoSource?
        private var videoWriter: BBMetalVideoWriter!
        
        var playerAudio: AVAudioPlayer?
        
        func setVideo(_ url: URL) {
            playBt.center = captureView.metalView.center
            videoSource = BBMetalVideoSource(url: url)
            videoSource?.playWithVideoRate = true
            
            let filePath = NSTemporaryDirectory() + "test.mp4"
            let outputUrl = URL(fileURLWithPath: filePath)
            try? FileManager.default.removeItem(at: outputUrl)
            videoWriter = BBMetalVideoWriter(url: outputUrl, frameSize: BBMetalIntSize(width: 1080, height: 1920))
            
            videoSource?.audioConsumer = videoWriter
            videoSource?.add(consumer: captureView.metalView)
            videoSource?.add(consumer: videoWriter)
            
            playerAudio = try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp4.rawValue)
            
            captureView.addSubview(playBt)
            let tap = UITapGestureRecognizer(target: self, action: #selector(stopPlay))
            captureView.addGestureRecognizer(tap)
            
        }
        
        func applyNewFiltersForVideo(_ filters: [BBMetalBaseFilter]) {
            print("applyNewFiltersForVideo", filters)
        }
        
        @objc func play(){
            start()
            playBt.hideWithAnimation()
        }
        private func start() {
            playerAudio?.play()
            videoSource?.start(completion:  { value in
                if value { self.start() }
            })
        }
        @objc func stopPlay() {
            playerAudio?.stop()
            playBt.showWithAnimation()
            videoSource?.cancel()
        }
        
        func clear() {
            captureView.canvasView.clear()
            videoSource?.cancel()
            playBt.removeFromSuperview()
            imageView.removeFromSuperview()
        }
    }
}

func chainingFilters<T: BBMetalBaseFilter>(_ filters: [T]) -> (input: BBMetalBaseFilter?, output: BBMetalBaseFilter?)? {
    guard var firstFilter = filters.first else {
        return nil
    }
    filters.enumerated().forEach {
        if $0.offset != 0  {
            firstFilter = firstFilter.add(consumer: $0.element)
        }
    }
    return (input: filters.first, output: filters.last)
}
