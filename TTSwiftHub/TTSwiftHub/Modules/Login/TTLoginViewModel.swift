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
    case oAuth, personal, basic
    
    var title: String {
        switch self {
        case .oAuth: return R.string.localizable.loginOAuthSegmentTitle.key.localized()
        case .personal: return R.string.localizable.loginPersonalSegmentTitle.key.localized()
        case .basic: return R.string.localizable.loginBasicSegmentTitle.key.localized()
        }
    }
}

class TTLoginViewModel: TTViewModel, TTViewModelType {
    struct Input {
        let segmentSelection: Driver<TTLoginSegments>
        let basicLoginTrigger: Driver<Void>
        let personalLoginTrigger: Driver<Void>
        let oAuthLoginTrigger: Driver<Void>
    }
    
    struct Output {
        let basicLoginButtonEnabled: Driver<Bool>
        let personalLoginButtonEnabled: Driver<Bool>
        let hidesBasicLoginView: Driver<Bool>
        let hidesPersonalLoginView: Driver<Bool>
        let hidesOAuthLoginView: Driver<Bool>
    }
    
    let login = BehaviorRelay(value: "")
    let password = BehaviorRelay(value: "")
    
    let personalToken = BehaviorRelay(value: "")
    
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
        
        input.personalLoginTrigger
            .drive(onNext: { [weak self] () in
                if let personalToken = self?.personalToken.value {
                    TTAuthManager.setToken(token: TTToken(personalToken: personalToken))
                    self?.tokenSaved.onNext(())
                }
            })
            .disposed(by: rx.disposeBag)
        
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
        
        let tokenRequest = code.flatMapLatest { code -> Observable<RxSwift.Event<TTToken>> in
            let clientId = Keys.github.appId
            let clientSecret = Keys.github.apiKey
            return self.provider.createAccessToken(clientId: clientId, clientSecret: clientSecret, code: code, redirectUri: nil, state: nil)
                .trackActivity(self.loading)
                .trackError(self.error)
                .materialize()
        }.share()
        tokenRequest.elements().subscribe(onNext: { [weak self] token in
            TTAuthManager.setToken(token: token)
            self?.tokenSaved.onNext(())
        }).disposed(by: rx.disposeBag)
        tokenRequest.errors().bind(to: serverError).disposed(by: rx.disposeBag)
        
        let profileRequest = tokenSaved.flatMapLatest { () -> Observable<RxSwift.Event<TTUser>> in
            return self.provider.profile()
                .trackActivity(self.loading)
                .materialize()
        }.share()
        profileRequest.elements().subscribe(onNext: { user in
            user.save()
            TTAuthManager.tokenValidated()
            if let login = user.login, let type = TTAuthManager.shared.token?.type().description {
                analytics.log(.login(login: login, type: type))
            }
            TTApplication.shared.presentInitialScreen(in: TTApplication.shared.window)
        }).disposed(by: rx.disposeBag)
        profileRequest.errors().bind(to: serverError).disposed(by: rx.disposeBag)
        
        serverError
            .subscribe(onNext: { (error) in
                TTAuthManager.removeToken()
            })
            .disposed(by: rx.disposeBag)
        
        let basicLoginButtonEnabled = BehaviorRelay.combineLatest(login, password, loading.asObservable()) {
            return $0.isNotEmpty && $1.isNotEmpty && !$2
        }.asDriver(onErrorJustReturn: false)
        
        let personalLoginButtonEnabled = BehaviorRelay.combineLatest(personalToken, loading.asObservable()) {
            return $0.isNotEmpty && !$1
        }.asDriver(onErrorJustReturn: false)
        
        let hidesBasicLoginView = input.segmentSelection.map { $0 != TTLoginSegments.basic }
        let hidesPersonalLoginView = input.segmentSelection.map { $0 != TTLoginSegments.personal }
        let hidesOAuthLoginView = input.segmentSelection.map { $0 != TTLoginSegments.oAuth }
        
        return Output(
            basicLoginButtonEnabled: basicLoginButtonEnabled,
            personalLoginButtonEnabled: personalLoginButtonEnabled,
            hidesBasicLoginView: hidesBasicLoginView,
            hidesPersonalLoginView: hidesPersonalLoginView,
            hidesOAuthLoginView: hidesOAuthLoginView
        )
    }
}
