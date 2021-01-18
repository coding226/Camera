//
//  RotateRulerView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/5/20.
//

import UIKit
import PinLayout

class RotateRulerView: UIView {
    // MARK: - Attributes
    var valueChange: valueChangedAction?
    
    private lazy var title: UILabel = .build {
        $0.textColor = .white
        $0.font = UIFont.Camera.BottomMenu.sliderTitle
    }
    
    private lazy var rotateAngle: UILabel = .build {
        $0.textColor = .white
        $0.font = UIFont.Camera.BottomMenu.sliderTitle
        $0.textAlignment = .center
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout(minimumLineSpacing: 12, scrollDirection: .horizontal, itemSize: .init(width: 2, height: 46))
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(cellWithClass: RuleDividingCell.self)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private lazy var centerIndicator: UIView = .build {
        $0.frame.size = .init(width: 4, height: 52)
        $0.backgroundColor = .init(hexString: "93A7B9")
        $0.layer.cornerRadius = $0.frame.width.half
    }
    
    private var ruleLenght = 361
    
    private var ruleCenterItem: Int {
        return 180
    }
    
    private var model: RotateFilterModel
    
    private var currentValue: Int {
        didSet {
            rotateAngle.text = String(abs(currentValue))
            var tmpModel = model
            tmpModel.angle = currentValue
            valueChange?(tmpModel)
        }
    }
    
    // MARK: - Initializers
    init(title:String, model: RotateFilterModel) {
        self.model = model
        self.currentValue = model.angle
        super.init(frame: .zero)
        self.title.text = title
        self.rotateAngle.text =  "0"
        configureHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configureHierarchy() {
        addSubviews(title, rotateAngle, collectionView, centerIndicator)
    }
    
    // MARK: - Layouting
    open override func layoutSubviews() {
        super.layoutSubviews()
        title.pin.left(20).top(14).width(30%).height(22)
        rotateAngle.pin.hCenter().vCenter(to: title.edge.vCenter).minWidth(30).sizeToFit()
        collectionView.pin.below(of: title).marginTop(7).right(20).left(20).height(52).hCenter()
        centerIndicator.pin.hCenter(0.1).top(to: collectionView.edge.top)
        
        collectionView.contentInset = .init(top: 6, left: collectionView.bounds.width / 2,
                                            bottom: 0, right: collectionView.bounds.width / 2)
        
        let row: IndexPath = .init(row: initIndexPathRow(), section: 0)
        collectionView.scrollToItem(at: row, at: .centeredHorizontally, animated: false)
    }
    
    private func initIndexPathRow() -> Int {
        guard model.angle != 0 else { return ruleCenterItem }
        return model.angle < 0 ? (ruleCenterItem - abs(model.angle)) : (ruleCenterItem + model.angle)
    }
}

extension RotateRulerView: AbstractConfiguratorView{
    var contentView: UIView {
        self
    }
    func updateViewWith(model: Model, recreate: Bool) {
        guard let rotateModel = model as? RotateFilterModel else { return }
        self.model = rotateModel
        let row: IndexPath = .init(row: initIndexPathRow(), section: 0)
        collectionView.scrollToItem(at: row, at: .centeredHorizontally, animated: false)
        self.rotateAngle.text = String(Int(abs(rotateModel.angle)))
    }
}

extension RotateRulerView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating else { return }
        let value = self.valueForContentOffset(contentOffset: collectionView.contentOffset)
        switch Int(value) {
        case let val where val > ruleCenterItem: currentValue = val - ruleCenterItem
        case let val where val < ruleCenterItem: currentValue = -Int(ruleCenterItem - val)
        default: currentValue = 0
        }
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var value = self.valueForContentOffset(contentOffset: targetContentOffset.pointee)
        modf(value).1 > 0.5 ? value.round(.up) : value.round(.down)
        targetContentOffset.pointee.x = self.contentOffsetForValue(value: value).x
    }
    
    func contentOffsetForValue(value: CGFloat) -> CGPoint {
        let contentOffset: CGFloat = (value * self.offsetCoefficient) - self.collectionView.contentInset.left
        return CGPoint(x: contentOffset, y: self.collectionView.contentOffset.y)
    }
    
    func valueForContentOffset(contentOffset: CGPoint) -> CGFloat {
        return (contentOffset.x + self.collectionView.contentInset.left) / self.offsetCoefficient
    }
    
    var offsetCoefficient: CGFloat {
        return 14 // minimumLineSpacing and cell width
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ruleLenght
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: RuleDividingCell.self, for: indexPath)
        return cell
    }
}

extension RotateRulerView {
    class RuleDividingCell: BaseCVCell {
        // MARK: - Layouting
        override func layoutSubviews() {
            super.layoutSubviews()
            self.layer.cornerRadius = self.bounds.width.half
            self.backgroundColor = .init(hexString: "C4C4C4")
        }
    }
}
