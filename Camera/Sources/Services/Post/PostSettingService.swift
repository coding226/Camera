//
//  PostSettingService.swift
//  Camera
//
//  Created by Erik Kamalov on 11/16/20.
//

import Foundation

protocol PostSettingService {
    func items() -> [PostSettingItem]
    func toggleSetting(for item: PostSettingItem)
    var captionText: String { get set }
}


class DefaultPostSettingsService {
    private var settingItems: [PostSettingItem]
    var captionText: String = ""
    
    private var itemsEnumList: [itemsEnum]  = [.reaction, .sharing, .saving, .activeTime]

    public init() {
        self.settingItems = itemsEnumList.map { $0.model }
    }

    enum itemsEnum {
        case reaction
        case sharing
        case saving
        case activeTime
        
        var model: PostSettingItem {
            switch self {
            case .reaction: return PostSettingItem(title: "Reaction Posts", subTitle: "When your friends see your story, a 5 sec video will be taken of their reaction to the post.")
            case .sharing: return PostSettingItem(title: "Sharing", subTitle: "Allow people to share your post")
            case .saving: return PostSettingItem(title: "Saving", subTitle: "Allow people to Save your post", isSelected: true)
            case .activeTime: return PostSettingItem(title: "Active Time", subTitle: "24 hours, 0 min, 0 sec")
            }
        }
    }
}

extension DefaultPostSettingsService: PostSettingService {
    func items() -> [PostSettingItem] {
        self.settingItems
    }
    
    func toggleSetting(for item: PostSettingItem) {
        guard let index = self.settingItems.lastIndex(where: { $0.title == item.title }) else { return }
        self.settingItems[index].isSelected = !item.isSelected
    }
}
