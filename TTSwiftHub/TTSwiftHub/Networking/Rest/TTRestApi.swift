//
//  TTRestApi.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper
import Moya
import Moya_ObjectMapper
import Alamofire

typealias MoyaError = Moya.MoyaError

enum ApiError: Error {
    case serverError(response: ErrorResponse)
}

class TTRestApi: TTSwiftHubAPI {
    
    let githubProvider: TTGithubNetworking
    let trendingGithubProvider: TTTrendingGithubNetworking
    let codetabsProvider: TTCodetabsNetworking
    
    init(githubProvider: TTGithubNetworking, trendingGithubProvider: TTTrendingGithubNetworking, codetabsProvider: TTCodetabsNetworking) {
        self.githubProvider = githubProvider
        self.trendingGithubProvider = trendingGithubProvider
        self.codetabsProvider = codetabsProvider
    }
}

extension TTRestApi {
    func downloadString(url: URL) -> Single<String> {
        return Single.create { single in
            DispatchQueue.global().async {
                do {
                    single(.success(try String(contentsOf: url)))
                } catch {
                    single(.error(error))
                }
            }
            
            return Disposables.create {}
        }
        .observeOn(MainScheduler.instance)
    }
    
    func downloadFile(url: URL, fileName: String?) -> Single<Void> {
        return githubProvider.request(.download(url: url, fileName: fileName))
            .mapToVoid()
            .asSingle()
    }
}

