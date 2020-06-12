//
//  TTCommitCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/12.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTCommitCellViewModel: TTDefaultTableViewCellViewModel {
    let commit: TTCommit
    
    let userSelected = PublishSubject<TTUser>()
    
    init(commit: TTCommit) {
        self.commit = commit
        super.init()
        title.accept(commit.commit?.message)
        detail.accept(commit.commit?.committer?.date?.toRelative())
        secondDetail.accept(commit.sha?.slicing(from: 0, length: 7))
        imageUrl.accept(commit.committer?.avatarUrl)
        badge.accept(R.image.icon_cell_badge_commit()?.template)
        badgeColor.accept(UIColor.Material.green)
    }
}
