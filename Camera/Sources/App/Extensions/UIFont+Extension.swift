//
//  UIFont+Extension.swift
//  Camera
//
//  Created by Erik Kamalov on 11/3/20.
//

import UIKit

extension UIFont {
    /// Create a UIFont object with a `Font` enum
    public convenience init?(font: Font, size: CGFloat) {
        let fontIdentifier: String = font.rawValue
        self.init(name: fontIdentifier, size: size)
    }
}

public enum Font: String {
    // MARK: Avenir Next Cyr
    case avenirNextCyrMedium = "AvenirNextCyr-Medium"
    case avenirNextCyrDemi = "AvenirNextCyr-Demi"
    case avenirNextCyrRegular = "AvenirNextCyr-Regular"
    case avenirNextCyrBold = "AvenirNext-Bold"
    
    func printFonts() {
        for family: String in UIFont.familyNames {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }
}
