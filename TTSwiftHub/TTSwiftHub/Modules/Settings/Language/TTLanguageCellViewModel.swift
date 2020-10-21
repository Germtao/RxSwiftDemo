//
//  TTLanguageCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation

class TTLanguageCellViewModel: TTDefaultTableViewCellViewModel {
    let language: String
    
    init(language: String) {
        self.language = language
        super.init()
        title.accept(displayName(for: language))
    }
}

func displayName(for language: String) -> String {
    let local = Locale(identifier: language)
    if let displayName = local.localizedString(forIdentifier: language) {
        return displayName.capitalized(with: local)
    }
    return String()
}
