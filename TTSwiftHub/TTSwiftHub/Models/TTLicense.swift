//
//  TTLicense.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/16.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

struct TTLicense: Mappable {
    var key: String?
    var name: String?
    var nodeId: String?
    var spdxId: AnyObject?
    var url: AnyObject?
    
    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        key    <- map["key"]
        name   <- map["name"]
        nodeId <- map["node_id"]
        spdxId <- map["spdx_id"]
        url    <- map["url"]
    }
}
