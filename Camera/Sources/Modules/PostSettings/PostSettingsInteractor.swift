//
//  PostSettingsInteractor.swift
//  PostSettings
//
//  Created by Erik Kamalov on 11/13/20.
//

import Foundation

final class PostSettingsInteractor: InteractorInterface {

    weak var presenter: PostSettingsPresenterInteractorInterface!
    
    private var postSettingService: PostSettingService

    public init(postSettingService: PostSettingService) {
        self.postSettingService = postSettingService
    }
}

extension PostSettingsInteractor: PostSettingsInteractorPresenterInterface {
    func updateCaptionText(_ text: String) {
        postSettingService.captionText = text
    }
    
    func getCaptionText() -> String {
        postSettingService.captionText
    }
    
    func toggleSetting(for item: PostSettingItem) {
        postSettingService.toggleSetting(for: item)
    }
    
    func allSettingItems() -> [PostSettingItem] {
        return postSettingService.items()
    }
}
