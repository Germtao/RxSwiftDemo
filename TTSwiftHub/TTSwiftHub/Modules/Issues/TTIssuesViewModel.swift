//
//  TTIssuesViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/12.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum TTIssueSegments: Int {
    case open, closed
    
    var title: String {
        switch self {
        case .open: return R.string.localizable.issuesOpenSegmentTitle.key.localized()
        case .closed: return R.string.localizable.issuesClosedSegmentTitle.key.localized()
        }
    }
    
    var state: TTState {
        switch self {
        case .open: return .open
        case .closed: return .closed
        }
    }
}

class TTIssuesViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let segmentSelection: Observable<TTIssueSegments>
        let selection: Driver<TTIssueCellViewModel>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let imageUrl: Driver<URL?>
        let items: BehaviorRelay<[TTIssueCellViewModel]>
        let userSelected: Driver<TTUserViewModel>
        let issueSelected: Driver<TTIssueViewModel>
    }
    
    let repository: BehaviorRelay<TTRepository>
    let segment = BehaviorRelay<TTIssueSegments>(value: .open)
    let userSelected = PublishSubject<TTUser>()
    
    init(repository: TTRepository, prodiver: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        super.init(provider: provider)
        if let fullname = repository.fullname {
            analytics.log(.issues(fullname: fullname))
        }
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTIssueCellViewModel]>(value: [])
        
        input.segmentSelection.bind(to: segment).disposed(by: rx.disposeBag)
        
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<[TTIssueCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page = 1
            return self.request().trackActivity(self.headerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(items)
        })
        .disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<[TTIssueCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page += 1
            return self.request().trackActivity(self.footerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(elements.value + items)
        })
        .disposed(by: rx.disposeBag)
        
        let userDetails = userSelected.asDriver(onErrorJustReturn: TTUser())
            .map { user -> TTUserViewModel in
                return TTUserViewModel(user: user, provider: self.provider)
        }
        
        let navigationTitle = repository.map { _ -> String in
            R.string.localizable.eventsNavigationTitle.key.localized()
        }.asDriver(onErrorJustReturn: "")
        
        let imageUrl = repository.map { repository -> URL? in
            repository.owner?.avatarUrl?.url
        }.asDriver(onErrorJustReturn: nil)
        
        let issueSelected = input.selection.map { cellViewModel -> TTIssueViewModel in
            return TTIssueViewModel(repository: self.repository.value,
                                    issue: cellViewModel.issue,
                                    provider: self.provider)
        }
        
        return Output(navigationTitle: navigationTitle,
                      imageUrl: imageUrl,
                      items: elements,
                      userSelected: userDetails,
                      issueSelected: issueSelected)
    }
    
    func request() -> Observable<[TTIssueCellViewModel]> {
        let fullname = repository.value.fullname ?? ""
        let state = segment.value.state.rawValue
        return provider.issues(fullname: fullname, state: state, page: page)
            .trackActivity(loading)
            .trackError(error)
            .map {
                $0.map { issue -> TTIssueCellViewModel in
                    let viewModel = TTIssueCellViewModel(issue: issue)
                    viewModel.userSelected.bind(to: self.userSelected).disposed(by: self.rx.disposeBag)
                    return viewModel
                }
            }
    }
}
