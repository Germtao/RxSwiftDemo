//
//  TTWebViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/22.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit

class TTWebViewController: TTBaseViewController {
    
    let url = BehaviorRelay<URL?>(value: nil)
    
    lazy var rightBarButton = TTBarButtonItem(
        image: R.image.icon_navigation_web(),
        style: .done,
        target: nil,
        action: nil
    )
    
    lazy var goBackBarButton = TTBarButtonItem(
        image: R.image.icon_navigation_back(),
        style: .done,
        target: nil,
        action: nil
    )
    
    lazy var goForwardBarButton = TTBarButtonItem(
        image: R.image.icon_navigation_forward(),
        style: .done,
        target: nil,
        action: nil
    )
    
    lazy var stopReloadBarButton = TTBarButtonItem(
        image: R.image.icon_navigation_refresh(),
        style: .done,
        target: nil,
        action: nil
    )
    
    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        view.uiDelegate = self
        return view
    }()
    
    lazy var toolbar: TTToolbar = {
        let view = TTToolbar()
        view.items = [self.goBackBarButton, self.goForwardBarButton, self.spaceBarItem, self.stopReloadBarButton]
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func makeUI() {
        super.makeUI()
        
        navigationItem.rightBarButtonItem = rightBarButton
        stackView.insertArrangedSubview(webView, at: 0)
        stackView.addArrangedSubview(toolbar)
        canOpenFlex = false
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        rightBarButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] () in
                if let url = self?.url.value {
                    self?.navigator.show(segue: .safari(url), sender: self, transition: .custom)
                }
            })
            .disposed(by: rx.disposeBag)
        
        url.map { $0?.absoluteString }
            .asObservable()
            .bind(to: navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        goBackBarButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] () in
                self?.webView.goBack()
            })
            .disposed(by: rx.disposeBag)
        
        goForwardBarButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] () in
                self?.webView.goForward()
            })
            .disposed(by: rx.disposeBag)
        
        stopReloadBarButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] () in
                if let webView = self?.webView {
                    if webView.isLoading {
                        webView.stopLoading()
                    } else {
                        webView.reload()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func updateUI() {
        super.updateUI()
        
        goBackBarButton.isEnabled = webView.canGoBack
        goForwardBarButton.isEnabled = webView.canGoForward
        stopReloadBarButton.image = webView.isLoading ? R.image.icon_navigation_stop() : R.image.icon_navigation_refresh()
    }
    
    func load(url: URL) {
        self.url.accept(url)
        webView.load(URLRequest(url: url))
    }
}

extension TTWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.url.accept(webView.url)
        updateUI()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateUI()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateUI()
    }
}

extension TTWebViewController: WKUIDelegate { }
