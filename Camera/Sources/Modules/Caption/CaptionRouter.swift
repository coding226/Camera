//
//  CaptionRouter.swift
//  Caption
//
//  Created by Erik Kamalov on 11/11/20.
//

import Foundation
import UIKit

final class CaptionRouter: RouterInterface {

    weak var presenter: CaptionPresenterRouterInterface!

    weak var viewController: UIViewController?
    
    weak var delegate: CaptionViewDelegate?

    public init(delegate: CaptionViewDelegate) {
        self.delegate = delegate
    }
}

extension CaptionRouter: CaptionRouterPresenterInterface {
    func dismiss() {
        delegate?.saveCaption(text: presenter.getCaptionText())
        self.viewController?.dismiss(animated: true, completion: nil)
    }
}
