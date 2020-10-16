//
//  TTEventsViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/18.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum TTEventSegments: Int {
    case received, performed
    
    var title: String {
        switch self {
        case .received: return R.string.localizable.eventsReceivedSegmentTitle.key.localized()
        case .performed: return R.string.localizable.eventsPerformedSegmentTitle.key.localized()
        }
    }
}

enum TTEventsMode {
    case repository(repository: TTRepository)
    case user(user: TTUser)
}

class TTEventsViewModel: TTViewModel, TTViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let segmentSelection: Observable<TTEventSegments>
        let selection: Driver<TTEventsCellViewModel>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let imageUrl: Driver<URL?>
        let items: BehaviorRelay<[TTEventsCellViewModel]>
        let userSelected: Driver<TTUserViewModel>
        let repositorySelected: Driver<TTRepositoryViewModel>
        let hidesSegment: Driver<Bool>
    }
    
    let mode: BehaviorRelay<TTEventsMode>
    let segment = BehaviorRelay<TTEventSegments>(value: .received)
    let userSelected = PublishSubject<TTUser>()
    
    init(mode: TTEventsMode, provider: TTSwiftHubAPI) {
        self.mode = BehaviorRelay(value: mode)
        super.init(provider: provider)
        switch mode {
        case .repository(let repository):
            if let fullname = repository.fullname {
                analytics.log(.repositoryEvents(fullname: fullname))
            }
        case .user(let user):
            if let login = user.login {
                analytics.log(.userEvents(login: login))
            }
        }
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTEventsCellViewModel]>(value: [])
        
        input.segmentSelection.bind(to: segment).disposed(by: rx.disposeBag)
        
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<[TTEventsCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page = 1
            return self.request()
                .trackActivity(self.headerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(items)
        })
        .disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<[TTEventsCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page += 1
            return self.request()
                .trackActivity(self.footerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(elements.value + items)
        })
        .disposed(by: rx.disposeBag)
        
        let userDetails = userSelected.asDriver(onErrorJustReturn: TTUser())
            .map { user -> TTUserViewModel in
                return TTUserViewModel(user: user, provider: self.provider)
        }
        
//        let repositoryDetails = input.selection
//            .map { $0.event.repository }
//            .filterNil()
//            .map { repository -> TTRepositoryViewModel in
//                return TTRepositoryViewModel(
//        }
    }
    
    func request() -> Observable<[TTEventsCellViewModel]> {
        var request: Single<[TTEvent]>
        switch mode.value {
        case .repository(let repository):
            request = provider.repositoryEvents(owner: repository.owner?.login ?? "", repo: repository.name ?? "", page: page)
        case .user(let user):
            switch user.type {
            case .user:
                switch segment.value {
                case .performed: request = provider.userPerformedEvents(username: user.login ?? "", page: page)
                case .received: request = provider.userReceivedEvents(username: user.login ?? "", page: page)
                }
            case .organization: request = provider.organizationEvents(username: user.login ?? "", page: page)
            }
        }
        return request
            .trackActivity(loading)
            .trackError(error)
            .map {
                $0.map { event -> TTEventsCellViewModel in
                    let viewModel = TTEventsCellViewModel(event: event)
                    viewModel.userSelected.bind(to: self.userSelected).disposed(by: self.rx.disposeBag)
                    return viewModel
                }
        }
    }
}
