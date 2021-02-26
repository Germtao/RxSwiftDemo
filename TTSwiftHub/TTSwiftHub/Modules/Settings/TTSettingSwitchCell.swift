//
//  TTSettingSwitchCell.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/26.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTSettingSwitchCell: TTDefaultTableViewCell {

    lazy var switchView = TTSwitch()
    
    override func makeUI() {
        super.makeUI()
        
        leftImageView.contentMode = .center
        leftImageView.snp.remakeConstraints { (make) in
            make.size.equalTo(40)
        }
        
        stackView.insertArrangedSubview(switchView, at: 2)
        themeService.rx
            .bind({ $0.secondary }, to: leftImageView.rx.tintColor)
            .disposed(by: rx.disposeBag)
    }
    
    override func bindViewModel(to viewModel: TTTableViewCellViewModel) {
        super.bindViewModel(to: viewModel)
        
        guard let viewModel = viewModel as? TTSettingSwitchCellViewModel else { return }
        
        viewModel.isEnabled.asDriver()
            .drive(switchView.rx.isOn)
            .disposed(by: rx.disposeBag)
        
        switchView.rx.isOn
            .bind(to: viewModel.switchChanged)
            .disposed(by: rx.disposeBag)
    }
    
}
