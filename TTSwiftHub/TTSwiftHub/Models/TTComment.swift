//
//  TTComment.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/11.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper
import MessageKit

struct TTComment: Mappable, MessageType {
    var authorAssociation: String?
    var body: String?
    var createdAt: Date?
    var htmlUrl: String?
    var id: Int?
    var issueUrl: String?
    var nodeId: String?
    var updatedAt: Date?
    var url: String?
    var user: TTUser?

    // MessageType
    var sender: SenderType { return user ?? TTUser() }
    var messageId: String { return id?.string ?? "" }
    var sentDate: Date { return createdAt ?? Date() }
    var kind: MessageKind { return .text(body ?? "") }
    
    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        authorAssociation <- map["author_association"]
        body              <- map["body"]
        createdAt         <- (map["created_at"], ISO8601DateTransform())
        htmlUrl           <- map["html_url"]
        id                <- map["id"]
        issueUrl          <- map["issue_url"]
        nodeId            <- map["node_id"]
        updatedAt         <- (map["updated_at"], ISO8601DateTransform())
        url               <- map["url"]
        user              <- map["user"]
    }
}
