//
//  TTTrendingUserCell.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/16.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTTrendingUserCell: TTDefaultTableViewCell {

    override func makeUI() {
        super.makeUI()
        leftImageView.cornerRadius = 25
        leftImageView.snp.remakeConstraints { make in
            make.size.equalTo(50)
        }
    }
    
}
