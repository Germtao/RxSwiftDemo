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
        let selection: Driver<TTRepositoryCellViewModel>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let items: BehaviorRelay<[TTRepositoryCellViewModel]>
        let imageUrl: Driver<URL?>
        let textDidBeginEditing: Driver<Void>
        let dismissKeyboard: Driver<Void>
        let repositorySelected: Driver<TTRepositoryViewModel>
    }
    
    let mode: BehaviorRelay<TTRepositoriesMode>
    
    init(mode: TTRepositoriesMode, provider: TTSwiftHubAPI) {
        self.mode = BehaviorRelay(value: mode)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTRepositoryCellViewModel]>(value: [])
        let dismissKeyboard = input.selection.mapToVoid()
        
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<[TTRepositoryCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page = 1
            return self.request().trackActivity(self.headerLoading)
        }.subscribe(onNext: { items in
            elements.accept(items)
        }).disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<[TTRepositoryCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page += 1
            return self.request().trackActivity(self.footerLoading)
        }.subscribe(onNext: { items in
            elements.accept(elements.value + items)
        }).disposed(by: rx.disposeBag)
        
        let textDidBeginEditing = input.textDidBeginEditing
        
        let repositoryDetails = input.selection.map {
            TTRepositoryViewModel(repository: $0.repository, provider: self.provider)
        }
        
        let navigationTitle = mode.map { mode -> String in
            switch mode {
            case .userRepositories: return R.string.localizable.repositoriesRepositoriesNavigationTitle.key.localized()
            case .userStarredRepositories: return R.string.localizable.repositoriesStarredNavigationTitle.key.localized()
            case .userWatchingRepositories: return "Watching"
            case .forks: return R.string.localizable.repositoriesForksNavigationTitle.key.localized()
            }
        }.asDriver(onErrorJustReturn: "")
        
        let imageUrl = mode.map { mode -> URL? in
            switch mode {
            case .userRepositories(let user),
                 .userStarredRepositories(let user),
                 .userWatchingRepositories(let user):
                return user.avatarUrl?.url
            case .forks(let repository):
                return repository.owner?.avatarUrl?.url
            }
        }.asDriver(onErrorJustReturn: nil)
        
        return Output(navigationTitle: navigationTitle,
                      items: elements,
                      imageUrl: imageUrl,
                      textDidBeginEditing: textDidBeginEditing,
                      dismissKeyboard: dismissKeyboard,
                      repositorySelected: repositoryDetails)
    }
    
    func request() -> Observable<[TTRepositoryCellViewModel]> {
        var request: Single<[TTRepository]>
        switch mode.value {
        case .userRepositories(let user):
            request = provider.userRepositories(username: user.login ?? "", page: page)
        case .userStarredRepositories(let user):
            request = provider.userStarredRepositories(username: user.login ?? "", page: page)
        case .userWatchingRepositories(let user):
            request = provider.userWatchingRepositories(username: user.login ?? "", page: page)
        case .forks(let repository):
            request = provider.forks(fullname: repository.fullname ?? "", page: page)
        }
        return request
            .trackActivity(loading)
            .trackError(error)
            .map { $0.map { TTRepositoryCellViewModel(repository: $0) }}
    }
}
