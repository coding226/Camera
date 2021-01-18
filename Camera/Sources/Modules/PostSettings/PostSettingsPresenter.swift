//
//  PostSettingsPresenter.swift
//  PostSettings
//
//  Created by Erik Kamalov on 11/13/20.
//

import Foundation

final class PostSettingsPresenter: PresenterInterface {
    
    var router: PostSettingsRouterPresenterInterface!
    var interactor: PostSettingsInteractorPresenterInterface!
    weak var view: PostSettingsViewPresenterInterface!
}

extension PostSettingsPresenter: PostSettingsPresenterRouterInterface {
    func getCaptionText() -> String {
        interactor.getCaptionText()
    }
}

extension PostSettingsPresenter: PostSettingsPresenterInteractorInterface {
}

extension PostSettingsPresenter: PostSettingsPresenterViewInterface {
    func updateCaptionText(_ text: String) {
        view.display(caption: text)
        interactor.updateCaptionText(text)
    }
    
    func loadData() {
        view.display(interactor.allSettingItems())
        view.display(caption: interactor.getCaptionText())
    }
    
    func deselect(_ setting: PostSettingItem) {
        interactor.toggleSetting(for: setting)
        loadData()
    }
    
    func didSelect(_ setting: PostSettingItem) {
        interactor.toggleSetting(for: setting)
        loadData()
    }
    
    func tappedBackBt() {
        router.dismissVC()
    }
    
    func tappedCationView() {
        router.showCaptionVC()
    }
    
    func viewDidLoad() {
        view.setupInitial()
    }
}
