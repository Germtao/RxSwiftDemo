//
//  TTNotification.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/16.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

struct TTNotification: Mappable {
    
    var id: String?
    var lastReadAt: Date?
    var reason: String?
    var repository: TTRepository?
    var subject: TTSubject?
    var subscriptionUrl: String?
    var unread: Bool?
    var updatedAt: Date?
    var url: String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        id              <- map["id"]
        lastReadAt      <- (map["last_read_at"], ISO8601DateTransform())
        reason          <- map["reason"]
        repository      <- map["repository"]
        subject         <- map["subject"]
        subscriptionUrl <- map["subscription_url"]
        unread          <- map["unread"]
        updatedAt       <- (map["updated_at"], ISO8601DateTransform())
        url             <- map["url"]
    }
}

extension TTNotification: Equatable {
    static func ==(lhs: TTNotification, rhs: TTNotification) -> Bool {
        lhs.id == rhs.id
    }
}

struct TTSubject: Mappable {
    var latestCommentUrl: String?
    var title: String?
    var type: String?
    var url: String?

    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        latestCommentUrl <- map["latest_comment_url"]
        title            <- map["title"]
        type             <- map["type"]
        url              <- map["url"]
    }
}
