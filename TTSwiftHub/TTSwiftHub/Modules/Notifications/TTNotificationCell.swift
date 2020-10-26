//
//  TTNotificationCell.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/26.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift

class TTNotificationCell: TTDefaultTableViewCell {

    override func makeUI() {
        super.makeUI()
        
        titleLabel.numberOfLines = 2
        leftImageView.cornerRadius = 25
    }
    
    override func bind(to viewModel: TTDefaultTableViewCellViewModel) {
        super.bind(to: viewModel)
        
        guard let viewModel = viewModel as? TTNotificationCellViewModel else { return }
        
        cellDisposeBag = DisposeBag()
        
        leftImageView.rx.tap()
            .map { _ in
                viewModel.notification.repository?.owner
            }
            .filterNil()
            .bind(to: viewModel.userSelected)
            .disposed(by: rx.disposeBag)
    }
    
}
