//
//  TTSplitViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTSplitViewController: UISplitViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return globalStatusBarStyle.value
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        preferredDisplayMode = .allVisible
        
        globalStatusBarStyle
            .mapToVoid()
            .subscribe(onNext: { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            })
            .disposed(by: rx.disposeBag)
    }
    
}

extension TTSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
