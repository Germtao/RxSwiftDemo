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
    /// 指向用户的公共头像的URL
    var avatarUrl: String?
    /// 指向用户的公共网站/博客的URL
    var blog: String?
    /// 用户的公开资料公司
    var company: String?
    var contributions: Int?
    /// 标识创建对象的日期和时间
    var createdAt: Date?
    /// 用户的公开个人资料电子邮件
    var email: String?
    /// 确定关注者总数
    var followers: Int?
    /// 标识跟随者的总数
    var following: Int?
    /// 该用户的HTTP URL
    var htmlUrl: String?
    /// 用户的公开个人资料位置
    var location: String?
    /// 用于登录的用户名
    var login: String?
    /// 用户的公开个人资料名称
    var name: String?
    var type: TTUserType = .user
    /// 标识上次更新的日期和时间
    var updatedAt: Date?
    /// 标识用户已加注星标的存储库总数
    var starredRepositoriesCount: Int?
    /// 标识用户拥有的存储库总数
    var repositoriesCount: Int?
    /// 标识与此用户相关的问题总数
    var issuesCount: Int?
    /// 标识给定用户正在查看的存储库总数
    var watchingCount: Int?
    /// 是否能够跟随用户
    var viewerCanFollow: Bool?
    /// 是否关注此用户
    var viewerIsFollowing: Bool?
    /// 此用户是否为访问者
    var isViewer: Bool?
    /// 该用户已固定到其个人资料的存储库列表
    var pinnedRepositories: [TTRepository]?
    /// 用户所属的组织列表
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
