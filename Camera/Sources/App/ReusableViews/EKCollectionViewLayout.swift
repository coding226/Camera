//
//  EKCollectionViewLayout.swift.swift
//  Camera
//
//  Created by Erik Kamalov on 11/10/20.
//

import UIKit

public protocol TransformableView {
    
    /// The view for detecting tap gesture
    /// when you call `CollectionViewPagingLayout.configureTapOnCollectionView()`
    /// a tap gesture will be added to the CollectionView and when the user tap on it
    /// it checks if the tap location was in this view frame it will trigger
    /// `CollectionViewPagingLayoutDelegate.collectionViewPagingLayout(_ layout:, didSelectItemAt indexPath:)`
    var selectableView: UIView? { get }
    
    /// Sends a float value based on the position of the view (cell)
    /// if the view is in the center of CollectionView it sends 0
    ///
    /// - Parameter progress: the interpolated progress for the cell view
    func transform(progress: CGFloat)
    
    /// Optional function for providing the Z index(position) of the cell view
    /// As defined as an extension the default value of zIndex is Int(-abs(round(progress)))
    ///
    /// - Parameter progress: the interpolated progress for the cell view
    /// - Returns: the z index(position)
    func zPosition(progress: CGFloat) -> Int
}


public extension TransformableView {
    /// Defining the default value of zIndex
    func zPosition(progress: CGFloat) -> Int {
        Int(-abs(round(progress)))
    }
}
public extension TransformableView where Self: UICollectionViewCell {
    /// Default `selectableView` for `UICollectionViewCell` is the first subview of
    /// `contentView` or the content view itself if there is no subview
    var selectableView: UIView? {
        contentView.subviews.first
    }
}



public protocol EKCollectionViewLayoutDelegate: class {
    
    /// Calls when the current page changes
    ///
    /// - Parameter layout: a reference to the layout class
    /// - Parameter currentPage: the new current page index
    func onCurrentPageChanged(layout: EKCollectionViewLayout, currentPage: Int)
    
    /// Calls when the user taps on the `TransformableView.selectableView`
    /// to enable this functionality you need to call `configureTapOnCollectionView()` after setting the layout
    ///
    /// - Parameter layout: a reference to the layout class
    /// - Parameter indexPath: IndexPath for the selected cell
    func collectionViewPagingLayout(_ layout: EKCollectionViewLayout, didSelectItemAt indexPath: IndexPath)
}


public extension EKCollectionViewLayoutDelegate {
    func onCurrentPageChanged(layout: EKCollectionViewLayout, currentPage: Int) {}
    func collectionViewPagingLayout(_ layout: EKCollectionViewLayout, didSelectItemAt indexPath: IndexPath) {}
}


public class EKCollectionViewLayout: UICollectionViewLayout {
    
    // MARK: Properties
    public var numberOfVisibleItems: Int?
    public var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    public weak var delegate: EKCollectionViewLayoutDelegate?
    
    override public var collectionViewContentSize: CGSize {
        getContentSize()
    }
    
    public private(set) var currentPage: Int = 0 {
        didSet {
            delegate?.onCurrentPageChanged(layout: self, currentPage: currentPage)
        }
    }
    
    private var currentScrollOffset: CGFloat {
        let visibleRect = self.visibleRect
        return scrollDirection == .horizontal ? (visibleRect.minX / max(visibleRect.width, 1)) : (visibleRect.minY / max(visibleRect.height, 1))
    }
    
    private var visibleRect: CGRect {
        collectionView.map { CGRect(origin: $0.contentOffset, size: $0.bounds.size) } ?? .zero
    }
    
    private var numberOfItems: Int {
        guard let numberOfSections = collectionView?.numberOfSections, numberOfSections > 0 else {
            return 0
        }
        return (0..<numberOfSections)
        .compactMap { collectionView?.numberOfItems(inSection: $0) }
        .reduce(0, +)
    }
    
    private var currentPageCache: Int?
    private var attributesCache: [(page: Int, attributes:UICollectionViewLayoutAttributes)]?
    private var scrollToSelectedCell: Bool = false

    
    // MARK: Public functions
    
    public func setCurrentPage(_ page: Int, animated: Bool = true) {
        safelySetCurrentPage(page, animated: animated)
    }
    
    public func goToNextPage(animated: Bool = true) {
        setCurrentPage(currentPage + 1, animated: animated)
    }
    
    public func goToPreviousPage(animated: Bool = true) {
        setCurrentPage(currentPage - 1, animated: animated)
    }
    
    public func configureTapOnCollectionView(goToSelectedPage: Bool = false) {
        self.scrollToSelectedCell = goToSelectedPage
        addTapGestureToCollectionView()
    }
    
    
    // MARK: UICollectionViewLayout
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if newBounds.size != visibleRect.size {
            currentPageCache = currentPage
        }
        return true
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let currentScrollOffset = self.currentScrollOffset
        let numberOfItems = self.numberOfItems
        let attributesCount = numberOfVisibleItems ?? numberOfItems
        let visibleRangeMid = attributesCount / 2
        let currentPageIndex = Int(round(currentScrollOffset))
        var initialStartIndex = currentPageIndex - visibleRangeMid
        var initialEndIndex = currentPageIndex + visibleRangeMid
        if attributesCount % 2 != 0 {
            if currentPageIndex < visibleRangeMid {
                initialStartIndex -= 1
            } else {
                initialEndIndex += 1
            }
        }
        let startIndexOutOfBounds = max(0, -initialStartIndex)
        let endIndexOutOfBounds = max(0, initialEndIndex - numberOfItems)
        let startIndex = max(0, initialStartIndex - endIndexOutOfBounds)
        let endIndex = min(numberOfItems, initialEndIndex + startIndexOutOfBounds)

