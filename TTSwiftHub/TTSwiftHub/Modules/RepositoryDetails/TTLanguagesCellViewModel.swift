//
//  TTLanguagesCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/12.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation

class TTLanguagesCellViewModel: NSObject {
    let languages: TTLanguages?
    
    init(languages: TTLanguages) {
        self.languages = languages
    }
}
