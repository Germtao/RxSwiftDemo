//
//  TTTrendingRepositoryCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/25.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import BonMot

class TTTrendingRepositoryCellViewModel: TTDefaultTableViewCellViewModel {
    
    let repository: TTTrendingRepository
    
    init(with repository: TTTrendingRepository, since: TTTrendingPeriodSegments) {
        self.repository = repository
        super.init()
        
        title.accept(repository.fullname)
        detail.accept(repository.descriptionField)
        attributedDetail.accept(repository.attributetDetail(since: since.title))
        imageUrl.accept(repository.avatarUrl)
        badge.accept(R.image.icon_cell_badge_repository()?.template)
        badgeColor.accept(UIColor.Material.green900)
    }
}

extension TTTrendingRepositoryCellViewModel {
    static func ==(lhs: TTTrendingRepositoryCellViewModel, rhs: TTTrendingRepositoryCellViewModel) -> Bool {
        return lhs.repository == rhs.repository
    }
}

extension TTTrendingRepository {
    func attributetDetail(since: String) -> NSAttributedString {
        let startImage = R.image.icon_cell_badge_star()?
            .filled(withColor: .text)
            .scaled(toHeight: 15)?
            .styled(with: .baselineOffset(-3)) ?? NSAttributedString()
        let starsString = (stars ?? 0).kFormatted.styled(with: .color(.text))
        let currentPeriodStarsString = "\((currentPeriodStars ?? 0).kFormatted) \(since.lowercased())".styled(with: .color(.text))
        let languageColorShape = "●".styled(with: StringStyle([.color(UIColor(hexString: languageColor ?? "") ?? .clear)]))
        let languageString = (language ?? "").styled(with: .color(.text))
        return NSAttributedString.composed(of: [
            startImage,
            Special.space,
            starsString,
            Special.space,
            Special.tab,
            startImage,
            Special.space,
            currentPeriodStarsString,
            Special.space,
            Special.tab,
            languageColorShape,
            Special.space,
            languageString
        ])
    }
}
