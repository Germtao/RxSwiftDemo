//
//  SceneDelegate.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/13.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import Toast_Swift

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        if windowScene.activationState == .foregroundActive {
            window = windowScene.windows.first
        }
        
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
        
        TTApplication.shared.presentInitialScreen(in: window)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

