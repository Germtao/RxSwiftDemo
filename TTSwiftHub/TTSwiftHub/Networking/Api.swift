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
    
    // MARK: - Search
    func searchRepositories(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<TTRepositorySearch>
    func searchUser(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<TTUserSearch>
    
    // MARK: - 不需要授权
    func userFollowers(username: String, page: Int) -> Single<[TTUser]>
    func userFollowing(username: String, page: Int) -> Single<[TTUser]>
    func watchers(fullname: String, page: Int) -> Single<[TTUser]>
    func stargazers(fullname: String, page: Int) -> Single<[TTUser]>
    func contributors(fullname: String, page: Int) -> Single<[TTUser]>
    
    func user(owner: String) -> Single<TTUser>
    func organization(owner: String) -> Single<TTUser>
    
    func repository(fullname: String, qualifiedName: String) -> Single<TTRepository>
    func readme(fullname: String, ref: String?) -> Single<TTContent>
    func issues(fullname: String, state: String, page: Int) -> Single<[TTIssue]>
    func issueComments(fullname: String, number: Int, page: Int) -> Single<[TTComment]>
    
    func commits(fullname: String, page: Int) -> Single<[TTCommit]>
    
    func branches(fullname: String, page: Int) -> Single<[TTBranch]>
    func releases(fullname: String, page: Int) -> Single<[TTRelease]>
    func pullRequests(fullname: String, state: String, page: Int) -> Single<[TTPullRequest]>
    
    func userRepositories(username: String, page: Int) -> Single<[TTRepository]>
    func userStarredRepositories(username: String, page: Int) -> Single<[TTRepository]>
    func userWatchingRepositories(username: String, page: Int) -> Single<[TTRepository]>
    func forks(fullname: String, page: Int) -> Single<[TTRepository]>
    
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
    
    // MARK: - Trending 趋向
    func trendingRepositories(language: String, since: String) -> Single<[TTTrendingRepository]>
    func trendingDevelopers(language: String, since: String) -> Single<[TTTrendingUser]>
    func languages() -> Single<[TTLanguage]>
}
