//
//  TTContentsViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTContentsViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let headerRefresh: Observable<Void>
        let selection: Driver<TTContentCellViewModel>
        let openInWebSelection: Observable<Void>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let items: BehaviorRelay<[TTContentCellViewModel]>
        let openContents: Driver<TTContentsViewModel>
        let openUrl: Driver<URL?>
        let openSource: Driver<TTSourceViewModel>
    }
    
    let repository: BehaviorRelay<TTRepository>
    let content: BehaviorRelay<TTContent?>
    let ref: BehaviorRelay<String?>
    
    init(repository: TTRepository, content: TTContent?, ref: String?, provider: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        self.content = BehaviorRelay(value: content)
        self.ref = BehaviorRelay(value: ref)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTContentCellViewModel]>(value: [])
        
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<[TTContentCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            
            return self.request()
                .trackActivity(self.loading)
        }.subscribe(onNext: { items in
            elements.accept(items)
        }).disposed(by: rx.disposeBag)
        
        let openContents = input.selection
            .map { $0.content }
            .filter { $0.type == .dir }
            .map { content -> TTContentsViewModel in
                let repository = self.repository.value
                let ref = self.ref.value
                let viewModel = TTContentsViewModel(repository: repository, content: content, ref: ref, provider: self.provider)
                return viewModel
            }
        
        let openUrl = input.openInWebSelection
            .map { self.content.value?.htmlUrl?.url }
            .filterNil()
            .asDriver(onErrorJustReturn: nil)
        
        let openSource = input.selection
            .map { $0.content }
            .filter { $0.type != .dir }
            .map { content -> TTSourceViewModel in
                return TTSourceViewModel(content: content, provider: self.provider)
            }
        
        let navigationTitle = content.map { content -> String in
            return content?.name ?? self.repository.value.fullname ?? ""
        }.asDriver(onErrorJustReturn: "")
        
        return Output(
            navigationTitle: navigationTitle,
            items: elements,
            openContents: openContents,
            openUrl: openUrl,
            openSource: openSource
        )
    }
    
    func request() -> Observable<[TTContentCellViewModel]> {
        let fullname = repository.value.fullname ?? ""
        let path = content.value?.path ?? ""
        let ref = self.ref.value
        
        return provider.contents(fullname: fullname, path: path, ref: ref)
            .trackActivity(loading)
            .trackError(error)
            .map {
                $0.sorted { (lhs, rhs) -> Bool in
                    if lhs.type == rhs.type {
                        return lhs.name?.lowercased() ?? "" < rhs.name?.lowercased() ?? ""
                    } else {
                        return lhs.type > rhs.type
                    }
                }.map { TTContentCellViewModel(content: $0) }
            }
    }
}
