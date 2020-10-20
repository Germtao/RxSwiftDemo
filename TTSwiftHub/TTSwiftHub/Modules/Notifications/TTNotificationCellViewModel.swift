//
//  TTNotificationCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/20.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTNotificationCellViewModel: TTDefaultTableViewCellViewModel {
    let notification: TTNotification
    
    let userSelected = PublishSubject<TTUser>()
    
    init(with notification: TTNotification) {
        self.notification = notification
        super.init()
        
        let actionText = notification.subject?.title ?? ""
        let repoName = notification.repository?.fullname ?? ""
        
        title.accept([repoName, actionText].joined(separator: "\n"))
        detail.accept(notification.updatedAt?.toRelative())
        imageUrl.accept(notification.repository?.owner?.avatarUrl)
    }
}

extension TTNotificationCellViewModel {
    static func ==(lhs: TTNotificationCellViewModel, rhs: TTNotificationCellViewModel) -> Bool {
        return lhs.notification == rhs.notification
    }
}

