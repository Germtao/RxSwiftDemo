//
//  TTSearchViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import RxOptional

enum TTSearchTypeSegments: Int {
    case repositories, users
    
    var title: String {
        switch self {
        case .repositories: return R.string.localizable.searchRepositoriesSegmentTitle.key.localized()
        case .users: return R.string.localizable.searchUsersSegmentTitle.key.localized()
        }
    }
}

enum TTTrendingPeriodSegments: Int {
    case daily, weekly, monthly
    
    var title: String {
        switch self {
        case .daily: return R.string.localizable.searchDailySegmentTitle.key.localized()
        case .weekly: return R.string.localizable.searchWeeklySegmentTitle.key.localized()
        case .monthly: return R.string.localizable.searchMonthlySegmentTitle.key.localized()
        }
    }
    
    var paramValue: String {
        switch self {
        case .daily: return "daily"
        case .weekly: return "weekly"
        case .monthly: return "monthly"
        }
    }
}

enum TTSearchModeSegments: Int {
    case trending, search
    
    var title: String {
        switch self {
        case .trending: return R.string.localizable.searchTrendingSegmentTitle.key.localized()
        case .search: return R.string.localizable.searchSearchSegmentTitle.key.localized()
        }
    }
}

enum TTSortRepositoryItems: Int {
    case bestMatch, mostStars, fewestStars, mostForks, fewestForks, recentlyUpdated, lastRecentlyUpdated
    
    var title: String {
        switch self {
        case .bestMatch: return R.string.localizable.searchSortRepositoriesBestMatchTitle.key.localized()
        case .mostStars: return R.string.localizable.searchSortRepositoriesMostStarsTitle.key.localized()
        case .fewestStars: return R.string.localizable.searchSortRepositoriesFewestStarsTitle.key.localized()
        case .mostForks: return R.string.localizable.searchSortRepositoriesMostForksTitle.key.localized()
        case .fewestForks: return R.string.localizable.searchSortRepositoriesFewestForksTitle.key.localized()
        case .recentlyUpdated: return R.string.localizable.searchSortRepositoriesRecentlyUpdatedTitle.key.localized()
        case .lastRecentlyUpdated: return R.string.localizable.searchSortRepositoriesLastRecentlyUpdatedTitle.key.localized()
        }
    }
    
    var sortValue: String {
        switch self {
        case .bestMatch: return ""
        case .mostStars, .fewestStars: return "stars"
        case .mostForks, .fewestForks: return "forks"
        case .recentlyUpdated, .lastRecentlyUpdated: return "updated"
        }
    }
    
    var orderValue: String {
        switch self {
        case .bestMatch: return ""
        case .mostStars, .mostForks, .recentlyUpdated: return "desc"
        case .fewestStars, .fewestForks, .lastRecentlyUpdated: return "asc"
        }
    }
    
    static func allItems() -> [String] {
        return (0...TTSortRepositoryItems.lastRecentlyUpdated.rawValue)
            .map { TTSortRepositoryItems(rawValue: $0)!.title }
    }
}

enum TTSortUserItems: Int {
    case bestMatch, mostFollowers, fewestFollowers, mostRecentlyJoined, leastRecentlyJoined, mostRepositories, fewestRepositories
    
    var title: String {
        switch self {
        case .bestMatch: return R.string.localizable.searchSortUsersBestMatchTitle.key.localized()
        case .mostFollowers: return R.string.localizable.searchSortUsersMostFollowersTitle.key.localized()
        case .fewestFollowers: return R.string.localizable.searchSortUsersFewestFollowersTitle.key.localized()
        case .mostRecentlyJoined: return R.string.localizable.searchSortUsersMostRecentlyJoinedTitle.key.localized()
        case .leastRecentlyJoined: return R.string.localizable.searchSortUsersLeastRecentlyJoinedTitle.key.localized()
        case .mostRepositories: return R.string.localizable.searchSortUsersMostRepositoriesTitle.key.localized()
        case .fewestRepositories: return R.string.localizable.searchSortUsersFewestRepositoriesTitle.key.localized()
        }
    }
    
    var sortValue: String {
        switch self {
        case .bestMatch: return ""
        case .mostFollowers, .fewestFollowers: return "followers"
        case .mostRecentlyJoined, .leastRecentlyJoined: return "joined"
        case .mostRepositories, .fewestRepositories: return "repositories"
        }
    }

    var orderValue: String {
        switch self {
        case .bestMatch, .mostFollowers, .mostRecentlyJoined, .mostRepositories: return "desc"
        case .fewestFollowers, .leastRecentlyJoined, .fewestRepositories: return "asc"
        }
    }

