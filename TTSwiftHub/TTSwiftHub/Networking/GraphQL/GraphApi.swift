//
//  GraphApi.swift
//  TTSwiftHub
//
//  Created by TT on 2021/2/24.
//  Copyright © 2021 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Apollo

class TTGraphApi: TTSwiftHubAPI {
    
    let restApi: TTRestApi
    let token: String
    
    lazy var networkTransport: HTTPNetworkTransport = {
        let transport = HTTPNetworkTransport(url: URL(string: "https://api.github.com/graphql")!)
        transport.delegate = self
        return transport
    }()
    
    private(set) lazy var apolloClient = ApolloClient(networkTransport: networkTransport)
    
    init(restApi: TTRestApi, token: String) {
        self.restApi = restApi
        self.token = token
    }
}

extension TTGraphApi: HTTPNetworkTransportPreflightDelegate {
    func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
        return true
    }
    
    func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
        var headers = request.allHTTPHeaderFields ?? [String: String]()
        headers["Authorization"] = "Bearer \(token)"
        request.allHTTPHeaderFields = headers
    }
}

extension TTGraphApi {
    func downloadString(url: URL) -> Single<String> {
        return restApi.downloadString(url: url)
    }
    
    func downloadFile(url: URL, fileName: String?) -> Single<Void> {
        return restApi.downloadFile(url: url, fileName: fileName)
    }
    
    // MARK: - Authentication is optional
    
    func createAccessToken(clientId: String, clientSecret: String, code: String, redirectUri: String?, state: String?) -> Single<TTToken> {
        return restApi.createAccessToken(clientId: clientId, clientSecret: clientSecret, code: code, redirectUri: redirectUri, state: state)
    }
    
