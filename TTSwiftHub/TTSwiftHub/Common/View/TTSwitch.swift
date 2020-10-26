//
//  TTSwitch.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/26.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTSwitch: UISwitch {
    
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
            .bind({ $0.secondary }, to: [rx.tintColor, rx.onTintColor])
            .disposed(by: rx.disposeBag)
    }
    
}
