//
//  TTMainTabBarViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WhatsNewKit

class TTMainTabBarViewModel: TTViewModel, TTViewModelType {
    
    struct Input {
        let whatsNewTrigger: Observable<Void>
    }
    
    struct Output {
        let tabBarItems: Driver<[MainTabBarItem]>
        let openWhatsNew: Driver<WhatsNewBlock>
    }
    
    let authorized: Bool
    let whatsNewManager: TTWhatsNewManager
    
    init(authorized: Bool, provider: TTSwiftHubAPI) {
        self.authorized = authorized
        whatsNewManager = TTWhatsNewManager.shared
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let tabBarItems = Observable.just(authorized).map { authorized -> [MainTabBarItem] in
            if authorized {
                return [.events, .search, .notifications, .settings]
            } else {
                return [.search, .login, .settings]
            }
        }
        .asDriver(onErrorJustReturn: [])
        
        let whatsNewItems = input.whatsNewTrigger.take(1).map { self.whatsNewManager.whatsNew() }
        
        return Output(tabBarItems: tabBarItems,
                      openWhatsNew: whatsNewItems.asDriverOnErrorJustComplete())
    }
    
    func viewModel(for tabBarItem: MainTabBarItem) -> TTViewModel {
        switch tabBarItem {
        case .search:
            return TTSearchViewModel(provider: provider)
        case .events:
            let user = TTUser.currentUser()!
            return TTEventsViewModel(mode: .user(user: user), provider: provider)
        case .notifications:
            return TTNotificationsViewModel(mode: .mine, provider: provider)
        case .settings:
            return TTSettingsViewModel(provider: provider)
        case .login:
            return TTLoginViewModel(provider: provider)
        }
    }
}
