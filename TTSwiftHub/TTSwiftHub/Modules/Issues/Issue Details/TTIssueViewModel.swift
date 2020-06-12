//
//  TTIssueViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/12.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MessageKit

class TTIssueViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let userSelected: Observable<TTUser>
        let mentionSelected: Observable<String>
    }
    
    struct Output {
        let userSelected: Observable<TTUserViewModel>
    }
    
    let repository: BehaviorRelay<TTRepository>
    let issue: BehaviorRelay<TTIssue>
    
    init(repository: TTRepository, issue: TTIssue, provider: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        self.issue = BehaviorRelay(value: issue)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let userSelected = Observable.of(input.userSelected, input.mentionSelected.map {
            var user = TTUser()
            user.login = $0.removingPrefix("@")
            return user
        })
        .merge()
        .map {
            return TTUserViewModel(user: $0, provider: self.provider)
        }
        
        return Output(userSelected: userSelected)
    }
    
    func issueCommentsViewModel() -> TTIssueCommentsViewModel {
        return TTIssueCommentsViewModel(repository: repository.value, issue: issue.value, provider: provider)
    }
}
