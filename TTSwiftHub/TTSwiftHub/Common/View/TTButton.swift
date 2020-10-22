//
//  TTButton.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/22.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }
    
    func makeUI() {
        themeService.rx
            .bind({ UIImage(color: $0.secondary, size: CGSize(width: 1, height: 1)) }, to: rx.backgroundImage(for: .normal))
            .bind({ UIImage(color: $0.secondary.withAlphaComponent(0.9), size: CGSize(width: 1, height: 1)) }, to: rx.backgroundImage(for: .selected))
            .bind({ UIImage(color: $0.secondary.withAlphaComponent(0.6), size: CGSize(width: 1, height: 1)) }, to: rx.backgroundImage(for: .disabled))
            .disposed(by: rx.disposeBag)
        
        layer.masksToBounds = true
        titleLabel?.lineBreakMode = .byWordWrapping
        cornerRadius = Configs.BaseDimensions.cornerRadius
        
        snp.makeConstraints { (make) in
            make.height.equalTo(Configs.BaseDimensions.buttonHeight)
        }
        
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }
}
