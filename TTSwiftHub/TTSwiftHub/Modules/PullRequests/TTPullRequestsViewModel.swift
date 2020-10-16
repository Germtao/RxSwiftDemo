//
//  TTPullRequestsViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum TTPullRequestSegments: Int {
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

class TTPullRequestsViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let segmentSelection: Observable<TTPullRequestSegments>
        let selection: Driver<TTPullRequestCellViewModel>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let items: BehaviorRelay<[TTPullRequestCellViewModel]>
        let pullRequestSelected: Driver<TTPullRequestViewModel>
        let userSelected: Driver<TTUserViewModel>
    }
    
    let repository: BehaviorRelay<TTRepository>
    let segment = BehaviorRelay<TTPullRequestSegments>(value: .open)
    let userSelected = PublishSubject<TTUser>()
    
    init(repository: TTRepository, provider: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTPullRequestCellViewModel]>(value: [])
        
        input.segmentSelection.bind(to: segment).disposed(by: rx.disposeBag)
        
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<[TTPullRequestCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page = 1
            return self.request().trackActivity(self.headerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(items)
        })
        .disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<[TTPullRequestCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page += 1
            return self.request().trackActivity(self.footerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(elements.value + items)
        })
        .disposed(by: rx.disposeBag)
        
        let navigationTitle = repository.map { $0.fullname ?? "" }.asDriver(onErrorJustReturn: "")
        let pullRequestSelected = input.selection.map { cellViewModel -> TTPullRequestViewModel in
            TTPullRequestViewModel(repository: self.repository.value, pullRequest: cellViewModel.pullRequest, provider: self.provider)
        }
        let userDetails = userSelected.asDriver(onErrorJustReturn: TTUser())
            .map { user -> TTUserViewModel in
                TTUserViewModel(user: user, provider: self.provider)
        }
        
        return Output(navigationTitle: navigationTitle,
                      items: elements,
                      pullRequestSelected: pullRequestSelected,
                      userSelected: userDetails)
    }
    
    func request() -> Observable<[TTPullRequestCellViewModel]> {
        let fullname = repository.value.fullname ?? ""
        let state = segment.value.state.rawValue
        return provider.pullRequests(fullname: fullname, state: state, page: page)
            .trackActivity(loading)
            .trackError(error)
            .map {
                $0.map {
                    let viewModel = TTPullRequestCellViewModel(pullRequest: $0)
                    viewModel.userSelected.bind(to: self.userSelected).disposed(by: self.rx.disposeBag)
                    return viewModel
                }
            }
    }
}
