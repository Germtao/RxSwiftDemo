//
//  TTSettingCell.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/26.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTSettingCell: TTDefaultTableViewCell {

    override func makeUI() {
        super.makeUI()
        
        leftImageView.contentMode = .center
        leftImageView.snp.remakeConstraints { (make) in
            make.size.equalTo(40)
        }
        
        detailLabel.isHidden = true
        attributedDetailLabel.isHidden = true
        secondDetailLabel.textAlignment = .right
        textsStackView.axis = .horizontal
        textsStackView.distribution = .fillEqually
    }
    
}
