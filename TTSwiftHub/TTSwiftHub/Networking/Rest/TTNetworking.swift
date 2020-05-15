//
//  TTNetworking.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class TTOnlineProvider<Target> where Target: Moya.TargetType {
    fileprivate let online: Observable<Bool>
    fileprivate let provider: MoyaProvider<Target>
    
    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider<Target>.neverStub,
         session: Session = MoyaProvider<Target>.defaultAlamofireSession(),
         plugins: [PluginType] = [],
         trackInflights: Bool = false,
         online: Observable<Bool> = connectedToInternet()) {
        self.online = online
        self.provider = MoyaProvider(
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure: stubClosure,
            session: session,
            plugins: plugins,
            trackInflights: trackInflights
        )
    }
    
    func request(_ token: Target) -> Observable<Moya.Response> {
        let actualRequest = provider.rx.request(token)
        return online
            .ignore(false)
            // 取1以确保我们仅调用一次API
            .take(1)
            // 将在线状态转换为网络请求
            .flatMap { _ in
                return actualRequest
                    .filterSuccessfulStatusCodes()
                    .do(onSuccess: { response in
                        
                    }, onError: { error in
                        if let error = error as? MoyaError {
                            switch error {
                            case .statusCode(let response):
                                if response.statusCode == 401 {
                                    // TODO: 无授权
                                }
                            default: break
                            }
                        }
                    })
            }
    }
}

protocol TTNetworkingType {
    associatedtype T: TargetType
    var provider: TTOnlineProvider<T> { get }
    
    static func defaultNetworking() -> Self
    static func stubbingNetworking() -> Self
}

struct TTGithubNetworking/*: TTNetworkingType*/ {
//    typealias T = TTgithubA
}
