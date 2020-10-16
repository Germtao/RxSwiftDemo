//
//  TTContact.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/16.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import ObjectMapper
import Contacts

struct TTContact: Mappable {
    var id: String?
    var name: String?
    var phones: [String] = []
    var emails: [String] = []

    var imageData: Data?
    
    init?(map: Map) {}
    init() {}

    init(with contact: CNContact) {
        id = contact.identifier
        name = [contact.givenName, contact.familyName].joined(separator: " ")
        phones = contact.phoneNumbers.map { $0.value.stringValue }
        emails = contact.emailAddresses.map { $0.value as String }
        imageData = contact.thumbnailImageData
    }

    mutating func mapping(map: Map) {
        id     <- map["id"]
        phones <- map["phones"]
//        emails <- map["emails"]
        name   <- map["name"]
    }
}
