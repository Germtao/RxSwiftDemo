//
//  TTSectionType.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/16.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxDataSources

struct TTSectionType<T> {
    var header: String
    var items: [T]
}

extension TTSectionType: SectionModelType {
    typealias Item = T
    
    init(original: TTSectionType<T>, items: [T]) {
        self = original
        self.items = items
    }
}
