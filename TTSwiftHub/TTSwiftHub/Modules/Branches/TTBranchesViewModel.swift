//
//  TTBranchesViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/12.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTBranchesViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let selection: Driver<TTBranchCellViewModel>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let items: BehaviorRelay<[TTBranchCellViewModel]>
    }
    
    let repository: BehaviorRelay<TTRepository>
    let branchSelected = PublishSubject<TTBranch>()
    
    init(repository: TTRepository, provider: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTBranchCellViewModel]>(value: [])
        
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<[TTBranchCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page = 1
            return self.request().trackActivity(self.headerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(items)
        })
        .disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<[TTBranchCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            self.page += 1
            return self.request().trackActivity(self.footerLoading)
        }
        .subscribe(onNext: { items in
            elements.accept(elements.value + items)
        })
        .disposed(by: rx.disposeBag)
        
        let navigationTitle = repository.map { $0.fullname ?? "" }.asDriver(onErrorJustReturn: "")
        
        input.selection.asObservable().map { $0.branch }.bind(to: branchSelected).disposed(by: rx.disposeBag)
        
        return Output(navigationTitle: navigationTitle, items: elements)
    }
    
    func request() -> Observable<[TTBranchCellViewModel]> {
        let fullname = repository.value.fullname ?? ""
        return provider.branches(fullname: fullname, page: page)
            .trackActivity(loading)
            .trackError(error)
            .map {
                $0.map { branch -> TTBranchCellViewModel in
                    return TTBranchCellViewModel(branch: branch)
                }
        }
    }
}
