//
//  Navigator.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import Hero
import RxSwift
import RxCocoa
import SafariServices
import WhatsNewKit
import MessageUI
import AcknowList

protocol Navigatable {
    var navigator: Navigator! { get set }
}

class Navigator {
    static var `default` = Navigator()
    
    enum Scene {
        case tabs(viewModel: TTMainTabBarViewModel)
        case search(viewModel: TTSearchViewModel)
        case languages(viewModel: TTLanguagesViewModel)
        case users(viewModel: TTUserViewModel)
        case userDetails(viewModel: TTUserViewModel)
        case repositories(viewModel: TTRepositoriesViewModel)
        case repositoryDetails(viewModel: TTRepositoryViewModel)
        case contents(viewModel: TTContentsViewModel)
        case source(viewModel: TTSourceViewModel)
        case commits(viewModel: TTCommitsViewModel)
        case branches(viewModel: TTBranchesViewModel)
        case releases(viewModel: TTReleasesViewModel)
        case pullRequests(viewModel: TTPullRequestsViewModel)
        case pullRequestDetails(viewModel: TTPullRequestViewModel)
        case events(viewModel: TTEventsViewModel)
        case notifications(viewModel: TTNotificationsViewModel)
        case issues(viewModel: TTIssuesViewModel)
        case issueDetails(viewModel: TTIssueViewModel)
        case linesCount(viewModel: TTLinesCountViewModel)
        case theme(viewModel: TTThemeViewModel)
        case language(viewModel: TTLanguageViewModel)
        case acknowledgements
        case contacts(viewModel: TTContactsViewModel)
        case whatsNew(block: WhatsNewBlock)
        case safari(URL)
        case safariController(URL)
        case webController(URL)
    }
    
    enum Transition {
        case root(in: UIWindow)
        case navigation(type: HeroDefaultAnimationType)
        case customModal(type: HeroDefaultAnimationType)
        case modal
        case detail
        case alert
        case custom
    }
    
    // MARK: - get a single VC
    func get(segue: Scene) -> UIViewController? {
        switch segue {
        case .tabs(let viewModel):
            let rootVc = TTMainViewController(viewModel: viewModel, navigator: self)
            let detailVc = InitialSplitViewController(viewModel: nil, navigator: self)
            let detailNavVc = TTNavigationController(rootViewController: detailVc)
            let splitVc = TTSplitViewController()
            splitVc.viewControllers = [rootVc, detailNavVc]
            return splitVc
        case .search(let viewModel):
            return TTSearchViewController(viewModel: viewModel, navigator: self)
        case .languages(let viewModel):
            return TTLanguagesViewController(viewModel: viewModel, navigator: self)
        case .users(let viewModel):
            return TTUsersViewController(viewModel: viewModel, navigator: self)
        case .userDetails(let viewModel):
            return TTUserViewController(viewModel: viewModel, navigator: self)
        case .repositories(let viewModel):
            return TTRepositoriesViewController(viewModel: viewModel, navigator: self)
        case .repositoryDetails(let viewModel):
            return TTRepositoryViewController(viewModel: viewModel, navigator: self)
        case .contents(let viewModel):
            return TTContentsViewController(viewModel: viewModel, navigator: self)
        case .source(let viewModel):
            return TTSourceViewController(viewModel: viewModel, navigator: self)
        case .commits(let viewModel):
            return TTCommitsViewController(viewModel: viewModel, navigator: self)
        case .branches(let viewModel):
            return TTBranchesViewController(viewModel: viewModel, navigator: self)
        case .releases(let viewModel):
            return TTReleasesViewController(viewModel: viewModel, navigator: self)
        case .pullRequests(let viewModel):
            return TTPullRequestsViewController(viewModel: viewModel, navigator: self)
        case .pullRequestDetails(let viewModel):
            return TTPullRequestViewController(viewModel: viewModel, navigator: self)
        case .events(let viewModel):
            return TTEventsViewController(viewModel: viewModel, navigator: self)
        case .notifications(let viewModel):
            return TTNotificationsViewController(viewModel: viewModel, navigator: self)
        case .issues(let viewModel):
            return TTIssuesViewController(viewModel: viewModel, navigator: self)
        case .issueDetails(let viewModel):
            return TTIssueViewController(viewModel: viewModel, navigator: self)
        case .linesCount(let viewModel):
            return TTLinesCountViewController(viewModel: viewModel, navigator: self)
        case .theme(let viewModel):
            return TTThemeViewController(viewModel: viewModel, navigator: self)
        case .language(let viewModel):
            return TTLanguageViewController(viewModel: viewModel, navigator: self)
        case .acknowledgements:
            return AcknowListViewController()
        case .contacts(let viewModel):
            return TTContactsViewController(viewModel: viewModel, navigator: self)
            
        case .whatsNew(let block):
            if let versionStore = block.2 {
                return WhatsNewViewController(whatsNew: block.0, configuration: block.1, versionStore: versionStore)
            } else {
                return WhatsNewViewController(whatsNew: block.0, configuration: block.1)
            }
        case .safari(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return nil
        case .safariController(let url):
            return SFSafariViewController(url: url)
        case .webController(let url):
            let vc = TTWebViewController(viewModel: nil, navigator: self)
            vc.load(url: url)
            return vc
        }
    }
    
    // MARK: - 跳转
    
    func pop(current sender: UIViewController?, toRoot: Bool = false) {
        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: true)
        } else {
            sender?.navigationController?.popViewController(animated: true)
        }
    }
    
    func dismiss(current sender: UIViewController?) {
        sender?.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - invoke a single segue
    func show(segue: Scene,
              sender: UIViewController?,
              transition: Transition = .navigation(type: .cover(direction: .left))) {
        if let target = get(segue: segue) {
            show(target: target, sender: sender, transition: transition)
        }
    }
    
    private func show(target: UIViewController, sender: UIViewController?, transition: Transition) {
        switch transition {
        case .root(in: let window):
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = target
            }, completion: nil)
            return
        case .custom: return
        default: break
        }
        
        guard let _sender = sender else {
            fatalError("You need to pass in a sender for .navigation or .modal transitions")
        }
        
        if let nav = sender as? UINavigationController {
            // push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }
        
        switch transition {
        case .navigation(let type):
            if let nav = _sender.navigationController {
                // push controller to navigation stack
                nav.hero.navigationAnimationType = .autoReverse(presenting: type)
                nav.pushViewController(target, animated: true)
            }
        case .customModal(let type):
            // present modally with custom animation
            DispatchQueue.main.async {
                let nav = TTNavigationController(rootViewController: target)
                nav.hero.modalAnimationType = .autoReverse(presenting: type)
                _sender.present(nav, animated: true, completion: nil)
            }
        case .modal:
            // present modally
            DispatchQueue.main.async {
                let nav = TTNavigationController(rootViewController: target)
                _sender.present(nav, animated: true, completion: nil)
            }
        case .detail:
            DispatchQueue.main.async {
                let nav = TTNavigationController(rootViewController: target)
                _sender.showDetailViewController(nav, sender: nil)
            }
        case .alert:
            DispatchQueue.main.async {
                _sender.present(target, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func toInviteContact(with phone: String) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.body = "Hey! Come join SwiftHub at \(Configs.App.githubUrl)"
        vc.recipients = [phone]
        return vc
    }
}
