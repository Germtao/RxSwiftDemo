//
//  TTEventCell.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/26.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift

class TTEventCell: TTDefaultTableViewCell {

    override func makeUI() {
        super.makeUI()
        
        titleLabel.numberOfLines = 2
        secondDetailLabel.numberOfLines = 0
        leftImageView.cornerRadius = 25
    }
    
    override func bindViewModel(to viewModel: TTTableViewCellViewModel) {
        super.bindViewModel(to: viewModel)
        
        guard let viewModel = viewModel as? TTEventsCellViewModel else { return }
        
        cellDisposeBag = DisposeBag()
        
        leftImageView.rx.tap()
            .map { _ in
                viewModel.event.actor
            }
            .filterNil()
            .bind(to: viewModel.userSelected)
            .disposed(by: cellDisposeBag)
    }
    
}
