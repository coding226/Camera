//
//  App.swift
//  Camera
//
//  Created by Erik Kamalov on 11/11/20.
//

import Foundation

final class App {
    
    static let shared = App()
    
    private init() { }

    var postSettingService: PostSettingService {
        return DefaultPostSettingsService()
    }
}
