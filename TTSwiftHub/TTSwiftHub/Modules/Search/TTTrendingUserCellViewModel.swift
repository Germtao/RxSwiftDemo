//
//  TTTrendingUserCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/9.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTTrendingUserCellViewModel: TTDefaultTableViewCellViewModel {
    let user: TTTrendingUser
    
    init(user: TTTrendingUser) {
        self.user = user
        super.init()
        title.accept("\(user.username ?? "") (\(user.name ?? ""))")
        detail.accept(user.repo?.fullname)
        imageUrl.accept(user.avatar)
        badge.accept(R.image.icon_cell_badge_user()?.template)
        badgeColor.accept(UIColor.Material.green900)
    }
}

extension TTTrendingUserCellViewModel {
    static func == (lhs: TTTrendingUserCellViewModel, rhs: TTTrendingUserCellViewModel) -> Bool {
        return lhs.user == rhs.user
    }
}
