//
//  TTSettingCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/20.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTSettingCellViewModel: TTDefaultTableViewCellViewModel {
    init(title: String, detail: String?, image: UIImage?, hidesDisclosure: Bool) {
        super.init()
        
        self.title.accept(title)
        self.detail.accept(detail)
        self.image.accept(image)
        self.hidesDisclosure.accept(hidesDisclosure)
    }
}
