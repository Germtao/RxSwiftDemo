//
//  TTMainViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController
import RxSwift
import Localize_Swift

enum MainTabBarItem: Int {
    case search, events, notifications, settings, login
    
    private func controller(with viewModel: TTViewModel, navigator: Navigator) -> UIViewController {
        switch self {
        case .search:
            let vc = TTSearchViewController(viewModel: viewModel, navigator: navigator)
            return TTNavigationController(rootViewController: vc)
        case .events:
            let vc = TTEventsViewController(viewModel: viewModel, navigator: navigator)
            return TTNavigationController(rootViewController: vc)
        case .notifications:
            let vc = TTNotificationsViewController(viewModel: viewModel, navigator: navigator)
            return TTNavigationController(rootViewController: vc)
        case .settings:
            let vc = TTSettingsViewController(viewModel: viewModel, navigator: navigator)
            return TTNavigationController(rootViewController: vc)
        case .login:
            let vc = TTLoginViewController(viewModel: viewModel, navigator: navigator)
            return TTNavigationController(rootViewController: vc)
        }
    }
    
    var image: UIImage? {
        switch self {
        case .search:        return R.image.icon_tabbar_search()
        case .events:        return R.image.icon_tabbar_news()
        case .notifications: return R.image.icon_tabbar_activity()
        case .settings:      return R.image.icon_tabbar_settings()
        case .login:         return R.image.icon_tabbar_login()
        }
    }
    
    var title: String {
        switch self {
        case .search:        return R.string.localizable.homeTabBarSearchTitle.key.localized()
        case .events:        return R.string.localizable.homeTabBarEventsTitle.key.localized()
        case .notifications: return R.string.localizable.homeTabBarNotificationsTitle.key.localized()
        case .settings:      return R.string.localizable.homeTabBarSettingsTitle.key.localized()
        case .login:         return R.string.localizable.homeTabBarLoginTitle.key.localized()
        }
    }
    
    var animation: RAMItemAnimation {
        var animation: RAMItemAnimation
        switch self {
        case .search:
            animation = RAMFlipLeftTransitionItemAnimations()
        case .events,
             .notifications,
             .login:
            animation = RAMBounceAnimation()
        case .settings:
            animation = RAMRightRotationAnimation()
        }
        
        _ = themeService.rx
            .bind({ $0.secondary }, to: animation.rx.iconSelectedColor)
            .bind({ $0.secondary }, to: animation.rx.textSelectedColor)
        
        return animation
    }
    
    func getController(with viewModel: TTViewModel, navigator: Navigator) -> UIViewController {
        let vc = controller(with: viewModel, navigator: navigator)
        let item = RAMAnimatedTabBarItem(title: title, image: image, tag: rawValue)
        item.animation = animation
        
        _ = themeService.rx
            .bind({ $0.text }, to: item.rx.iconColor)
            .bind({ $0.text }, to: item.rx.textColor)
        
        vc.tabBarItem = item
        return vc
    }
}

class TTMainViewController: RAMAnimatedTabBarController, Navigatable {
    
    var viewModel: TTMainTabBarViewModel?
    var navigator: Navigator!
    
    init(viewModel: TTViewModel?, navigator: Navigator) {
        self.viewModel = viewModel as? TTMainTabBarViewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bindViewModel()
    }
    
    func makeUI() {
        hero.isEnabled = true
        tabBar.hero.id = "TabBarID"
        tabBar.isTranslucent = false
        
        NotificationCenter.default
            .rx.notification(Notification.Name(LCLLanguageChangeNotification))
            .subscribe(onNext: { [weak self] event in
                self?.animatedItems.forEach {
                    $0.title = MainTabBarItem(rawValue: $0.tag)?.title
                }
                self?.setViewControllers(self?.viewControllers, animated: false)
                self?.setSelectIndex(from: 0, to: self?.selectedIndex ?? 0)
            })
            .disposed(by: rx.disposeBag)
        
        themeService.rx
            .bind({ $0.primaryDark }, to: tabBar.rx.barTintColor)
            .disposed(by: rx.disposeBag)
        
        themeService.typeStream
            .delay(DispatchTimeInterval.milliseconds(700), scheduler: MainScheduler.instance)
            .subscribe(onNext: { theme in
                switch theme {
                case .light(let color), .dark(let color):
                    self.changeSelectedColor(color.color, iconSelectedColor: color.color)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        guard let vm = viewModel else { return }
        
        let input = TTMainTabBarViewModel.Input(whatsNewTrigger: rx.viewDidAppear.mapToVoid())
        let output = vm.transform(input: input)
        
        output.tabBarItems
            .delay(.milliseconds(50))
            .drive(onNext: { [weak self] tabBarItems in
                guard let self = self else { return }
                let vcs = tabBarItems.map {
                    $0.getController(with: vm.viewModel(for: $0), navigator: self.navigator)
                }
                self.setViewControllers(vcs, animated: false)
            })
            .disposed(by: rx.disposeBag)
        
        output.openWhatsNew
            .drive(onNext: { [weak self] block in
                if Configs.Network.useStaging == false {
                    self?.navigator.show(segue: .whatsNew(block: block), sender: self, transition: .modal)
                }
            })
            .disposed(by: rx.disposeBag)
    }
}
