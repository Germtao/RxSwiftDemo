//
//  TTEventsCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/11.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTEventsCellViewModel: TTDefaultTableViewCellViewModel {
    let event: TTEvent
    
    let userSelected = PublishSubject<TTUser>()
    
    init(event: TTEvent) {
        self.event = event
        super.init()
        
        let actorName = event.actor?.login ?? ""
        var badgeImage: UIImage?
        var actionText = ""
        var body = ""
        
        switch event.type {
        case .fork:
            actionText = "forked"
            badgeImage = R.image.icon_cell_badge_fork()
        case .create:
            let payload = event.payload as? TTCreatePayload
            actionText = ["created", (payload?.refType.rawValue ?? ""), (payload?.ref ?? ""), "in"].joined(separator: " ")
            badgeImage = payload?.refType.image
        case .issueComment:
            let payload = event.payload as? TTIssueCommentPayload
            actionText = ["commented on issue", "#\(payload?.issue?.number ?? 0)", "at"].joined(separator: " ")
            body = payload?.comment?.body ?? ""
            badgeImage = R.image.icon_cell_badge_comment()
        case .issues:
            let payload = event.payload as? TTIssuesPayload
            actionText = [(payload?.action ?? ""), "issue", "in"].joined(separator: " ")
            body = payload?.issue?.title ?? ""
            badgeImage = R.image.icon_cell_badge_issue()
        case .member:
            let payload = event.payload as? TTMemberPayload
            actionText = [(payload?.action ?? ""), "\(payload?.member?.login ?? "")", "as a collaborator to"].joined(separator: " ")
            badgeImage = R.image.icon_cell_badge_collaborator()
        case .pullRequest:
            let payload = event.payload as? TTPullRequestPayload
            actionText = [(payload?.action ?? ""), "pull request", "#\(payload?.number ?? 0)", "in"].joined(separator: " ")
            body = payload?.pullRequest?.title ?? ""
            badgeImage = R.image.icon_cell_badge_pull_request()
        case .pullRequestReviewComment:
            let payload = event.payload as? TTPullRequestReviewCommentPayload
            actionText = ["commented on pull request", "#\(payload?.pullRequest?.number ?? 0)", "in"].joined(separator: " ")
            body = payload?.comment?.body ?? ""
            badgeImage = R.image.icon_cell_badge_comment()
        case .push:
            let payload = event.payload as? TTPushPayload
            actionText = ["pushed to", payload?.ref ?? "", "at"].joined(separator: " ")
            badgeImage = R.image.icon_cell_badge_push()
        case .release:
            let payload = event.payload as? TTReleasePayload
            actionText = [payload?.action ?? "", "release", payload?.release?.name ?? "", "in"].joined(separator: " ")
            body = payload?.release?.body ?? ""
            badgeImage = R.image.icon_cell_badge_tag()
        case .star:
            actionText = "starred"
            badgeImage = R.image.icon_cell_badge_star()
        default: break
        }
        
        let repoName = event.repository?.fullname ?? ""
        
        title.accept([actorName, actionText, repoName].joined(separator: " "))
        detail.accept(event.createdAt?.toRelative())
        secondDetail.accept(body)
        imageUrl.accept(event.actor?.avatarUrl)
        badge.accept(badgeImage?.template)
        badgeColor.accept(UIColor.Material.green)
    }
}

extension TTEventsCellViewModel {
    static func == (lhs: TTEventsCellViewModel, rhs: TTEventsCellViewModel) -> Bool {
        return lhs.event == rhs.event
    }
}

extension TTCreateEventType {
    var image: UIImage? {
        switch self {
        case .repository: return R.image.icon_cell_badge_repository()
        case .branch: return R.image.icon_cell_badge_branch()
        case .tag: return R.image.icon_cell_badge_tag()
        }
    }
}
