//
//  TTReleaseCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTReleaseCellViewModel: TTDefaultTableViewCellViewModel {
    let release: TTRelease
    
    let userSelected = PublishSubject<TTUser>()
    
    init(release: TTRelease) {
        self.release = release
        super.init()
        title.accept("\(release.tagName ?? "") - \(release.name ?? "")")
        detail.accept(release.publishedAt?.toRelative())
        secondDetail.accept(release.body)
        imageUrl.accept(release.author?.avatarUrl)
        badge.accept(R.image.icon_cell_badge_tag()?.template)
        badgeColor.accept(UIColor.Material.green)
    }
}
