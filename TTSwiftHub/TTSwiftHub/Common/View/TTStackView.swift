//
//  TTStackView.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/14.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        spacing = inset
        axis = .vertical
        
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }
    
}
