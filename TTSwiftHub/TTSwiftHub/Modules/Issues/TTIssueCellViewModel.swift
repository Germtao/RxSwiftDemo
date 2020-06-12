//
//  TTIssueCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/12.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import BonMot

class TTIssueCellViewModel: TTDefaultTableViewCellViewModel {
    let issue: TTIssue
    
    let userSelected = PublishSubject<TTUser>()
    
    init(issue: TTIssue) {
        self.issue = issue
        super.init()
        title.accept(issue.title)
        detail.accept(issue.detail)
        attributedDetail.accept(issue.attributedDetail())
        imageUrl.accept(issue.user?.avatarUrl)
        badge.accept(R.image.icon_cell_badge_issue()?.template)
        badgeColor.accept(issue.state == .open ? UIColor.Material.green : UIColor.Material.red)
    }
}

extension TTIssue {
    var detail: String {
        switch state {
        case .open: return "#\(number ?? 0) opened \(createdAt?.toRelative() ?? "") by \(user?.login ?? "")"
        case .closed: return "#\(number ?? 0) closed \(closedAt?.toRelative() ?? "") by \(user?.login ?? "")"
        case .all: return ""
        }
    }
    
    func attributedDetail() -> NSAttributedString {
        var texts: [NSAttributedString] = []
        if let commentsString = comments?.string.styled(with: .color(.text)) {
            let commentsImage = R.image.icon_cell_badge_comment()?.filled(withColor: .secondary).scaled(toHeight: 15)?.styled(with: .baselineOffset(-3)) ?? NSAttributedString()
            texts.append(NSAttributedString.composed(of: [
                commentsImage, Special.space, commentsString, Tab.headIndent(10)
            ]))
        }
        
        labels?.forEach({ label in
            if let name = label.name, let color = UIColor(hexString: label.color ?? "") {
                let labelString = " \(name) ".styled(with: .color(color.darken(by: 0.35).brightnessAdjustedColor),
                                                     .backgroundColor(color),
                                                     .lineHeightMultiple(1.2),
                                                     .baselineOffset(1))
                texts.append(NSAttributedString.composed(of: [
                    labelString, Special.space
                ]))
            }
        })
        
        return NSAttributedString.composed(of: texts)
    }
}
