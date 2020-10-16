//
//  TTRepoLanguageCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTRepoLanguageCellViewModel: TTDefaultTableViewCellViewModel {
    let language: TTLanguage
    
    init(language: TTLanguage) {
        self.language = language
        super.init()
        title.accept(language.displayName())
    }
}
