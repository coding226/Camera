//
//  PostModule.swift
//  Post
//
//  Created by Erik Kamalov on 11/12/20.
//
import Foundation
import UIKit

// MARK: - router

protocol PostRouterPresenterInterface: RouterPresenterInterface {
    func showPostSettings()
    func dismissVC()
}

// MARK: - presenter

protocol PostPresenterRouterInterface: PresenterRouterInterface {
    func settingsService() -> PostSettingService
}

protocol PostPresenterInteractorInterface: PresenterInteractorInterface {

}

protocol PostPresenterViewInterface: PresenterViewInterface {
    func viewDidLoad()
    func tapBackBt()
    func tapSettingBt()
    func reload()
    func didSelect(_ item: Item)
    func deselect(_ item: Item)
}

// MARK: - interactor

protocol PostInteractorPresenterInterface: InteractorPresenterInterface {
    func allRecent() -> [Item]
    func allMyFriends() -> [Item]
    func mainItem() -> [Item]
    func settingsService() -> PostSettingService
}

// MARK: - view

protocol PostViewPresenterInterface: ViewPresenterInterface {
    func setupInitial()
    func display(recents: [Item])
    func display(myFriends: [Item])
    func display(basic: [Item])
    func updateSendView(subTitle:String?, height: CGFloat)
}


// MARK: - module builder

final class PostModule: ModuleInterface {

    typealias View = PostView
    typealias Presenter = PostPresenter
    typealias Router = PostRouter
    typealias Interactor = PostInteractor

    func build() -> UIViewController {
        let view = View()
        let interactor = Interactor(postSettingService: App.shared.postSettingService)
        let presenter = Presenter()
        let router = Router()

        self.assemble(view: view, presenter: presenter, router: router, interactor: interactor)

        router.viewController = view

        return view
    }
}
