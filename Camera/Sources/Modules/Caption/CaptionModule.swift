//
//  CaptionModule.swift
//  Caption
//
//  Created by Erik Kamalov on 11/11/20.
//
import Foundation
import UIKit

// MARK: - router

protocol CaptionRouterPresenterInterface: RouterPresenterInterface {
    func dismiss()
}

// MARK: - presenter

protocol CaptionPresenterRouterInterface: PresenterRouterInterface {
    func getCaptionText() -> String
}

protocol CaptionPresenterInteractorInterface: PresenterInteractorInterface {
}

protocol CaptionPresenterViewInterface: PresenterViewInterface {
    func viewDidLoad()
    func tappedCloseButton()
    func saveCaption(text: String)
}

// MARK: - interactor

protocol CaptionInteractorPresenterInterface: InteractorPresenterInterface {
}

// MARK: - view

protocol CaptionViewPresenterInterface: ViewPresenterInterface {
    var captionTextLimit: Int { get }
    func setupInitial(captionText: String)
}


// MARK: - module builder

final class CaptionModule: ModuleInterface {

    typealias View = CaptionView
    typealias Presenter = CaptionPresenter
    typealias Router = CaptionRouter
    typealias Interactor = CaptionInteractor

    func build(captionText:String, delegate: CaptionViewDelegate) -> UIViewController {
        let view = View(captionTextLimit: 120)
        let interactor = Interactor()
        let presenter = Presenter(captionText: captionText)
        let router = Router(delegate: delegate)

        self.assemble(view: view, presenter: presenter, router: router, interactor: interactor)

        router.viewController = view

        return view
    }
}

