//
//  TTAnalyticsManager.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/10.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import Mixpanel
import FirebaseAnalytics

let analytics = Analytics()

enum AnalyticsUserEventType {
    case name(value: String)
    case email(value: String)
    case colorTheme(value: String)
    case adsEnabled(value: Bool)
    case nightMode(value: Bool)
}

extension AnalyticsUserEventType {
    var name: String {
        switch self {
        case .name: return "name"
        case .email: return "email"
        case .colorTheme: return "color_theme"
        case .adsEnabled: return "ads_enabled"
        case .nightMode: return "night_mode_enabled"
        }
    }
    
    var value: Any {
        switch self {
        case .name(let value),
             .email(let value),
             .colorTheme(let value):
            return value
        case .adsEnabled(let value),
             .nightMode(let value):
            return value
        }
    }
}

enum AnalyticsEventType {
    case appAds(enabled: Bool)
    case appNightMode(enabled: Bool)
    case appTheme(color: String)
    case appLanguage(language: String)
    case appCacheRemoved
    case userInvited(success: Bool)
    case whatsNew
    case flexOpened
    
    case login(login: String, type: String)
    case logout
    case search(keyword: String)
    case repoLanguage(language: String)
    case repository(fullname: String)
    case user(login: String)
    case userEvents(login: String)
    case repositoryEvents(fullname: String)
    case issues(fullname: String)
    case source(fullname: String)
    case readme(fullname: String)
    case linesCount(fullname: String)
}

extension AnalyticsEventType {
    var name: String {
        switch self {
        case .appAds: return "ads_changed"
        case .appNightMode: return "night_mode_changed"
        case .appTheme: return "theme"
        case .appLanguage: return "language"
        case .appCacheRemoved: return "cache_removed"
        case .userInvited: return "user_invited"
        case .whatsNew: return "whats_new"
        case .flexOpened: return "flex_opened"
        case .login: return "login"
        case .logout: return "logout"
        case .search: return "search"
        case .repoLanguage: return "repo_language"
        case .repository: return "repository"
        case .user: return "user"
        case .userEvents: return "user_events"
        case .repositoryEvents: return "repository_events"
        case .issues: return "issues"
        case .source: return "source"
        case .readme: return "readme"
        case .linesCount: return "lines_count"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .appAds(let enabled),
             .appNightMode(let enabled):
            return ["enabled": enabled]
        case .appTheme(let color):
            return ["color": color]
        case .appLanguage(let language):
            return ["language": language]
        case .userInvited(let success):
            return ["success": success]
        case .login(let login, let type):
            return ["login": login, "type": type]
        case .search(let keyword):
            return ["keyword": keyword]
        case .repoLanguage(let language):
            return ["language": language]
        case .user(let login),
             .userEvents(let login):
            return ["login": login]
        case .repository(let fullname),
             .repositoryEvents(let fullname),
             .issues(let fullname),
             .source(let fullname),
             .readme(let fullname),
             .linesCount(let fullname):
            return ["fullname": fullname]
        default:
            return nil
        }
    }
}

class Analytics {
    func log(_ event: AnalyticsEventType) {
        let name = event.name
        let parameters = event.parameters
        Mixpanel.sharedInstance()?.track(name, properties: parameters)
        FirebaseAnalytics.Analytics.logEvent(name, parameters: parameters)
    }
    
    func set(_ userProperty: AnalyticsUserEventType) {
        let name = userProperty.name
        let value = userProperty.value
        if let _value = value as? MixpanelType {
            Mixpanel.sharedInstance()?.people.set("$\(name)", to: _value)
        }
        FirebaseAnalytics.Analytics.setUserProperty("\(value)", forName: name)
    }
}

extension Analytics {
    func identify(userId: String) {
        Mixpanel.sharedInstance()?.identify(userId)
        FirebaseAnalytics.Analytics.setUserID(userId)
    }
    
    func reset() {
        Mixpanel.sharedInstance()?.reset()
        FirebaseAnalytics.Analytics.resetAnalyticsData()
    }
}
