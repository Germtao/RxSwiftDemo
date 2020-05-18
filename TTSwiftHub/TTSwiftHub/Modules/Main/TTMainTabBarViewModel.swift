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

class TTMainTabBarViewModel: TTViewModel, TTViewModelType {
    
    struct Input {
        let whatsNewTrigger: Observable<Void>
    }
    
    struct Output {
        let tabBarItems: Driver<[MainTabBarItem]>
//        let openWhatsNew: Driver<What>
    }
    
    override init(provider: TTSwiftHubAPI) {
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
        
        return Output(tabBarItems: tabBarItems)
    }
    
    func viewModel(for tabBarItem: MainTabBarItem) -> TTViewModel {
        switch tabBarItem {
        case .search: return TTSearchViewModel(provider: provider)
        default:
            return TTViewModel(provider: provider)
        }
    }
}
