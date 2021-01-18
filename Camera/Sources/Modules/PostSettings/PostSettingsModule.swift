//
//  PostSettingsModule.swift
//  PostSettings
//
//  Created by Erik Kamalov on 11/13/20.
//
import Foundation
import UIKit

// MARK: - router

protocol PostSettingsRouterPresenterInterface: RouterPresenterInterface {
    func showCaptionVC()
    func dismissVC()
}

// MARK: - presenter

protocol PostSettingsPresenterRouterInterface: PresenterRouterInterface {
    func getCaptionText() -> String
    func updateCaptionText(_ text: String)
}

protocol PostSettingsPresenterInteractorInterface: PresenterInteractorInterface {

}

protocol PostSettingsPresenterViewInterface: PresenterViewInterface {
    func viewDidLoad()
    func tappedBackBt()
    func loadData()
    func tappedCationView()
    func didSelect(_ setting: PostSettingItem)
    func deselect(_ setting: PostSettingItem)
}

// MARK: - interactor

protocol PostSettingsInteractorPresenterInterface: InteractorPresenterInterface {
    func allSettingItems() -> [PostSettingItem]
    func toggleSetting(for item: PostSettingItem)
    func getCaptionText() -> String
    func updateCaptionText(_ text: String)
}

// MARK: - view

protocol PostSettingsViewPresenterInterface: ViewPresenterInterface {
    func setupInitial()
    func display(_ items: [PostSettingItem])
    func display(caption text: String)
}


// MARK: - module builder

final class PostSettingsModule: ModuleInterface {

    typealias View = PostSettingsView
    typealias Presenter = PostSettingsPresenter
    typealias Router = PostSettingsRouter
    typealias Interactor = PostSettingsInteractor

    func build(service: PostSettingService) -> UIViewController {
        let view = View()
        let interactor = Interactor(postSettingService: service)
        let presenter = Presenter()
        let router = Router()

        self.assemble(view: view, presenter: presenter, router: router, interactor: interactor)

        router.viewController = view

        return view
    }
}
