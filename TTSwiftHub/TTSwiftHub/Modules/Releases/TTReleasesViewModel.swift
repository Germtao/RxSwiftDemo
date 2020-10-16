//
//  TTReleasesViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTReleasesViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection: Driver<TTReleaseCellViewModel>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let items: BehaviorRelay<[TTReleaseCellViewModel]>
        let releaseSelected: Driver<URL>
        let userSelected: Driver<TTUserViewModel>
    }
    
    let repository: BehaviorRelay<TTRepository>
    let userSelected = PublishSubject<TTUser>()
    
    init(repository: TTRepository, provider: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTReleaseCellViewModel]>(value: [])
        
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<[TTReleaseCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page = 1
            return self.request().trackActivity(self.headerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(items)
        })
        .disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<[TTReleaseCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page += 1
            return self.request().trackActivity(self.footerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(elements.value + items)
        })
        .disposed(by: rx.disposeBag)
        
        let navigationTitle = repository.map { $0.fullname ?? "" }.asDriver(onErrorJustReturn: "")
        let releaseSelected = input.selection.map { $0.release.htmlUrl?.url }.filterNil()
        let userDetails = userSelected.asDriver(onErrorJustReturn: TTUser())
            .map { TTUserViewModel(user: $0, provider: self.provider) }
        
        return Output(navigationTitle: navigationTitle,
                      items: elements,
                      releaseSelected: releaseSelected,
                      userSelected: userDetails)
    }
    
    func request() -> Observable<[TTReleaseCellViewModel]> {
        let fullname = repository.value.fullname ?? ""
        return provider.releases(fullname: fullname, page: page)
            .trackActivity(loading)
            .trackError(error)
            .map {
                $0.map { release -> TTReleaseCellViewModel in
                    let viewModel = TTReleaseCellViewModel(release: release)
                    viewModel.userSelected.bind(to: self.userSelected).disposed(by: self.rx.disposeBag)
                    return viewModel
                }
            }
    }
}
