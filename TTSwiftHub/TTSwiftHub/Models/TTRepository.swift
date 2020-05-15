//
//  TTRepository.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

// MARK: - 存储库

struct TTRepository: Mappable {
    var archived: Bool?
    var cloneUrl: String?
    var createdAt: Date?
    var defaultBranch = "master"
    var descriptionField: String?
    var fork: Bool?
    var forks: Int?
    var forksCount: Int?
    var fullname: String?   // 拥有者的存储库的名称
    var hasDownloads: Bool?
    var hasIssues: Bool?
    var hasPages: Bool?
    var hasProjects: Bool?
    var hasWiki: Bool?
    var homepage: String?  // 存储库的URL
    var htmlUrl: String?
    var language: String?
    var languageColor: String?
//    var languages: Languages?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
    }
}

struct TTTrendingRepository {
    
}
