//
//  TTLanguagesViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTLanguagesViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let trigger: Observable<Void>
        let saveTrigger: Observable<Void>
        let keywordTrigger: Driver<String>
        let allTrigger: Driver<Void>
        let selection: Driver<TTLanguageSectionItem>
    }
    
    struct Output {
        let items: Driver<[TTLanguageSection]>
        let selectedRow: Driver<IndexPath?>
        let dismiss: Driver<Void>
    }
    
    let currentLanguage: BehaviorRelay<TTLanguage?>
    let languages: BehaviorRelay<[TTLanguage]>
    let selectedIndexPath: IndexPath?
    
    init(currentLanguage: TTLanguage?, languages: [TTLanguage], provider: TTSwiftHubAPI) {
        self.currentLanguage = BehaviorRelay(value: currentLanguage)
        self.languages = BehaviorRelay(value: languages)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTLanguageSection]>(value: [])
        
        let selectedLanguage = BehaviorRelay<TTLanguage?>(value: nil)
        
        Observable.combineLatest(languages, input.keywordTrigger.asObservable())
            .map { (languages, keyword) -> [TTLanguageSection] in
                var elements: [TTLanguageSection] = []
                
                let languages = languages.filtered({ language -> Bool in
                    if keyword.isEmpty { return true }
                    return language.displayName().contains(keyword, caseSensitive: false)
                }) { language -> TTLanguageSectionItem in
                    let cellViewModel = TTRepoLanguageCellViewModel(language: language)
                    return TTLanguageSectionItem.languageItem(cellViewModel: cellViewModel)
                }
                
                let title = R.string.localizable.languagesAllSectionTitle.key.localized()
                elements.append(.languages(title: title, items: languages))
                return elements
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        let saved = input.saveTrigger.map {
            let language = selectedLanguage.value
            self.currentLanguage.accept(language)
            language?.save()
            if let name = language?.name {
                analytics.log(.repoLanguage(language: name))
            }
        }
        
        let allTriggered = input.allTrigger
        allTriggered.drive(onNext: { () in
            self.currentLanguage.accept(nil)
            TTLanguage.removeCurrentLanguage()
            analytics.log(.repoLanguage(language: "All"))
        })
        .disposed(by: rx.disposeBag)
        
        input.selection.drive(onNext: { item in
            switch item {
            case .languageItem(let cellViewModel):
                selectedLanguage.accept(cellViewModel.language)
            }
        })
        .disposed(by: rx.disposeBag)
        
        let selectedRow = elements.map { items -> IndexPath? in
            guard let currentLanguage = self.currentLanguage.value else { return nil }
            for (section, item) in items.enumerated() {
                for(row, item) in item.items.enumerated() {
                    switch item {
                    case .languageItem(let cellViewModel):
                        if currentLanguage == cellViewModel.language {
                            return IndexPath(row: row, section: section)
                        }
                    }
                }
            }
            return nil
        }.asDriver(onErrorJustReturn: nil)
        
        let dismiss = Observable.of(saved.asObservable(), allTriggered.asObservable()).merge()
        
        return Output(items: elements.asDriver(),
                      selectedRow: selectedRow,
                      dismiss: dismiss.asDriver(onErrorJustReturn: ()))
    }
    
}
