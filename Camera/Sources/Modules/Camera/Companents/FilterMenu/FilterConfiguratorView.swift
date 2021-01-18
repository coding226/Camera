//
//  FilterConfiguratorView.swift
//  Camera
//
//  Created by Erik Kamalov on 11/11/20.
//

import UIKit
import Combine

class FilterConfiguratorView: UIView {
    private var currentFilterType: AbstractFilter?
    private var currentView: AbstractConfiguratorView?
    private var filterManager: FilterViewModel
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(manager: FilterViewModel) {
        self.filterManager = manager
        super.init(frame: .zero)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentView() {
        guard let filter = self.currentFilterType else { return }
        var view = FilterConfiguratorViewFactory.configuratorView(for: filter.congiguratorViewType, with: filter)
        self.currentView = view
        
        view.valueChange = { [weak self] value in
            if self?.currentFilterType?.type == .brush {
                guard let vl = value as? SliderFilterModel else { return }
                NotificationCenter.default.post(name: .canvasViewColorChange, object: vl.currentValue)
            } else {
                self?.filterManager.filterEditing(value)
            }
        }
        
        UIView.transition(with: self, duration: 0.3, options: [.curveEaseIn], animations: {
            self.addSubview(view.contentView)
        }, completion: nil)
    }
    
    func dismissContentView() {
        currentView?.contentView.removeFromSuperview()
        currentView = nil
        self.currentFilterType = nil
    }
    
   private func setFactory(filter: AbstractFilter) {
        if currentFilterType?.congiguratorViewType == filter.congiguratorViewType {
            currentView?.updateViewWith(model: filter, recreate: true)
        } else {
            self.dismissContentView()
            self.currentFilterType = filter
            self.presentView()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        currentView?.contentView.pin.all()
    }
    
    private func bindViewModel() {
        filterManager.currentFilterWillChange.sink { [weak self] filter in
            self?.setFactory(filter: filter)
        }.store(in: &cancellables)
        
        filterManager.undoManagerFilterWillChange.sink { [weak self] filter in
            self?.currentView?.updateViewWith(model: filter, recreate: false)
        }.store(in: &cancellables)
    }
    deinit {
        cancellables.removeAll()
    }
}
