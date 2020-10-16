//
//  TTLanguageSection.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxDataSources

enum TTLanguageSectionItem {
    case languageItem(cellViewModel: TTRepoLanguageCellViewModel)
}

enum TTLanguageSection {
    case languages(title: String, items: [TTLanguageSectionItem])
}

extension TTLanguageSection: SectionModelType {
    typealias Item = TTLanguageSectionItem
    
    var title: String {
        switch self {
        case .languages(let title, _): return title
        }
    }
    
    var items: [TTLanguageSectionItem] {
        switch self {
        case .languages(_, let items): return items.map { $0 }
        }
    }
    
    init(original: TTLanguageSection, items: [Item]) {
        switch original {
        case .languages(let title, let items): self = .languages(title: title, items: items)
        }
    }
}
