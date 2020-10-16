//
//  TTContent.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/11.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

enum TTContentType: String {
    case file = "file"
    case dir = "dir"
    case symlink = "symlink"
    case submodule = "submodule"
    case unknown = ""
}

extension TTContentType: Comparable {
    var priority: Int {
        switch self {
        case .file: return 0
        case .dir: return 1
        case .symlink: return 2
        case .submodule: return 3
        case .unknown: return 4
        }
    }
    
    static func < (lhs: TTContentType, rhs: TTContentType) -> Bool {
        return lhs.priority < rhs.priority
    }
}

struct TTContent: Mappable {
    var content: String?
    var downloadUrl: String?
    var encoding: String?
    var gitUrl: String?
    var htmlUrl: String?
    var name: String?
    var path: String?
    var sha: String?
    var size: Int?
    var type: TTContentType = .unknown
    var url: String?
    var target: String?
    var submoduleGitUrl: String?
    
    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        content         <- map["content"]
        downloadUrl     <- map["download_url"]
        encoding        <- map["encoding"]
        gitUrl          <- map["git_url"]
        htmlUrl         <- map["html_url"]
        name            <- map["name"]
        path            <- map["path"]
        sha             <- map["sha"]
        size            <- map["size"]
        type            <- map["type"]
        url             <- map["url"]
        target          <- map["target"]
        submoduleGitUrl <- map["submodule_git_url"]
    }
}
