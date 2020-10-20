//
//  TTReachabilityManager.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

/// 应用程序上线时完成的可观察对象（可能立即完成）
func connectedToInternet() -> Observable<Bool> {
    return TTReachabilityManager.shared.reach
}

private class TTReachabilityManager: NSObject {
    
    static let shared = TTReachabilityManager()
    
    /// ReplaySubject：创建时需要指定对象缓存区容量，该容量表示会给订阅者重新发送订阅前数据的大小
    let reachSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    
    var reach: Observable<Bool> {
        return reachSubject.asObservable()
    }
    
    override init() {
        super.init()
        
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { status in
            switch status {
            case .notReachable, .unknown:
                self.reachSubject.onNext(false)
            case .reachable:
                self.reachSubject.onNext(true)
            }
        })
    }
}
