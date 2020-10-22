//
//  Api.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TTSwiftHubAPI {
    func downloadString(url: URL) -> Single<String>
    func downloadFile(url: URL, fileName: String?) -> Single<Void>
    
    // MARK: - Search
    func searchRepositories(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<TTRepositorySearch>
    func searchUsers(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<TTUserSearch>
    
    // MARK: - 不需要授权
    func createAccessToken(clientId: String, clientSecret: String, code: String, redirectUri: String?, state: String?) -> Single<TTToken>
    
    func userFollowers(username: String, page: Int) -> Single<[TTUser]>
    func userFollowing(username: String, page: Int) -> Single<[TTUser]>
    func watchers(fullname: String, page: Int) -> Single<[TTUser]>
    func stargazers(fullname: String, page: Int) -> Single<[TTUser]>
    func contributors(fullname: String, page: Int) -> Single<[TTUser]>
    
    func user(owner: String) -> Single<TTUser>
    func organization(owner: String) -> Single<TTUser>
    
    func repository(fullname: String, qualifiedName: String) -> Single<TTRepository>
    func readme(fullname: String, ref: String?) -> Single<TTContent>
    func contents(fullname: String, path: String, ref: String?) -> Single<[TTContent]>
    func issue(fullname: String, number: Int) -> Single<TTIssue>
    func issues(fullname: String, state: String, page: Int) -> Single<[TTIssue]>
    func issueComments(fullname: String, number: Int, page: Int) -> Single<[TTComment]>
    
    func commit(fullname: String, sha: String) -> Single<TTCommit>
    func commits(fullname: String, page: Int) -> Single<[TTCommit]>
    
    func branch(fullname: String, name: String) -> Single<TTBranch>
    func branches(fullname: String, page: Int) -> Single<[TTBranch]>
    
    func release(fullname: String, releaseId: Int) -> Single<TTRelease>
    func releases(fullname: String, page: Int) -> Single<[TTRelease]>
    
    func pullRequest(fullname: String, number: Int) -> Single<TTPullRequest>
    func pullRequests(fullname: String, state: String, page: Int) -> Single<[TTPullRequest]>
    func pullRequestComments(fullname: String, number: Int, page: Int) -> Single<[TTComment]>
    
    func userRepositories(username: String, page: Int) -> Single<[TTRepository]>
    func userStarredRepositories(username: String, page: Int) -> Single<[TTRepository]>
    func userWatchingRepositories(username: String, page: Int) -> Single<[TTRepository]>
    func forks(fullname: String, page: Int) -> Single<[TTRepository]>
    
    func events(page: Int) -> Single<[TTEvent]>
    func repositoryEvents(owner: String, repo: String, page: Int) -> Single<[TTEvent]>
    func userPerformedEvents(username: String, page: Int) -> Single<[TTEvent]>
    func userReceivedEvents(username: String, page: Int) -> Single<[TTEvent]>
    func organizationEvents(username: String, page: Int) -> Single<[TTEvent]>
    
    // MARK: - 需要授权
    func profile() -> Single<TTUser>
    func followUser(username: String) -> Single<Void>
    func unfollowUser(username: String) -> Single<Void>
    func checkFollowing(username: String) -> Single<Void>
    func starRepository(fullname: String) -> Single<Void>
    func unstarRepository(fullname: String) -> Single<Void>
    func checkStarring(fullname: String) -> Single<Void>
    
    func markAsReadNotifications() -> Single<Void>
    func markAsReadRepositoryNotifications(fullname: String) -> Single<Void>
    func notifications(all: Bool, participating: Bool, page: Int) -> Single<[TTNotification]>
    func repositoryNotifications(fullname: String, all: Bool, participating: Bool, page: Int) -> Single<[TTNotification]>
    
    // MARK: - Trending 趋向
    func trendingRepositories(language: String, since: String) -> Single<[TTTrendingRepository]>
    func trendingDevelopers(language: String, since: String) -> Single<[TTTrendingUser]>
    func languages() -> Single<[TTLanguage]>
    
    // MARK: - Codetabs
    func numberOfLines(fullname: String) -> Single<[TTLanguageLines]>
}
