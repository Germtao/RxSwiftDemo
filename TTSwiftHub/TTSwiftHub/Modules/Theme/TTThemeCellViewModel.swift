//
//  TTThemeCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTThemeCellViewModel: TTDefaultTableViewCellViewModel {
    let imageColor = BehaviorRelay<UIColor?>(value: nil)
    
    let theme: TTThemeColor
    
    init(theme: TTThemeColor) {
        self.theme = theme
        super.init()
        title.accept(theme.title)
        imageColor.accept(theme.color)
    }
}

