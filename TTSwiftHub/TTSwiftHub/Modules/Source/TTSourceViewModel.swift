//
//  TTSourceViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Highlightr

class TTSourceViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let trigger: Observable<Void>
        let historySelection: Observable<Void>
        let themesSelection: Observable<Void>
        let languagesSelection: Observable<Void>
        let themeSelected: Observable<String>
        let languageSelected: Observable<String>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let themes: Driver<[String]>
        let selectedThemeIndex: Driver<Int?>
        let languages: Driver<[String]>
        let selectedLanguageIndex: Driver<Int?>
        let historySelected: Driver<URL>
        let highlightedCode: Observable<NSAttributedString?>
        let themeBackgroundColor: Observable<UIColor?>
        let hidesThemes: Driver<Bool>
        let hidesLanguages: Driver<Bool>
    }
    
    let highlightr = Highlightr()
}
