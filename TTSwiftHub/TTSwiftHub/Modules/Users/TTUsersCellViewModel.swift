//
//  TTUsersCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/9.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import BonMot

class TTUsersCellViewModel: TTDefaultTableViewCellViewModel {
    let following = BehaviorRelay<Bool>(value: false)
    let hidesFollowButton = BehaviorRelay<Bool>(value: true)
    
    let user: TTUser
    
    init(user: TTUser) {
        self.user = user
        super.init()
        title.accept(user.login)
        detail.accept("\(user.contributions != nil ? "\(user.contributions ?? 0) commits" : user.name ?? "")")
        attributedDetail.accept(user.attributedDetail())
        imageUrl.accept(user.avatarUrl)
        badge.accept(R.image.icon_cell_badge_user()?.template)
        badgeColor.accept(UIColor.Material.green900)
        
        following.accept(user.viewerIsFollowing ?? false)
        loggedIn.map { loggedIn -> Bool in
            if !loggedIn { return true }
            if let viewerCanFollow = user.viewerCanFollow { return !viewerCanFollow }
            return true
        }
        .bind(to: hidesFollowButton).disposed(by: rx.disposeBag)
    }
}

extension TTUsersCellViewModel {
    static func == (lhs: TTUsersCellViewModel, rhs: TTUsersCellViewModel) -> Bool {
        return lhs.user == rhs.user
    }
}

extension TTUser {
    func attributedDetail() -> NSAttributedString? {
        var texts: [NSAttributedString] = []
        
        if let repositoriesStr = repositoriesCount?.string.styled(with: .color(UIColor.text)) {
            let repositoriesImage = R.image.icon_cell_badge_repository()?.filled(withColor: UIColor.text).scaled(toHeight: 15)?.styled(with: .baselineOffset(-3)) ?? NSAttributedString()
            texts.append(NSAttributedString.composed(of: [
                repositoriesImage, Special.space, repositoriesStr, Special.space, Special.tab
            ]))
        }
        
        if let followersStr = followers?.kFormatted.styled(with: .color(UIColor.text)) {
            let followersImage = R.image.icon_cell_badge_collaborator()?.filled(withColor: UIColor.text).scaled(toHeight: 15)?.styled(with: .baselineOffset(-3)) ?? NSAttributedString()
            texts.append(NSAttributedString.composed(of: [
                followersImage, Special.space, followersStr
            ]))
         }
        
        return NSAttributedString.composed(of: texts)
    }
}
