//
//  Observable+Logging.swift
//  TTSwiftHub
//
//  Created by QDSG on 2021/2/24.
//  Copyright © 2021 tTao. All rights reserved.
//

import Foundation
import RxSwift

extension Observable {
    func logError(prefix: String = "Error: ") -> Observable<Element> {
        return self.do(onNext: nil,
                       afterNext: nil,
                       onError: { (error) in print("\(prefix)\(error)") },
                       afterError: nil,
                       onCompleted: nil,
                       afterCompleted: nil,
                       onSubscribe: nil,
                       onSubscribed: nil,
                       onDispose: nil)
    }
    
    func logServerError(message: String) -> Observable<Element> {
        return self.do(onNext: nil,
                       afterNext: nil,
                       onError: { (error) in
                        print(message)
                        print("Error: \(error.localizedDescription). \n")
                       },
                       afterError: nil,
                       onCompleted: nil,
                       afterCompleted: nil,
                       onSubscribe: nil,
                       onSubscribed: nil,
                       onDispose: nil)
    }
    
    func logNext() -> Observable<Element> {
        return self.do(onNext: { (element) in print(element) },
                       afterNext: nil,
                       onError: nil,
                       afterError: nil,
                       onCompleted: nil,
                       afterCompleted: nil,
                       onSubscribe: nil,
                       onSubscribed: nil,
                       onDispose: nil)
    }
}
