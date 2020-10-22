//
//  TTToolbar.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/22.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTToolbar: UIToolbar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }
    
    func makeUI() {
        isTranslucent = false
        
        themeService.rx
            .bind({ $0.barStyle }, to: rx.barStyle)
            .bind({ $0.primaryDark }, to: rx.barTintColor)
            .bind({ $0.secondary }, to: rx.tintColor)
            .disposed(by: rx.disposeBag)
        
        snp.makeConstraints { make in
            make.height.equalTo(Configs.BaseDimensions.tabBarHeight)
        }
    }
}
