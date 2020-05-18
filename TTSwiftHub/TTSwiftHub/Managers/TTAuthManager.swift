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
import KeychainAccess
import ObjectMapper

/// login subject
let loggedIn = BehaviorRelay<Bool>(value: false)

class TTAuthManager {
    static let shared = TTAuthManager()
    
    // MARK: - Properties
    fileprivate let tokenKey = "TokenKey"
    fileprivate let keychain = Keychain(service: Configs.App.bundleIdentifier)
    
    let tokenChanged = PublishSubject<TTToken?>()
    
    init() {
        loggedIn.accept(hasValidToken)
    }
    
    var token: TTToken? {
        set {
            if let token = newValue, let jsonStr = token.toJSONString() {
                keychain[tokenKey] = jsonStr
            } else {
                keychain[tokenKey] = nil
            }
            tokenChanged.onNext(newValue)
            loggedIn.accept(hasValidToken)
        }
        get {
            guard let jsonStr = keychain[tokenKey] else { return nil }
            return Mapper<TTToken>().map(JSONString: jsonStr)
        }
    }
    
    var hasValidToken: Bool {
        return token?.isValid == true
    }
    
    class func setToken(token: TTToken) {
        TTAuthManager.shared.token = token
    }
    
    class func removeToken() {
        TTAuthManager.shared.token = nil
    }
    
    class func tokenValidated() {
        TTAuthManager.shared.token?.isValid = true
    }
    
}
