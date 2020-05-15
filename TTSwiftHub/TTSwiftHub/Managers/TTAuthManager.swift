//
//  TTAuthManager.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// login subject
let loggedIn = BehaviorRelay<Bool>(value: false)

class TTAuthManager: NSObject {
    static let shared = TTAuthManager()
    
    // MARK: - Properties
    fileprivate let tokenKey = "TokenKey"
//    fileprivate let
    
    let tokenChanged = PublishSubject<TTToken?>()
    
    
}
