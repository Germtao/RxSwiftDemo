//
//  UserViewModel.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2020/4/30.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct UserViewModel {
    /// 用户名
    let username = BehaviorRelay(value: "guest")
    
    /// 用户信息
    lazy var userInfo = {
        return self.username.asObservable()
            .map { $0 == "hangge" ? "您是管理员" : "您是普通访客" }
            .share(replay: 1)
    }()
}
