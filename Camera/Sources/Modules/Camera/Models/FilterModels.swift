//
//  FilterModels.swift
//  Camera
//
//  Created by Erik Kamalov on 11/11/20.
//

import UIKit

enum FilterEnum: String, CaseIterable, Equatable {
    static var allAbstractFilterCases: [AbstractFilter] {
        return self.allCases.map { $0.defaultModel }
    }
    
    case filters, rotate, brush, brightness, contrast, blur, sharpness, temperature, saturation, fade, highlights, shadow, vignette, clarity
    
    var name: String {
        return self.rawValue.capitalizingFirstLetter()
    }
    
    var icon: UIImage? {
        return UIImage(named: self.rawValue)
    }
    
    var defaultModel: AbstractFilter {
        switch self {
        case .brightness: return SliderFilterModel(type: .brightness, currentValue: 0, range: -0.7...0.7) // BBMetalBrightnessFilter
        case .contrast: return SliderFilterModel(type: .contrast, currentValue: 1, range: 0.0...4.0) // BBMetalContrastFilter
        case .blur: return SliderFilterModel(type: .blur, currentValue: 0, range: 0.0...10.0) // BBMetalGaussianBlurFilter
        case .sharpness: return SliderFilterModel(type: .sharpness, currentValue: 0, range: -4.0...4.0) // BBMetalSharpenFilter
        case .temperature: return SliderFilterModel(type: .temperature, currentValue: 5000, range: 4000...7000) // BBMetalWhiteBalanceFilter
        case .saturation: return SliderFilterModel(type: .saturation, currentValue: 1, range: 0...2) // BBMetalSaturationFilter
        case .fade: return SliderFilterModel(type: .fade, currentValue: 0, range: 0...1)   // check
        case .highlights: return SliderFilterModel(type: .highlights, currentValue: 0, range: 0...1) // BBMetalHighlightShadowFilter
        case .shadow: return SliderFilterModel(type: .shadow, currentValue: 0, range: 0...1) // BBMetalHighlightShadowFilter

        case .vignette: return SliderFilterModel(type: .vignette, currentValue: 0, range: 0...1) // BBMetalVignetteFilter
        case .clarity: return SliderFilterModel(type: .clarity, currentValue: 0, range: 0...1) // BBMetalUnsharpMaskFilter
        
        case .filters: return LookupFilterModel(type: .filters, filter: "normal")
        case .rotate: return RotateFilterModel(type: .rotate, angle: 0)
        case .brush: return SliderFilterModel(type: .brush, currentValue: 0, range: 0...1)
        }
    }
    var lookupModels: [String] {
        return ["LUT_M01", "LUT_M02", "LUT_M03", "LUT_M05", "LUT_M06", "normal", "LUT_M07", "LUT_M08", "LUT_M09", "LUT_M11", "LUT_M12"]
    }
}

protocol AbstractFilter {
    var type: FilterEnum { get }
    var congiguratorViewType: ConfiguratorViewType { get }
}

extension AbstractFilter {
    var congiguratorViewType: ConfiguratorViewType {
        switch type {
        case .brush: return .gradientSliderView
        case .rotate: return .rotateView
        case .filters: return .collectionView
        default: return .sliderView
        }
    }
}

struct SliderFilterModel: AbstractFilter {
    var type: FilterEnum
    var currentValue: Float
    let range: ClosedRange<Float>
}

struct LookupFilterModel: AbstractFilter {
    var type: FilterEnum
    var filter: String
}

struct RotateFilterModel: AbstractFilter {
    var type: FilterEnum
    var angle: Int
}
