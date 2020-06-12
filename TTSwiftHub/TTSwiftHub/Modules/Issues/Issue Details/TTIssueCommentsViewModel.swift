//
//  TTIssueCommentsViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/12.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTIssueCommentsViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let sendSelected: Observable<String>
    }
    
    struct Output {
        let items: Observable<[TTComment]>
    }
    
    let repository: BehaviorRelay<TTRepository>
    let issue: BehaviorRelay<TTIssue>
    
    init(repository: TTRepository, issue: TTIssue, provider: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        self.issue = BehaviorRelay(value: issue)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let comments = input.headerRefresh.flatMapLatest { () -> Observable<[TTComment]> in
            let fullname = self.repository.value.fullname ?? ""
            let issueNumber = self.issue.value.number ?? 0
            return self.provider.issueComments(fullname: fullname, number: issueNumber, page: self.page)
                .trackActivity(self.loading)
                .trackError(self.error)
        }
        
        input.sendSelected.subscribe(onNext: { text in
            logDebug(text)
        })
        .disposed(by: rx.disposeBag)
        
        return Output(items: comments)
    }
}
