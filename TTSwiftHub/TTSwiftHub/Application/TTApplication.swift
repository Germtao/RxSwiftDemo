//
//  TTApplication.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTApplication: NSObject {
    static let shared = TTApplication()
    
    var window: UIWindow?
    
    var provider: TTSwiftHubAPI?
    let authManager: TTAuthManager
    let navigator: Navigator
    
    private override init() {
        authManager = TTAuthManager.shared
        navigator = Navigator.default
        super.init()
        updateProvider()
    }
    
    private func updateProvider() {
        let useStaging = Configs.Network.useStaging
        let githubProvider = useStaging ? TTGithubNetworking.stubbingNetworking() : TTGithubNetworking.defaultNetworking()
        let trendingGithubProvider = useStaging ? TTTrendingGithubNetworking.stubbingNetworking() : TTTrendingGithubNetworking.defaultNetworking()
        let codetabsProvider = useStaging ? TTCodetabsNetworking.stubbingNetworking() : TTCodetabsNetworking.defaultNetworking()
        let restApi = TTRestApi(
            githubProvider: githubProvider,
            trendingGithubProvider: trendingGithubProvider,
            codetabsProvider: codetabsProvider
        )
        provider = restApi
        
        if let token = authManager.token, !Configs.Network.useStaging {
            switch token.type() {
            case .oAuth(let token):
//                provider = Grap
            logError("开始授权")
            default: break
            }
        }
    }
    
    func presentInitialScreen(in window: UIWindow?) {
        updateProvider()
        
        guard let window = window, let provider = provider else { return }
        self.window = window
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let user = TTUser.currentUser(), let login = user.login {
                analytics.identify(userId: login)
                analytics.set(.name(value: user.name ?? ""))
                analytics.set(.email(value: user.email ?? ""))
            }
            
            let authorized = self?.authManager.token?.isValid ?? false
            let viewModel = TTMainTabBarViewModel(provider: provider)
            self?.navigator.show(segue: .tabs(viewModel: viewModel), sender: nil, transition: .root(in: window))
        }
    }
    
    func presentTestScreen(in window: UIWindow?) {
        guard let window = window, let provider = provider else { return }
        
        let viewModel = TTUserViewModel(user: TTUser(), provider: provider)
        navigator.show(segue: .userDetails(viewModel: viewModel), sender: nil, transition: .root(in: window))
    }
}
