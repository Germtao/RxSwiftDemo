//
//  TTRepositoriesViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/26.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum TTRepositoriesMode {
    case userRepositories(user: TTUser)
    case userStarredRepositories(user: TTUser)
    case userWatchingRepositories(user: TTUser)
    
    case forks(repository: TTRepository)
}

class TTRepositoriesViewModel: TTViewModel, TTViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let keywordTrigger: Driver<String>
        let textDidBeginEditing: Driver<Void>
//        let selection: Driver<>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
//        let items: BehaviorRelay<[]>
        
    }
    
    let mode: BehaviorRelay<TTRepositoriesMode>
    
    init(mode: TTRepositoriesMode, provider: TTSwiftHubAPI) {
        self.mode = BehaviorRelay(value: mode)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        return Output(navigationTitle: Driver<String>())
    }
}
