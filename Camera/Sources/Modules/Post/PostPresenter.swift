//
//  PostPresenter.swift
//  Post
//
//  Created by Erik Kamalov on 11/12/20.
//

import Foundation

final class PostPresenter: PresenterInterface {

    var router: PostRouterPresenterInterface!
    var interactor: PostInteractorPresenterInterface!
    weak var view: PostViewPresenterInterface!

    private var items: [Item] = []
    
    private func updateSendView() {
        guard let firstItem = items.first else {
            view.updateSendView(subTitle: nil, height: 0)
            return
        }
        view.updateSendView(subTitle: items.count > 1 ? nil : firstItem.title, height: 72.adaptive)
    }
}

extension PostPresenter: PostPresenterRouterInterface {
    func settingsService() -> PostSettingService {
        interactor.settingsService()
    }
}

extension PostPresenter: PostPresenterInteractorInterface {

}

extension PostPresenter: PostPresenterViewInterface {
    func didSelect(_ item: Item) {
        items.append(item)
        updateSendView()
    }
    
    func deselect(_ item: Item) {
        items.removeAll(where:  { $0.id == item.id })
        updateSendView()
    }
    
    func reload() {
        view.display(basic: interactor.mainItem())
        view.display(recents: interactor.allRecent())
        view.display(myFriends: interactor.allMyFriends())
    }
    
    func tapBackBt() {
        router.dismissVC()
    }
    
    func tapSettingBt() {
        router.showPostSettings()
    }
    
    func viewDidLoad() {
        view.setupInitial()
    }
}
