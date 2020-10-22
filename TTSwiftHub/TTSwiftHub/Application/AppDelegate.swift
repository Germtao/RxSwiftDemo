//
//  AppDelegate.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/13.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import Toast_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let libsManager = TTLibsManager.shared
        libsManager.setupLibs(with: window)
        
        if Configs.Network.useStaging {
            // logout
            TTUser.removeCurrentUser()
            TTAuthManager.removeToken()
            
            // Use Green Dark theme
            var theme = TTThemeType.currentTheme()
            if theme.isDark != true {
                theme = theme.toggled()
            }
            theme = theme.withColor(color: .green)
            themeService.switch(theme)
            
            // Disable banners
            libsManager.bannersEnabled.accept(false)
            
        } else {
            connectedToInternet()
                .skip(1)
                .subscribe(onNext: { [weak self] connected in
                    var style = ToastManager.shared.style
                    style.backgroundColor = connected ? UIColor.Material.green : UIColor.Material.red
                    let message = connected ? R.string.localizable.toastConnectionBackMessage.key.localized() : R.string.localizable.toastConnectionLostMessage.key.localized()
                    let image = connected ? R.image.icon_toast_success() : R.image.icon_toast_warning()
                    if let view = self?.window?.rootViewController?.view {
                        view.makeToast(message, position: .bottom, image: image, style: style)
                    }
                })
                .disposed(by: rx.disposeBag)
        }
        
        // Show initial screen
        TTApplication.shared.presentInitialScreen(in: window)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

