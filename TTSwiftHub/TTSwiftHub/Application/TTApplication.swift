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
    
    let navigator: Navigator
    
    private override init() {
        
        navigator = Navigator.default
        super.init()
        updateProvider()
    }
    
    private func updateProvider() {
        let useStaging = Configs.Network.useStaging
//        let githubProvider = useStaging ? GithubNet
    }
    
    func presentInitialScreen(in window: UIWindow?) {
        updateProvider()
        
        guard let _window = window, let _provider = provider else { return }
        self.window = _window
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if let user =
            
            let viewModel = TTMainTabBarViewModel(provider: _provider)
            self.navigator.show(segue: .tabs(viewModel: viewModel), sender: nil, transition: .root(in: _window))
        }
    }
}