    static func allItems() -> [String] {
        return (0...TTSortUserItems.fewestRepositories.rawValue)
            .map { TTSortUserItems(rawValue: $0)!.title }
    }
}

class TTSearchViewModel: TTViewModel, TTViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let languageTrigger: Observable<Void>
        let keywordTrigger: Driver<String>
        let textDidBeginEditing: Driver<Void>
        let languagesSelection: Observable<Void>
        let searchTypeSegmentSelection: Observable<TTSearchTypeSegments>
        let trendingPeriodSegmentSelection: Observable<TTTrendingPeriodSegments>
        let searchModeSelection: Observable<TTSearchModeSegments>
        let sortRepositorySelection: Observable<TTSortRepositoryItems>
        let sortUserSelection: Observable<TTSortUserItems>
        let selection: Driver<TTSearchSectionItem>
    }
    
    struct Output {
        let items: BehaviorRelay<[TTSearchSection]>
        let sortItems: Driver<[String]>
        let sortText: Driver<String>
        let totalCountText: Driver<String>
        let textDidBeginEditing: Driver<Void>
        let dismissKeyboard: Driver<Void>
        let languagesSelection: Driver<TTLanguagesViewModel>
        let repositorySelected: Driver<TTRepositoryViewModel>
        let userSelected: Driver<TTUserViewModel>
        let hidesTrendingPeriodSegment: Driver<Bool>
        let hidesSearchModeSegment: Driver<Bool>
        let hidesSortLabel: Driver<Bool>
    }
    
    let searchType = BehaviorRelay<TTSearchTypeSegments>(value: .repositories)
    let trendingPeriod = BehaviorRelay<TTTrendingPeriodSegments>(value: .daily)
    let searchMode = BehaviorRelay<TTSearchModeSegments>(value: .trending)
    
    let keyword = BehaviorRelay(value: "")
    let currentLanguage = BehaviorRelay<TTLanguage?>(value: TTLanguage.currentLanguage)
    let sortRepositoryItem = BehaviorRelay(value: TTSortRepositoryItems.bestMatch)
    let sortUserItem = BehaviorRelay(value: TTSortUserItems.bestMatch)
    
    let repositorySearchElements = BehaviorRelay(value: TTRepositorySearch())
    let userSearchElements = BehaviorRelay(value: TTUserSearch())
    
    var repositoriesPage = 1
    var usersPage = 1
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTSearchSection]>(value: [])
        let trendingRepositoryElements = BehaviorRelay<[TTTrendingRepository]>(value: [])
        let trendingUserElements = BehaviorRelay<[TTTrendingUser]>(value: [])
        let languageElements = BehaviorRelay<[TTLanguage]>(value: [])
        let repositorySelected = PublishSubject<TTRepository>()
        let userSelected = PublishSubject<TTUser>()
        let dismissKeyboard = input.selection.mapToVoid()
        
        input.searchTypeSegmentSelection.bind(to: searchType).disposed(by: rx.disposeBag)
        input.trendingPeriodSegmentSelection.bind(to: trendingPeriod).disposed(by: rx.disposeBag)
        input.searchModeSelection.bind(to: searchMode).disposed(by: rx.disposeBag)
        
        input.keywordTrigger
            .skip(1)
            .debounce(DispatchTimeInterval.milliseconds(500))
            .distinctUntilChanged() // 根据相等运算符，返回仅包含不同连续元素的可观察序列
            .asObservable()
            .bind(to: keyword)
            .disposed(by: rx.disposeBag)
        
        Observable.combineLatest(keyword, currentLanguage)
            .map { (keyword, currentLanguage) in
                return (keyword.isEmpty && currentLanguage == nil) ? .trending : .search
            }
            .asObservable()
            .bind(to: searchMode)
            .disposed(by: rx.disposeBag)
        
        input.sortRepositorySelection.bind(to: sortRepositoryItem).disposed(by: rx.disposeBag)
        input.sortUserSelection.bind(to: sortUserItem).disposed(by: rx.disposeBag)
        
        // 监听header刷新
        Observable.combineLatest(keyword, currentLanguage, sortRepositoryItem)
            .filter { (keyword, currentLanguage, sortRepositoryItem) -> Bool in
                return keyword.isNotEmpty || currentLanguage != nil
            }
            .flatMapLatest { [weak self] (keyword, currentLanguage, sortRepositoryItem) -> Observable<RxSwift.Event<TTRepositorySearch>> in
                guard let _self = self else {
                    return Observable.just(RxSwift.Event.next(TTRepositorySearch()))
                }
                
                _self.repositoriesPage = 1
                let query = _self.makeQuery()
                let sort = sortRepositoryItem.sortValue
                let order = sortRepositoryItem.orderValue
                return _self.provider.searchRepositories(query: query, sort: sort, order: order, page: _self.repositoriesPage, endCursor: nil)
                    .trackActivity(_self.loading)
                    .trackActivity(_self.headerLoading)
                    .trackError(_self.error)
                    .materialize()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let result):
                    self?.repositorySearchElements.accept(result)
                default: break
                }
            })
            .disposed(by: rx.disposeBag)
        
        // 监听footer刷新
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<RxSwift.Event<TTRepositorySearch>> in
            guard let _self = self else {
                return Observable.just(RxSwift.Event.next(TTRepositorySearch()))
            }
            
            if _self.searchMode.value != .search || !_self.repositorySearchElements.value.hasNextPage {
                var result = TTRepositorySearch()
                result.totalCount = _self.repositorySearchElements.value.totalCount
                return Observable.just(RxSwift.Event.next(result))
                    .trackActivity(_self.footerLoading) // 用于强制停止表格footer动画
            }
            
            _self.repositoriesPage += 1
            let query = _self.makeQuery()
            let sort = _self.sortRepositoryItem.value.sortValue
            let order = _self.sortRepositoryItem.value.orderValue
            let endCursor = _self.repositorySearchElements.value.endCursor
            return _self.provider.searchRepositories(query: query, sort: sort, order: order, page: _self.repositoriesPage, endCursor: endCursor)
                .trackActivity(_self.loading)
                .trackActivity(_self.footerLoading)
                .trackError(_self.error)
                .materialize()
        }
        .subscribe(onNext: { [weak self] event in
            switch event {
            case .next(let result):
                var newResult = result
                newResult.items = (self?.repositorySearchElements.value.items ?? []) + result.items
                self?.repositorySearchElements.accept(newResult)
            default: break
            }
        })
        .disposed(by: rx.disposeBag)
        
        Observable.combineLatest(keyword, currentLanguage, sortUserItem)
            .filter { (keyword, currentLanguage, sortUserItem) -> Bool in
                return keyword.isNotEmpty || currentLanguage != nil
            }
            .flatMapLatest { [weak self] (keyword, currentLanguage, sortUserItem) -> Observable<RxSwift.Event<TTUserSearch>> in
                guard let _self = self else {
                    return Observable.just(RxSwift.Event.next(TTUserSearch()))
                }
                
                _self.usersPage = 1
                let query = _self.makeQuery()
                let sort = sortUserItem.sortValue
                let order = sortUserItem.orderValue
                return _self.provider.searchUser(query: query, sort: sort, order: order, page: _self.usersPage, endCursor: nil)
                    .trackActivity(_self.loading)
                    .trackActivity(_self.headerLoading)
                    .trackError(_self.error)
                    .materialize()
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let result):
                    self?.userSearchElements.accept(result)
                default: break
                }
            })
            .disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] () -> Observable<RxSwift.Event<TTUserSearch>> in
            guard let _self = self else {
                return Observable.just(RxSwift.Event.next(TTUserSearch()))
            }
            
            if _self.searchMode.value != .search || !_self.userSearchElements.value.hasNextPage {
                var result = TTUserSearch()
                result.totalCount = _self.userSearchElements.value.totalCount
                return Observable.just(RxSwift.Event.next(TTUserSearch()))
            }
            
            _self.usersPage += 1
            let query = _self.makeQuery()
            let sort = _self.sortUserItem.value.sortValue
            let order = _self.sortUserItem.value.orderValue
            let endCursor = _self.userSearchElements.value.endCursor
            return _self.provider.searchUser(query: query, sort: sort, order: order, page: _self.usersPage, endCursor: endCursor)
                .trackActivity(_self.loading)
                .trackActivity(_self.footerLoading)
                .trackError(_self.error)
                .materialize()
        }
        .subscribe(onNext: { [weak self] event in
            switch event {
            case .next(let result):
                var newResult = result
                newResult.items = (self?.userSearchElements.value.items ?? []) + result.items
                self?.userSearchElements.accept(newResult)
            default: break
            }
        })
        .disposed(by: rx.disposeBag)
        
        keyword.asDriver().debounce(RxTimeInterval.milliseconds(300)).filterEmpty().drive(onNext: { keyword in
//            analytics
        }).disposed(by: rx.disposeBag)
        
        Observable.just(()).flatMapLatest { () -> Observable<[TTLanguage]> in
            return self.provider.languages()
                .trackActivity(self.loading)
                .trackError(self.error)
        }
        .subscribe(onNext: { items in
            languageElements.accept(items)
        }, onError: { (error) in
            logError(error.localizedDescription)
        })
        .disposed(by: rx.disposeBag)
        
        let trendingPeriodSegment = BehaviorRelay(value: TTTrendingPeriodSegments.daily)
        input.trendingPeriodSegmentSelection.bind(to: trendingPeriodSegment).disposed(by: rx.disposeBag)
        
        let trendingTrigger = Observable.of(
            input.headerRefresh.skip(1),
            input.trendingPeriodSegmentSelection.mapToVoid().skip(1),
            currentLanguage.mapToVoid().skip(1),
            keyword.asObservable().map { $0.isEmpty }.filter { $0 == true }.mapToVoid()
        ).merge()
        trendingTrigger.flatMapLatest { () -> Observable<RxSwift.Event<[TTTrendingRepository]>> in
            let language = self.currentLanguage.value?.urlParam ?? ""
            let since = trendingPeriodSegment.value.paramValue
            return self.provider.trendingRepositories(language: language, since: since)
                .trackActivity(self.loading)
                .trackActivity(self.headerLoading)
                .trackError(self.error)
                .materialize()
        }
        .subscribe(onNext: { event in
            switch event {
            case .next(let items): trendingRepositoryElements.accept(items)
            default: break
            }
        })
        .disposed(by: rx.disposeBag)
        
        trendingTrigger.flatMapLatest { () -> Observable<RxSwift.Event<[TTTrendingUser]>> in
            let language = self.currentLanguage.value?.urlParam ?? ""
            let since = trendingPeriodSegment.value.paramValue
            return self.provider.trendingDevelopers(language: language, since: since)
                .trackActivity(self.loading)
                .trackActivity(self.headerLoading)
                .trackError(self.error)
                .materialize()
        }
        .subscribe(onNext: { event in
            switch event {
            case .next(let items): trendingUserElements.accept(items)
            default: break
            }
        })
        .disposed(by: rx.disposeBag)
        
        input.selection.drive(onNext: { item in
            switch item {
            case .trendingRepositoriesItem(let cellViewModel):
                repositorySelected.onNext(TTRepository(repo: cellViewModel.repository))
            case .trendingUsersItem(let cellViewModel):
                userSelected.onNext(TTUser(user: cellViewModel.user))
            case .repositoriesItem(let cellViewModel):
                repositorySelected.onNext(cellViewModel.repository)
            case .usersItem(let cellViewModel):
                userSelected.onNext(cellViewModel.user)
            }
        }).disposed(by: rx.disposeBag)
        
        Observable.combineLatest(
            trendingRepositoryElements,
            trendingUserElements,
            repositorySearchElements,
            userSearchElements,
            searchType,
            searchMode
        )
        .map { (trendingRepositories, trendingUsers, repositories, users, searchType, searchMode) -> [TTSearchSection] in
            var elements: [TTSearchSection] = []
            let language = self.currentLanguage.value?.displayName()
            let since = trendingPeriodSegment.value
            var title = ""
            switch searchMode {
            case .trending: title = language != nil ?
                R.string.localizable.searchTrendingSectionWithLanguageTitle.key.localizedFormat("\(language ?? "")") :
                R.string.localizable.searchTrendingSectionTitle.key.localized()
            case .search: title = language != nil ?
                R.string.localizable.searchSearchSectionWithLanguageTitle.key.localizedFormat("\(language ?? "")") :
                R.string.localizable.searchSearchSectionTitle.key.localized()
            }
            
            switch searchType {
            case .repositories:
                switch searchMode {
                case .trending:
                    let repositories = trendingRepositories.map { repository -> TTSearchSectionItem in
                        let cellViewModel = TTTrendingRepositoryCellViewModel(with: repository, since: since)
                        return TTSearchSectionItem.trendingRepositoriesItem(cellViewModel: cellViewModel)
                    }
                    
                    if repositories.isNotEmpty {
                        elements.append(TTSearchSection.repositories(title: title, items: repositories))
                    }
                    
                case .search:
                    let repositories = repositories.items.map { repository -> TTSearchSectionItem in
                        let cellViewModel = TTRepositoryCellViewModel(repository: repository)
                        return TTSearchSectionItem.repositoriesItem(cellViewModel: cellViewModel)
                    }
                    
                    if repositories.isNotEmpty {
                        elements.append(TTSearchSection.repositories(title: title, items: repositories))
                    }
                }
            case .users:
                switch searchMode {
                case .trending:
                    let users = trendingUsers.map { user -> TTSearchSectionItem in
                        let cellViewModel = TTTrendingUserCellViewModel(user: user)
                        return TTSearchSectionItem.trendingUsersItem(cellViewModel: cellViewModel)
                    }
                    if users.isNotEmpty {
                        elements.append(TTSearchSection.users(title: title, items: users))
                    }
                case .search:
                    let users = users.items.map { user -> TTSearchSectionItem in
                        let cellViewModel = TTUsersCellViewModel(user: user)
                        return TTSearchSectionItem.usersItem(cellViewModel: cellViewModel)
                    }
                    if users.isNotEmpty {
                        elements.append(TTSearchSection.users(title: title, items: users))
                    }
                }
            }
            return elements
        }
        .bind(to: elements).disposed(by: rx.disposeBag)
        
        let textDidBeginEditing = input.textDidBeginEditing
        
        let repositoryDetails = repositorySelected.map { repository -> TTRepositoryViewModel in
            TTRepositoryViewModel(repository: repository, provider: self.provider)
        }.asDriverOnErrorJustComplete()
        
        let userDetails = userSelected.map { user -> TTUserViewModel in
            TTUserViewModel(user: user, provider: self.provider)
        }.asDriverOnErrorJustComplete()
        
        let languagesSelection = input.languagesSelection.asDriver(onErrorJustReturn: ())
            .map { () -> TTLanguagesViewModel in
                let viewModel = TTLanguagesViewModel(currentLanguage: self.currentLanguage.value,
                                                     languages: languageElements.value,
                                                     provider: self.provider)
                viewModel.currentLanguage.skip(1).bind(to: self.currentLanguage).disposed(by: self.rx.disposeBag)
                return viewModel
            }
        
        let hidesTrendingPeriodSegment = searchMode.map { $0 != .trending }.asDriver(onErrorJustReturn: false)
        
        let hidesSearchModeSegment = Observable.combineLatest(
            input.keywordTrigger.asObservable().map { $0.isNotEmpty },
            currentLanguage.map { $0 == nil }
        ).map {
            $0 || $1
        }.asDriver(onErrorJustReturn: false)
        
        let hidesSortLabel = searchMode.map { $0 == .trending }.asDriver(onErrorJustReturn: false)
        
        let sortItems = Observable.combineLatest(searchType, input.languageTrigger)
            .map { (searchType, _) -> [String] in
                switch searchType {
                case .repositories: return TTSortRepositoryItems.allItems()
                case .users: return TTSortUserItems.allItems()
                }
        }.asDriver(onErrorJustReturn: [])
        
        let sortText = Observable.combineLatest(searchType, sortRepositoryItem, sortUserItem, input.languageTrigger)
            .map { (searchType, sortRepositoryItem, sortUserItem, _) -> String in
                switch searchType {
                case .repositories: return sortRepositoryItem.title + " ▼"
                case .users: return sortUserItem.title + " ▼"
                }
        }.asDriver(onErrorJustReturn: "")
        
        let totalCountText = Observable.combineLatest(searchType, repositorySearchElements, userSearchElements, input.languageTrigger)
            .map { (searchType, repositorySearchElements, userSearchElements, _) -> String in
                switch searchType {
                case .repositories: return R.string.localizable.searchRepositoriesTotalCountTitle.key.localizedFormat("\(repositorySearchElements.totalCount.kFormatted())")
                case .users: return R.string.localizable.searchUsersTotalCountTitle.key.localizedFormat("\(userSearchElements.totalCount.kFormatted())")
                }
        }.asDriver(onErrorJustReturn: "")
        
        return Output(items: elements,
                      sortItems: sortItems,
                      sortText: sortText,
                      totalCountText: totalCountText,
                      textDidBeginEditing: textDidBeginEditing,
                      dismissKeyboard: dismissKeyboard,
                      languagesSelection: languagesSelection,
                      repositorySelected: repositoryDetails,
                      userSelected: userDetails,
                      hidesTrendingPeriodSegment: hidesTrendingPeriodSegment,
                      hidesSearchModeSegment: hidesSearchModeSegment,
                      hidesSortLabel: hidesSortLabel)
    }
    
    func makeQuery() -> String {
        var query = keyword.value
        if let language = currentLanguage.value?.urlParam {
            query += " language:\(language)"
        }
        return query
    }
}
