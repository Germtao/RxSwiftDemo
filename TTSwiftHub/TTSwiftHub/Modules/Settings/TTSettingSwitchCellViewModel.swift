//
//  TTSettingSwitchCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/20.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TTSettingSwitchCellViewModel: TTDefaultTableViewCellViewModel {
    let isEnabled = BehaviorRelay(value: false)
    
    let switchChanged = PublishSubject<Bool>()
    
    init(title: String, detail: String?, image: UIImage?, hidesDisclosure: Bool, isEnabled: Bool) {
        super.init()
        
        self.title.accept(title)
        self.detail.accept(detail)
        self.image.accept(image)
        self.hidesDisclosure.accept(hidesDisclosure)
        self.isEnabled.accept(isEnabled)
    }
}
