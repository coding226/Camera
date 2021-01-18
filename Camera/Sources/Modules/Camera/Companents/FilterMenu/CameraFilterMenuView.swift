//
//  CameraButtomMenu.swift
//  Camera
//
//  Created by Erik Kamalov on 11/2/20.
//

import UIKit
import Combine
import PinLayout

private extension UIButton {
    open override var isEnabled: Bool {
        didSet {
            DispatchQueue.main.async {
                self.alpha = self.isEnabled ? 1 : 0.6
            }
        }
    }
}

open class CameraFilterMenuView: UIView {
    
    private lazy var bg: UIImageView = .build {
        $0.image = UIImage(named: "buttomMenuGradient")
    }
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(cellWithClass: MenuCollectionViewCell.self)
        cv.contentInset =  .init(top: 0, left: 20, bottom: 0, right: 20)
        return cv
    }()
    
    private lazy var undoBt: UIButton = .build {
        $0.setImage(UIImage.Camera.BottomsMenu.undo, for: .normal)
    }
    
    private lazy var closeButton: UIButton = .build {
        $0.setImage(UIImage.Camera.BottomsMenu.downArrow, for: .normal)
        $0.isHidden = true
    }
    
    private lazy var redoBt: UIButton = .build {
        $0.setImage(UIImage.Camera.BottomsMenu.redo, for: .normal)
    }
    
    private let viewModel: FilterViewModel
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var configuratorView: FilterConfiguratorView
    
    init(manager: FilterViewModel) {
        viewModel = manager
        configuratorView = .init(manager: manager)
        super.init(frame: .zero)
        configureHierarchy()
        bindViewModel()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.pin.height(47.adaptive).left().right().bottom(pin.safeArea.bottom == 0 ? 4 : 28)
        layoutAnimatedViewWith(filter: self.viewModel.currentEditingFilter)
        bg.pin.top(to: redoBt.edge.vCenter).right().left().bottom()
    }
    
    private func configureHierarchy() {
        addSubviews(bg, undoBt, redoBt)
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubviews(collectionView, configuratorView, closeButton)
    }
    
    private func bindViewModel() {
        undoBt.publisher(for: .touchUpInside).sink { [weak self] _ in
            if self?.viewModel.currentEditingFilter?.type == .brush {
                NotificationCenter.default.post(name: .canvasViewUndo, object: nil)
            } else {
                self?.viewModel.undoManager.undo()
            }
        }.store(in: &cancellables)
        
        redoBt.publisher(for: .touchUpInside).sink { [weak self] _ in
            if self?.viewModel.currentEditingFilter?.type == .brush {
                NotificationCenter.default.post(name: .canvasViewRedo, object: nil)
            } else {
                self?.viewModel.undoManager.redo()
            }
        }.store(in: &cancellables)
        
        closeButton.publisher(for: .touchUpInside).sink { [weak self] _ in
            self?.viewModel.removeCurrentEditingFilter()
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .NSUndoManagerCheckpoint).sink { notification in
            guard let manager = notification.object as? UndoManager else { return }
            self.checkUndoEnableDisableActions(manager)
        }.store(in: &cancellables)
    }
    
    private func checkUndoEnableDisableActions(_ manager: UndoManager) {
        undoBt.isEnabled = manager.canUndo
        redoBt.isEnabled = manager.canRedo
    }
    
    private func layoutAnimatedViewWith(filter: AbstractFilter?) {
        let undoRedoSize: CGFloat = 18.adaptive
        
        guard let fl = filter else {
            closeButton.hideWithAnimation()
            configuratorView.hideWithAnimation()
            configuratorView.dismissContentView()
            undoBt.pin.left(20).top(0).size(undoRedoSize)
            redoBt.pin.right(20).top(0).size(undoRedoSize)
            closeButton.pin.below(of: redoBt, aligned: .center).marginTop(14).size(24.adaptive)
            checkUndoEnableDisableActions(viewModel.undoManager)
            collectionView.deselectSelectedRow(animated: true)
            return
        }
        closeButton.showWithAnimation()
        configuratorView.showWithAnimation()
        
        if fl.type == .filters {
            closeButton.pin.right(20).top()
            redoBt.pin.below(of: closeButton, aligned: .center).marginTop(17).size(undoRedoSize)
            undoBt.pin.left(20).vCenter(to: redoBt.edge.vCenter).size(undoRedoSize)
            configuratorView.pin.top(to: undoBt.edge.bottom).height(102.adaptive).marginBottom(14).width(100%)
        } else {
            undoBt.pin.left(20).top(0).size(undoRedoSize)
            redoBt.pin.right(20).top(0).size(undoRedoSize)
            closeButton.pin.below(of: redoBt, aligned: .center).marginTop(14).size(24.adaptive)
            configuratorView.pin.top(to: undoBt.edge.bottom).bottom(to: collectionView.edge.top).width(100%)
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - UICollectionViewDataSource
extension CameraFilterMenuView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MenuCollectionViewCell.self, for: indexPath)
        if let item = viewModel.data[safe: indexPath.row] {
            cell.apply(item)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CameraFilterMenuView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = viewModel.data[safe: indexPath.row] else { return  }
        self.viewModel.setCurrentFilter(filter: item)
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension CameraFilterMenuView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = viewModel.data[safe: indexPath.row] else { return  .zero }
        let size = item.type.name.sizeOf(font: UIFont.Camera.BottomMenu.cellTitle)
        return .init(width: size.width + 3, height: 47.adaptive)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}
