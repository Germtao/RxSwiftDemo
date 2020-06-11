//
//  TTEvent.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/11.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

enum TTEventType: String {
    case fork = "ForkEvent"
    case commitComment = "CommitCommentEvent"
    case create = "CreateEvent"
    case issueComment = "IssueCommentEvent"
    case issues = "IssuesEvent"
    case member = "MemberEvent"
    case organizationBlock = "OrgBlockEvent"
    case `public` = "PublicEvent"
    case pullRequest = "PullRequestEvent"
    case pullRequestReviewComment = "PullRequestReviewCommentEvent"
    case push = "PushEvent"
    case release = "ReleaseEvent"
    case star = "WatchEvent"
    case unknown = ""
}

struct TTEvent: Mappable {
    var actor: TTUser?
    var createdAt: Date?
    var id: String?
    var organization: TTUser?
    var isPublic: Bool?
    var repository: TTRepository?
    var type: TTEventType = .unknown
    
    var payload: TTPayload?

    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        actor <- map["actor"]
        createdAt <- (map["created_at"], ISO8601DateTransform())
        id <- map["id"]
        organization <- map["org"]
        isPublic <- map["public"]
        repository <- map["repo"]
        type <- map["type"]

        payload = Mapper<TTPayload>().map(JSON: map.JSON)

        if let fullname = repository?.name {
            let parts = fullname.components(separatedBy: "/")
            repository?.name = parts.last
            repository?.owner = TTUser()
            repository?.owner?.login = parts.first
            repository?.fullname = fullname
        }
    }
}

extension TTEvent: Equatable {
    static func == (lhs: TTEvent, rhs: TTEvent) -> Bool {
        return lhs.id == rhs.id
    }
}

class TTPayload: StaticMappable {
    
    required init?(map: Map) {}
    init() {}
    
    static func objectForMapping(map: Map) -> BaseMappable? {
        var type: TTEventType = .unknown
        type <- map["type"]
        switch type {
        case .fork: return TTForkPayload()
        case .create: return TTCreatePayload()
        case .issueComment: return TTIssueCommentPayload()
        case .issues: return TTIssuesPayload()
        case .member: return TTMemberPayload()
        case .pullRequest: return TTPullRequestPayload()
        case .pullRequestReviewComment: return TTPullRequestReviewCommentPayload()
        case .push: return TTPushPayload()
        case .release: return TTReleasePayload()
        case .star: return TTStarPayload()
        default: return TTPayload()
        }
    }
    
    func mapping(map: Map) {}
    
}

class TTForkPayload: TTPayload {
    var repository: TTRepository?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        repository <- map["payload.forkee"]
    }
}

enum TTCreateEventType: String {
    case repository
    case branch
    case tag
}

class TTCreatePayload: TTPayload {
    var ref: String?
    var refType: TTCreateEventType = .repository
    var masterBranch: String?
    var description: String?
    var pusherType: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        ref <- map["payload.ref"]
        refType <- map["payload.ref_type"]
        masterBranch <- map["payload.master_branch"]
        description <- map["payload.description"]
        pusherType <- map["payload.pusher_type"]
    }
}

class TTIssueCommentPayload: TTPayload {
    var action: String?
    var issue: TTIssue?
    var comment: TTComment?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        issue <- map["payload.issue"]
        comment <- map["payload.comment"]
    }
}

class TTIssuesPayload: TTPayload {
    var action: String?
    var issue: TTIssue?
    var repository: TTRepository?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        issue <- map["payload.issue"]
        repository <- map["payload.forkee"]
    }
}

class TTMemberPayload: TTPayload {
    var action: String?
    var member: TTUser?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        member <- map["payload.member"]
    }
}

class TTPullRequestPayload: TTPayload {
    var action: String?
    var number: Int?
    var pullRequest: TTPullRequest?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        number <- map["payload.number"]
        pullRequest <- map["payload.pull_request"]
    }
}

class TTPullRequestReviewCommentPayload: TTPayload {
    var action: String?
    var comment: TTComment?
    var pullRequest: TTPullRequest?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        comment <- map["payload.comment"]
        pullRequest <- map["payload.pull_request"]
    }
}

class TTPushPayload: TTPayload {
    var ref: String?
    var size: Int?
    var commits: [TTCommit] = []

    override func mapping(map: Map) {
        super.mapping(map: map)

        ref <- map["payload.ref"]
        size <- map["payload.size"]
        commits <- map["payload.commits"]
    }
}

class TTReleasePayload: TTPayload {
    var action: String?
    var release: TTRelease?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
        release <- map["payload.release"]
    }
}

class TTStarPayload: TTPayload {
    var action: String?

    override func mapping(map: Map) {
        super.mapping(map: map)

        action <- map["payload.action"]
    }
}
