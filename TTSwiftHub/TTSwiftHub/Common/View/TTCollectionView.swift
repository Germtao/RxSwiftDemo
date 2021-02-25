//
//  TTCollectionView.swift
//  TTSwiftHub
//
//  Created by QDSG on 2021/2/25.
//  Copyright © 2021 tTao. All rights reserved.
//

import UIKit

class TTCollectionView: UICollectionView {
    init() {
        super.init(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        makeUI()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }
    
    func makeUI() {
        layer.masksToBounds = true
        backgroundColor = .clear
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }
    
    func itemWidth(forItemsPerRow itemsPerRow: Int, withInset inset: CGFloat = 0.0) -> CGFloat {
        let collectionWidth = frame.size.width
        if collectionWidth == 0 {
            return 0
        }
        
        return (collectionWidth - CGFloat(itemsPerRow + 1) * inset) / CGFloat(itemsPerRow)
    }
    
    func setItemSize(_ size: CGSize) {
        if size.width == 0 || size.height == 0 {
            return
        }
        
        let layout = self.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = size
    }
}
