//
//  TTLanguageViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Localize_Swift

class TTLanguageViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let trigger: Observable<Void>
        let saveTrigger: Driver<Void>
        let selection: Driver<TTLanguageCellViewModel>
    }
    
    struct Output {
        let items: Driver<[TTLanguageCellViewModel]>
        let saved: Driver<Void>
    }
    
    private var currentLanguage: BehaviorRelay<String>
    
    override init(provider: TTSwiftHubAPI) {
        currentLanguage = BehaviorRelay(value: Localize.currentLanguage())
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTLanguageCellViewModel]>(value: [])
        
        input.trigger.map { () -> [TTLanguageCellViewModel] in
            let languages = Localize.availableLanguages(true)
            return languages.map { language -> TTLanguageCellViewModel in
                return TTLanguageCellViewModel(language: language)
            }
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        let saved = input.saveTrigger.map { () -> Void in
            let language = self.currentLanguage.value
            Localize.setCurrentLanguage(language)
            analytics.log(.appLanguage(language: language))
        }
        
        input.selection.drive(onNext: { cellVm in
            self.currentLanguage.accept(cellVm.language)
        }).disposed(by: rx.disposeBag)
        
        return Output(
            items: elements.asDriver(),
            saved: saved.asDriver(onErrorJustReturn:())
        )
    }
}
