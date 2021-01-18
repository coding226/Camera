//
//  Extensions.swift
//  Camera
//
//  Created by Erik Kamalov on 11/2/20.
//

import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func sizeOf(font: UIFont?) -> CGSize {
        return self.size(withAttributes: [.font: font ?? .systemFont(ofSize: 12)])
    }
}

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else { return nil }
        return self[index]
    }
}

public extension Array where Element: Equatable {
    @discardableResult
    mutating func removeDuplicates() -> [Element] {
        // Thanks to https://github.com/sairamkotha for improving the method
        self = reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
        return self
    }
}

extension CGSize {
    public init(lenght: CGFloat) {
        self.init(width: lenght, height: lenght)
    }
}

public extension CGFloat {
    var half: CGFloat { return self / 2 }
    
}

public func calcRangePercent(min:CGFloat, max:CGFloat, percentage:CGFloat,_ reverse:Bool = false) -> CGFloat {
    if percentage  < 0 { return min }
    let tmpPercentage = CGFloat.minimum(percentage, 1.0)
    return ((max - min) * tmpPercentage) + min
}
