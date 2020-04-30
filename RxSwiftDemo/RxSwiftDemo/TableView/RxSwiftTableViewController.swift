//
//  RxSwiftTableViewController.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2020/4/29.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxSwiftTableViewController: UIViewController {
    
    private let isRx: Bool
    
    init(isRx: Bool) {
        self.isRx = isRx
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isRx {
            tableView.rowHeight = 60
            tableView.estimatedRowHeight = UITableView.automaticDimension
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
            // 将数据源数据绑定到tableView上
            rxViewModel.data
                .bind(to:
                // rx.items(cellIdentifier:）:这是 Rx 基于 cellForRowAt 数据源方法的一个封装。
                // 传统方式中我们还要有个 numberOfRowsInSection 方法，
                // 使用 Rx 后就不再需要了（Rx 已经帮我们完成了相关工作）
                tableView.rx.items(cellIdentifier: "cellId")) { row, music, cell in
                    cell.textLabel?.text = music.name
                    cell.detailTextLabel?.text = music.singer
                }
                .disposed(by: disposeBag)
            
            // 点击响应
            tableView.rx.modelSelected(Music.self)
                .subscribe(onNext: { music in
                    print("rx_选中的歌曲信息【\(music)】")
                })
                .disposed(by: disposeBag)
        } else {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
    }
    
    private let viewModel = MusicViewModel()
    
    private let rxViewModel = RxMusicViewModel()
}

extension RxSwiftTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !isRx ? viewModel.data.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        }
        
        if !isRx {
            let music = viewModel.data[indexPath.row]
            cell?.textLabel?.text = music.name
            cell?.detailTextLabel?.text = music.singer
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("你选中的歌曲信息 【\(viewModel.data[indexPath.row])】")
    }
}
