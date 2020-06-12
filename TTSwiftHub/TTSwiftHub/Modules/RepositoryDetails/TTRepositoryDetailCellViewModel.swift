//
//  TTRepositoryDetailCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/11.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTRepositoryDetailCellViewModel: TTDefaultTableViewCellViewModel {
    init(title: String, detail: String, image: UIImage?, hidesDisclosure: Bool) {
        super.init()
        self.title.accept(title)
        self.secondDetail.accept(detail)
        self.image.accept(image)
        self.hidesDisclosure.accept(hidesDisclosure)
    }
}
