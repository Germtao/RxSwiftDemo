//
//  Configs.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/13.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import UIKit

@_exported import SnapKit
@_exported import NSObject_Rx
@_exported import DZNEmptyDataSet
@_exported import RxSwiftExt
@_exported import Hero
@_exported import RxViewController
@_exported import SwiftDate
@_exported import SwifterSwift

// MARK: - 所有键都是说明性的，用于测试

enum Keys {
    case github, mixpanel, adMob
    
    var apiKey: String {
        switch self {
        case .github:   return "5a39979251c0452a9476bd45c82a14d8e98c3fb3"
        case .mixpanel: return "7e428bc407e3612f6d3a4c8f50fd4643"
        case .adMob:    return "ca-app-pub-3940256099942544/2934735716"
        }
    }
    
    var appId: String {
        switch self {
        case .github:   return "00cbdbffb01ec72e280a"
        case .mixpanel: return ""
        case .adMob:    return ""  // See GADApplicationIdentifier in Info.plist
        }
    }
}

// MARK: - 全局配置

struct Configs {
    
    struct App {
        static let githubUrl        = "https://github.com/khoren93/SwiftHub"
        static let bundleIdentifier = "com.public.SwiftHub"
    }
    
    struct Network {
        static let useStaging            = false  // 为测试设置正确，并使用fastlane生成屏幕截图
        static let loggingEnabled        = false
        static let githubBaseUrl         = "https://api.github.com"
        static let trendingGithubBaseUrl = "https://github-trending-api.now.sh"
        static let codetabsBaseUrl       = "https://api.codetabs.com/v1"
        static let githistoryBaseUrl     = "https://github.githistory.xyz"
        static let starHistoryBaseUrl    = "https://star-history.t9t.io"
        static let profileSummaryBaseUrl = "https://profile-summary-for-github.com"
    }
    
    struct BaseDimensions {
        static let inset: CGFloat                     = 10
        static let cornerRadius: CGFloat              = 5
        static let tabBarHeight: CGFloat              = 58
        static let toolBarHeight: CGFloat             = 66
        static let navBarWithStatusBarHeight: CGFloat = 64
        static let borderWidth: CGFloat               = 1
        static let buttonHeight: CGFloat              = 40
        static let textFieldHeight: CGFloat           = 40
        static let tableRowHeight: CGFloat            = 40
        static let segmentedControlHeight: CGFloat    = 40
    }
    
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        static let Tmp       = NSTemporaryDirectory()
    }
    
    struct UserDefaultsKeys {
        static let bannersEnabled = "BannersEnabled"
    }
}
