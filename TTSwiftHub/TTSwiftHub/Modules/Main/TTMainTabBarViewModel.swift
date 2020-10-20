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
    
    let whatsNewManager: TTWhatsNewManager
    
    override init(provider: TTSwiftHubAPI) {
        whatsNewManager = TTWhatsNewManager.shared
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let tabBarItems = loggedIn.map { loggedIn -> [MainTabBarItem] in
            if loggedIn {
                return [.events, .search, .notifications, .settings]
            } else {
                return [.search, .notifications, .settings]
            }
        }
        .asDriver(onErrorJustReturn: [])
        
        let whatsNewItems = Driver.just(whatsNewManager.whatsNew())
        
        return Output(tabBarItems: tabBarItems,
                      openWhatsNew: whatsNewItems)
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
            
        default:
            return TTViewModel(provider: provider)
        }
    }
}
