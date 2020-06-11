//
//  TTUser.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper
import KeychainAccess
import MessageKit

private let userKey = "CurrentUserKey"
private let keychain = Keychain(service: Configs.App.bundleIdentifier)

enum TTUserType: String {
    case user = "User"
    case organization = "Organization"
}

struct TTUser: Mappable, SenderType {
    var avatarUrl: String?
    var blog: String?
    var company: String?
    var contributions: Int?
    var createdAt: Date?
    var email: String?
    var followers: Int?
    var following: Int?
    var htmlUrl: String?
    var location: String?
    var login: String?
    var name: String?
    var type: TTUserType = .user
    var updatedAt: Date?
    var starredRepositoriesCount: Int?
    var repositoriesCount: Int?
    var issuesCount: Int?
    var watchingCount: Int?
    var viewerCanFollow: Bool?
    var viewerIsFollowing: Bool?
    var isViewer: Bool?
    var pinnedRepositories: [TTRepository]?
    var organizations: [TTUser]?
    
    // 仅针对组织类型
    var descriptionField: String?
    
    // 仅针对用户类型
    var bio: String?
    
    // SenderType
    var senderId: String { return login ?? "" }
    var displayName: String { return login ?? "" }
    
    init?(map: Map) {}
    init() {}
    
    init(login: String?,
         name: String?,
         avatarUrl: String?,
         followers: Int?,
         viewerCanFollow: Bool?,
         viewerIsFollowing: Bool?) {
        self.login = login
        self.name = name
        self.avatarUrl = avatarUrl
        self.followers = followers
        self.viewerCanFollow = viewerCanFollow
        self.viewerIsFollowing = viewerIsFollowing
    }
    
    init(user: TTTrendingUser) {
        self.init(login: user.username,
                  name: user.name,
                  avatarUrl: user.avatar,
                  followers: nil,
                  viewerCanFollow: nil,
                  viewerIsFollowing: nil)
        switch user.type {
        case .user: self.type = .user
        case .organization: self.type = .organization
        }
    }
    
    mutating func mapping(map: Map) {
        avatarUrl <- map["avatar_url"]
        blog <- map["blog"]
        company <- map["company"]
        contributions <- map["contributions"]
        createdAt <- (map["created_at"], ISO8601DateTransform())
        descriptionField <- map["description"]
        email <- map["email"]
        followers <- map["followers"]
        following <- map["following"]
        htmlUrl <- map["html_url"]
        location <- map["location"]
        login <- map["login"]
        name <- map["name"]
        repositoriesCount <- map["public_repos"]
        type <- map["type"]
        updatedAt <- (map["updated_at"], ISO8601DateTransform())
        bio <- map["bio"]
    }
    
}

extension TTUser {
    func isMine() -> Bool {
        if let isViewer = isViewer {
            return isViewer
        }
        return self == TTUser.currentUser()
    }
    
    func save() {
        if let json = self.toJSONString() {
            keychain[userKey] = json
        } else {
            logError("User can't be saved")
        }
    }
    
    static func currentUser() -> TTUser? {
        if let jsonStr = keychain[userKey], let user = TTUser(JSONString: jsonStr) {
            return user
        }
        return nil
    }
    
    static func removeCurrentUser() {
        keychain[userKey] = nil
    }
}

extension TTUser: Equatable {
    static func ==(lhs: TTUser, rhs: TTUser) -> Bool {
        return lhs.login == rhs.login
    }
}

// MARK: - 搜索用户

struct TTUserSearch: Mappable {
    var items: [TTUser] = []
    var totalCount: Int = 0
    var incompleteResults: Bool = false
    var hasNextPage: Bool = false
    var endCursor: String?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        items             <- map["items"]
        totalCount        <- map["total_count"]
        incompleteResults <- map["incomplete_results"]
        
        hasNextPage = items.isNotEmpty
    }
}

// MARK: - 热门用户

enum TTTrendingUserType: String {
    case user
    case organization
}

struct TTTrendingUser: Mappable {
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        username <- map["username"]
        name     <- map["name"]
        url      <- map["url"]
        avatar   <- map["avatar"]
        repo     <- map["repo"]
        type     <- map["type"]
        
        repo?.author = username
    }
    
    var username: String?
    var name: String?
    var url: String?
    var avatar: String?
    var repo: TTTrendingRepository?
    var type: TTTrendingUserType = .user
}

extension TTTrendingUser: Equatable {
    static func ==(lhs: TTTrendingUser, rhs: TTTrendingUser) -> Bool {
        return lhs.username == rhs.username
    }
}
