//
//  TTRepositoryCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/9.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import BonMot

class TTRepositoryCellViewModel: TTDefaultTableViewCellViewModel {
    let starring = BehaviorRelay<Bool>(value: false)
    let hidesStarButton = BehaviorRelay<Bool>(value: true)
    
    let repository: TTRepository
    
    init(repository: TTRepository) {
        self.repository = repository
        super.init()
        title.accept(repository.fullname)
        detail.accept(repository.descriptionField)
        attributedDetail.accept(repository.attributetDetail())
        imageUrl.accept(repository.owner?.avatarUrl)
        badge.accept(R.image.icon_cell_badge_repository()?.template)
        badgeColor.accept(UIColor.Material.green900)
        
        starring.accept(repository.viewerHasStarred ?? false)
        loggedIn.map { !$0 || repository.viewerHasStarred == nil }
            .bind(to: hidesStarButton)
            .disposed(by: rx.disposeBag)
    }
}

extension TTRepositoryCellViewModel {
    static func == (lhs: TTRepositoryCellViewModel, rhs: TTRepositoryCellViewModel) -> Bool {
        return lhs.repository == rhs.repository
    }
}

extension TTRepository {
    func attributetDetail() -> NSAttributedString? {
        var texts: [NSAttributedString] = []
        
        let starsString = (stargazersCount ?? 0).kFormatted.styled(with: .color(UIColor.text))
        let starsImage = R.image.icon_cell_star()?.filled(withColor: UIColor.text).scaled(toHeight: 15)?.styled(with: .baselineOffset(-3)) ?? NSAttributedString()
        
        texts.append(NSAttributedString.composed(of: [
            starsImage, Special.space, starsString, Special.space, Special.tab
        ]))
        
        if let languageStr = language?.styled(with: .color(UIColor.text)) {
            let languageColorShape = "●".styled(with: StringStyle([.color(UIColor(hexString: languageColor ?? "") ?? .clear)]))
            texts.append(NSAttributedString.composed(of: [
                languageColorShape, Special.space, languageStr
            ]))
        }
        
        return NSAttributedString.composed(of: texts)
    }
}
