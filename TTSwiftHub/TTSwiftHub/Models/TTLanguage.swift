//
//  TTLanguage.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

private let languageKey = "CurrentLanguageKey"

struct TTLanguage: Mappable {
    var urlParam: String?
    var name: String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        urlParam <- map["urlParam"]
        name     <- map["name"]
    }
    
    func displayName() -> String {
        return (name.isNilOrEmpty == false ? name : urlParam) ?? ""
    }
}

extension TTLanguage {
    func save() {
        if let json = toJSONString() {
            UserDefaults.standard.set(json, forKey: languageKey)
        } else {
            logError("Language can't be saved")
        }
    }
    
    static var currentLanguage: TTLanguage? {
        if let json = UserDefaults.standard.string(forKey: languageKey),
            let language = TTLanguage(JSONString: json) {
            return language
        }
        return nil
    }
    
    static func removeCurrentLanguage() {
        UserDefaults.standard.removeObject(forKey: languageKey)
    }
}

extension TTLanguage: Equatable {
    static func ==(lhs: TTLanguage, rhs: TTLanguage) -> Bool {
        return lhs.urlParam == rhs.urlParam
    }
}

struct TTLanguages {
    var totalCount: Int = 0
    var totalSize: Int = 0
    var languages: [TTRepoLanguage] = []
}

struct TTRepoLanguage {
    var size: Int = 0
    var name: String?
    var color: String?
//
//    init(graph: RepositoryQuery.Data.Repository.Language.Edge?) {
//        size = graph?.size ?? 0
//        name = graph?.node.name
//        color = graph?.node.color
//    }
}

struct TTLanguageLines: Mappable {
    var language: String?
    var files: String?
    var lines: String?
    var blanks: String?
    var comments: String?
    var linesOfCode: String?
    
    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        language    <- map["language"]
        files       <- map["files"]
        lines       <- map["lines"]
        blanks      <- map["blanks"]
        comments    <- map["comments"]
        linesOfCode <- map["linesOfCode"]
    }
}
