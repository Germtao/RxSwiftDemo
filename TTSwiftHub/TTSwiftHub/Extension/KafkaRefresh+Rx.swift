//
//  KafkaRefresh+Rx.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import KafkaRefresh

extension Reactive where Base: KafkaRefreshControl {
    public var isAnimating: Binder<Bool> {
        return Binder(self.base) { (refreshControl, active) in
            if !active {
                refreshControl.endRefreshing()
            }
        }
    }
}
