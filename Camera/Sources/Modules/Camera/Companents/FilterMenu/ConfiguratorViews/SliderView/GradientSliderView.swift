//
//  GradientSliderView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/7/20.
//

import UIKit

class GradientSliderView: UIView, AbstractConfiguratorView {
    
    // MARK: - Attributes
    var contentView: UIView {
        return self
    }
    var valueChange: valueChangedAction?

    private lazy var title: UILabel = .build {
        $0.textColor = .white
        $0.font = UIFont.Camera.BottomMenu.sliderTitle
    }
    
    lazy var gradientSlider: EKGradientSlider = .build {
        $0.trackLineHeight = 7
        $0.thumbViewSize = 23
        $0.addTarget(self, action: #selector(changedColor(_ :)), for: .valueChanged)
    }
    var model: SliderFilterModel
    
    // MARK: - Initializers
    init(title:String, model: SliderFilterModel) {
        self.model = model
        super.init(frame: .zero)
        self.title.text = title
        configureHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.post(name: .canvasViewEnabled, object: false) // Look CanvasView
    }
    
    // MARK: - Configuration
    private func configureHierarchy() {
        addSubviews(title, gradientSlider)
        NotificationCenter.default.post(name: .canvasViewEnabled, object: true)
    }
    
    // MARK: - Layouting
    open override func layoutSubviews() {
        super.layoutSubviews()
        title.pin.left(20).top(14).sizeToFit()
        gradientSlider.pin.below(of: title).bottom(0).right(11.5).left(11.5).hCenter()
    }
    
    @objc func changedColor(_ slider: EKGradientSlider) {
        let value = Float(slider.value)
        self.model.currentValue = value
        self.valueChange?(self.model)
    }
}
