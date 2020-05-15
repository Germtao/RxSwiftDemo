//
//  ISO8601DateTransform.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper

open class ISO8601DateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public func transformFromJSON(_ value: Any?) -> Date? {
        guard let dateString = value as? String else { return nil }
        return dateString.toISODate()?.date
    }
    
    public func transformToJSON(_ value: Date?) -> String? {
        guard let date = value else { return nil }
        return date.toISO()
    }
}
