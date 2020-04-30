//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2020/4/26.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let reuseIdentifier = "cellId"
    
    var titles: [String] = ["Observable创建、订阅和销毁", "RxSwift UI用法"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBOutlet private weak var tableView: UITableView!
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let observableVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ObservableId") as! CustomViewController
            observableVc.title = titles[indexPath.row]
            present(observableVc, animated: true)
        case 1:
            let vc = RxSwiftUIViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .currentContext
            nav.modalTransitionStyle = .flipHorizontal
            nav.title = titles[indexPath.row]
            present(nav, animated: true)
        default:
            break
        }
    }
}

