//
//  RxSwiftTableViewController.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2020/4/29.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class RxSwiftTableViewController: UIViewController {
    
    private let isRx: Bool
    
    init(isRx: Bool) {
        self.isRx = isRx
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        }
    }
    
    private let viewModel = MusicViewModel()

}

extension RxSwiftTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isRx ? viewModel.data.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
    }
}
