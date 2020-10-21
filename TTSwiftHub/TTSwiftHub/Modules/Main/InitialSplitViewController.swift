//
//  InitialSplitViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/13.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class InitialSplitViewController: TTTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func makeUI() {
        super.makeUI()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        
        emptyDataSetTitle = R.string.localizable.initialNoResults.key.localized()
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
    }
}

