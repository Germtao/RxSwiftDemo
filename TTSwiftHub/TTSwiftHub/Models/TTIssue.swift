//
//  TTIssue.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/11.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

struct TTIssue: Mappable {
    var activeLockReason: String?
    var assignee: TTUser?
    var assignees: [TTUser]?
    var body: String?
    var closedAt: Date?
    var closedBy: TTUser?
    var comments: Int?
    var commentsUrl: String?
    var createdAt: Date?
    var eventsUrl: String?
    var htmlUrl: String?
    var id: Int?
    var labels: [TTIssueLabel]?
    var labelsUrl: String?
    var locked: Bool?
    var milestone: TTMilestone?
    var nodeId: String?
    var number: Int?
    var pullRequest: TTPullRequest?
    var repositoryUrl: String?
    var state: TTState = .open
    var title: String?
    var updatedAt: Date?
    var url: String?
    var user: TTUser?
    
    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        activeLockReason <- map["active_lock_reason"]
        assignee         <- map["assignee"]
        assignees        <- map["assignees"]
        body             <- map["body"]
        closedAt         <- (map["closed_at"], ISO8601DateTransform())
        closedBy         <- map["closed_by"]
        comments         <- map["comments"]
        commentsUrl      <- map["comments_url"]
        createdAt        <- (map["created_at"], ISO8601DateTransform())
        eventsUrl        <- map["events_url"]
        htmlUrl          <- map["html_url"]
        id               <- map["id"]
        labels           <- map["labels"]
        labelsUrl        <- map["labels_url"]
        locked           <- map["locked"]
        milestone        <- map["milestone"]
        nodeId           <- map["node_id"]
        number           <- map["number"]
        pullRequest      <- map["pull_request"]
        repositoryUrl    <- map["repository_url"]
        state            <- map["state"]
        title            <- map["title"]
        updatedAt        <- (map["updated_at"], ISO8601DateTransform())
        url              <- map["url"]
        user             <- map["user"]
    }
}

struct TTIssueLabel: Mappable {
    var color: String?
    var defaultField: Bool?
    var descriptionField: String?
    var id: Int?
    var name: String?
    var nodeId: String?
    var url: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        color            <- map["color"]
        defaultField     <- map["default"]
        descriptionField <- map["description"]
        id               <- map["id"]
        name             <- map["name"]
        nodeId           <- map["node_id"]
        url              <- map["url"]
    }
}
