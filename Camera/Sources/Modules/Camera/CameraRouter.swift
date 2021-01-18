//
//  CameraRouter.swift
//  Camera
//
//  Created by Erik Kamalov on 11/11/20.
//

import Foundation
import UIKit

final class CameraRouter: RouterInterface {

    weak var presenter: CameraPresenterRouterInterface!

    weak var viewController: UIViewController?
}

extension CameraRouter: CameraRouterPresenterInterface {
    func showPostVC() {
        let vc = PostModule().build()
        self.viewController?.show(vc, sender: nil)
    }
}