    func searchRepositories(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<TTRepositorySearch> {
        let query = query + (sort.isNotEmpty ? " sort:\(sort)-\(order)" : "")
//        return apolloClient.rx.fetch(query: SearchRepositoriesQuery, cachePolicy: <#T##CachePolicy#>, queue: <#T##DispatchQueue#>)
    }
    
    func watchers(fullname: String, page: Int) -> Single<[TTUser]> {
        return restApi.watchers(fullname: fullname, page: page)
    }
    
    func stargazers(fullname: String, page: Int) -> Single<[TTUser]> {
        return restApi.stargazers(fullname: fullname, page: page)
    }
    
    func forks(fullname: String, page: Int) -> Single<[TTRepository]> {
        return restApi.forks(fullname: fullname, page: page)
    }
    
    func readme(fullname: String, ref: String?) -> Single<TTContent> {
        return restApi.readme(fullname: fullname, ref: ref)
    }
    
    func contents(fullname: String, path: String, ref: String?) -> Single<[TTContent]> {
        return restApi.contents(fullname: fullname, path: path, ref: ref)
    }
    
    func issues(fullname: String, state: String, page: Int) -> Single<[TTIssue]> {
        return restApi.issues(fullname: fullname, state: state, page: page)
    }
    
    func issue(fullname: String, number: Int) -> Single<TTIssue> {
        return restApi.issue(fullname: fullname, number: number)
    }
    
    func issueComments(fullname: String, number: Int, page: Int) -> Single<[TTComment]> {
        return restApi.issueComments(fullname: fullname, number: number, page: page)
    }
    
    func commits(fullname: String, page: Int) -> Single<[TTCommit]> {
        return restApi.commits(fullname: fullname, page: page)
    }
    
    func commit(fullname: String, sha: String) -> Single<TTCommit> {
        return restApi.commit(fullname: fullname, sha: sha)
    }
    
    func branches(fullname: String, page: Int) -> Single<[TTBranch]> {
        return restApi.branches(fullname: fullname, page: page)
    }
    
    func branch(fullname: String, name: String) -> Single<TTBranch> {
        return restApi.branch(fullname: fullname, name: name)
    }
    
    func releases(fullname: String, page: Int) -> Single<[TTRelease]> {
        return restApi.releases(fullname: fullname, page: page)
    }
    
    func release(fullname: String, releaseId: Int) -> Single<TTRelease> {
        return restApi.release(fullname: fullname, releaseId: releaseId)
    }
    
    func pullRequests(fullname: String, state: String, page: Int) -> Single<[TTPullRequest]> {
        return restApi.pullRequests(fullname: fullname, state: state, page: page)
    }
    
    func pullRequest(fullname: String, number: Int) -> Single<TTPullRequest> {
        return restApi.pullRequest(fullname: fullname, number: number)
    }
    
    func pullRequestComments(fullname: String, number: Int, page: Int) -> Single<[TTComment]> {
        return restApi.pullRequestComments(fullname: fullname, number: number, page: page)
    }
    
    func contributors(fullname: String, page: Int) -> Single<[TTUser]> {
        return restApi.contributors(fullname: fullname, page: page)
    }
    
    func repository(fullname: String, qualifiedName: String) -> Single<TTRepository> {
        return restApi.repository(fullname: fullname, qualifiedName: qualifiedName)
    }
    
    func searchUsers(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<TTUserSearch> {
        let query = query + (sort.isNotEmpty ? " sort:\(sort)-\(order)" : "")
    }
    
    func user(owner: String) -> Single<TTUser> {
//        return apolloClient.rx.fetch(query: TTUserQuery(login: owner))
    }
    
    func organization(owner: String) -> Single<TTUser> {
        return restApi.organization(owner: owner)
    }
    
    func userRepositories(username: String, page: Int) -> Single<[TTRepository]> {
        return restApi.userRepositories(username: username, page: page)
    }
    
    func userStarredRepositories(username: String, page: Int) -> Single<[TTRepository]> {
        return restApi.userStarredRepositories(username: username, page: page)
    }
    
    func userWatchingRepositories(username: String, page: Int) -> Single<[TTRepository]> {
        return restApi.userWatchingRepositories(username: username, page: page)
    }
    
    func userFollowers(username: String, page: Int) -> Single<[TTUser]> {
        return restApi.userFollowers(username: username, page: page)
    }
    
    func userFollowing(username: String, page: Int) -> Single<[TTUser]> {
        return restApi.userFollowing(username: username, page: page)
    }
    
    func events(page: Int) -> Single<[TTEvent]> {
        return restApi.events(page: page)
    }
    
    func repositoryEvents(owner: String, repo: String, page: Int) -> Single<[TTEvent]> {
        return restApi.repositoryEvents(owner: owner, repo: repo, page: page)
    }
    
    func userPerformedEvents(username: String, page: Int) -> Single<[TTEvent]> {
        return restApi.userPerformedEvents(username: username, page: page)
    }
    
    func userReceivedEvents(username: String, page: Int) -> Single<[TTEvent]> {
        return restApi.userReceivedEvents(username: username, page: page)
    }
    
    func organizationEvents(username: String, page: Int) -> Single<[TTEvent]> {
        return restApi.organizationEvents(username: username, page: page)
    }
    
    // MARK: - Authentication is required
    
    func profile() -> Single<TTUser> {
        
    }
    
    func followUser(username: String) -> Single<Void> {
        return restApi.followUser(username: username)
    }
    
    func unfollowUser(username: String) -> Single<Void> {
        return restApi.unfollowUser(username: username)
    }
    
    func checkFollowing(username: String) -> Single<Void> {
        return restApi.checkFollowing(username: username)
    }
    
    func starRepository(fullname: String) -> Single<Void> {
        return restApi.starRepository(fullname: fullname)
    }
    
    func unstarRepository(fullname: String) -> Single<Void> {
        return restApi.unstarRepository(fullname: fullname)
    }
    
    func checkStarring(fullname: String) -> Single<Void> {
        return restApi.checkStarring(fullname: fullname)
    }
    
    func markAsReadNotifications() -> Single<Void> {
        return restApi.markAsReadNotifications()
    }
    
    func markAsReadRepositoryNotifications(fullname: String) -> Single<Void> {
        return restApi.markAsReadRepositoryNotifications(fullname: fullname)
    }
    
    func notifications(all: Bool, participating: Bool, page: Int) -> Single<[TTNotification]> {
        return restApi.notifications(all: all, participating: participating, page: page)
    }
    
    func repositoryNotifications(fullname: String, all: Bool, participating: Bool, page: Int) -> Single<[TTNotification]> {
        return restApi.repositoryNotifications(fullname: fullname, all: all, participating: participating, page: page)
    }
    
    // MARK: - Trending
    
    func trendingRepositories(language: String, since: String) -> Single<[TTTrendingRepository]> {
        return restApi.trendingRepositories(language: language, since: since)
    }
    
    func trendingDevelopers(language: String, since: String) -> Single<[TTTrendingUser]> {
        return restApi.trendingDevelopers(language: language, since: since)
    }
    
    func languages() -> Single<[TTLanguage]> {
        return restApi.languages()
    }
    
    // MARK: - Codetabs
    
    func numberOfLines(fullname: String) -> Single<[TTLanguageLines]> {
        return restApi.numberOfLines(fullname: fullname)
    }
}

extension TTGraphApi {
    private func ownerName(from fullname: String) -> String {
        return fullname.components(separatedBy: "/").first ?? ""
    }
    
    private func repoName(from fullname: String) -> String {
        return fullname.components(separatedBy: "/").last ?? ""
    }
}
