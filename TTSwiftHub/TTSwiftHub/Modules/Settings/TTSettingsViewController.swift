//
//  TTSettingsViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private let settingSwitchCellId = R.reuseIdentifier.ttSettingSwitchCell
private let settingCellId = R.reuseIdentifier.ttSettingCell
private let profileCellId = R.reuseIdentifier.ttUserCell
private let repositoryCellId = R.reuseIdentifier.ttRepositoryCell

class TTSettingsViewController: TTTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func makeUI() {
        super.makeUI()
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = R.string.localizable.settingsNavigationTitle.key.localized()
        }).disposed(by: rx.disposeBag)
        
        tableView.register(R.nib.ttSettingCell)
        tableView.register(R.nib.ttSettingSwitchCell)
        tableView.register(R.nib.ttUserCell)
        tableView.register(R.nib.ttRepositoryCell)
        
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? TTSettingsViewModel else { return }
        
        let refresh = Observable.of(rx.viewWillAppear.mapToVoid(), languageChanged.asObservable()).merge()
        let input = TTSettingsViewModel.Input(
            trigger: refresh,
            selection: tableView.rx.modelSelected(TTSettingsSectionItem.self).asDriver()
        )
        let output = viewModel.transform(input: input)
        
        let dataSource = RxTableViewSectionedReloadDataSource<TTSettingsSection> { (dataSource, tableView, indexPath, item) in
            switch item {
            case .profileItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: profileCellId, for: indexPath)!
                cell.bind(to: viewModel)
                return cell
            case .bannerItem(let viewModel),
                 .nightModeItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: settingSwitchCellId, for: indexPath)!
                cell.bind(to: viewModel)
                return cell
            case .themeItem(let viewModel),
                 .languageItem(let viewModel),
                 .contactsItem(let viewModel),
                 .removeCacheItem(let viewModel),
                 .acknowledgementsItem(let viewModel),
                 .whatsNewItem(let viewModel),
                 .logoutItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: settingCellId, for: indexPath)!
                cell.bind(to: viewModel)
                return cell
            case .repositoryItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: repositoryCellId, for: indexPath)!
                cell.bind(to: viewModel)
                return cell
            }
        } titleForHeaderInSection: { (dataSource, index) in
            let section = dataSource[index]
            return section.title
        }
        
        output.items.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        output.selectedEvent
            .drive(onNext: { [weak self] (item) in
                switch item {
                case .profileItem:
                    if let viewModel = viewModel.viewModel(for: item) as? TTUserViewModel {
                        self?.navigator.show(segue: .userDetails(viewModel: viewModel), sender: self, transition: .detail)
                    }
                case .logoutItem:
                    self?.deselectSelectedRow()
                    self?.logoutAction()
                case .bannerItem,
                     .nightModeItem,
                     .removeCacheItem:
                    self?.deselectSelectedRow()
                case .themeItem:
                    if let viewModel = viewModel.viewModel(for: item) as? TTThemeViewModel {
                        self?.navigator.show(segue: .theme(viewModel: viewModel), sender: self, transition: .detail)
                    }
                case .languageItem:
                    if let viewModel = viewModel.viewModel(for: item) as? TTLanguageViewModel {
                        self?.navigator.show(segue: .language(viewModel: viewModel), sender: self, transition: .detail)
                    }
                case .contactsItem:
                    if let viewModel = viewModel.viewModel(for: item) as? TTContactsViewModel {
                        self?.navigator.show(segue: .contacts(viewModel: viewModel), sender: self, transition: .detail)
                    }
                case .acknowledgementsItem:
                    self?.navigator.show(segue: .acknowledgements, sender: self, transition: .detail)
                case .whatsNewItem:
                    self?.navigator.show(segue: .whatsNew(block: viewModel.whatsNewBlock()), sender: self, transition: .modal)
                    analytics.log(.whatsNew)
                case .repositoryItem:
                    if let viewModel = viewModel.viewModel(for: item) as? TTRepositoryViewModel {
                        self?.navigator.show(segue: .repositoryDetails(viewModel: viewModel), sender: self, transition: .detail)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func logoutAction() {
        var name = ""
        if let user = TTUser.currentUser() {
            name = user.name ?? user.login ?? ""
        }
        
        let alertController = UIAlertController(
            title: name,
            message: R.string.localizable.settingsLogoutAlertMessage.key.localized(),
            preferredStyle: .alert
        )
        let logoutAction = UIAlertAction(
            title: R.string.localizable.settingsLogoutAlertConfirmButtonTitle.key.localized(),
            style: .destructive) { [weak self] _ in
            self?.logout()
        }
        let cancelAction = UIAlertAction(
            title: R.string.localizable.commonCancel.key.localized(),
            style: .default,
            handler: nil
        )
        
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func logout() {
        TTUser.removeCurrentUser()
        TTAuthManager.removeToken()
        
        TTApplication.shared.presentInitialScreen(in: TTApplication.shared.window)
        
        analytics.log(.logout)
        analytics.reset()
    }
}
