//
//  TTUserViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/10.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTUserViewModel: TTViewModel, TTViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let imageSelection: Observable<Void>
        let openInWebSelection: Observable<Void>
        let repositoriesSelection: Observable<Void>
        let followersSelection: Observable<Void>
        let followingSelection: Observable<Void>
        let selection: Driver<TTUserSectionItem>
        let followSelection: Observable<Void>
    }
    
    struct Output {
        let items: Observable<[TTUserSection]>
        let username: Driver<String>
        let fullname: Driver<String>
        let description: Driver<String>
        let imageUrl: Driver<URL?>
        let following: Driver<Bool>
        let hidesFollowButton: Driver<Bool>
        let repositoriesCount: Driver<Int>
        let followersCount: Driver<Int>
        let followingCount: Driver<Int>
        let imageSelected: Driver<Void>
        let openInWebSelected: Driver<URL?>
        let repositoriesSelected: Driver<TTRepositoriesViewModel>
        let usersSelected: Driver<TTUsersViewModel>
        let selectedEvent: Driver<TTUserSectionItem>
    }
    
    let user: BehaviorRelay<TTUser>
    
    init(user: TTUser, provider: TTSwiftHubAPI) {
        self.user = BehaviorRelay(value: user)
        super.init(provider: provider)
        if let login = user.login {
            analytics.log(.user(login: login))
        }
    }
    
    func transform(input: Input) -> Output {
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<TTUser> in
            guard let _self = self else { return Observable.just(TTUser()) }
            let user = _self.user.value
            let request: Single<TTUser>
            if !user.isMine() {
                let owner = user.login ?? ""
                switch user.type {
                case .user: request = _self.provider.user(owner: owner)
                case .organization: request = _self.provider.organization(owner: owner)
                }
            } else {
                request = _self.provider.profile()
            }
            
            return request
                .trackActivity(_self.loading)
                .trackActivity(_self.headerLoading)
                .trackError(_self.error)
        }
        .subscribe(onNext: { [weak self] user in
            self?.user.accept(user)
            if user.isMine() {
                user.save()
            }
        })
        .disposed(by: rx.disposeBag)
        
        let followed = input.followSelection.flatMapLatest { [weak self] () -> Observable<RxSwift.Event<Void>> in
            guard let self = self else { return Observable.just(RxSwift.Event.next(())) }
            let username = self.user.value.login ?? ""
            let following = self.user.value.viewerIsFollowing
            let request = following == true ? self.provider.unfollowUser(username: username) : self.provider.followUser(username: username)
            return request
                .trackActivity(self.loading)
                .materialize()
                .share()
        }
        followed.subscribe { event in
            switch event {
            case .next: logDebug("Follow success!!!")
            case .error(let error): logError(error.localizedDescription)
            case .completed: break
            }
        }
        .disposed(by: rx.disposeBag)
        
        let refreshStarring = Observable.of(input.headerRefresh, followed.mapToVoid()).merge()
        refreshStarring.flatMapLatest { [weak self] () -> Observable<RxSwift.Event<Void>> in
            guard let self = self, loggedIn.value == true else { return Observable.just(RxSwift.Event.next(())) }
            let username = self.user.value.login ?? ""
            return self.provider.checkFollowing(username: username)
                .trackActivity(self.loading)
                .materialize()
                .share()
        }
        .subscribe { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .next:
                var user = self.user.value
                user.viewerIsFollowing = true
                self.user.accept(user)
            case .error:
                var user = self.user.value
                user.viewerIsFollowing = false
                self.user.accept(user)
            case .completed: break
            }
        }
        .disposed(by: rx.disposeBag)
        
        let username = user.map { $0.login ?? "" }.asDriverOnErrorJustComplete()
        let fullname = user.map { $0.name ?? "" }.asDriverOnErrorJustComplete()
        let description = user.map { $0.bio ?? $0.descriptionField ?? "" }.asDriverOnErrorJustComplete()
        let imageUrl = user.map { $0.avatarUrl?.url }.asDriverOnErrorJustComplete()
        let repositoriesCount = user.map { $0.repositoriesCount ?? 0 }.asDriverOnErrorJustComplete()
        let followersCount = user.map { $0.followers ?? 0 }.asDriverOnErrorJustComplete()
        let followingCount = user.map { $0.following ?? 0 }.asDriverOnErrorJustComplete()
        let imageSelected = input.imageSelection.asDriverOnErrorJustComplete()
        let openInWebSelected = input.openInWebSelection.map { () -> URL? in
            self.user.value.htmlUrl?.url
        }.asDriver(onErrorJustReturn: nil)
        
        let hidesFollowButton = Observable.combineLatest(loggedIn, user).map { (loggedIn, user) -> Bool in
            guard loggedIn else { return true }
            return user.isMine() || user.type == .organization
        }.asDriver(onErrorJustReturn: false)
        
        let repositoriesSelected = input.repositoriesSelection.asDriver(onErrorJustReturn: ()).map { () -> TTRepositoriesViewModel in
            let mode = TTRepositoriesMode.userRepositories(user: self.user.value)
            let viewModel = TTRepositoriesViewModel(mode: mode, provider: self.provider)
            return viewModel
        }
        
        let followersSelected = input.followersSelection.map { TTUsersMode.followers(user: self.user.value) }
        let followingSelected = input.followingSelection.map { TTUsersMode.following(user: self.user.value) }
        
        let usersSelected = Observable.of(followersSelected, followingSelected).merge()
            .asDriver(onErrorJustReturn: .followers(user: TTUser()))
            .map { mode -> TTUsersViewModel in
                let viewModel = TTUsersViewModel(mode: mode, provider: self.provider)
                return viewModel
        }
        
        let following = user.map { $0.viewerIsFollowing }.filterNil()
        
        let items = user.map { user -> [TTUserSection] in
            var items: [TTUserSectionItem] = []
            
            // Created
            if let created = user.createdAt {
                let createdCellViewModel = TTUserDetailCellViewModel(
                    title: R.string.localizable.repositoryCreatedCellTitle.key.localized(),
                    detail: created.toRelative(),
                    image: R.image.icon_cell_created()?.template,
                    hidesDisclosure: true
                )
                items.append(TTUserSectionItem.createdItem(viewModel: createdCellViewModel))
            }
            
            // Updated
            if let updated = user.updatedAt {
                let updatedCellViewModel = TTUserDetailCellViewModel(
                    title: R.string.localizable.repositoryUpdatedCellTitle.key.localized(),
                    detail: updated.toRelative(),
                    image: R.image.icon_cell_updated()?.template,
                    hidesDisclosure: true
                )
                items.append(TTUserSectionItem.updatedItem(viewModel: updatedCellViewModel))
            }
            
            if user.type == .user {
                // Stars
                let starsCellViewModel = TTUserDetailCellViewModel(
                    title: R.string.localizable.userStarsCellTitle.key.localized(),
                    detail: user.starredRepositoriesCount?.string ?? "",
                    image: R.image.icon_cell_star()?.template,
                    hidesDisclosure: false
                )
                items.append(TTUserSectionItem.starsItem(viewModel: starsCellViewModel))
                
                // Watching
                let watchingCellViewModel = TTUserDetailCellViewModel(
                    title: R.string.localizable.userWatchingCellTitle.key.localized(),
                    detail: user.watchingCount?.string ?? "",
                    image: R.image.icon_cell_theme()?.template,
                    hidesDisclosure: false
                )
                items.append(TTUserSectionItem.watchingItem(viewModel: watchingCellViewModel))
            }
            
            // Events
            let eventsCellViewModel = TTUserDetailCellViewModel(
                title: R.string.localizable.userEventsCellTitle.key.localized(),
                detail: "",
                image: R.image.icon_cell_theme()?.template,
                hidesDisclosure: false
            )
            items.append(TTUserSectionItem.eventsItem(viewModel: eventsCellViewModel))
            
            // Company
            if let company = user.company, company.isNotEmpty {
                let companyCellViewModel = TTUserDetailCellViewModel(
                    title: R.string.localizable.userCompanyCellTitle.key.localized(),
                    detail: company,
                    image: R.image.icon_cell_company()?.template,
                    hidesDisclosure: false
                )
                items.append(TTUserSectionItem.companyItem(viewModel: companyCellViewModel))
            }
            
            // Blog
            if let blog = user.blog, blog.isNotEmpty {
                let blogCellViewModel = TTUserDetailCellViewModel(
                    title: R.string.localizable.userBlogCellTitle.key.localized(),
                    detail: blog,
                    image: R.image.icon_cell_link()?.template,
                    hidesDisclosure: false
                )
                items.append(TTUserSectionItem.blogItem(viewModel: blogCellViewModel))
            }
            
            // Profile Summary
            let profileSummaryCellViewModel = TTUserDetailCellViewModel(
                title: R.string.localizable.userProfileSummaryCellTitle.key.localized(),
                detail: "\(Configs.Network.profileSummaryBaseUrl)",
                image: R.image.icon_cell_profile_summary()?.template,
                hidesDisclosure: false
            )
            items.append(TTUserSectionItem.profileSummaryItem(viewModel: profileSummaryCellViewModel))
            
            // Pinned Repositories
            var pinnedItems: [TTUserSectionItem] = []
            if let repos = user.pinnedRepositories?.map({ TTRepositoryCellViewModel(repository: $0) }) {
                repos.forEach {
                    pinnedItems.append(TTUserSectionItem.repositoryItem(viewModel: $0))
                }
            }
            
            // User Organizations
            var organizationItems: [TTUserSectionItem] = []
            if let repos = user.organizations?.map({ TTUserCellViewModel(user: $0) }) {
                repos.forEach {
                    organizationItems.append(TTUserSectionItem.organizationItem(viewModel: $0))
                }
            }
            
            var userSections: [TTUserSection] = []
            userSections.append(TTUserSection.user(title: "", items: items))
            if pinnedItems.isNotEmpty {
                userSections.append(TTUserSection.user(title: R.string.localizable.userPinnedSectionTitle.key.localized(),
                                                       items: pinnedItems))
            }
            if organizationItems.isNotEmpty {
                userSections.append(TTUserSection.user(title: R.string.localizable.userOrganizationsSectionTitle.key.localized(),
                                                       items: organizationItems))
            }
            return userSections
        }
        
        let selectedEvent = input.selection
        
        return Output(items: items,
                      username: username,
                      fullname: fullname,
                      description: description,
                      imageUrl: imageUrl,
                      following: following.asDriver(onErrorJustReturn: false),
                      hidesFollowButton: hidesFollowButton,
                      repositoriesCount: repositoriesCount,
                      followersCount: followersCount,
                      followingCount: followingCount,
                      imageSelected: imageSelected,
                      openInWebSelected: openInWebSelected,
                      repositoriesSelected: repositoriesSelected,
                      usersSelected: usersSelected,
                      selectedEvent: selectedEvent)
    }
    
    func viewModel(for item: TTUserSectionItem) -> TTViewModel? {
        let user = self.user.value
        switch item {
        case .createdItem, .updatedItem: return nil
        case .starsItem:
            let mode = TTRepositoriesMode.userStarredRepositories(user: user)
            return TTRepositoriesViewModel(mode: mode, provider: provider)
        case .watchingItem:
            let mode = TTRepositoriesMode.userWatchingRepositories(user: user)
            return TTRepositoriesViewModel(mode: mode, provider: provider)
        case .eventsItem:
            let mode = TTEventsMode.user(user: user)
            return TTEventsViewModel(mode: mode, provider: provider)
        case .companyItem:
            if let companyName = user.company?.removingPrefix("@") {
                var user = TTUser()
                user.login = companyName
                return TTUserViewModel(user: user, provider: provider)
            }
        case .blogItem, .profileSummaryItem: return nil
        case .repositoryItem(let cellViewModel):
            return TTRepositoryViewModel(repository: cellViewModel.repository, provider: provider)
        case .organizationItem(let cellViewModel):
            return TTUserViewModel(user: cellViewModel.user, provider: provider)
        }
        
        return nil
    }
    
    func profileSummaryUrl() -> URL? {
        return "\(Configs.Network.profileSummaryBaseUrl)/user/\(self.user.value.login ?? "")".url
    }
}
