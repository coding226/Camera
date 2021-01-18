//
//  AdaptiveLayoutHelper.swift
//  Camera
//
//  Created by Erik Kamalov on 11/14/20.
//

import UIKit

enum Device {
    case iPhoneSE
    case iPhone8
    case iPhone8Plus
    case iPhone11Pro
    case iPhone11ProMax
    
    static let baseScreenSize: Device = .iPhone11Pro // This is the device for which the design was drawn
}

extension Device: RawRepresentable {
    typealias RawValue = CGSize
    
    init?(rawValue: CGSize) {
        switch rawValue {
        case CGSize(width: 320, height: 568): self = .iPhoneSE
        case CGSize(width: 375, height: 667): self = .iPhone8
        case CGSize(width: 414, height: 736): self = .iPhone8Plus
        case CGSize(width: 375, height: 812): self = .iPhone11Pro
        case CGSize(width: 414, height: 896): self = .iPhone11ProMax
        default:
            return nil
        }
    }
    
    var rawValue: CGSize {
        switch self {
        case .iPhoneSE: return CGSize(width: 320, height: 568)
        case .iPhone8: return CGSize(width: 375, height: 667)
        case .iPhone8Plus: return CGSize(width: 414, height: 736)
        case .iPhone11Pro: return CGSize(width: 375, height: 812)
        case .iPhone11ProMax: return CGSize(width: 414, height: 896)
        }
    }
}

enum Dimension {
    case width
    case height
}

var dimension: Dimension {
    UIDevice.current.orientation.isPortrait ? .width : .height
}

func resized(size: CGSize, basedOn dimension: Dimension) -> CGSize {
    let screenWidth  = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    var ratio:  CGFloat = 0.0
    var width:  CGFloat = 0.0
    var height: CGFloat = 0.0
    
    switch dimension {
    case .width:
        ratio  = size.height / size.width
        width  = screenWidth * (size.width / Device.baseScreenSize.rawValue.width)
        height = width * ratio
    case .height:
        ratio  = size.width / size.height
        height = screenHeight * (size.height / Device.baseScreenSize.rawValue.height)
        width  = height * ratio
    }
    
    return CGSize(width: width, height: height)
}

func adapted(dimensionSize: CGFloat, to dimension: Dimension) -> CGFloat {
    let screenWidth  = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    var ratio: CGFloat = 0.0
    var resultDimensionSize: CGFloat = 0.0
    switch dimension {
    case .width:
        ratio = dimensionSize / Device.baseScreenSize.rawValue.width
        resultDimensionSize = screenWidth * ratio
    case .height:
        ratio = dimensionSize / Device.baseScreenSize.rawValue.height
        resultDimensionSize = screenHeight * ratio
    }
//    print(dimensionSize, "result", resultDimensionSize)
    return resultDimensionSize
}


 // MARK: - Extensions

protocol Adaptive { }

extension Adaptive {
    private var value: CGFloat {
        switch self {
        case let value as CGFloat: return value
        case let value as Double: return CGFloat(value)
        case let value as Float: return CGFloat(value)
        case let value as Int: return CGFloat(value)
        default: fatalError("NumberConvertible convert cast failed! Please check value")
        }
    }
    
    var adaptive: CGFloat {
        adapted(dimensionSize: self.value, to: dimension)
    }
    
    func adaptive(_ demension: Dimension) -> CGFloat {
        adapted(dimensionSize: self.value, to: demension)
    }
}

extension Int: Adaptive {}
extension Float: Adaptive {}
extension Double: Adaptive {}
extension CGFloat: Adaptive {}

//extension CGFloat {
//    var adaptedFontSize: CGFloat {
//        print(self, adapted(dimensionSize: self, to: dimension))
//        return adapted(dimensionSize: self, to: dimension)
//    }
//}
//
//extension CGFloat {
//    var adaptive: CGFloat {
//        return adapted(dimensionSize: self, to: dimension)
//    }
//}
//
//extension Int {
//    var adaptive: CGFloat {
//        return adapted(dimensionSize: CGFloat(self), to: dimension)
//    }
//}
//
//extension Double {
//    var adaptive: CGFloat {
//        return adapted(dimensionSize: CGFloat(self), to: dimension)
//    }
//}
