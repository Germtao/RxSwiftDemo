//
//  TTSettingsSection.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/20.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxDataSources

enum TTSettingsSectionItem {
    // Account
    case profileItem(viewModel: TTUserCellViewModel)
    case logoutItem(viewModel: TTSettingCellViewModel)
    
    // My Projects
    case repositoryItem(viewModel: TTRepositoryCellViewModel)
    
    // Preferences
    case bannerItem(viewModel: TTSettingSwitchCellViewModel)
    case nightModeItem(viewModel: TTSettingSwitchCellViewModel)
    case themeItem(viewModel: TTSettingCellViewModel)
    case languageItem(viewModel: TTSettingCellViewModel)
    case contactsItem(viewModel: TTSettingCellViewModel)
    case removeCacheItem(viewModel: TTSettingCellViewModel)
    
    // Support
    case acknowledgementsItem(viewModel: TTSettingCellViewModel)
    case whatsNewItem(viewModel: TTSettingCellViewModel)
}

extension TTSettingsSectionItem: IdentifiableType {
    typealias Identity = String
    
    var identity: Identity {
        switch self {
        case .profileItem(let viewModel): return viewModel.user.login ?? ""
        case .repositoryItem(let viewModel): return viewModel.repository.fullname ?? ""
        case .bannerItem(let viewModel),
             .nightModeItem(let viewModel): return viewModel.title.value ?? ""
        case .logoutItem(let viewModel),
             .themeItem(let viewModel),
             .languageItem(let viewModel),
             .contactsItem(let viewModel),
             .removeCacheItem(let viewModel),
             .acknowledgementsItem(let viewModel),
             .whatsNewItem(let viewModel): return viewModel.title.value ?? ""
        }
    }
}

extension TTSettingsSectionItem: Equatable {
    static func ==(lhs: TTSettingsSectionItem, rhs: TTSettingsSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

enum TTSettingsSection {
    case setting(title: String, items: [TTSettingsSectionItem])
    
}

extension TTSettingsSection: AnimatableSectionModelType, IdentifiableType {
    
    typealias Identity = String
    
    typealias Item = TTSettingsSectionItem
    
    var identity: Identity { title }
    
    var title: String {
        switch self {
        case .setting(let title, _): return title
        }
    }
    
    var items: [TTSettingsSectionItem] {
        switch self {
        case .setting(_, let items): return items
        }
    }
    
    init(original: TTSettingsSection, items: [Item]) {
        switch original {
        case .setting(let title, let items):
            self = .setting(title: title, items: items)
        }
    }
}
