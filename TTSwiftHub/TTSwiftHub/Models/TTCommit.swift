//
//  TTCommit.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/11.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

struct TTCommit: Mappable {
    var url: String?
    var commentsUrl: String?
    var commit: TTCommitInfo?
    var files: [TTFile]?
    var htmlUrl: String?
    var nodeId: String?
//    var parents: [Tree]?
    var sha: String?
    var stats: TTStat?
    var author: TTUser?
    var committer: TTUser?

    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        url         <- map["url"]
        commentsUrl <- map["comments_url"]
        commit      <- map["commit"]
        files       <- map["files"]
        htmlUrl     <- map["html_url"]
        nodeId      <- map["node_id"]
//        parents <- map["parents"]
        sha         <- map["sha"]
        stats       <- map["stats"]
        author      <- map["author"]
        committer   <- map["committer"]
    }
}

struct TTCommitter: Mappable {
    var name: String?
    var email: String?
    var date: Date?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        name  <- map["name"]
        email <- map["email"]
        date  <- (map["date"], ISO8601DateTransform())
    }
}

struct TTCommitInfo: Mappable {
    var author: TTCommitter?
    var commentCount: Int?
    var committer: TTCommitter?
    var message: String?
    var url: String?
    var verification: TTVerification?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        author       <- map["author"]
        commentCount <- map["comment_count"]
        committer    <- map["committer"]
        message      <- map["message"]
        url          <- map["url"]
        verification <- map["verification"]
    }
}

struct TTStat: Mappable {
    var additions: Int?
    var deletions: Int?
    var total: Int?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        additions <- map["additions"]
        deletions <- map["deletions"]
        total     <- map["total"]
    }
}

struct TTFile: Mappable {
    var additions: Int?
    var blobUrl: String?
    var changes: Int?
    var deletions: Int?
    var filename: String?
    var patch: String?
    var rawUrl: String?
    var status: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        additions <- map["additions"]
        blobUrl   <- map["blob_url"]
        changes   <- map["changes"]
        deletions <- map["deletions"]
        filename  <- map["filename"]
        patch     <- map["patch"]
        rawUrl    <- map["raw_url"]
        status    <- map["status"]
    }
}

struct TTVerification: Mappable {
    var payload: AnyObject?
    var reason: String?
    var signature: AnyObject?
    var verified: Bool?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        payload   <- map["payload"]
        reason    <- map["reason"]
        signature <- map["signature"]
        verified  <- map["verified"]
    }
}
