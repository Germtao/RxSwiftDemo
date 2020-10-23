//
//  TTSearchViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private let trendingRepositoryCellId = R.reuseIdentifier.ttTrendingRepositoryCell
private let trendingUserCellId = R.reuseIdentifier.ttTrendingUserCell
private let repositoryCellId = R.reuseIdentifier.ttRepositoryCell
private let userCellId = R.reuseIdentifier.ttUserCell

class TTSearchViewController: TTTableViewController {
    
    let sortRepositoryItem = BehaviorRelay(value: TTSortRepositoryItems.bestMatch)
    let sortUserItem = BehaviorRelay(value: TTSortUserItems.bestMatch)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func makeUI() {
        super.makeUI()
        
        navigationItem.titleView = segmentedControl
        navigationItem.rightBarButtonItem = rightBarButton
        
        trendingPeriodView.addSubview(trendingPeriodSegmentedControl)
        trendingPeriodSegmentedControl.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(inset)
            make.top.bottom.equalToSuperview()
        }
        
        searchModeView.addSubview(searchModeSegmentedControl)
        searchModeSegmentedControl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(inset)
        }
        
        stackView.insertArrangedSubview(labelsStackView, at: 0)
        stackView.insertArrangedSubview(trendingPeriodView, at: 0)
        stackView.insertArrangedSubview(searchBar, at: 0)
        stackView.addArrangedSubview(searchModeView)
        
        labelsStackView.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }
        
        sortDropDown.selectionAction = { [weak self] (index, item) in
            if self?.segmentedControl.selectedSegmentIndex == 0 {
                if let items = TTSortRepositoryItems(rawValue: index) {
                    self?.sortRepositoryItem.accept(items)
                }
            } else {
                if let items = TTSortUserItems(rawValue: index) {
                    self?.sortUserItem.accept(items)
                }
            }
        }
        
        bannerView.isHidden = true
        
        registerCell()
        subscribeLanguageChanged()
        subscribeThemeService()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? TTSearchViewModel else { return }
        
        let searchTypeSegmentSelected = segmentedControl.segmentSelection.map { TTSearchTypeSegments(rawValue: $0)! }
        let trendingPerionSegmentSelected = trendingPeriodSegmentedControl.segmentSelection.map { TTTrendingPeriodSegments(rawValue: $0)! }
        let searchModeSegmentSelected = searchModeSegmentedControl.segmentSelection.map { TTSearchModeSegments(rawValue: $0)! }
        let refresh = Observable.of(Observable.just(()), headerRefreshTrigger, themeService.attrsStream.mapToVoid()).merge()
        let input = TTSearchViewModel.Input(headerRefresh: refresh,
                                            footerRefresh: footerRefreshTrigger,
                                            languageTrigger: languageChanged.asObservable(),
                                            keywordTrigger: searchBar.rx.text.orEmpty.asDriver(),
                                            textDidBeginEditing: searchBar.rx.textDidBeginEditing.asDriver(),
                                            languagesSelection: rightBarButton.rx.tap.asObservable(),
                                            searchTypeSegmentSelection: searchTypeSegmentSelected,
                                            trendingPeriodSegmentSelection: trendingPerionSegmentSelected,
                                            searchModeSelection: searchModeSegmentSelected,
                                            sortRepositorySelection: sortRepositoryItem.asObservable(),
                                            sortUserSelection: sortUserItem.asObservable(),
                                            selection: tableView.rx.modelSelected(TTSearchSectionItem.self).asDriver())
        let output = viewModel.transform(input: input)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<TTSearchSection>(configureCell: { (dataSource, tableView, indexPath, item) in
            switch item {
            case .trendingRepositoriesItem(let cellViewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: trendingRepositoryCellId, for: indexPath)!
                cell.bind(to: cellViewModel)
                return cell
            case .trendingUsersItem(let cellViewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: trendingUserCellId, for: indexPath)!
                cell.bind(to: cellViewModel)
                return cell
            case .repositoriesItem(let cellViewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: repositoryCellId, for: indexPath)!
                cell.bind(to: cellViewModel)
                return cell
            case .usersItem(let cellViewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath)!
                cell.bind(to: cellViewModel)
                return cell
            }
        }) { (dataSource, index) -> String? in
            let section = dataSource[index]
            return section.title
        }
        
        // MARK: - Output
        output.items
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        output.languagesSelection
            .drive(onNext: { [weak self] viewModel in
                self?.navigator.show(segue: .languages(viewModel: viewModel), sender: self, transition: .modal)
            })
            .disposed(by: rx.disposeBag)
        
        output.repositorySelected
            .drive(onNext: { [weak self] viewModel in
                self?.navigator.show(segue: .repositoryDetails(viewModel: viewModel), sender: self, transition: .detail)
            })
            .disposed(by: rx.disposeBag)
        
        output.userSelected
            .drive(onNext: { [weak self] viewModel in
                self?.navigator.show(segue: .userDetails(viewModel: viewModel), sender: self, transition: .detail)
            })
            .disposed(by: rx.disposeBag)
        
        output.dismissKeyboard
            .drive(onNext: { [weak self] () in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: rx.disposeBag)
        
        output.hidesTrendingPeriodSegment
            .drive(trendingPeriodView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        output.hidesSearchModeSegment
            .drive(searchModeView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        output.hidesSortLabel
            .drive(labelsStackView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        output.hidesSortLabel
            .drive(totalCountLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        output.hidesSortLabel
            .drive(sortLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        sortLabel.rx.tap()
            .subscribe(onNext: { [weak self] () in
                self?.sortDropDown.show()
            })
            .disposed(by: rx.disposeBag)
        
        output.sortItems
            .drive(onNext: { [weak self] items in
                self?.sortDropDown.dataSource = items
                self?.sortDropDown.reloadAllComponents()
            })
            .disposed(by: rx.disposeBag)
        
        output.totalCountText.drive(totalCountLabel.rx.text).disposed(by: rx.disposeBag)
        output.sortText.drive(sortLabel.rx.text).disposed(by: rx.disposeBag)
        
        viewModel.searchMode
            .asDriver()
            .drive(onNext: { [weak self] searchMode in
                guard let self = self else { return }
                
                self.searchModeSegmentedControl.selectedSegmentIndex = searchMode.rawValue
                
                switch searchMode {
                case .trending:
                    self.tableView.footRefreshControl = nil
                case .search:
                    self.tableView
                        .bindGlobalStyle { [weak self] in
                            self?.footerRefreshTrigger.onNext(())
                        }
                    self.tableView.footRefreshControl.autoRefreshOnFoot = true
                    self.isFooterLoading
                        .bind(to: self.tableView.footRefreshControl.rx.isAnimating)
                        .disposed(by: self.rx.disposeBag)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    // MARK: - Lazy Load
    lazy var rightBarButton: TTBarButtonItem = {
        let button = TTBarButtonItem(
            image: R.image.icon_navigation_language(),
            style: .done,
            target: nil,
            action: nil)
        return button
    }()
    
    lazy var segmentedControl: TTSegmentedControl = {
        let titles = [TTSearchTypeSegments.repositories.title, TTSearchTypeSegments.users.title]
        let images = [R.image.icon_cell_badge_repository()!, R.image.icon_cell_badge_user()!]
        let selectedImages = [R.image.icon_cell_badge_repository()!, R.image.icon_cell_badge_user()!]
        let view = TTSegmentedControl(sectionImages: images, sectionSelectedImages: selectedImages, titlesForSections: titles)
        view.selectedSegmentIndex = 0
        view.snp.makeConstraints({ (make) in
            make.width.equalTo(220)
        })
        return view
    }()
    
    let trendingPeriodView = TTView()
    lazy var trendingPeriodSegmentedControl: TTSegmentedControl = {
        let items = [
            TTTrendingPeriodSegments.daily.title,
            TTTrendingPeriodSegments.weekly.title,
            TTTrendingPeriodSegments.monthly.title
        ]
        let view = TTSegmentedControl(sectionTitles: items)
        view.selectedSegmentIndex = 0
        return view
    }()
    
    let searchModeView = TTView()
    lazy var searchModeSegmentedControl: TTSegmentedControl = {
        let titles = [TTSearchModeSegments.trending.title, TTSearchModeSegments.search.title]
        let images = [R.image.icon_cell_badge_trending()!, R.image.icon_cell_badge_search()!]
        let selectedImages = [R.image.icon_cell_badge_trending()!, R.image.icon_cell_badge_search()!]
        let view = TTSegmentedControl(sectionImages: images, sectionSelectedImages: selectedImages, titlesForSections: titles)
        view.selectedSegmentIndex = 0
        return view
    }()
    
    lazy var totalCountLabel: TTLabel = {
        let view = TTLabel()
        view.font = view.font.withSize(14)
        view.leftTextInset = self.inset
        return view
    }()
    
    lazy var sortLabel: TTLabel = {
        let view = TTLabel()
        view.font = view.font.withSize(14)
        view.textAlignment = .right
        view.rightTextInset = self.inset
        return view
    }()
    
    lazy var labelsStackView: TTStackView = {
        let view = TTStackView(arrangedSubviews: [self.totalCountLabel, self.sortLabel])
        view.axis = .horizontal
        return view
    }()
    
    lazy var sortDropDown: DropDownView = {
        let view = DropDownView(anchorView: self.tableView)
        return view
    }()
    
}

extension TTSearchViewController {
    private func registerCell() {
        tableView.register(R.nib.ttTrendingRepositoryCell)
        tableView.register(R.nib.ttTrendingUserCell)
        tableView.register(R.nib.ttRepositoryCell)
        tableView.register(R.nib.ttUserCell)
    }
    
    private func subscribeLanguageChanged() {
        languageChanged.subscribe(onNext: { [weak self] in
            self?.searchBar.placeholder = R.string.localizable.searchSearchBarPlaceholder.key.localized()
            self?.segmentedControl.sectionTitles = [
                TTSearchTypeSegments.repositories.title,
                TTSearchTypeSegments.users.title
            ]
            self?.trendingPeriodSegmentedControl.sectionTitles = [
                TTTrendingPeriodSegments.daily.title,
                TTTrendingPeriodSegments.weekly.title,
                TTTrendingPeriodSegments.monthly.title
            ]
            self?.searchModeSegmentedControl.sectionTitles = [
                TTSearchModeSegments.trending.title,
                TTSearchModeSegments.search.title
            ]
        }).disposed(by: rx.disposeBag)
    }
    
    private func subscribeThemeService() {
        themeService.rx
            .bind({ $0.text }, to: [totalCountLabel.rx.textColor, sortLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
        
        themeService.attrsStream.subscribe(onNext: { [weak self] theme in
            self?.sortDropDown.dimmedBackgroundColor = theme.primaryDark.withAlphaComponent(0.5)
            
            self?.segmentedControl.sectionImages = [
                R.image.icon_cell_badge_repository()!.tint(theme.textGray, blendMode: .normal).withRoundedCorners()!,
                R.image.icon_cell_badge_user()!.tint(theme.textGray, blendMode: .normal).withRoundedCorners()!
            ]
            
            self?.segmentedControl.sectionSelectedImages = [
                R.image.icon_cell_badge_repository()!.tint(theme.secondary, blendMode: .normal).withRoundedCorners()!,
                R.image.icon_cell_badge_user()!.tint(theme.secondary, blendMode: .normal).withRoundedCorners()!
            ]
            
            self?.searchModeSegmentedControl.sectionImages = [
                R.image.icon_cell_badge_trending()!.tint(theme.textGray, blendMode: .normal).withRoundedCorners()!,
                R.image.icon_cell_badge_search()!.tint(theme.textGray, blendMode: .normal).withRoundedCorners()!
            ]
            
            self?.searchModeSegmentedControl.sectionSelectedImages = [
                R.image.icon_cell_badge_trending()!.tint(theme.secondary, blendMode: .normal).withRoundedCorners()!,
                R.image.icon_cell_badge_search()!.tint(theme.secondary, blendMode: .normal).withRoundedCorners()!
            ]
            
        }).disposed(by: rx.disposeBag)
    }
}
