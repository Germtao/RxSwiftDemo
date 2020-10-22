//
//  TTBaseViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Localize_Swift
import GoogleMobileAds
import DZNEmptyDataSet
import Hero
import NVActivityIndicatorView

class TTBaseViewController: UIViewController, Navigatable, NVActivityIndicatorViewable {
    
    var viewModel: TTViewModel?
    var navigator: Navigator!
    
    init(viewModel: TTViewModel?, navigator: Navigator) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    let isLoading = BehaviorRelay(value: false)
    let error = PublishSubject<ApiError>()
    
    var automaticallyAdjustsLeftBarButtonItem = true
    var canOpenFlex = true
    
    var navigationTitle: String = "" {
        didSet {
            navigationItem.title = navigationTitle
        }
    }
    
    let spaceBarItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    let emptyDataSetButtonTap = PublishSubject<Void>()
    var emptyDataSetTitle = R.string.localizable.commonNoResults.key.localized()
    var emptyDataSetDescription = ""
    var emptyDataSetImage = R.image.image_no_result()
    var emptyDataSetImageTintColor = BehaviorRelay<UIColor?>(value: nil)
    
    let languageChanged = BehaviorRelay<Void>(value: ())
    
    let motionShakeEvent = PublishSubject<Void>()
    
    lazy var searchBar = UISearchBar()
    
    lazy var backBarItem: TTBarButtonItem = {
        let item = TTBarButtonItem()
        item.title = ""
        return item
    }()
    
    lazy var closeBarItem: TTBarButtonItem = {
        let item = TTBarButtonItem(image: R.image.icon_navigation_close(),
                                   style: .plain,
                                   target: self,
                                   action: nil)
        return item
    }()
    
    lazy var bannerView: GADBannerView = {
        let banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        banner.rootViewController = self
        banner.adUnitID = Keys.adMob.apiKey
        banner.hero.id = "BannerView"
        return banner
    }()
    
    lazy var contentView: UIView = {
        let content = UIView()
//        content.hero.id = "ContentView"
        self.view.addSubview(content)
        content.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        return content
    }()
    
    lazy var stackView: TTStackView = {
        let subviews: [UIView] = []
        let stack = TTStackView(arrangedSubviews: subviews)
        stack.spacing = 0
        self.contentView.addSubview(stack)
        stack.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bindViewModel()
        
        closeBarItem.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] in
                self?.navigator.dismiss(current: self)
            })
            .disposed(by: rx.disposeBag)
        
        // 监听设备方向
        NotificationCenter.default
            .rx.notification(UIDevice.orientationDidChangeNotification)
            .subscribe(onNext: { [weak self] event in
                self?.orientationChanged()
            })
            .disposed(by: rx.disposeBag)
        
        // 监听应用激活
        NotificationCenter.default
            .rx.notification(UIApplication.didBecomeActiveNotification)
            .subscribe(onNext: { [weak self] event in
                self?.didBecomeActive()
            })
            .disposed(by: rx.disposeBag)
        
        NotificationCenter.default
            .rx.notification(UIAccessibility.reduceMotionStatusDidChangeNotification)
            .subscribe(onNext: { event in
                logDebug("Motion Status changed")
            })
            .disposed(by: rx.disposeBag)
        
        // 监听应用更换了语言
        NotificationCenter.default
            .rx.notification(NSNotification.Name(LCLLanguageChangeNotification))
            .subscribe(onNext: { [weak self] event in
                self?.languageChanged.accept(())
            })
            .disposed(by: rx.disposeBag)
        
        // 一根手指轻扫打开Flex
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleOneFingerSwipe(_:)))
        swipeGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeGesture)
        
        // 两指轻扫打开Flex和Hero调试
        let twoSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleTwoFingerSwipe(_:)))
        swipeGesture.numberOfTouchesRequired = 2
        view.addGestureRecognizer(twoSwipeGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if automaticallyAdjustsLeftBarButtonItem {
            adjustLeftBarButtonItem()
        }
        
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateUI()
        
        logResourcesCount()
    }
    
    deinit {
        logDebug("\(type(of: self)): Deinited")
        logResourcesCount()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        logDebug("\(type(of: self)): Received Memory Warning")
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            motionShakeEvent.onNext(())
        }
    }
    
    func makeUI() {
        hero.isEnabled = true
        navigationItem.backBarButtonItem = backBarItem
        
        bannerView.load(GADRequest())
        TTLibsManager.shared.bannersEnabled
            .asDriver() // Driver序列不允许发出error, Driver序列的监听只会在主线程中
            .drive(onNext: { [weak self] enabled in
                guard let self = self else { return }
                
                self.bannerView.removeFromSuperview()
                self.stackView.removeArrangedSubview(self.bannerView)
                
                if enabled {
                    self.stackView.addArrangedSubview(self.bannerView)
                }
            })
            .disposed(by: rx.disposeBag)
        
        languageChanged
            .subscribe(onNext: { [weak self] in
                self?.emptyDataSetTitle = R.string.localizable.commonNoResults.key.localized()
            })
            .disposed(by: rx.disposeBag)
        
        motionShakeEvent
            .subscribe(onNext: {
                let theme = themeService.type.toggled()
                themeService.switch(theme)
            })
            .disposed(by: rx.disposeBag)
        
        themeService.rx
            .bind({ $0.primaryDark }, to: view.rx.backgroundColor)
            .bind({ $0.secondary }, to: [backBarItem.rx.tintColor, closeBarItem.rx.tintColor])
            .bind({ $0.text }, to: self.rx.emptyDataSetImageTintColorBinder)
            .disposed(by: rx.disposeBag)
        
        updateUI()
    }
    
    func bindViewModel() {
        
    }
    
    func updateUI() {
        
    }
}

extension TTBaseViewController {
    /// 方向改变
    func orientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateUI()
        }
    }
    
    /// 应用激活
    func didBecomeActive() {
        updateUI()
    }
    
    /// 适配导航item
    func adjustLeftBarButtonItem() {
        if navigationController?.viewControllers.count ?? 0 > 1 { // pushed
            navigationItem.leftBarButtonItem = nil
        } else if presentingViewController != nil { // presented
            navigationItem.leftBarButtonItem = closeBarItem
        }
    }
}

extension TTBaseViewController {
    func emptyView(with height: CGFloat) -> TTView {
        let view = TTView()
        view.snp.makeConstraints { (make) in
            make.height.equalTo(height)
        }
        return view
    }
    
    @objc func handleOneFingerSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .recognized, canOpenFlex {
            TTLibsManager.shared.showFlex()
        }
    }
    
    @objc func handleTwoFingerSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .recognized {
            TTLibsManager.shared.showFlex()
            HeroDebugPlugin.isEnabled = !HeroDebugPlugin.isEnabled
        }
    }
}

extension TTBaseViewController {
    var inset: CGFloat {
        return Configs.BaseDimensions.inset
    }
}

extension Reactive where Base: TTBaseViewController {
    /// “ backgroundColor”属性的可绑定接收器
    var emptyDataSetImageTintColorBinder: Binder<UIColor?> {
        return Binder(self.base) { (view, attr) in
            view.emptyDataSetImageTintColor.accept(attr)
        }
    }
}

extension TTBaseViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: emptyDataSetTitle)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: emptyDataSetDescription)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return emptyDataSetImage
    }
    
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return emptyDataSetImageTintColor.value
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .clear
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -60
    }
}

extension TTBaseViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return !isLoading.value
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        emptyDataSetButtonTap.onNext(())
    }
}
