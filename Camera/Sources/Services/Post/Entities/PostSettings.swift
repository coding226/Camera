//
//  PostSettings.swift
//  Camera
//
//  Created by Erik Kamalov on 11/16/20.
//

import Foundation

struct PostSettings {
    let reaction: Bool
    let sharing: Bool
    let saving: Bool
    let activeTime: Bool
    let caption: String
}

struct PostSettingItem: Hashable {
    let title: String
    let subTitle: String
    var isSelected: Bool
    
    public init(title: String, subTitle: String, isSelected: Bool = false) {
        self.title = title
        self.subTitle = subTitle
        self.isSelected = isSelected
        
        self.identifier = UUID()
    }
    
    private let identifier: UUID
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}


