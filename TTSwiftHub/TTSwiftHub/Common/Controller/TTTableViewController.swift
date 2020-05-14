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

class TTTableViewController: UIViewController, UIScrollViewDelegate {
    
    /// PublishSubject: 既是可观察对象同时也是观察者, 初始化时并不包含数据，并且只会给订阅者发送后续数据
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    
    let isHeaderLoading = BehaviorRelay(value: false)
    let isFooterLoading = BehaviorRelay(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            <#code#>
        }
    }
}

extension TTTableViewController: UITableViewDelegate {
    
}
