//
//  TTNotificationsViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/20.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum TTNotificationsMode {
    case mine
    case repository(repository: TTRepository)
}

enum TTNotificationSegment: Int {
    case unread, participating, all
    
    var title: String {
        switch self {
        case .unread: return R.string.localizable.notificationsUnreadSegmentTitle.key.localized()
        case .participating: return R.string.localizable.notificationsParticipatingSegmentTitle.key.localized()
        case .all: return R.string.localizable.notificationsAllSegmentTitle.key.localized()
        }
    }
}

class TTNotificationsViewModel: TTViewModel, TTViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let segmentSelection: Observable<TTNotificationSegment>
        let markAsReadSelection: Observable<Void>
        let selection: Driver<TTNotificationCellViewModel>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let imageUrl: Driver<URL?>
        let items: BehaviorRelay<[TTNotificationCellViewModel]>
        let userSelected: Driver<TTUserViewModel>
        let repositorySelected: Driver<TTRepositoryViewModel>
        let markAsReadSelected: Driver<Void>
    }
    
    let mode: BehaviorRelay<TTNotificationsMode>
    let all = BehaviorRelay(value: false)
    let participating = BehaviorRelay(value: false)
    let userSelected = PublishSubject<TTUser>()
    
    init(mode: TTNotificationsMode, provider: TTSwiftHubAPI) {
        self.mode = BehaviorRelay(value: mode)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        input.segmentSelection.map { $0 == .all }.bind(to: all).disposed(by: rx.disposeBag)
        input.segmentSelection.map { $0 == .participating }.bind(to: participating).disposed(by: rx.disposeBag)
        
        let elements = BehaviorRelay<[TTNotificationCellViewModel]>(value: [])
        
        let markAsRead = input.markAsReadSelection.flatMapLatest { () -> Observable<Void> in
            return self.markAsReadRequest()
        }.asDriver(onErrorJustReturn: ())
        
        let refresh = Observable.of(input.headerRefresh, input.segmentSelection.mapToVoid(), markAsRead.asObservable()).merge()
        refresh.flatMapLatest { [weak self] () -> Observable<[TTNotificationCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page = 1
            return self.request()
                .trackActivity(self.headerLoading)
        }.subscribe { items in
            elements.accept(items)
        }.disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<[TTNotificationCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page += 1
            return self.request()
                .trackActivity(self.footerLoading)
        }.subscribe { items in
            elements.accept(elements.value + items)
        }.disposed(by: rx.disposeBag)
        
        let userDetails = userSelected.asDriver(onErrorJustReturn: TTUser())
            .map { user -> TTUserViewModel in
                return TTUserViewModel(user: user, provider: self.provider)
            }
        
        let repositoryDetails = input.selection.map { $0.notification.repository }.filterNil()
            .map { repository -> TTRepositoryViewModel in
                return TTRepositoryViewModel(repository: repository, provider: self.provider)
            }
        
        let navigationTitle = mode.map { mode -> String in
            return R.string.localizable.notificationsNavigationTitle.key.localized()
        }.asDriver(onErrorJustReturn: "")
        
        let imageUrl = mode.map { mode -> URL? in
            switch mode {
            case .mine: return nil
            case .repository(let repository): return repository.owner?.avatarUrl?.url
            }
        }.asDriver(onErrorJustReturn: nil)
        
        return Output(navigationTitle: navigationTitle,
                      imageUrl: imageUrl,
                      items: elements,
                      userSelected: userDetails,
                      repositorySelected: repositoryDetails,
                      markAsReadSelected: markAsRead)
    }
    
    func request() -> Observable<[TTNotificationCellViewModel]> {
        var request: Single<[TTNotification]>
        
        switch mode.value {
        case .mine:
            request = provider.notifications(all: all.value, participating: participating.value, page: page)
        case .repository(let repository):
            request = provider.repositoryNotifications(fullname: repository.fullname ?? "", all: all.value, participating: participating.value, page: page)
        }
        
        return request
            .trackActivity(loading)
            .trackError(error)
            .map {
                $0.map { notification -> TTNotificationCellViewModel in
                    let viewModel = TTNotificationCellViewModel(with: notification)
                    viewModel.userSelected.bind(to: self.userSelected).disposed(by: self.rx.disposeBag)
                    return viewModel
                }
            }
    }
    
    func markAsReadRequest() -> Observable<Void> {
        var request: Single<Void>
        
        switch mode.value {
        case .mine:
            request = provider.markAsReadNotifications()
        case .repository(let repository):
            request = provider.markAsReadRepositoryNotifications(fullname: repository.fullname ?? "")
        }
        
        return request
            .trackActivity(loading)
            .trackError(error)
    }
}
