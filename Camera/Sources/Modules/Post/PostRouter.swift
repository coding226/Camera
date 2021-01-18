//
//  PostRouter.swift
//  Post
//
//  Created by Erik Kamalov on 11/12/20.
//

import Foundation
import UIKit

final class PostRouter: RouterInterface {

    weak var presenter: PostPresenterRouterInterface!

    weak var viewController: UIViewController?
}

extension PostRouter: PostRouterPresenterInterface {
    func showPostSettings() {
        let vc = PostSettingsModule().build(service: presenter.settingsService())
        self.viewController?.show(vc, sender: nil)
    }
    func dismissVC() {
        self.viewController?.navigationController?.popViewController(animated: true)
    }
}
