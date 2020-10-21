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
//        case contents(viewModel: TTcontent)
//        case source(viewModel: )
        case commits(viewModel: TTCommitsViewModel)
        case branches(viewModel: TTBranchesViewModel)
        case releases(viewModel: TTReleasesViewModel)
        case pullRequests(viewModel: TTPullRequestsViewModel)
        case pullRequestDetails(viewModel: TTPullRequestViewModel)
        case events(viewModel: TTEventsViewModel)
        case notifications(viewModel: TTNotificationsViewModel)
        case issues(viewModel: TTIssuesViewModel)
        case issueDetails(viewModel: TTIssueViewModel)
//        case linesCount(viewModel: TTline)
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
//        case .contents
            
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
}
