//
//  TTCollectionViewController.swift
//  TTSwiftHub
//
//  Created by QDSG on 2021/2/25.
//  Copyright © 2021 tTao. All rights reserved.
//

import UIKit

class TTCollectionViewController: TTBaseViewController {
    var clearsSelectionOnViewWillAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if clearsSelectionOnViewWillAppear {
            deselectSelectedItems()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func makeUI() {
        super.makeUI()
        
        stackView.spacing = 0
        stackView.insertSubview(collectionView, at: 0)
    }
    
    override func updateUI() {
        super.updateUI()
    }
    
    lazy var collectionView: TTCollectionView = {
        let view = TTCollectionView()
        view.emptyDataSetSource = self
        view.emptyDataSetDelegate = self
        return view
    }()
}

extension TTCollectionViewController {
    func deselectSelectedItems() {
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
            selectedIndexPaths.forEach {
                collectionView.deselectItem(at: $0, animated: false)
            }
        }
    }
}
