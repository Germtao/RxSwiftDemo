//
//  TTRepositoryViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/9.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTRepositoryViewModel: TTViewModel, TTViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let imageSelection: Observable<Void>
        let openInWebSelection: Observable<Void>
        let watchersSelection: Observable<Void>
        let starsSelection: Observable<Void>
        let forksSelection: Observable<Void>
        let selection: Driver<TTRepositorySectionItem>
        let starSelection: Observable<Void>
    }
    
    struct Output {
        let items: Observable<[TTRepositorySection]>
        let name: Driver<String>
        let description: Driver<String>
        let imageUrl: Driver<URL?>
        let starring: Driver<Bool>
        let hidesStarButton: Driver<Bool>
        let watchersCount: Driver<Int>
        let starsCount: Driver<Int>
        let forksCount: Driver<Int>
        let imageSelected: Driver<TTUserViewModel>
        let openInWebSelected: Driver<URL>
        let repositoriesSelected: Driver<TTRepositoriesViewModel>
        let usersSelected: Driver<TTUsersViewModel>
        let selectedEvent: Driver<TTRepositorySectionItem>
    }
    
    let repository: BehaviorRelay<TTRepository>
    let readme = BehaviorRelay<TTContent?>(value: nil)
    let selectedBranch = BehaviorRelay<String?>(value: nil)
    
    init(repository: TTRepository, provider: TTSwiftHubAPI) {
        self.repository = BehaviorRelay(value: repository)
        super.init(provider: provider)
        if let fullname = repository.fullname {
            analytics.log(.repository(fullname: fullname))
        }
    }
    
    func transform(input: Input) -> Output {
        Observable.combineLatest(input.headerRefresh, selectedBranch)
            .flatMapLatest { [weak self] (_, branch) -> Observable<TTRepository> in
                guard let self = self else { return Observable.just(TTRepository()) }
                let fullname = self.repository.value.fullname ?? ""
                let qualifiedName = branch ?? self.repository.value.defaultBranch
                return self.provider.repository(fullname: fullname, qualifiedName: qualifiedName)
                    .trackActivity(self.loading)
                    .trackActivity(self.headerLoading)
                    .trackError(self.error)
        }
        .subscribe(onNext: { [weak self] repository in
            self?.repository.accept(repository)
        })
        .disposed(by: rx.disposeBag)
        
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<TTContent> in
            guard let self = self else { return Observable.just(TTContent()) }
            let fullname = self.repository.value.fullname ?? ""
            return self.provider.readme(fullname: fullname, ref: nil)
                .trackActivity(self.loading)
                .trackActivity(self.headerLoading)
        }
        .subscribe(onNext: { [weak self] content in
            self?.readme.accept(content)
        })
        .disposed(by: rx.disposeBag)
        
        let starred = input.starSelection.flatMapLatest { [weak self] () -> Observable<RxSwift.Event<Void>> in
            guard let self = self, loggedIn.value else { return Observable.just(RxSwift.Event.next(())) }
            let fullname = self.repository.value.fullname ?? ""
            let starring = self.repository.value.viewerHasStarred
            let request = starring == true ? self.provider.unstarRepository(fullname: fullname) : self.provider.starRepository(fullname: fullname)
            return request
                .trackActivity(self.loading)
                .materialize()
                .share()
        }
        starred.subscribe { event in
            switch event {
            case .next: logDebug("Starred Success")
            case .error(let error): logError(error.localizedDescription)
            case .completed: break
            }
        }
        .disposed(by: rx.disposeBag)
        
        let refreshStarring = Observable.of(input.headerRefresh, starred.mapToVoid()).merge()
        refreshStarring.flatMapLatest { [weak self] () -> Observable<RxSwift.Event<Void>> in
            guard let self = self, loggedIn.value else { return Observable.just(RxSwift.Event.next(())) }
            let fullname = self.repository.value.fullname ?? ""
            return self.provider.checkStarring(fullname: fullname)
                .trackActivity(self.loading)
                .materialize()
                .share()
         }
        .subscribe { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .next:
                var repository = self.repository.value
                repository.viewerHasStarred = true
                self.repository.accept(repository)
            case .error:
                var repository = self.repository.value
                repository.viewerHasStarred = false
                self.repository.accept(repository)
            case .completed: break
            }
        }
        .disposed(by: rx.disposeBag)
        
        let name = repository.map { $0.fullname ?? "" }.asDriverOnErrorJustComplete()
        let description = repository.map { $0.descriptionField ?? "" }.asDriverOnErrorJustComplete()
        let watchersCount = repository.map { $0.subscribersCount ?? 0 }.asDriverOnErrorJustComplete()
        let starsCount = repository.map { $0.stargazersCount ?? 0 }.asDriverOnErrorJustComplete()
        let forksCount = repository.map { $0.forksCount ?? 0 }.asDriverOnErrorJustComplete()
        let imageUrl = repository.map { $0.owner?.avatarUrl?.url }.asDriverOnErrorJustComplete()
        let hidesStarButton = loggedIn.map { !$0 }.asDriver(onErrorJustReturn: false)
        
        let imageSelected = input.imageSelection.asDriver(onErrorJustReturn: ())
            .map { () -> TTUserViewModel in
                let user = self.repository.value.owner ?? TTUser()
                return TTUserViewModel(user: user, provider: self.provider)
        }
        
        let openInWebSelected = input.openInWebSelection.map { () -> URL? in
            self.repository.value.htmlUrl?.url
        }.asDriver(onErrorJustReturn: nil).filterNil()
        
        let repositoriesSelected = input.forksSelection.asDriver(onErrorJustReturn: ())
            .map { () -> TTRepositoriesViewModel in
                let mode = TTRepositoriesMode.forks(repository: self.repository.value)
                return TTRepositoriesViewModel(mode: mode, provider: self.provider)
        }
        
        let watchersSelected = input.watchersSelection.map { TTUsersMode.watchers(repository: self.repository.value) }
        let starsSelected = input.starsSelection.map { TTUsersMode.stars(repository: self.repository.value) }
        let usersSelected = Observable.of(watchersSelected, starsSelected).merge()
            .asDriver(onErrorJustReturn: .followers(user: TTUser()))
            .map { mode -> TTUsersViewModel in
                return TTUsersViewModel(mode: mode, provider: self.provider)
        }
        
        let starring = repository.map { $0.viewerHasStarred }.filterNil()
        
        let items = repository.map { repository -> [TTRepositorySection] in
            var items: [TTRepositorySectionItem] = []
            
            // Parent
            if let parentName = repository.parentFullname {
                let parentCellViewModel = TTRepositoryDetailCellViewModel(
                    title: R.string.localizable.repositoryParentCellTitle.key.localized(),
                    detail: parentName,
                    image: R.image.icon_cell_git_fork()?.template,
                    hidesDisclosure: false)
                items.append(TTRepositorySectionItem.parentItem(viewModel: parentCellViewModel))
            }
            
            if let languages = repository.languages {
                // 仅适用于OAuth身份验证的语言
                let languagesCellViewModel = TTLanguagesCellViewModel(languages: languages)
                items.append(TTRepositorySectionItem.languagesItem(viewModel: languagesCellViewModel))
            } else if let language = repository.language {
                // Language
                let languageCellViewModel = TTRepositoryDetailCellViewModel(
                    title: R.string.localizable.repositoryLanguageCellTitle.key.localized(),
                    detail: language,
                    image: R.image.icon_cell_git_language()?.template,
                    hidesDisclosure: true)
                items.append(TTRepositorySectionItem.languageItem(viewModel: languageCellViewModel))
            }
            
            // Size
            if let size = repository.size {
                let sizeCellViewModel = TTRepositoryDetailCellViewModel(
                    title: R.string.localizable.repositorySizeCellTitle.key.localized(),
                    detail: size.sizeFromKB(),
                    image: R.image.icon_cell_size()?.template,
                    hidesDisclosure: true)
                items.append(TTRepositorySectionItem.sizeItem(viewModel: sizeCellViewModel))
            }
            
            // Created
            if let created = repository.createdAt {
                let createdCellViewModel = TTRepositoryDetailCellViewModel(
                    title: R.string.localizable.repositoryCreatedCellTitle.key.localized(),
                    detail: created.toRelative(),
                    image: R.image.icon_cell_created()?.template,
                    hidesDisclosure: true)
                items.append(TTRepositorySectionItem.createdItem(viewModel: createdCellViewModel))
            }
            
            // Updated
            if let updated = repository.updatedAt {
                let updatedCellViewModel = TTRepositoryDetailCellViewModel(
                    title: R.string.localizable.repositoryUpdatedCellTitle.key.localized(),
                    detail: updated.toRelative(),
                    image: R.image.icon_cell_updated()?.template,
                    hidesDisclosure: true)
                items.append(TTRepositorySectionItem.updatedItem(viewModel: updatedCellViewModel))
            }
            
            // Homepage
            if let homepage = repository.homepage {
                let homepageCellViewModel = TTRepositoryDetailCellViewModel(
                    title: R.string.localizable.repositoryHomepageCellTitle.key.localized(),
                    detail: homepage,
                    image: R.image.icon_cell_link()?.template,
                    hidesDisclosure: false)
                items.append(TTRepositorySectionItem.homepageItem(viewModel: homepageCellViewModel))
            }
            
            // Issues
            let issuesCellViewModel = TTRepositoryDetailCellViewModel(
                title: R.string.localizable.repositoryIssuesCellTitle.key.localized(),
                detail: repository.openIssuesCount?.string ?? "",
                image: R.image.icon_cell_issues()?.template,
                hidesDisclosure: false)
            items.append(TTRepositorySectionItem.issuesItem(viewModel: issuesCellViewModel))
            
            // Pull Requests
            let pullRequestsCellViewModel = TTRepositoryDetailCellViewModel(
                title: R.string.localizable.repositoryPullRequestsCellTitle.key.localized(),
                detail: repository.pullRequestsCount?.string ?? "",
                image: R.image.icon_cell_git_pull_request()?.template,
                hidesDisclosure: false)
            items.append(TTRepositorySectionItem.pullRequestsItem(viewModel: pullRequestsCellViewModel))
            
            // Commits
            let commitsCellViewModel = TTRepositoryDetailCellViewModel(
                title: R.string.localizable.repositoryCommitsCellTitle.key.localized(),
                detail: repository.commitsCount?.string ?? "",
                image: R.image.icon_cell_git_commit()?.template,
                hidesDisclosure: false)
            items.append(TTRepositorySectionItem.commitsItem(viewModel: commitsCellViewModel))
            
            // Branches
            let branchesCellViewModel = TTRepositoryDetailCellViewModel(
                title: R.string.localizable.repositoryBranchesCellTitle.key.localized(),
                detail: self.selectedBranch.value ?? repository.defaultBranch,
                image: R.image.icon_cell_git_branch()?.template,
                hidesDisclosure: false)
            items.append(TTRepositorySectionItem.branchesItem(viewModel: branchesCellViewModel))
            
            // Releases
            let releasesCellViewModel = TTRepositoryDetailCellViewModel(
                title: R.string.localizable.repositoryReleasesCellTitle.key.localized(),
                detail: repository.releasesCount?.string ?? "",
                image: R.image.icon_cell_releases()?.template,
                hidesDisclosure: false)
            items.append(TTRepositorySectionItem.releasesItem(viewModel: releasesCellViewModel))
            
            // Contributors
            let contributorsCellViewModel = TTRepositoryDetailCellViewModel(
                title: R.string.localizable.repositoryContributorsCellTitle.key.localized(),
                detail: repository.contributorsCount?.string ?? "",
                image: R.image.icon_cell_company()?.template,
                hidesDisclosure: false)
            items.append(TTRepositorySectionItem.contributorsItem(viewModel: contributorsCellViewModel))
            
            // Events
            let eventsCellViewModel = TTRepositoryDetailCellViewModel(
                title: R.string.localizable.repositoryEventsCellTitle.key.localized(),
                detail: "",
                image: R.image.icon_cell_events()?.template,
                hidesDisclosure: false)
            items.append(TTRepositorySectionItem.eventsItem(viewModel: eventsCellViewModel))
            
            if loggedIn.value {
                // Notifications
                let notificationsCellViewModel = TTRepositoryDetailCellViewModel(
                    title: R.string.localizable.repositoryNotificationsCellTitle.key.localized(),
                    detail: "",
                    image: R.image.icon_tabbar_activity()?.template,
                    hidesDisclosure: false)
                items.append(TTRepositorySectionItem.notificationsItem(viewModel: notificationsCellViewModel))
            }
            
            // Source
            let sourceCellViewModel = TTRepositoryDetailCellViewModel(
                title: R.string.localizable.repositorySourceCellTitle.key.localized(),
                detail: "",
                image: R.image.icon_cell_source()?.template,
                hidesDisclosure: false)
            items.append(TTRepositorySectionItem.sourceItem(viewModel: sourceCellViewModel))
            
            // Stars history
            let starsHistoryCellViewModel = TTRepositoryDetailCellViewModel(
                title: R.string.localizable.repositoryStarsHistoryCellTitle.key.localized(),
                detail: Configs.Network.starHistoryBaseUrl,
                image: R.image.icon_cell_stars_history()?.template,
                hidesDisclosure: false)
            items.append(TTRepositorySectionItem.starHistoryItem(viewModel: starsHistoryCellViewModel))
            
            // Count lines of code
            let clocCellViewModel = TTRepositoryDetailCellViewModel(
                title: R.string.localizable.repositoryCountLinesOfCodeCellTitle.key.localized(),
                detail: "",
                image: R.image.icon_cell_cloc()?.template,
                hidesDisclosure: false)
            items.append(TTRepositorySectionItem.countLinesOfCodeItem(viewModel: clocCellViewModel))
            
            return [TTRepositorySection.repository(title: "", items: items)]
        }
        
        let selectedEvent = input.selection
        
        return Output(items: items,
                      name: name,
                      description: description,
                      imageUrl: imageUrl,
                      starring: starring.asDriver(onErrorJustReturn: false),
                      hidesStarButton: hidesStarButton,
                      watchersCount: watchersCount,
                      starsCount: starsCount,
                      forksCount: forksCount,
                      imageSelected: imageSelected,
                      openInWebSelected: openInWebSelected,
                      repositoriesSelected: repositoriesSelected,
                      usersSelected: usersSelected,
                      selectedEvent: selectedEvent)
    }
    
    func viewModel(for item: TTRepositorySectionItem) -> TTViewModel? {
        switch item {
        case .parentItem:
            if let parentRepository = repository.value.parentRepository {
                return TTRepositoryViewModel(repository: parentRepository, provider: provider)
            }
        case .issuesItem:
            return TTIssuesViewModel(repository: repository.value, prodiver: provider)
        case .commitsItem:
            return TTCommitsViewModel(repository: repository.value, provider: provider)
        case .branchesItem:
            return TTBranchesViewModel(repository: repository.value, provider: provider)
        case .releasesItem:
            return 
        default:
            <#code#>
        }
    }
}
