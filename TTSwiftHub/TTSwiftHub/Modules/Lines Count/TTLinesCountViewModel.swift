//
//  TTLinesCountViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/22.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTLinesCountViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let refresh: Observable<Void>
    }
    
    struct Output {
        let items: Driver<[TTLanguageLines]>
    }
    
    let repository: BehaviorRelay<TTRepository>
    
    init(repository: TTRepository, provider: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        super.init(provider: provider)
        
        if let fullname = repository.fullname {
            analytics.log(.linesCount(fullname: fullname))
        }
    }
    
    func transform(input: Input) -> Output {
        let elements = input.refresh.flatMapLatest { () -> Observable<[TTLanguageLines]> in
            let fullname = self.repository.value.fullname ?? ""
            return self.provider.numberOfLines(fullname: fullname)
                .trackActivity(self.loading)
                .trackError(self.error)
        }.asDriver(onErrorJustReturn: [])
        
        return Output(items: elements)
    }
    
    func color(for language: String) -> String? {
        guard let language = repository.value.languages?.languages.filter({ $0.name == language }).first else { return nil }
        return language.color
    }
}
