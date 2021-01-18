//
//  SliderView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/6/20.
//

import UIKit
import PinLayout


struct SliderModel {
    let currentValue: Float
    let range: ClosedRange<Float>
}

class RangeSliderView: UIView {
    // MARK: - Attributes

    private lazy var title: UILabel = .build {
        $0.text = "Brightness"
        $0.textColor = .white
        $0.font = UIFont.Camera.BottomMenu.sliderTitle
    }
    
    lazy var slider: EKSlider = .build {
        $0.applyCustomDesign()
        $0.applyThumbImageWith(size: 22)
    }
    
    private lazy var centerPointer: UIView = .build {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.31)
        $0.pin.width(3).height(42)
        $0.layer.cornerRadius = 1.5
    }
    
    let model: SliderModel
    
    // MARK: - Initializers
    init(title:String, model: SliderModel) {
        self.model = model
        super.init(frame: .zero)
        self.title.text = title
        configureHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configutation
    private func configureHierarchy() {
        self.slider.minimumValue = model.range.lowerBound
        self.slider.maximumValue = model.range.upperBound
        self.slider.setValue(model.currentValue, animated: false)
    
        addSubviews(title, centerPointer, slider)
    }
    
    // MARK: - Layouting
    open override func layoutSubviews() {
        super.layoutSubviews()
        title.pin.left(20).top(14).sizeToFit()
        slider.pin.below(of: title).marginTop(7).right(20).left(20).hCenter()
        centerPointer.pin.center(to: slider.anchor.center)
    }
}
