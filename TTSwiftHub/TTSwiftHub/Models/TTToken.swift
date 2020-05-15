//
//  TTToken.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

enum TTTokenType {
    case basic(token: String)
    case oAuth(token: String)
    case unauthorized
    
    var description: String {
        switch self {
        case .basic: return "basic"
        case .oAuth: return "OAuth"
        case .unauthorized: return "unauthorized"
        }
    }
}

struct TTToken: Mappable {
    
    var isValid = false
    
    // Basic
    var basicToken: String?
    
    // OAuth2
    var accessToken: String?
    var tokenType: String?
    var scope: String?
    
    init?(map: Map) {}
    
    init(basicToken: String) {
        self.basicToken = basicToken
    }
    
    mutating func mapping(map: Map) {
        isValid <- map["valid"]
        basicToken <- map["basic_token"]
        accessToken <- map["access_token"]
        tokenType <- map["token_type"]
        scope <- map["scope"]
    }
    
    func type() -> TTTokenType {
        if let token = basicToken {
            return .basic(token: token)
        }
        
        if let token = accessToken {
            return .oAuth(token: token)
        }
        
        return .unauthorized
    }
}
