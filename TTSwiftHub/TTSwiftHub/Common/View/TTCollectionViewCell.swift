//
//  TTCollectionViewCell.swift
//  TTSwiftHub
//
//  Created by QDSG on 2021/2/25.
//  Copyright © 2021 tTao. All rights reserved.
//

import UIKit

class TTCollectionViewCell: UICollectionViewCell {
    func makeUI() {
        layer.masksToBounds = true
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }
}
