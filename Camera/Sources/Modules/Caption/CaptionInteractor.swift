//
//  CaptionInteractor.swift
//  Caption
//
//  Created by Erik Kamalov on 11/11/20.
//

import Foundation

final class CaptionInteractor: InteractorInterface {

    weak var presenter: CaptionPresenterInteractorInterface!
}

extension CaptionInteractor: CaptionInteractorPresenterInterface {}
