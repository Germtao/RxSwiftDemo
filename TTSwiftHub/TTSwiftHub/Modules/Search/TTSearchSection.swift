//
//  TTSearchSection.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/25.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxDataSources

enum TTSearchSection {
    case repositories(title: String, items: [TTSearchSectionItem])
    case users(title: String, items: [TTSearchSectionItem])
}

enum TTSearchSectionItem {
    case trendingRepositoriesItem(cellViewModel: TTTrendingRepositoryCellViewModel)
    case trendingUsersItem(cellViewModel: TTTrendingUserCellViewModel)
    case repositoriesItem(cellViewModel: TTRepositoryCellViewModel)
    case usersItem(cellViewModel: TTUsersCellViewModel)
}

extension TTSearchSection: SectionModelType {
    typealias Item = TTSearchSectionItem
    
    var title: String {
        switch self {
        case .repositories(let title, _): return title
        case .users(let title, _): return title
        }
    }
    
    var items: [TTSearchSectionItem] {
        switch self {
        case .repositories(_, let items): return items.map { $0 }
        case .users(_, let items): return items.map { $0 }
        }
    }
    
    init(original: TTSearchSection, items: [Item]) {
        switch original {
        case .repositories(let title, let items):
            self = .repositories(title: title, items: items)
        case .users(let title, let items):
            self = .users(title: title, items: items)
        }
    }
    
}
