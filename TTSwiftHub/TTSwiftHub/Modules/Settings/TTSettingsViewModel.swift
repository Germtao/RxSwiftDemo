//
//  TTSettingsViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/20.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class TTSettingsViewModel: TTViewModel, TTViewModelType {
    
    struct Input {
        let trigger: Observable<Void>
        let selection: Driver<TTSettingsSectionItem>
    }
    
    struct Output {
        let items: BehaviorRelay<[TTSettingsSection]>
        let selectedEvent: Driver<TTSettingsSectionItem>
    }
    
    let currentUser: TTUser?
    
    let bannerEnabled: BehaviorRelay<Bool>
    let nightModeEnabled: BehaviorRelay<Bool>
    
    let whatsNewManager: TTWhatsNewManager
    
    let swiftHubRepository = BehaviorRelay<TTRepository?>(value: nil)
    
    var cellDisposeBag = DisposeBag()
    
    override init(provider: TTSwiftHubAPI) {
        currentUser = TTUser.currentUser()
        whatsNewManager = TTWhatsNewManager.shared
        bannerEnabled = BehaviorRelay(value: TTLibsManager.shared.bannersEnabled.value)
        nightModeEnabled = BehaviorRelay(value: TTThemeType.currentTheme().isDark)
        super.init(provider: provider)
        bannerEnabled.bind(to: TTLibsManager.shared.bannersEnabled).disposed(by: rx.disposeBag)
    }
    
    func transform(input: Input) -> Output {
        let elements = BehaviorRelay<[TTSettingsSection]>(value: [])
        let removeCache = PublishSubject<Void>()
        
        let cacheRemoved = removeCache.flatMapLatest { () -> Observable<Void> in
            return TTLibsManager.shared.removeKingfisherCache()
        }
        
        let refresh = Observable.of(input.trigger, cacheRemoved, swiftHubRepository.mapToVoid(), bannerEnabled.mapToVoid(), nightModeEnabled.mapToVoid()).merge()
        
        let cacheSize = refresh.flatMapLatest { () -> Observable<Int> in
            return TTLibsManager.shared.kingfisherCacheSize()
        }
        
        Observable.combineLatest(refresh, cacheSize).map { [weak self] (_, size) -> [TTSettingsSection] in
            guard let self = self else { return [] }
            
            self.cellDisposeBag = DisposeBag()
            
            var items: [TTSettingsSection] = []
            
            if loggedIn.value {
                var accountItems: [TTSettingsSectionItem] = []
                
                if let user = self.currentUser {
                    let profileCellVm = TTUserCellViewModel(user: user)
                    accountItems.append(.profileItem(viewModel: profileCellVm))
                }
                
                let logoutCellVm = TTSettingCellViewModel(
                    title: R.string.localizable.settingsLogOutTitle.key.localized(),
                    detail: nil,
                    image: R.image.icon_cell_logout()?.template,
                    hidesDisclosure: true
                )
                accountItems.append(TTSettingsSectionItem.logoutItem(viewModel: logoutCellVm))
                
                items.append(
                    TTSettingsSection.setting(title: R.string.localizable.settingsAccountSectionTitle.key.localized(),
                                              items: accountItems)
                )
            }
            
            if let swiftHubRepository = self.swiftHubRepository.value {
                let swiftHubCellVm = TTRepositoryCellViewModel(repository: swiftHubRepository)
                items.append(
                    TTSettingsSection.setting(title: R.string.localizable.settingsProjectsSectionTitle.key.localized(),
                                              items: [TTSettingsSectionItem.repositoryItem(viewModel: swiftHubCellVm)])
                )
            }
            
            // MARK: - banner cell view model
            let bannerEnabled = self.bannerEnabled.value
            let bannerImage = bannerEnabled ? R.image.icon_cell_smile()?.template : R.image.icon_cell_frown()?.template
            let bannerCellVm = TTSettingSwitchCellViewModel(
                title: R.string.localizable.settingsBannerTitle.key.localized(),
                detail: nil,
                image: bannerImage,
                hidesDisclosure: true,
                isEnabled: bannerEnabled
            )
            bannerCellVm.switchChanged.skip(1).bind(to: self.bannerEnabled).disposed(by: self.cellDisposeBag)
            
            // MARK: - night mode cell view model
            let nightModeEnabled = self.nightModeEnabled.value
            let nightModeCellVm = TTSettingSwitchCellViewModel(
                title: R.string.localizable.settingsNightModeTitle.key.localized(),
                detail: nil,
                image: R.image.icon_cell_night_mode()?.template,
                hidesDisclosure: true,
                isEnabled: nightModeEnabled
            )
            nightModeCellVm.switchChanged.skip(1).bind(to: self.nightModeEnabled).disposed(by: self.cellDisposeBag)
            
            // MARK: - theme cell view model
            let themeCellVm = TTSettingCellViewModel(
                title: R.string.localizable.settingsThemeTitle.key.localized(),
                detail: nil,
                image: R.image.icon_cell_theme()?.template,
                hidesDisclosure: false
            )
            
            // MARK: - language cell view model
            let languageCellVm = TTSettingCellViewModel(
                title: R.string.localizable.settingsLanguageTitle.key.localized(),
                detail: nil,
                image: R.image.icon_cell_language()?.template,
                hidesDisclosure: false
            )
            
            // MARK: - contacts cell view model
            let contactsCellVm = TTSettingCellViewModel(
                title: R.string.localizable.settingsContactsTitle.key.localized(),
                detail: nil,
                image: R.image.icon_cell_company()?.template,
                hidesDisclosure: false
            )
            
            // MARK: - remove cache cell view model
            let removeCacheCellVm = TTSettingCellViewModel(
                title: R.string.localizable.settingsRemoveCacheTitle.key.localized(),
                detail: nil,
                image: R.image.icon_cell_remove()?.template,
                hidesDisclosure: true
            )
            
            // MARK: - acknowledgements cell view model
            let acknowledgementsCellVm = TTSettingCellViewModel(
                title: R.string.localizable.settingsAcknowledgementsTitle.key.localized(),
                detail: size.sizeFromByte(),
                image: R.image.icon_cell_acknowledgements()?.template,
                hidesDisclosure: false
            )
            
            // MARK: - whats new cell view model
            let whatsNewCellVm = TTSettingCellViewModel(
                title: R.string.localizable.settingsWhatsNewTitle.key.localized(),
                detail: nil,
                image: R.image.icon_cell_whats_new()?.template,
                hidesDisclosure: false
            )
            
            items += [
                TTSettingsSection.setting(
                    title: R.string.localizable.settingsPreferencesSectionTitle.key.localized(),
                    items: [
                        TTSettingsSectionItem.bannerItem(viewModel: bannerCellVm),
                        TTSettingsSectionItem.nightModeItem(viewModel: nightModeCellVm),
                        TTSettingsSectionItem.themeItem(viewModel: themeCellVm),
                        TTSettingsSectionItem.languageItem(viewModel: languageCellVm),
                        TTSettingsSectionItem.contactsItem(viewModel: contactsCellVm),
                        TTSettingsSectionItem.removeCacheItem(viewModel: removeCacheCellVm)
                    ]
                ),
                TTSettingsSection.setting(
                    title: R.string.localizable.settingsSupportSectionTitle.key.localized(),
                    items: [
                        TTSettingsSectionItem.acknowledgementsItem(viewModel: acknowledgementsCellVm),
                        TTSettingsSectionItem.whatsNewItem(viewModel: whatsNewCellVm)
                    ]
                )
            ]
            return items
        }.bind(to: elements).disposed(by: rx.disposeBag)
        
        input.trigger.flatMapLatest { [weak self] () -> Observable<TTRepository> in
            guard let self = self else { return Observable.just(TTRepository()) }
            
            let fullname = "khoren93/SwiftHub"
            let qualifiedName = "master"
            return self.provider.repository(fullname: fullname, qualifiedName: qualifiedName)
                .trackActivity(self.loading)
                .trackError(self.error)
        }.subscribe { [weak self] repository in
            self?.swiftHubRepository.accept(repository)
        }.disposed(by: rx.disposeBag)
        
        let selectedEvent = input.selection
        selectedEvent.asObservable().subscribe(onNext: { item in
            switch item {
            case .removeCacheItem: removeCache.onNext(())
            default: break
            }
        }).disposed(by: rx.disposeBag)
        
        nightModeEnabled.subscribe(onNext: { isEnabled in
            var theme = TTThemeType.currentTheme()
            if theme.isDark != isEnabled {
                theme = theme.toggled()
            }
            themeService.switch(theme)
        }).disposed(by: rx.disposeBag)
        
        nightModeEnabled.skip(1).subscribe(onNext: { isEnabled in
            analytics.log(.appNightMode(enabled: isEnabled))
            analytics.set(.nightMode(value: isEnabled))
        }).disposed(by: rx.disposeBag)
        
        bannerEnabled.skip(1).subscribe(onNext: { isEnabled in
            analytics.log(.appAds(enabled: isEnabled))
        }).disposed(by: rx.disposeBag)
        
        cacheRemoved.subscribe(onNext: { () in
            analytics.log(.appCacheRemoved)
        }).disposed(by: rx.disposeBag)
        
        return Output(items: elements, selectedEvent: selectedEvent)
    }
    
    func viewModel(for item: TTSettingsSectionItem) -> TTViewModel? {
        switch item {
        case .profileItem:
            return TTUserViewModel(user: currentUser ?? TTUser(), provider: provider)
        case .themeItem:
            return TTThemeViewModel(provider: provider)
        case .languageItem:
            return TTLanguageViewModel(provider: provider)
        case .contactsItem:
            return TTContactsViewModel(provider: provider)
        case .repositoryItem(let viewModel):
            return TTRepositoryViewModel(repository: viewModel.repository, provider: provider)
        default:
            return nil
        }
    }
    
    func whatsNewBlock() -> WhatsNewBlock {
        return whatsNewManager.whatsNew(trackVersion: false)
    }
}
