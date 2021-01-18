//
//  PostSettingsRouter.swift
//  PostSettings
//
//  Created by Erik Kamalov on 11/13/20.
//

import Foundation
import UIKit

protocol CaptionViewDelegate: class {
    func saveCaption(text: String)
}

final class PostSettingsRouter: RouterInterface {
    weak var presenter: PostSettingsPresenterRouterInterface!
    weak var viewController: UIViewController?
}

extension PostSettingsRouter: PostSettingsRouterPresenterInterface {
    func dismissVC() {
        self.viewController?.navigationController?.popViewController(animated: true)
    }
    
    func showCaptionVC() {
        let vc = CaptionModule().build(captionText: presenter.getCaptionText(), delegate: self)
        vc.modalPresentationStyle = .fullScreen
        self.viewController?.present(vc, animated: true, completion: nil)
    }
}

extension PostSettingsRouter: CaptionViewDelegate {
    func saveCaption(text: String) {
        presenter.updateCaptionText(text)
    }
}
