//
//  CaptionPresenter.swift
//  Caption
//
//  Created by Erik Kamalov on 11/11/20.
//

import Foundation

final class CaptionPresenter: PresenterInterface {

    var router: CaptionRouterPresenterInterface!
    var interactor: CaptionInteractorPresenterInterface!
    weak var view: CaptionViewPresenterInterface!

    var captionText: String

    public init(captionText: String) {
        self.captionText = captionText
    }
}

extension CaptionPresenter: CaptionPresenterRouterInterface {
    func getCaptionText() -> String {
        self.captionText
    }
}

extension CaptionPresenter: CaptionPresenterInteractorInterface {
}

extension CaptionPresenter: CaptionPresenterViewInterface {
    func saveCaption(text: String) {
        self.captionText = text
    }
    
    func tappedCloseButton() {
        router.dismiss()
    }

    func viewDidLoad() {
        view.setupInitial(captionText: captionText)
    }
}
