//
//  TTView.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/13.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTView: UIView {

    convenience init(width: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        snp.makeConstraints { (make) in
            make.width.equalTo(width)
        }
    }
    
    convenience init(height: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
        snp.makeConstraints { (make) in
            make.height.equalTo(height)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        layer.masksToBounds = true
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }
    
    func getCenter() -> CGPoint {
        return convert(center, from: superview)
    }
    
}
