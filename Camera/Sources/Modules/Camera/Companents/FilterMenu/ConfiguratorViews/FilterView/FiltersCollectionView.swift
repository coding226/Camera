//
//  FiltersCollectionView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/5/20.
//

import UIKit
import EKBuilder

class FiltersCollectionView: UIView {
    // MARK: - Attributes
    var valueChange: valueChangedAction?
    
    lazy var collectionView: UICollectionView = {
        let layout = EKCollectionViewLayout()
        layout.numberOfVisibleItems = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(cellWithClass: FilterCollectionViewCell.self)
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        return cv
    }()
    
    private var data: [String]
    private var model: LookupFilterModel
    private var didScrollCollectionViewToMiddle: Bool
    
    // MARK: - Initializers
    // didScrolToDefaultFilter will scroll collectionview to selected filter
    init(model: LookupFilterModel, didScrolToSelectedFilter: Bool = true) {
        self.data = model.type.lookupModels
        self.model = model
        self.didScrollCollectionViewToMiddle = !didScrolToSelectedFilter
        super.init(frame: .zero)
        configureHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configureHierarchy() {
        addSubview(collectionView)
    }
    
    // MARK: - Layouting
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.pin.all()
        reloadCollectionView()
        
        guard let scrollIndex = data.firstIndex(of: model.filter), !didScrollCollectionViewToMiddle && bounds.height != 0 else { return }
        collectionViewLayout()?.setCurrentPage(scrollIndex, animated: false)
        didScrollCollectionViewToMiddle = true
    }
   
    private func reloadCollectionView() {
        collectionView.reloadData()
        collectionView.performBatchUpdates({ [weak self] in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    private func collectionViewLayout() -> EKCollectionViewLayout? {
        collectionView.collectionViewLayout as? EKCollectionViewLayout
    }
}


extension FiltersCollectionView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: FilterCollectionViewCell.self, for: indexPath)
        if let item = data[safe: indexPath.row] {
            cell.apply(item)
        }
        return cell
    }
}

extension FiltersCollectionView: UICollectionViewDelegate {
    private func updateSelectedLayout() {
        guard let layout = collectionView.collectionViewLayout as? EKCollectionViewLayout,
              let selectedFilter = data[safe: layout.currentPage],
              selectedFilter !=  model.filter else {
            return
        }
        model.filter = selectedFilter
        valueChange?(model)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSelectedLayout()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedLayout()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateSelectedLayout()
    }
}

extension  FiltersCollectionView: AbstractConfiguratorView {
    var contentView: UIView {
        return self
    }
    func updateViewWith(model: Model, recreate: Bool) {
        guard let lookupModel = model as? LookupFilterModel, let scrollIndex = data.firstIndex(of: lookupModel.filter) else { return }
        self.model = lookupModel
        collectionViewLayout()?.setCurrentPage(scrollIndex, animated: true)
    }
}
