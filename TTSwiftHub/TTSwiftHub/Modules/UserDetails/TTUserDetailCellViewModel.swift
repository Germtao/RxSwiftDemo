//
//  TTUserDetailCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/10.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTUserDetailCellViewModel: TTDefaultTableViewCellViewModel {
    init(title: String, detail: String, image: UIImage?, hidesDisclosure: Bool) {
        super.init()
        self.title.accept(title)
        self.secondDetail.accept(detail)
        self.image.accept(image)
        self.hidesDisclosure.accept(hidesDisclosure)
    }
}
