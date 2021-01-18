//
//  SliderView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/6/20.
//

import UIKit
import PinLayout



class RangeSliderView: UIView {
    
    // MARK: - Attributes
    var valueChange: valueChangedAction?
    
    private lazy var title: UILabel = .build {
        $0.textColor = .white
        $0.font = UIFont.Camera.BottomMenu.sliderTitle
    }
    
    lazy var slider: EKSlider = .build {
        $0.applyCustomDesign()
        $0.applyThumbImageWith(size: 22)
        $0.addTarget(self, action: #selector(changed), for: .valueChanged)
    }
    
    private lazy var centerPointer: UIView = .build {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.31)
        $0.pin.width(3).height(42)
        $0.layer.cornerRadius = 1.5
    }
    
    private var model: SliderFilterModel
    
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
    
    // MARK: - Configuration
    private func configureHierarchy() {
        addSubviews(title, centerPointer, slider)
        self.updateSliderModel()
    }
    
    // MARK: - Layouting
    open override func layoutSubviews() {
        super.layoutSubviews()
        title.pin.left(20).top(15).width(30%).height(22)
        slider.pin.below(of: title).marginTop(7).right(20).left(20).hCenter()
        centerPointer.pin.center(to: slider.anchor.center)
//        print(slider.globalFrame, title.globalFrame)
    }
    
    @objc func changed(target: UISlider) {
        self.model.currentValue = target.value
        self.valueChange?(self.model)
    }
    
    private func updateSliderModel() {
        self.slider.minimumValue = model.range.lowerBound
        self.slider.maximumValue = model.range.upperBound
        UIView.animate(withDuration: 0.3) {
            self.slider.setValue(self.model.currentValue, animated: true)
        }
    }
}

extension RangeSliderView: AbstractConfiguratorView {
    var contentView: UIView {
        return self
    }
    
    func updateViewWith(model: Model, recreate: Bool = true) {
        guard let modelTmp = model as? SliderFilterModel else { return  }
        self.model = modelTmp
       
        if recreate {
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.push
            
            self.title.text = modelTmp.type.rawValue.capitalizingFirstLetter()
            animation.duration = 0.3
            self.title.layer.add(animation, forKey: CATransitionType.push.rawValue)
        } else {
            self.title.text = modelTmp.type.rawValue.capitalizingFirstLetter()
        }
        updateSliderModel()
    }
}
