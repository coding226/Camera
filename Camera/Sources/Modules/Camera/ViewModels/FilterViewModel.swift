//
//  FilterManager.swift
//  Camera
//
//  Created by Erik Kamalov on 11/6/20.
//

import UIKit
import Combine

typealias FilterDictionary = [FilterEnum: AbstractFilter]

let filterMenuDefaultHeight: CGFloat = 82

final class FilterViewModel: ObservableObject {
    // MARK: - Attributes
    let buttonViewHeightWillChange = PassthroughSubject<CGFloat, Never>()
    let currentFilterWillChange = PassthroughSubject<AbstractFilter, Never>()
    let undoManagerFilterWillChange = PassthroughSubject<AbstractFilter, Never>()
    let applyFilterChanged = PassthroughSubject<FilterDictionary, Never>()
    
    private(set) var data =  FilterEnum.allAbstractFilterCases
    
    private(set) var bottomViewHeight: CGFloat = filterMenuDefaultHeight {
        didSet {
            if bottomViewHeight != oldValue {
                buttonViewHeightWillChange.send(bottomViewHeight)
            }
        }
    }
    
    private(set) var currentEditingFilter: AbstractFilter? {
        didSet {
            if let newValue = currentEditingFilter,  newValue.type != oldValue?.type {
                // check previous this filter applied or not.
                print("checking", applyFilter[newValue.type])
                currentFilterWillChange.send(applyFilter[newValue.type] ?? newValue)
            }
        }
    }
    
    private var applyFilter: FilterDictionary = [:]
    private var backupApplyFilter: FilterDictionary = [:] // Use for undo manager
    
    private(set) var undoManager: UndoManager
    
    // MARK: - Life cycle
    init() {
        undoManager = UndoManager()
    }
    
    // MARK: - Configuration
    func filterEditing(_ filter: AbstractFilter) {
        // first, we check new a filter to exits in applied filters
        if applyFilter[filter.type] != nil {
            self.applyFilter.updateValue(filter, forKey: filter.type)
        } else {
            self.applyFilter[filter.type] = filter
            self.addUndoActionRegister(at: filter.type)
        }
        backupApplyFilter = applyFilter
        applyFilterChanged.send(applyFilter)
    }
    
    func setCurrentFilter(filter: AbstractFilter) {
        self.currentEditingFilter = filter
        self.bottomViewHeight = filter.congiguratorViewType.viewHeight
    }
    func removeCurrentEditingFilter(){
        self.currentEditingFilter = nil
        self.bottomViewHeight = filterMenuDefaultHeight
    }
    func removeApplyFilters() {
        self.applyFilter.removeAll()
        self.backupApplyFilter.removeAll()
    }
}


//MARK:- Add/Remove Filter : Undo/Redo Actions
extension FilterViewModel {
   private func addFilter(at key: FilterEnum){
        guard let item = backupApplyFilter[key] else { return }
        applyFilter[key] = item
        applyFilterChanged.send(applyFilter)
        undoManagerFilterWillChange.send(item)
    }
    
   private func removeRemoveFilter(at key: FilterEnum) {
        applyFilter.removeValue(forKey: key)
        applyFilterChanged.send(applyFilter)
        undoManagerFilterWillChange.send(key.defaultModel)
    }
    
    func addUndoActionRegister(at key: FilterEnum){
        self.undoManager.registerUndo(withTarget: self, handler: { (selfTarget) in
            selfTarget.removeRemoveFilter(at: key)
            selfTarget.removeUndoActionRegister(at: key)
        })
    }
    
    func removeUndoActionRegister(at key: FilterEnum){
        self.undoManager.registerUndo(withTarget: self, handler: { (selfTarget) in
            selfTarget.addFilter(at: key)
            selfTarget.addUndoActionRegister(at: key)
        })
    }
}
