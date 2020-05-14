//
//  TTLibsManager.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//typealias DropDownView = DropDown

class TTLibsManager: NSObject {
    
    static let shared = TTLibsManager()
    
    let bannersEnabled = BehaviorRelay(value: UserDefaults.standard.bool(forKey: Configs.UserDefaultsKeys.bannersEnabled))
    
    override init() {
        super.init()
        
        if UserDefaults.standard.object(forKey: Configs.UserDefaultsKeys.bannersEnabled) == nil {
            bannersEnabled.accept(true)
        }
        
        bannersEnabled
            .skip(1) // 从1开始
            .subscribe(onNext: { enabled in
                UserDefaults.standard.set(enabled, forKey: Configs.UserDefaultsKeys.bannersEnabled)
                // TODO: analytics
            })
            .disposed(by: rx.disposeBag)
    }
    
}
