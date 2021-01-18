//
//  UICollectionView+Extensions.swift
//  Camera
//
//  Created by Erik Kamalov on 11/2/20.
//

import UIKit

public extension UICollectionViewCell {
    static var reuseIdentifier: String { String(describing: Self.self) }
}

class BaseCVCell: UICollectionViewCell {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.reset()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.reset()
    }
    
    // MARK: - API
    open func initialize() {}
    open func reset() {}
}


public extension UICollectionView {
    /// SwifterSwift: Dequeue reusable UICollectionViewCell using class name.
    ///
    /// - Parameters:
    ///   - name: UICollectionViewCell type.
    ///   - indexPath: location of cell in collectionView.
    /// - Returns: UICollectionViewCell object with associated class name.
    func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError(
                "Couldn't find UICollectionViewCell for \(String(describing: name)), make sure the cell is registered with collection view")
        }
        return cell
    }
    
    /// SwifterSwift: Register UICollectionViewCell using class name.
    ///
    /// - Parameter name: UICollectionViewCell type.
    func register<T: UICollectionViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: name))
    }
    
    func deselectSelectedRow(animated: Bool){
        self.indexPathsForSelectedItems?.forEach { self.deselectItem(at: $0, animated: animated) }
    }
}

public extension UICollectionViewFlowLayout {
    convenience init(minimumLineSpacing: CGFloat = 10, scrollDirection:UICollectionView.ScrollDirection = .horizontal ,
                     itemSize:CGSize = .init(width: 20, height: 20)) {
        self.init()
        self.minimumLineSpacing = minimumLineSpacing
        self.scrollDirection = scrollDirection
        self.itemSize = itemSize
    }
}
