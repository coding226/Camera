//
//  PostInteractor.swift
//  Post
//
//  Created by Erik Kamalov on 11/12/20.
//

import Foundation

final class PostInteractor: InteractorInterface {

    weak var presenter: PostPresenterInteractorInterface!
    
    private var postSettingService: PostSettingService

    public init(postSettingService: PostSettingService) {
        self.postSettingService = postSettingService
    }
}

extension PostInteractor: PostInteractorPresenterInterface {
    func settingsService() -> PostSettingService {
        postSettingService
    }
    
    func mainItem() -> [Item] {
       return [Item(title: "Public", subtitle: "Everyone in the world will see this", imageName: "publicGlobus"),
               Item(title: "Friends", subtitle: "All the friends you follow will see this", imageName: "friends")]
    }
    
    func allRecent() -> [Item] {
         Item.stubs.shuffled()
    }
    
    func allMyFriends() -> [Item] {
         Item.stubs.shuffled()
    }
}


//App.shared.postSettingService
