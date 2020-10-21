//
//  TTContentCellViewModel.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/21.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTContentCellViewModel: TTDefaultTableViewCellViewModel {
    let content: TTContent
    
    init(content: TTContent) {
        self.content = content
        super.init()
        
        title.accept(content.name)
        detail.accept(content.type == .file ? content.size?.sizeFromByte() : nil)
        image.accept(content.type.image()?.template)
    }
}
