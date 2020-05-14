//
//  ErrorResponse.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

struct ErrorResponse: Mappable {
    var message: String?
    var errors: [ErrorModel] = []
    var documentationUrl: String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        message          <- map["message"]
        errors           <- map["errors"]
        documentationUrl <- map["documentation_url"]
    }
}

struct ErrorModel: Mappable {
    var code: String?
    var message: String?
    var field: String?
    var resource: String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        code     <- map["code"]
        message  <- map["message"]
        field    <- map["field"]
        resource <- map["resource"]
    }
}
