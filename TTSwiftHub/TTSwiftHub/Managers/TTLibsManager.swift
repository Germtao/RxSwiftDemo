//
//  TTLibsManager.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

#if DEBUG
import FLEX
#endif

import CocoaLumberjack
import DropDown
import Toast_Swift
import Kingfisher
import IQKeyboardManagerSwift
import NVActivityIndicatorView
import KafkaRefresh
import Firebase
import Mixpanel

typealias DropDownView = DropDown

/// 用于配置应用中使用的所有库的manager类
class TTLibsManager: NSObject {
    
    static let shared = TTLibsManager()
    
    let bannersEnabled = BehaviorRelay(value: UserDefaults.standard.bool(forKey: Configs.UserDefaultsKeys.bannersEnabled))
    
    override init() {
        super.init()
        
        if UserDefaults.standard.object(forKey: Configs.UserDefaultsKeys.bannersEnabled) == nil {
            bannersEnabled.accept(true)
        }
        
        bannersEnabled
            .skip(1) // 从1开始
            .subscribe(onNext: { enabled in
                UserDefaults.standard.set(enabled, forKey: Configs.UserDefaultsKeys.bannersEnabled)
                analytics.set(.adsEnabled(value: enabled))
            })
            .disposed(by: rx.disposeBag)
    }
}

extension TTLibsManager {
    func setupLibs(with window: UIWindow? = nil) {
        let libs = TTLibsManager.shared
        libs.setupCocoaLumberjack()
        libs.setupAnalytics()
        libs.setupAds()
        libs.setupFLEX()
        libs.setupTheme()
//        libs.setupKingfisher()
        libs.setupKeyboardManager()
        libs.setupActivityView()
        libs.setupKafkaRefresh()
        libs.setupToast()
        libs.setupDropDown()
    }
    
    func setupDropDown() {
        themeService.attrsStream.subscribe(onNext: { theme in
            DropDown.appearance().backgroundColor = theme.primary
            DropDown.appearance().selectionBackgroundColor = theme.primaryDark
            DropDown.appearance().textColor = theme.text
            DropDown.appearance().selectedTextColor = theme.text
            DropDown.appearance().separatorColor = theme.separator
        }).disposed(by: rx.disposeBag)
    }
    
    func setupToast() {
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.position = .top
        var style = ToastStyle()
        style.backgroundColor = UIColor.Material.red
        style.messageColor = UIColor.Material.white
        style.imageSize = CGSize(width: 20, height: 20)
        ToastManager.shared.style = style
    }
    
    func setupKafkaRefresh() {
        if let refresh = KafkaRefreshDefaults.standard() {
            refresh.headDefaultStyle = .replicatorAllen
            refresh.footDefaultStyle = .replicatorDot
            themeService.rx
                .bind({ $0.secondary }, to: refresh.rx.themeColor)
                .disposed(by: rx.disposeBag)
        }
    }
    
    func setupActivityView() {
        NVActivityIndicatorView.DEFAULT_TYPE = .ballRotateChase
        NVActivityIndicatorView.DEFAULT_COLOR = .secondary
    }
    
    func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
    }
    
    func setupKingfisher() {
        // 设置默认缓存的最大磁盘缓存大小。 默认值为0，表示没有限制
        ImageCache.default.diskStorage.config.sizeLimit = UInt(500 * 1024 * 1024) // 500M
        
        // 设置存储在磁盘中的缓存的最长持续时间。 默认值为1周
        ImageCache.default.diskStorage.config.expiration = .days(7)
        
        // 设置默认的图像下载器超时时间。 默认值为15秒
        ImageDownloader.default.downloadTimeout = 15
    }
        
    func setupTheme() {
        themeService.rx
            .bind({ $0.statusBarStyle }, to: UIApplication.shared.rx.statusBarStyle)
            .disposed(by: rx.disposeBag)
    }
    
    func setupCocoaLumberjack() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger = DDFileLogger() // file logger
        fileLogger.rollingFrequency = TimeInterval(60*60*24) // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    func setupFLEX() {
        #if DEBUG
        FLEXManager.shared.isNetworkDebuggingEnabled = true
        #endif
    }
    
    func setupAnalytics() {
        FirebaseApp.configure()
        Mixpanel.sharedInstance(withToken: Keys.mixpanel.apiKey)
    }
    
    func setupAds() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
}

extension TTLibsManager {
    func showFlex() {
        #if DEBUG
        FLEXManager.shared.showExplorer()
        analytics.log(.flexOpened)
        #endif
    }
    
    func removeKingfisherCache() -> Observable<Void> {
        return ImageCache.default.rx.clearCache()
    }
    
    func kingfisherCacheSize() -> Observable<Int> {
        return ImageCache.default.rx.retrieveCacheSize()
    }
}
