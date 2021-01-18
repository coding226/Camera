//
//  FilterConfiguratorAbstractFactory.swift
//  Camera
//
//  Created by Erik Kamalov on 11/7/20.
//

import Foundation
import UIKit

protocol AbstractConfiguratorView {
    typealias Model = AbstractFilter
    typealias valueChangedAction = (Model) -> ()
    
    var valueChange: valueChangedAction? { get set }
    var contentView: UIView { get }
    var description: String { get }
    func updateViewWith(model: Model, recreate: Bool)  // TODO: - normal cool name
}

extension AbstractConfiguratorView {
    func updateViewWith(model: Model, recreate: Bool) {}
}

enum ConfiguratorViewType {
    case sliderView
    case gradientSliderView
    case rotateView
    case collectionView
    
    var viewHeight: CGFloat {
        switch self {
        case .gradientSliderView: return 150
        case .collectionView: return 214.adaptive
        case .rotateView: return 179
        case .sliderView: return 151
        }
    }
}

protocol ConfiguratorViewFactory {
    static func configuratorView(for type: ConfiguratorViewType, with filter: AbstractFilter) -> AbstractConfiguratorView
}

class FilterConfiguratorViewFactory: ConfiguratorViewFactory {
    static func configuratorView(for type: ConfiguratorViewType, with filter: AbstractFilter) -> AbstractConfiguratorView {
        print("Configurator View has been created")
        let title = filter.type.rawValue.capitalizingFirstLetter()
        switch type {
        case .sliderView: return RangeSliderView(title: title, model: filter as! SliderFilterModel)
        case .gradientSliderView: return GradientSliderView(title: title, model: .init(type: .brush, currentValue: 0.0, range: 0...1))
        case .rotateView: return RotateRulerView(title: title, model: filter as! RotateFilterModel)
        case .collectionView: return FiltersCollectionView(model: filter as! LookupFilterModel)
        }
    }
}


