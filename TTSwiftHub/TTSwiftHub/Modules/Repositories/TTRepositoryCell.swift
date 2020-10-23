//
//  TTRepositoryCell.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/23.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTRepositoryCell: TTDefaultTableViewCell {
    
    override func makeUI() {
        super.makeUI()
        
        leftImageView.cornerRadius = 25
        stackView.insertArrangedSubview(starButton, at: 2)
    }
    
    override func bind(to viewModel: TTDefaultTableViewCellViewModel) {
        super.bind(to: viewModel)
        
        guard let viewModel = viewModel as? TTRepositoryCellViewModel else { return }
        
        viewModel.hidesStarButton
            .asDriver()
            .drive(starButton.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        viewModel.starring
            .asDriver()
            .map { starred -> UIImage? in
                let image = starred ? R.image.icon_button_unstar() : R.image.icon_button_star()
                return image?.template
            }
            .drive(starButton.rx.image())
            .disposed(by: rx.disposeBag)
        
        viewModel.starring
            .map { $0 ? 1.0 : 0.6 }
            .asDriver(onErrorJustReturn: 0)
            .drive(starButton.rx.alpha)
            .disposed(by: rx.disposeBag)
    }

    lazy var starButton: TTButton = {
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
