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
                    let profileCellVm = TTUsersCellViewModel(user: user)
                    accountItems.append(.profileItem(viewModel: profileCellVm))
                }
                
                // TODO:
            }
        }
    }
}
