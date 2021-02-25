//
//  TTPickerView.swift
//  TTSwiftHub
//
//  Created by QDSG on 2021/2/25.
//  Copyright © 2021 tTao. All rights reserved.
//

import UIKit

class TTPickerView: UIPickerView {
    init() {
        super.init(frame: CGRect())
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }
    
    func makeUI() {}
}
