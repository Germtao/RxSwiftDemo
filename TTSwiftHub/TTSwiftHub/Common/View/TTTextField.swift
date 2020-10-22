//
//  TTTextField.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/22.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }
    
    override var placeholder: String? {
        didSet {
            themeService.switch(themeService.type)
        }
    }
    
    func makeUI() {
        themeService.rx
            .bind({ $0.text }, to: rx.textColor)
            .bind({ $0.secondary }, to: rx.tintColor)
            .bind({ $0.textGray }, to: rx.placeholderColor)
            .bind({ $0.text }, to: rx.borderColor)
            .bind({ $0.keyboardAppearance }, to: rx.keyboardAppearance)
            .disposed(by: rx.disposeBag)
        
        layer.masksToBounds = true
        borderWidth = Configs.BaseDimensions.borderWidth
        cornerRadius = Configs.BaseDimensions.cornerRadius
        
        snp.makeConstraints { (make) in
            make.height.equalTo(Configs.BaseDimensions.textFieldHeight)
        }
    }
    
}
