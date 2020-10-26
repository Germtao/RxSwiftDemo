//
//  TTNotificationsViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let notificationCellId = R.reuseIdentifier.ttNotificationCell.identifier

class TTNotificationsViewController: TTTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func makeUI() {
        super.makeUI()
        
        navigationItem.titleView = segmentedControl
        navigationItem.rightBarButtonItem = rightBarButton
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.segmentedControl.sectionTitles = [
                TTNotificationSegment.unread.title,
                TTNotificationSegment.participating.title,
                TTNotificationSegment.all.title
            ]
        }).disposed(by: rx.disposeBag)
        
        tableView.register(R.nib.ttNotificationCell)
        tableView.headRefreshControl = nil
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? TTNotificationsViewModel else { return }
        
        let segmentSelected = Observable.of(
            segmentedControl.segmentSelection.map { TTNotificationSegment(rawValue: $0)! }
        ).merge()
        let refresh = Observable.of(Observable.just(()), segmentSelected.mapToVoid()).merge()
        let input = TTNotificationsViewModel.Input(
            headerRefresh: refresh,
            footerRefresh: footerRefreshTrigger,
            segmentSelection: segmentSelected,
            markAsReadSelection: rightBarButton.rx.tap.asObservable(),
            selection: tableView.rx.modelSelected(TTNotificationCellViewModel.self).asDriver()
        )
        let output = viewModel.transform(input: input)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.parsedError.bind(to: error).disposed(by: rx.disposeBag)
        
        output.navigationTitle
            .drive(onNext: { [weak self] title in
                self?.navigationTitle = title
            })
            .disposed(by: rx.disposeBag)
        
        output.items.asDriver()
            .drive(tableView.rx.items(cellIdentifier: notificationCellId, cellType: TTNotificationCell.self)) { tableView, viewModel, cell in
                cell.bind(to: viewModel)
            }
            .disposed(by: rx.disposeBag)
        
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
        
        output.markAsReadSelected
            .drive(onNext: { [weak self] () in
                let title = R.string.localizable.commonSuccess.key.localized()
                let description = R.string.localizable.notificationsMarkAsReadSuccess.key.localized()
                let image = R.image.icon_toast_success()
                self?.tableView.makeToast(description, title: title, image: image)
            })
            .disposed(by: rx.disposeBag)
    }

    lazy var rightBarButton = TTBarButtonItem(
        image: R.image.icon_cell_check(),
        style: .done,
        target: nil,
        action: nil
    )
    
    lazy var segmentedControl: TTSegmentedControl = {
        let items = [
            TTNotificationSegment.unread.title,
            TTNotificationSegment.participating.title,
            TTNotificationSegment.all.title
        ]
        let view = TTSegmentedControl(sectionTitles: items)
        view.selectedSegmentIndex = 0
        view.snp.makeConstraints { (make) in
            make.width.equalTo(260)
        }
        return view
    }()

}
