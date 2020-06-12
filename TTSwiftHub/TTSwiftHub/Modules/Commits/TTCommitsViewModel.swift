//
//  TTCommitsViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/12.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTCommitsViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection: Driver<TTCommitCellViewModel>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let items: BehaviorRelay<[TTCommitCellViewModel]>
        let commitSelected: Driver<URL?>
        let userSelected: Driver<TTUserViewModel>
    }
    
    let repository: BehaviorRelay<TTRepository>
    let userSelected = PublishSubject<TTUser>()
    
    init(repository: TTRepository, provider: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTCommitCellViewModel]>(value: [])
        
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<[TTCommitCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page = 1
            return self.request().trackActivity(self.headerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(items)
        })
        .disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<[TTCommitCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page += 1
            return self.request().trackActivity(self.footerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(elements.value + items)
        })
        .disposed(by: rx.disposeBag)
        
        let navigationTitle = repository.map { repository -> String in
            repository.fullname ?? ""
        }.asDriver(onErrorJustReturn: "")
        
        let commitSelected = input.selection.map { cellViewModel -> URL? in
            cellViewModel.commit.htmlUrl?.url
        }
        
        let userDetails = userSelected.asDriver(onErrorJustReturn: TTUser())
            .map { user -> TTUserViewModel in
                return TTUserViewModel(user: user, provider: self.provider)
            }
        
        return Output(navigationTitle: navigationTitle,
                      items: elements,
                      commitSelected: commitSelected,
                      userSelected: userDetails)
    }
    
    func request() -> Observable<[TTCommitCellViewModel]> {
        let fullname = repository.value.fullname ?? ""
        return provider.commits(fullname: fullname, page: page)
            .trackActivity(loading)
            .trackError(error)
            .map {
                $0.map { commit -> TTCommitCellViewModel in
                    let viewModel = TTCommitCellViewModel(commit: commit)
                    viewModel.userSelected.bind(to: self.userSelected).disposed(by: self.rx.disposeBag)
                    return viewModel
                }
            }
    }
}
