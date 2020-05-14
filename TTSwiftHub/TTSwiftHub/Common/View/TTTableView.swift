//
//  TTTableView.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/13.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTTableView: UITableView {

    init() {
        super.init(frame: .zero, style: .grouped)
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        defaultConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultConfigure()
    }
    
    func defaultConfigure() {
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 50
        sectionHeaderHeight = 30
        backgroundColor = .clear
        cellLayoutMarginsFollowReadableWidth = false
        keyboardDismissMode = .onDrag
        separatorColor = .clear
        separatorInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)
        tableHeaderView = TTView(height: 1)
        tableFooterView = UIView()
    }
}
