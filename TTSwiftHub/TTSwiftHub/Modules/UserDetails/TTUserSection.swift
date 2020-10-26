//
//  TTUserSection.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/10.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxDataSources

enum TTUserSectionItem {
    case createdItem(viewModel: TTUserDetailCellViewModel)
    case updatedItem(viewModel: TTUserDetailCellViewModel)
    case starsItem(viewModel: TTUserDetailCellViewModel)
    case watchingItem(viewModel: TTUserDetailCellViewModel)
    case eventsItem(viewModel: TTUserDetailCellViewModel)
    case companyItem(viewModel: TTUserDetailCellViewModel)
    case blogItem(viewModel: TTUserDetailCellViewModel)
    case profileSummaryItem(viewModel: TTUserDetailCellViewModel)
    
    case repositoryItem(viewModel: TTRepositoryCellViewModel)
    case organizationItem(viewModel: TTUserCellViewModel)
}

enum TTUserSection {
    case user(title: String, items: [TTUserSectionItem])
}

extension TTUserSection: SectionModelType {
    typealias Item = TTUserSectionItem
    
    var title: String {
        switch self {
        case .user(let title, _): return title
        }
    }
    
    var items: [TTUserSectionItem] {
        switch self {
        case .user(_, let items): return items.map { $0 }
        }
    }
    
    init(original: TTUserSection, items: [Item]) {
        switch original {
        case .user(let title, let items):
            self = .user(title: title, items: items)
        }
    }
    
}
