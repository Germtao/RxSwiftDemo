//
//  Music.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2020/4/29.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation

struct Music {
    let name: String
    let singer: String
    
    init(name: String, singer: String) {
        self.name = name
        self.singer = singer
    }
}

struct MusicViewModel {
    let data = [
        Music(name: "无条件", singer: "陈奕迅"),
        Music(name: "你曾是少年", singer: "S.H.E"),
        Music(name: "从前的我", singer: "陈洁仪"),
        Music(name: "在木星", singer: "朴树")
    ]
}
