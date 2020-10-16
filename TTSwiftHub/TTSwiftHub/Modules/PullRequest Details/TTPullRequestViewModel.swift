//
//  TTPullRequestViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MessageKit

class TTPullRequestViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let userSelected: Observable<TTUser>
        let mentionSelected: Observable<String>
    }
    
    struct Output {
        let userSelected: Observable<TTUserViewModel>
    }
    
    let repository: BehaviorRelay<TTRepository>
    let pullRequest: BehaviorRelay<TTPullRequest>
    
    init(repository: TTRepository, pullRequest: TTPullRequest, provider: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        self.pullRequest = BehaviorRelay(value: pullRequest)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let userSelected = Observable.of(input.userSelected, input.mentionSelected.map({ mention -> TTUser in
            var user = TTUser()
            user.login = mention.removingPrefix("@")
            return user
        })).merge()
            .map { user -> TTUserViewModel in
                TTUserViewModel(user: user, provider: self.provider)
        }
        
        return Output(userSelected: userSelected)
    }
}
