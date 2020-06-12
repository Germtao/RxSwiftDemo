//
//  TTBranch.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/12.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

struct TTBranch: Mappable {
//    var links:
    
    var commit: TTCommit?
    var name: String?
    var protectedField: Bool?
    var protectionUrl: String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        commit <- map["commit"]
        name <- map["name"]
        protectedField <- map["protected"]
        protectionUrl <- map["protection_url"]
    }
    
}
