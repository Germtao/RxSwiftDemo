//
//  TTEventsViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let eventCellId = R.reuseIdentifier.ttEventCell.identifier

class TTEventsViewController: TTTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func makeUI() {
        super.makeUI()
        
        navigationItem.titleView = segmentedControl
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.segmentedControl.sectionTitles = [TTEventSegments.received.title, TTEventSegments.performed.title]
        }).disposed(by: rx.disposeBag)
        
        themeService.rx
            .bind({ $0.primaryDark }, to: headerView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
        stackView.insertArrangedSubview(headerView, at: 0)
        
        tableView.register(R.nib.ttEventCell)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? TTEventsViewModel else { return }
        
        let segmentSelected = Observable.of(
            segmentedControl.segmentSelection.map { TTEventSegments(rawValue: $0)! }
        ).merge()
        
        let refresh = Observable.of(
            Observable.just(()),
            headerRefreshTrigger,
            segmentSelected.mapToVoid().skip(1)
        ).merge()
        
        let input = TTEventsViewModel.Input(
            headerRefresh: refresh,
            footerRefresh: footerRefreshTrigger,
            segmentSelection: segmentSelected,
            selection: tableView.rx.modelSelected(TTEventsCellViewModel.self).asDriver()
        )
        
        let output = viewModel.transform(input: input)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        
        output.navigationTitle
            .drive(onNext: { [weak self] (title) in
                self?.navigationTitle = title
            })
            .disposed(by: rx.disposeBag)
        
        output.hidesSegment
            .drive(onNext: { [weak self] (hides) in
                self?.navigationItem.titleView = hides ? nil : self?.segmentedControl
            })
            .disposed(by: rx.disposeBag)
        
        output.imageUrl
            .drive(onNext: { [weak self] (url) in
                if let url = url {
                    self?.ownerImageView.setSources(sources: [url])
                    self?.ownerImageView.hero.id = url.absoluteString
                }
            })
            .disposed(by: rx.disposeBag)
        
        output.items
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: eventCellId, cellType: TTEventCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
            }.disposed(by: rx.disposeBag)
        
        output.userSelected
            .drive(onNext: { [weak self] viewModel in
                self?.navigator.show(segue: .userDetails(viewModel: viewModel), sender: self, transition: .detail)
            })
            .disposed(by: rx.disposeBag)
        
        output.repositorySelected
            .drive(onNext: { [weak self] viewModel in
                self?.navigator.show(segue: .repositoryDetails(viewModel: viewModel), sender: self, transition: .detail)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.error.asDriver()
            .drive(onNext: { [weak self] error in
                self?.showAlert(title: R.string.localizable.commonError.key.localized(), message: error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    

    lazy var segmentedControl: TTSegmentedControl = {
        let items = [TTEventSegments.received.title, TTEventSegments.performed.title]
        let view = TTSegmentedControl(sectionTitles: items)
        view.selectedSegmentIndex = 0
        view.snp.makeConstraints { (make) in
            make.width.equalTo(250)
        }
        return view
    }()
    
    lazy var ownerImageView: TTSlideImageView = {
        let view = TTSlideImageView()
        view.cornerRadius = 40
        return view
    }()
    
    lazy var headerView: TTView = {
        let view = TTView()
        view.hero.id = "TopHeaderId"
        view.addSubview(self.ownerImageView)
        self.ownerImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(self.inset)
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
        return view
    }()

}
