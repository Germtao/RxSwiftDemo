//
//  TTTableViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/13.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KafkaRefresh

class TTTableViewController: TTBaseViewController, UIScrollViewDelegate {
    
    /// PublishSubject: 既是可观察对象同时也是观察者, 初始化时并不包含数据，并且只会给订阅者发送后续数据
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    
    let isHeaderLoading = BehaviorRelay(value: false)
    let isFooterLoading = BehaviorRelay(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    lazy var tableView: TTTableView = {
        let tableView = TTTableView(frame: CGRect(), style: .plain)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.rx.setDelegate(self).disposed(by: self.rx.disposeBag)
        return tableView
    }()
    
    var clearsSelectionOnViewWillAppear = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if clearsSelectionOnViewWillAppear {
            deselectSelectedRow()
        }
    }
    
    override func makeUI() {
        super.makeUI()
        
        stackView.spacing = 0
        stackView.insertArrangedSubview(tableView, at: 0)
        
        tableView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        
        tableView.bindGlobalStyle(forFootRefreshHandler: { [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        
        isHeaderLoading
            .bind(to: tableView.headRefreshControl.rx.isAnimating)
            .disposed(by: rx.disposeBag)
        
        isFooterLoading
            .bind(to: tableView.footRefreshControl.rx.isAnimating)
            .disposed(by: rx.disposeBag)
        
        tableView.footRefreshControl.autoRefreshOnFoot = true
        
        // 错误监听
        error
            .subscribe(onNext: { [weak self] error in
                var title = ""
                var description = ""
                let image = R.image.icon_toast_warning()
                switch error {
                case .serverError(let response):
                    title = response.message ?? ""
                    description = response.detail()
                }
                self?.tableView.makeToast(description, title: title, image: image)
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func updateUI() {
        super.updateUI()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        viewModel?.headerLoading
            .asObservable()
            .bind(to: isHeaderLoading)
            .disposed(by: rx.disposeBag)
        
        viewModel?.footerLoading
            .asObservable()
            .bind(to: isFooterLoading)
            .disposed(by: rx.disposeBag)
        
        // 更新空数据
        let updateEmptyDataSet =
            Observable.of(
                isLoading.mapToVoid().asObservable(),
                emptyDataSetImageTintColor.mapToVoid(),
                languageChanged.asObservable()
            ).merge()
        updateEmptyDataSet
            .subscribe(onNext: { [weak self] in
                self?.tableView.reloadEmptyDataSet()
            })
            .disposed(by: rx.disposeBag)
    }
}

extension TTTableViewController {
    func deselectSelectedRow() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            selectedIndexPaths.forEach {
                tableView.deselectRow(at: $0, animated: false)
            }
        }
    }
}

extension TTTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView, let textLabel = header.textLabel {
            textLabel.font = UIFont.systemFont(ofSize: 15.0)
            themeService.rx
                .bind({ $0.text }, to: textLabel.rx.textColor)
                .bind({ $0.primaryDark }, to: header.contentView.rx.backgroundColor)
                .disposed(by: rx.disposeBag)
        }
    }
}
