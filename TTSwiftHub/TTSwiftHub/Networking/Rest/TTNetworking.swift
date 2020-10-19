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
import Alamofire

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

// MARK: - Protocol TTNetworkingType
protocol TTNetworkingType {
    associatedtype T: TargetType, TTProductAPIType
    var provider: TTOnlineProvider<T> { get }
    
    static func defaultNetworking() -> Self
    static func stubbingNetworking() -> Self
}

extension TTNetworkingType {
    static func endpointsClosure<T>(_ xAccessToken: String? = nil) -> (T) -> Endpoint where T: TargetType, T: TTProductAPIType {
        return { target in
            let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
            
            // 签署所有非XApp，非XAuth令牌请求
            return endpoint
        }
    }
    
    static func APIKeysBasedStubBehaviour<T>(_: T) -> Moya.StubBehavior {
        return .never
    }
    
    static var plugins: [PluginType] {
        var plugins: [PluginType] = []
        if Configs.Network.loggingEnabled {
            plugins.append(NetworkLoggerPlugin())
        }
        return plugins
    }
    
    /// 终点解析器
    /// (Endpoint<Target>, NSURLRequest -> Void) -> Void
    static func endpointResolver() -> MoyaProvider<T>.RequestClosure {
        return { (endpoint, closure) in
            do {
                var request = try endpoint.urlRequest()
                request.httpShouldHandleCookies = false
                closure(.success(request))
            } catch {
                logError(error.localizedDescription)
            }
        }
    }
}

// MARK: - TTGithubNetworking
struct TTGithubNetworking: TTNetworkingType {
    typealias T = TTGithubAPI
    let provider: TTOnlineProvider<T>
    
    static func defaultNetworking() -> Self {
        return TTGithubNetworking(provider: newProvider(plugins))
    }
    
    static func stubbingNetworking() -> Self {
        return TTGithubNetworking(provider: TTOnlineProvider(endpointClosure: TTGithubNetworking.endpointsClosure(),
                                                             requestClosure: TTGithubNetworking.endpointResolver(),
                                                             stubClosure: MoyaProvider.immediatelyStub,
                                                             online: .just(true)))
    }
    
    func request(_ token: T) -> Observable<Moya.Response> {
        let actualRequest = provider.request(token)
        return actualRequest
    }
}

// MARK: - TTTrendingGithubNetworking
struct TTTrendingGithubNetworking: TTNetworkingType {
    typealias T = TTTrendingGithubAPI
    let provider: TTOnlineProvider<T>
    
    static func defaultNetworking() -> Self {
        return TTTrendingGithubNetworking(provider: newProvider(plugins))
    }
    
    static func stubbingNetworking() -> Self {
        return TTTrendingGithubNetworking(provider:
            TTOnlineProvider(endpointClosure: TTTrendingGithubNetworking.endpointsClosure(),
                             requestClosure: TTTrendingGithubNetworking.endpointResolver(),
                             stubClosure: MoyaProvider.immediatelyStub,
                             online: .just(true)))
    }
    
    func request(_ token: T) -> Observable<Moya.Response> {
        let actualRequest = provider.request(token)
        return actualRequest
    }
}

struct TTCodetabsNetworking: TTNetworkingType {
    typealias T = TTCodetabsApi
    let provider: TTOnlineProvider<T>
    
    static func defaultNetworking() -> Self {
        return TTCodetabsNetworking(provider: newProvider(plugins))
    }
    
    static func stubbingNetworking() -> Self {
        return TTCodetabsNetworking(provider: TTOnlineProvider(endpointClosure: endpointsClosure(), requestClosure: TTCodetabsNetworking.endpointResolver(), stubClosure: MoyaProvider.immediatelyStub, online: .just(true)))
    }
    
    func request(_ token: T) -> Observable<Moya.Response> {
        let actualRequest = provider.request(token)
        return actualRequest
    }
}

// MARK: - 新建provider
private func newProvider<T>(_ plugins: [PluginType], xAccessToken: String? = nil) -> TTOnlineProvider<T> where T: TTProductAPIType {
    return TTOnlineProvider(endpointClosure: TTGithubNetworking.endpointsClosure(xAccessToken),
                            requestClosure: TTGithubNetworking.endpointResolver(),
                            stubClosure: TTGithubNetworking.APIKeysBasedStubBehaviour,
                            plugins: plugins)
}
