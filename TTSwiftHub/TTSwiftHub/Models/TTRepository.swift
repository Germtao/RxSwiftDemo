//
//  TTRepository.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper
import RxOptional

// MARK: - 存储库

struct TTRepository: Mappable {
    var archived: Bool?
    var cloneUrl: String?
    /// 标识创建对象的日期和时间
    var createdAt: Date?
    /// 与存储库的默认分支关联的引用名称
    var defaultBranch = "master"
    /// 资料库的描述
    var descriptionField: String?
    /// 标识存储库是否为fork
    var fork: Bool?
    /// 标识直接分支存储库的总数
    var forks: Int?
    var forksCount: Int?
    /// 拥有者的存储库的名称
    var fullname: String?
    var hasDownloads: Bool?
    var hasIssues: Bool?
    var hasPages: Bool?
    var hasProjects: Bool?
    var hasWiki: Bool?
    /// 存储库的URL
    var homepage: String?
    var htmlUrl: String?
    /// 当前语言的名称
    var language: String?
    /// 为当前语言定义的颜色
    var languageColor: String?
    /// 包含存储库语言组成明细的列表
    var languages: TTLanguages?
    var license: TTLicense?
    /// 仓库名称
    var name: String?
    var networkCount: Int?
    var nodeId: String?
    var openIssues: Int?
    /// 标识已在存储库中打开的问题的总数
    var openIssuesCount: Int?
    var organization: TTUser?
    /// 存储库的拥有者
    var owner: TTUser?
    var privateField: Bool?
    var pushedAt: String?
    /// 该存储库在磁盘上占用大小
    var size: Int?
    var sshUrl: String?
    /// 标识已对该星标加注星标的项目总数
    var stargazersCount: Int?
    /// 标识观看存储库的用户总数
    var subscribersCount: Int?
    /// 标识上次更新对象的日期和时间
    var updatedAt: Date?
    /// 该存储库的HTTP URL
    var url: String?
    var watchers: Int?
    var watchersCount: Int?
    /// 父存储库的名称，带有所有者（如果这是派生的话）
    var parentFullname: String?
    
    /// 标识提交的总数
    var commitsCount: Int?
    /// 标识已在存储库中打开的拉取请求列表的总数
    var pullRequestsCount: Int?
    var branchesCount: Int?
    /// 标识依赖于此存储库的发行总数
    var releasesCount: Int?
    /// 标识可以在存储库上下文中提及的用户总数
    var contributorsCount: Int?

    /// 返回一个布尔值，指示查看用户是否已对此可加注星标加注
    var viewerHasStarred: Bool?
    
    init(name: String?,
         fullname: String?,
         description: String?,
         language: String?,
         languageColor: String?,
         stargazers: Int?,
         viewerHasStarred: Bool?,
         ownerAvatarUrl: String?) {
        self.name = name
        self.fullname = fullname
        self.descriptionField = description
        self.language = language
        self.languageColor = languageColor
        self.stargazersCount = stargazers
        self.viewerHasStarred = viewerHasStarred
        owner = TTUser()
        owner?.avatarUrl = ownerAvatarUrl
    }
    
    init(repo: TTTrendingRepository) {
        self.init(name: repo.name,
                  fullname: repo.fullname,
                  description: repo.descriptionField,
                  language: repo.language,
                  languageColor: repo.languageColor,
                  stargazers: repo.stars,
                  viewerHasStarred: nil,
                  ownerAvatarUrl: repo.builtBy?.first?.avatar)
    }
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        archived         <- map["archived"]
        cloneUrl         <- map["clone_url"]
        createdAt        <- (map["created_at"], ISO8601DateTransform())
        defaultBranch    <- map["default_branch"]
        descriptionField <- map["description"]
        fork             <- map["fork"]
        forks            <- map["forks"]
        forksCount       <- map["forks_count"]
        fullname         <- map["full_name"]
        hasDownloads     <- map["has_downloads"]
        hasIssues        <- map["has_issues"]
        hasPages         <- map["has_pages"]
        hasProjects      <- map["has_projects"]
        hasWiki          <- map["has_wiki"]
        homepage         <- map["homepage"]
        htmlUrl          <- map["html_url"]
        language         <- map["language"]
        license          <- map["license"]
        name             <- map["name"]
        networkCount     <- map["network_count"]
        nodeId           <- map["node_id"]
        openIssues       <- map["open_issues"]
        openIssuesCount  <- map["open_issues_count"]
        organization     <- map["organization"]
        owner            <- map["owner"]
        privateField     <- map["private"]
        pushedAt         <- map["pushed_at"]
        size             <- map["size"]
        sshUrl           <- map["ssh_url"]
        stargazersCount  <- map["stargazers_count"]
        subscribersCount <- map["subscribers_count"]
        updatedAt        <- (map["updated_at"], ISO8601DateTransform())
        url              <- map["url"]
        watchers         <- map["watchers"]
        watchersCount    <- map["watchers_count"]
        parentFullname   <- map["parent.full_name"]
    }
    
    var parentRepository: TTRepository? {
        guard let parentFullname = parentFullname else { return nil }
        var repo = TTRepository()
        repo.fullname = parentFullname
        return repo
    }
}

extension TTRepository: Equatable {
    static func == (lhs: TTRepository, rhs: TTRepository) -> Bool {
        return lhs.fullname == rhs.fullname
    }
}

struct TTRepositorySearch: Mappable {
    var items: [TTRepository] = []
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

struct TTTrendingRepository: Mappable {
    var author: String?
    var name: String?
    var url: String?
    var descriptionField: String?
    var language: String?
    var languageColor: String?
    var stars: Int?
    var forks: Int?
    var currentPeriodStars: Int?
    var builtBy: [TTTrendingUser]?

    var fullname: String? {
        return "\(author ?? "")/\(name ?? "")"
    }
    
    var avatarUrl: String? {
        return builtBy?.first?.avatar
    }
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        author             <- map["author"]
        name               <- map["name"]
        url                <- map["url"]
        descriptionField   <- map["description"]
        language           <- map["language"]
        languageColor      <- map["languageColor"]
        stars              <- map["stars"]
        forks              <- map["forks"]
        currentPeriodStars <- map["currentPeriodStars"]
        builtBy            <- map["builtBy"]
    }
}

extension TTTrendingRepository: Equatable {
    static func ==(lhs: TTTrendingRepository, rhs: TTTrendingRepository) -> Bool {
        return lhs.fullname == rhs.fullname
    }
}
