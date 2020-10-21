//
//  TTContactsViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTContactsViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let cancelTrigger: Driver<Void>
        let cancelSearchTrigger: Driver<Void>
        let trigger: Observable<Void>
        let keywordTrigger: Driver<String>
        let selection: Driver<TTContactCellViewModel>
    }
    
    struct Output {
        let items: Driver<[TTContactCellViewModel]>
        let cancelSearchEvent: Driver<Void>
        let contactSelected: Driver<TTContact>
    }
    
    let keyword = BehaviorRelay<String>(value: "")
    let contactSelected = PublishSubject<TTContact>()
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTContactCellViewModel]>(value: [])
        
        let refresh = Observable.of(input.trigger, keyword.mapToVoid()).merge()
        
        input.keywordTrigger
            .skip(1)
            .throttle(DispatchTimeInterval.milliseconds(300))
            .distinctUntilChanged()
            .asObservable()
            .bind(to: keyword)
            .disposed(by: rx.disposeBag)
        
        refresh.flatMapLatest { [weak self] () -> Observable<[TTContactCellViewModel]> in
            guard let self = self else { return Observable.just([]) }
            
            return TTContactsManager.default.getContacts(with: self.keyword.value)
                .trackActivity(self.loading)
                .trackError(self.error)
                .map {
                    $0.map { contact -> TTContactCellViewModel in
                        return TTContactCellViewModel(contact: contact)
                    }
                }
        }.subscribe(onNext: { items in
            elements.accept(items)
        }, onError: { error in
            logError(error.localizedDescription)
        }).disposed(by: rx.disposeBag)
        
        let cancelSearchEvent = input.cancelSearchTrigger
        
        input.selection
            .map { $0.contact }
            .asObservable()
            .bind(to: contactSelected)
            .disposed(by: rx.disposeBag)
        
        return Output(
            items: elements.asDriver(),
            cancelSearchEvent: cancelSearchEvent,
            contactSelected: contactSelected.asDriver(onErrorJustReturn: TTContact())
        )
    }
}
