//
//  TTThemeViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class TTThemeViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let refresh: Observable<Void>
        let selection: Driver<TTThemeCellViewModel>
    }
    
    struct Output {
        let items: Driver<[TTThemeCellViewModel]>
        let selected: Driver<TTThemeCellViewModel>
    }
    
    func transform(input: Input) -> Output {
        let elements = input.refresh
            .map { TTThemeColor.allValues }
            .map { $0.map { TTThemeCellViewModel(theme: $0) } }
            .asDriver(onErrorJustReturn: [])
        
        let selected = input.selection
        selected.drive(onNext: { cellVm in
            let color = cellVm.theme
            let theme = TTThemeType.currentTheme().withColor(color: color)
            themeService.switch(theme)
            analytics.log(.appTheme(color: color.title))
            analytics.set(.colorTheme(value: color.title))
        }).disposed(by: rx.disposeBag)
        
        return Output(items: elements, selected: selected)
    }
}