        var attributesArray: [(page: Int, attributes:UICollectionViewLayoutAttributes)] = []
        var section = 0
        var numberOfItemsInSection = collectionView?.numberOfItems(inSection: section) ?? 0
        var numberOfItemsInPrevSections = 0
        for index in startIndex..<endIndex {
            var item = index - numberOfItemsInPrevSections
            while item >= numberOfItemsInSection {
                numberOfItemsInPrevSections += numberOfItemsInSection
                section += 1
                numberOfItemsInSection = collectionView?.numberOfItems(inSection: section) ?? 0
                item = index - numberOfItemsInPrevSections
            }
            
            let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: section))
            let pageIndex = CGFloat(index)
            let progress = pageIndex - currentScrollOffset
            var zIndex = Int(-abs(round(progress)))
            
            let cell = collectionView?.cellForItem(at: cellAttributes.indexPath)
            
            if let cell = cell as? TransformableView {
                cell.transform(progress: progress)
                zIndex = cell.zPosition(progress: progress)
            }
            if cell == nil || cell is TransformableView {
                cellAttributes.frame = visibleRect
            } else {
                cellAttributes.frame = CGRect(origin: CGPoint(x: pageIndex * visibleRect.width, y: 0), size: visibleRect.size)
            }
            
            cellAttributes.zIndex = zIndex
            attributesArray.append((page: Int(pageIndex), attributes: cellAttributes))
        }
        attributesCache = attributesArray
        return attributesArray.map(\.attributes)
    }
    
    override public func invalidateLayout() {
        super.invalidateLayout()
        if let page = currentPageCache {
            setCurrentPage(page, animated: false)
            currentPageCache = nil
        } else {
            updateCurrentPageIfNeeded()
        }
    }
    
    
    // MARK: Private functions
    private func updateCurrentPageIfNeeded() {
        var currentPage: Int = 0
        if let collectionView = collectionView {
            let contentOffset = collectionView.contentOffset
            let pageSize = scrollDirection == .horizontal ? collectionView.frame.width : collectionView.frame.height
            let offset = scrollDirection == .horizontal ?
                (contentOffset.x + collectionView.contentInset.left) :
                (contentOffset.y + collectionView.contentInset.top)
            if pageSize > 0 {
                currentPage = Int(round(offset / pageSize))
            }
        }
        if currentPage != self.currentPage {
            self.currentPage = currentPage
        }
    }
    
    private func getContentSize() -> CGSize {
        var safeAreaLeftRight: CGFloat = 0
        var safeAreaTopBottom: CGFloat = 0
        if #available(iOS 11, *) {
            safeAreaLeftRight = (collectionView?.safeAreaInsets.left ?? 0) + (collectionView?.safeAreaInsets.right ?? 0)
            safeAreaTopBottom = (collectionView?.safeAreaInsets.top ?? 0) + (collectionView?.safeAreaInsets.bottom ?? 0)
        }
        if scrollDirection == .horizontal {
            return CGSize(width: CGFloat(numberOfItems) * visibleRect.width, height: visibleRect.height - safeAreaTopBottom)
        } else {
             return CGSize(width: visibleRect.width - safeAreaLeftRight, height: CGFloat(numberOfItems) * visibleRect.height)
        }
    }
    
    private func safelySetCurrentPage(_ page: Int, animated: Bool) {
        let pageSize = scrollDirection == .horizontal ? visibleRect.width : visibleRect.height
        let contentSize = scrollDirection == .horizontal ? collectionViewContentSize.width : collectionViewContentSize.height
        let maxPossibleOffset = contentSize - pageSize
        var offset = pageSize * CGFloat(page)
        offset = max(0, offset)
        offset = min(offset, maxPossibleOffset)
        let contentOffset: CGPoint = scrollDirection == .horizontal ? CGPoint(x: offset, y: 0) : CGPoint(x: 0, y: offset)
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.invalidateLayout()
        }
        collectionView?.setContentOffset(contentOffset, animated: animated)
        CATransaction.commit()
        
        // this is necessary when we want to set the current page without animation
        if !animated, page != currentPage, let collectionView = collectionView {
            collectionView.performBatchUpdates({
                collectionView.collectionViewLayout.invalidateLayout()
            })
        }
    }
    
    private func addTapGestureToCollectionView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapOnCollectionView(gesture:)))
        collectionView?.addGestureRecognizer(gesture)
    }
    
    @objc private func tapOnCollectionView(gesture: UITapGestureRecognizer) {
        var items = collectionView?.visibleCells.compactMap { cell -> (cell: UICollectionViewCell, rect: CGRect, attributes: UICollectionViewLayoutAttributes, page: Int)? in
            guard let indexPath = collectionView?.indexPath(for: cell),
                let view = cell as? TransformableView,
                let selectableView = view.selectableView,
                let attributesAndPage = attributesCache?.first(where: { $0.attributes.indexPath == indexPath }) else {
                    return nil
            }
            let rect = selectableView.superview?.convert(selectableView.frame, to: collectionView) ?? .zero
            return (cell: cell, rect: rect, attributes: attributesAndPage.attributes, page: attributesAndPage.page)
            } ?? []
        
        items.sort { $0.attributes.zIndex > $1.attributes.zIndex }
        
        let location = gesture.location(in: gesture.view)
        var findSelected = false
        for item in items {
            if !findSelected, item.rect.contains(location) {
                delegate?.collectionViewPagingLayout(self, didSelectItemAt: item.attributes.indexPath)
                item.cell.isSelected = true
                findSelected = true
                if scrollToSelectedCell {
                    setCurrentPage(item.page, animated: true)
                }
            }
            item.cell.isSelected = false
        }
    }
}