private extension TTRestApi {
    func request(_ target: TTGithubAPI) -> Single<Any> {
        return githubProvider.request(target)
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    func requestWithoutMapping(_ target: TTGithubAPI) -> Single<Moya.Response> {
        return githubProvider.request(target)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    func requestObject<T: BaseMappable>(_ target: TTGithubAPI, type: T.Type) -> Single<T> {
        return githubProvider.request(target)
            .mapObject(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    func requestArray<T: BaseMappable>(_ target: TTGithubAPI, type: T.Type) -> Single<[T]> {
        return githubProvider.request(target)
            .mapArray(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
}

private extension TTRestApi {
    func trendingRequestObject<T: BaseMappable>(_ target: TTTrendingGithubAPI, type: T.Type) -> Single<T> {
        return trendingGithubProvider.request(target)
            .mapObject(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
    
    func trendingRequestArray<T: BaseMappable>(_ target: TTTrendingGithubAPI, type: T.Type) -> Single<[T]> {
        return trendingGithubProvider.request(target)
            .mapArray(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
}

private extension TTRestApi {
    func codetabsRequestArray<T: BaseMappable>(_ target: TTCodetabsApi, type: T.Type) -> Single<[T]> {
        return codetabsProvider.request(target)
            .mapArray(T.self)
            .observeOn(MainScheduler.instance)
            .asSingle()
    }
}

extension TTRestApi {
    func createAccessToken(clientId: String, clientSecret: String, code: String, redirectUri: String?, state: String?) -> Single<TTToken> {
        return Single.create { single in
            var params: Parameters = [:]
            params["client_id"] = clientId
            params["client_secret"] = clientSecret
            params["code"] = code
            params["redirect_uri"] = redirectUri
            params["state"] = state
            AF.request("https://github.com/login/oauth/access_token",
                       method: .post,
                       parameters: params,
                       encoding: URLEncoding.default,
                       headers: ["Accept": "application/json"])
                .responseJSON { response in
                    if let error = response.error {
                        single(.error(error))
                        return
                    }
                    
                    if let json = response.value as? [String: Any] {
                        if let token = Mapper<TTToken>().map(JSON: json) {
                            single(.success(token))
                            return
                        }
                    }
                    single(.error(RxError.unknown))
                }
            
            return Disposables.create {}
        }
        .observeOn(MainScheduler.instance)
    }
    
    func searchRepositories(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<TTRepositorySearch> {
        return requestObject(.searchRepositories(query: query, sort: sort, order: order, page: page), type: TTRepositorySearch.self)
    }
    
    func searchUsers(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<TTUserSearch> {
        return requestObject(.searchUsers(query: query, sort: sort, order: order, page: page), type: TTUserSearch.self)
    }
    
    func userFollowers(username: String, page: Int) -> Single<[TTUser]> {
        return requestArray(.userFollowers(username: username, page: page), type: TTUser.self)
    }
    
    func userFollowing(username: String, page: Int) -> Single<[TTUser]> {
        return requestArray(.userFollowing(username: username, page: page), type: TTUser.self)
    }
    
    func watchers(fullname: String, page: Int) -> Single<[TTUser]> {
        return requestArray(.watchers(fullname: fullname, page: page), type: TTUser.self)
    }
    
    func stargazers(fullname: String, page: Int) -> Single<[TTUser]> {
        return requestArray(.stargazers(fullname: fullname, page: page), type: TTUser.self)
    }
    
    func contributors(fullname: String, page: Int) -> Single<[TTUser]> {
        return requestArray(.contributors(fullname: fullname, page: page), type: TTUser.self)
    }
    
    func user(owner: String) -> Single<TTUser> {
        return requestObject(.user(owner: owner), type: TTUser.self)
    }
    
    func organization(owner: String) -> Single<TTUser> {
        return requestObject(.organization(owner: owner), type: TTUser.self)
    }
    
    func repository(fullname: String, qualifiedName: String) -> Single<TTRepository> {
        return requestObject(.repository(fullname: fullname), type: TTRepository.self)
    }
    
    func readme(fullname: String, ref: String?) -> Single<TTContent> {
        return requestObject(.readme(fullname: fullname, ref: ref), type: TTContent.self)
    }
    
    func contents(fullname: String, path: String, ref: String?) -> Single<[TTContent]> {
        return requestArray(.contents(fullname: fullname, path: path, ref: ref), type: TTContent.self)
    }
    
    func issue(fullname: String, number: Int) -> Single<TTIssue> {
        return requestObject(.issue(fullname: fullname, number: number), type: TTIssue.self)
    }
    
    func issues(fullname: String, state: String, page: Int) -> Single<[TTIssue]> {
        return requestArray(.issues(fullname: fullname, state: state, page: page), type: TTIssue.self)
    }
    
    func issueComments(fullname: String, number: Int, page: Int) -> Single<[TTComment]> {
        return requestArray(.issueComments(fullname: fullname, number: number, page: page), type: TTComment.self)
    }
    
    func commit(fullname: String, sha: String) -> Single<TTCommit> {
        return requestObject(.commit(fullname: fullname, sha: sha), type: TTCommit.self)
    }
    
    func commits(fullname: String, page: Int) -> Single<[TTCommit]> {
        return requestArray(.commits(fullname: fullname, page: page), type: TTCommit.self)
    }
    
    func branch(fullname: String, name: String) -> Single<TTBranch> {
        return requestObject(.branch(fullname: fullname, name: name), type: TTBranch.self)
    }
    
    func branches(fullname: String, page: Int) -> Single<[TTBranch]> {
        return requestArray(.branches(fullname: fullname, page: page), type: TTBranch.self)
    }
    
    func release(fullname: String, releaseId: Int) -> Single<TTRelease> {
        return requestObject(.release(fullname: fullname, releaseId: releaseId), type: TTRelease.self)
    }
    
    func releases(fullname: String, page: Int) -> Single<[TTRelease]> {
        return requestArray(.releases(fullname: fullname, page: page), type: TTRelease.self)
    }
    
    func pullRequest(fullname: String, number: Int) -> Single<TTPullRequest> {
        return requestObject(.pullRequest(fullname: fullname, number: number), type: TTPullRequest.self)
    }
    
    func pullRequests(fullname: String, state: String, page: Int) -> Single<[TTPullRequest]> {
        return requestArray(.pullRequests(fullname: fullname, state: state, page: page), type: TTPullRequest.self)
    }
    
    func pullRequestComments(fullname: String, number: Int, page: Int) -> Single<[TTComment]> {
        return requestArray(.pullRequestComments(fullname: fullname, number: number, page: page), type: TTComment.self)
    }
    
    func userRepositories(username: String, page: Int) -> Single<[TTRepository]> {
        return requestArray(.userRepositories(username: username, page: page), type: TTRepository.self)
    }
    
    func userStarredRepositories(username: String, page: Int) -> Single<[TTRepository]> {
        return requestArray(.userStarredRepositories(username: username, page: page), type: TTRepository.self)
    }
    
    func userWatchingRepositories(username: String, page: Int) -> Single<[TTRepository]> {
        return requestArray(.userWatchingRepositories(username: username, page: page), type: TTRepository.self)
    }
    
    func forks(fullname: String, page: Int) -> Single<[TTRepository]> {
        return requestArray(.forks(fullname: fullname, page: page), type: TTRepository.self)
    }
    
    func events(page: Int) -> Single<[TTEvent]> {
        return requestArray(.events(page: page), type: TTEvent.self)
    }
    
    func repositoryEvents(owner: String, repo: String, page: Int) -> Single<[TTEvent]> {
        return requestArray(.repositoryEvents(owner: owner, repo: repo, page: page), type: TTEvent.self)
    }
    
    func userPerformedEvents(username: String, page: Int) -> Single<[TTEvent]> {
        return requestArray(.userPerformedEvents(username: username, page: page), type: TTEvent.self)
    }
    
    func userReceivedEvents(username: String, page: Int) -> Single<[TTEvent]> {
        return requestArray(.userReceivedEvents(username: username, page: page), type: TTEvent.self)
    }
    
    func organizationEvents(username: String, page: Int) -> Single<[TTEvent]> {
        return requestArray(.organizationEvents(username: username, page: page), type: TTEvent.self)
    }
    
    func profile() -> Single<TTUser> {
        return requestObject(.profile, type: TTUser.self)
    }
    
    func followUser(username: String) -> Single<Void> {
        return requestWithoutMapping(.followUser(username: username)).map { _ in }
    }
    
    func unfollowUser(username: String) -> Single<Void> {
        return requestWithoutMapping(.unfollowUser(username: username)).map { _ in }
    }
    
    func checkFollowing(username: String) -> Single<Void> {
        return requestWithoutMapping(.checkFollowing(username: username)).map { _ in }
    }
    
    func starRepository(fullname: String) -> Single<Void> {
        return requestWithoutMapping(.starRepository(fullname: fullname)).map { _ in }
    }
    
    func unstarRepository(fullname: String) -> Single<Void> {
        return requestWithoutMapping(.unstarRepository(fullname: fullname)).map { _ in }
    }
    
    func checkStarring(fullname: String) -> Single<Void> {
        return requestWithoutMapping(.checkStarring(fullname: fullname)).map { _ in }
    }
    
    func markAsReadNotifications() -> Single<Void> {
        return requestWithoutMapping(.markAsReadNotifications).map { _ in }
    }
    
    func markAsReadRepositoryNotifications(fullname: String) -> Single<Void> {
        return requestWithoutMapping(.markAsReadRepositoryNotifications(fullname: fullname)).map { _ in }
    }
    
    func notifications(all: Bool, participating: Bool, page: Int) -> Single<[TTNotification]> {
        return requestArray(.notifications(all: all, participating: participating, page: page), type: TTNotification.self)
    }
    
    func repositoryNotifications(fullname: String, all: Bool, participating: Bool, page: Int) -> Single<[TTNotification]> {
        return requestArray(.repositoryNotifications(fullname: fullname, all: all, participating: participating, page: page), type: TTNotification.self)
    }
    
    func trendingRepositories(language: String, since: String) -> Single<[TTTrendingRepository]> {
        return trendingRequestArray(.trendingRepositories(language: language, since: since), type: TTTrendingRepository.self)
    }
    
    func trendingDevelopers(language: String, since: String) -> Single<[TTTrendingUser]> {
        return trendingRequestArray(.trendingDevelopers(language: language, since: since), type: TTTrendingUser.self)
    }
    
    func languages() -> Single<[TTLanguage]> {
        return trendingRequestArray(.languages, type: TTLanguage.self)
    }
    
    func numberOfLines(fullname: String) -> Single<[TTLanguageLines]> {
        return codetabsRequestArray(.numberOfLines(fullname: fullname), type: TTLanguageLines.self)
    }
}
