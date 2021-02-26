//
//  TTUserCell.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/23.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTUserCell: TTDefaultTableViewCell {
    
    override func makeUI() {
        super.makeUI()
        
        leftImageView.cornerRadius = 25
        stackView.insertArrangedSubview(followButton, at: 2)
    }
    
    override func bindViewModel(to viewModel: TTTableViewCellViewModel) {
        super.bindViewModel(to: viewModel)
        
        guard let viewModel = viewModel as? TTUserCellViewModel else { return }
        
        viewModel.hidesFollowButton
            .asDriver()
            .drive(followButton.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        viewModel.following
            .asDriver()
            .map { followed -> UIImage? in
                let image = followed ? R.image.icon_button_user_x() : R.image.icon_button_user_plus()
                return image?.template
            }
            .drive(followButton.rx.image())
            .disposed(by: rx.disposeBag)
        
        viewModel.following
            .map { $0 ? 1.0 : 0.6 }
            .asDriver(onErrorJustReturn: 0)
            .drive(followButton.rx.alpha)
            .disposed(by: rx.disposeBag)
    }

    lazy var followButton: TTButton = {
        let button = TTButton()
        button.borderColor = .white
        button.borderWidth = Configs.BaseDimensions.borderWidth
        button.tintColor = .white
        button.cornerRadius = 17
        button.snp.remakeConstraints { (make) in
            make.size.equalTo(34)
        }
        return button
    }()
    
}
