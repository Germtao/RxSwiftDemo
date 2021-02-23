//
//  TTUsersViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/9.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum TTUsersMode {
    case followers(user: TTUser)
    case following(user: TTUser)
    
    case watchers(repository: TTRepository)
    case stars(repository: TTRepository)
    case contributors(repository: TTRepository)
}

class TTUsersViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let keywordTrigger: Driver<String>
        let textDidBeginEditing: Driver<Void>
        let selection: Driver<TTUserCellViewModel>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let items: BehaviorRelay<[TTUserCellViewModel]>
        let imageUrl: Driver<URL?>
        let textDidBeginEditing: Driver<Void>
        let dismissKeyboard: Driver<Void>
        let userSelected: Driver<TTUserViewModel>
    }
    
    let mode: BehaviorRelay<TTUsersMode>
    
    init(mode: TTUsersMode, provider: TTSwiftHubAPI) {
        self.mode = BehaviorRelay(value: mode)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTUserCellViewModel]>(value: [])
        let dismissKeyboard = input.selection.mapToVoid()
        
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<[TTUserCellViewModel]> in
            guard let _self = self else { return Observable.just([]) }
            _self.page = 1
            return _self.request()
                .trackActivity(_self.headerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(items)
        })
        .disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<[TTUserCellViewModel]> in
            guard let _self = self else { return Observable.just([]) }
            _self.page += 1
            return _self.request()
                .trackActivity(_self.footerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(elements.value + items)
        })
        .disposed(by: rx.disposeBag)
        
        let textDidBeginEditing = input.textDidBeginEditing
        
        let userDetails = input.selection.map { cellViewModel -> TTUserViewModel in
            let user = cellViewModel.user
            return TTUserViewModel(user: user, provider: self.provider)
        }
        
        let navigationTitle = mode.map { mode -> String in
            switch mode {
            case .followers: return R.string.localizable.usersFollowersNavigationTitle.key.localized()
            case .following: return R.string.localizable.usersFollowingNavigationTitle.key.localized()
            case .watchers: return R.string.localizable.usersWatchersNavigationTitle.key.localized()
            case .stars: return R.string.localizable.usersStargazersNavigationTitle.key.localized()
            case .contributors: return R.string.localizable.usersContributorsNavigationTitle.key.localized()
            }
        }.asDriver(onErrorJustReturn: "")
        
        let imageUrl = mode.map { mode -> URL? in
            switch mode {
            case .followers(let user),
                 .following(let user):
                return user.avatarUrl?.url
            case .watchers(let repository),
                 .stars(let repository),
                 .contributors(let repository):
                return repository.owner?.avatarUrl?.url
            }
        }.asDriver(onErrorJustReturn: nil)
        
        return Output(
            navigationTitle: navigationTitle,
            items: elements,
            imageUrl: imageUrl,
            textDidBeginEditing: textDidBeginEditing,
            dismissKeyboard: dismissKeyboard,
            userSelected: userDetails
        )
    }
    
    func request() -> Observable<[TTUserCellViewModel]> {
        var request: Single<[TTUser]>
        switch mode.value {
        case .followers(let user):
            request = provider.userFollowers(username: user.login ?? "", page: page)
        case .following(let user):
            request = provider.userFollowing(username: user.login ?? "", page: page)
        case .watchers(let repository):
            request = provider.watchers(fullname: repository.fullname ?? "", page: page)
        case .stars(let repository):
            request = provider.stargazers(fullname: repository.fullname ?? "", page: page)
        case .contributors(let repository):
            request = provider.contributors(fullname: repository.fullname ?? "", page: page)
        }
        return request
            .trackActivity(loading)
            .trackError(error)
            .map { $0.map { TTUserCellViewModel(user: $0) } }
    }
}
