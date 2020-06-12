//
//  TTRepositorySection.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/11.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxDataSources

enum TTRepositorySectionItem {
    case parentItem(viewModel: TTRepositoryDetailCellViewModel)
    case languageItem(viewModel: TTRepositoryDetailCellViewModel)
    case languagesItem(viewModel: TTLanguagesCellViewModel)
    case sizeItem(viewModel: TTRepositoryDetailCellViewModel)
    case createdItem(viewModel: TTRepositoryDetailCellViewModel)
    case updatedItem(viewModel: TTRepositoryDetailCellViewModel)
    case homepageItem(viewModel: TTRepositoryDetailCellViewModel)
    case issuesItem(viewModel: TTRepositoryDetailCellViewModel)
    case pullRequestsItem(viewModel: TTRepositoryDetailCellViewModel)
    case commitsItem(viewModel: TTRepositoryDetailCellViewModel)
    case branchesItem(viewModel: TTRepositoryDetailCellViewModel)
    case releasesItem(viewModel: TTRepositoryDetailCellViewModel)
    case contributorsItem(viewModel: TTRepositoryDetailCellViewModel)
    case eventsItem(viewModel: TTRepositoryDetailCellViewModel)
    case notificationsItem(viewModel: TTRepositoryDetailCellViewModel)
    case sourceItem(viewModel: TTRepositoryDetailCellViewModel)
    case starHistoryItem(viewModel: TTRepositoryDetailCellViewModel)
    case countLinesOfCodeItem(viewModel: TTRepositoryDetailCellViewModel)
}

enum TTRepositorySection {
    case repository(title: String, items: [TTRepositorySectionItem])
}

extension TTRepositorySection: SectionModelType {
    typealias Item = TTRepositorySectionItem
    
    var title: String {
        switch self {
        case .repository(let title, _): return title
        }
    }
    
    var items: [TTRepositorySectionItem] {
        switch self {
        case .repository(_, let items): return items.map { $0 }
        }
    }
    
    init(original: TTRepositorySection, items: [Item]) {
        switch original {
        case .repository(let title, let items):
            self = .repository(title: title, items: items)
        }
    }
}
