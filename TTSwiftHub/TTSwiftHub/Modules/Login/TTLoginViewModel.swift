//
//  TTLoginViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SafariServices

private let loginURL = URL(string: "http://github.com/login/oauth/authorize?client_id=\(Keys.github.appId)&scope=user+repo+notifications+read:org")!
private let callbackURLScheme = "swifthub"

enum TTLoginSegments: Int {
    case oAuth, basic
    
    var title: String {
        switch self {
        case .oAuth: return R.string.localizable.loginOAuthSegmentTitle.key.localized()
        case .basic: return R.string.localizable.loginBasicSegmentTitle.key.localized()
        }
    }
}

class TTLoginViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let segmentSelection: Driver<TTLoginSegments>
        let basicLoginTrigger: Driver<Void>
        let oAuthLoginTrigger: Driver<Void>
    }
    
    struct Output {
        let basicLoginTrigger: Driver<Void>
        let oAuthLoginTrigger: Driver<Void>
        let basicLoginButtonEnabled: Driver<Bool>
        let hidesBasicLoginView: Driver<Bool>
        let hidesOAuthLoginView: Driver<Bool>
    }
    
    let login = BehaviorRelay(value: "")
    let password = BehaviorRelay(value: "")
    
    let code = PublishSubject<String>()
    let tokenSaved = PublishSubject<Void>()
    
    private var _authSession: Any?
    
    private var authSession: SFAuthenticationSession? {
        set {
            _authSession = newValue
        }
        get {
            _authSession as? SFAuthenticationSession
        }
    }
    
    func transform(input: Input) -> Output {
        let basicLoginTrigger = input.basicLoginTrigger
        basicLoginTrigger.drive(onNext: { [weak self] () in
            if let login = self?.login.value,
               let password = self?.password.value,
               let authHash = "\(login):\(password)".base64Encoded {
                TTAuthManager.setToken(token: TTToken(basicToken: authHash))
                self?.tokenSaved.onNext(())
            }
        }).disposed(by: rx.disposeBag)
        
        let oAuthLoginTrigger = input.oAuthLoginTrigger
        oAuthLoginTrigger.drive(onNext: { [weak self] () in
            self?.authSession = SFAuthenticationSession(url: loginURL, callbackURLScheme: callbackURLScheme, completionHandler: { (callbackUrl, error) in
                if let error = error {
                    logError(error.localizedDescription)
                }
                
                if let codeValue = callbackUrl?.queryParameters?["code"] {
                    self?.code.onNext(codeValue)
                }
            })
            
            self?.authSession?.start()
            
        }).disposed(by: rx.disposeBag)
        
        code.flatMapLatest { code -> Observable<TTToken> in
            let clientId = Keys.github.appId
            let clientSecret = Keys.github.apiKey
            return self.provider.createAccessToken(clientId: clientId, clientSecret: clientSecret, code: code, redirectUri: nil, state: nil)
                .trackActivity(self.loading)
                .trackError(self.error)
        }.subscribe { [weak self] event in
            switch event {
            case .next(let token):
                TTAuthManager.setToken(token: token)
                self?.tokenSaved.onNext(())
            case .error(let error):
                logError(error.localizedDescription)
            default: break
            }
        }.disposed(by: rx.disposeBag)
        
        tokenSaved.flatMapLatest { () -> Observable<RxSwift.Event<TTUser>> in
            return self.provider.profile()
                .trackActivity(self.loading)
                .trackError(self.error)
                .materialize()
        }.subscribe(onNext: { event in
            switch event {
            case .next(let user):
                user.save()
                TTAuthManager.tokenValidated()
                if let login = user.login, let type = TTAuthManager.shared.token?.type().description {
                    analytics.log(.login(login: login, type: type))
                }
                TTApplication.shared.presentInitialScreen(in: TTApplication.shared.window)
            case .error(let error):
                logError(error.localizedDescription)
                TTAuthManager.removeToken()
            default: break
            }
        }).disposed(by: rx.disposeBag)
        
        let basicLoginButtonEnabled = BehaviorRelay.combineLatest(login, password, loading.asObservable()) {
            return $0.isNotEmpty && $1.isNotEmpty && !$2
        }.asDriver(onErrorJustReturn: false)
        
        let hidesBasicLoginView = input.segmentSelection.map { $0 != TTLoginSegments.basic }
        let hidesOAuthLoginView = input.segmentSelection.map { $0 != TTLoginSegments.oAuth }
        
        return Output(
            basicLoginTrigger: basicLoginTrigger,
            oAuthLoginTrigger: oAuthLoginTrigger,
            basicLoginButtonEnabled: basicLoginButtonEnabled,
            hidesBasicLoginView: hidesBasicLoginView,
            hidesOAuthLoginView: hidesOAuthLoginView
        )
    }
}
