//
//  TTImageView.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/6/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

class TTImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        makeUI()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }
    
    func makeUI() {
        tintColor = .primary
        layer.masksToBounds = true
        contentMode = .center
        
        hero.modifiers = [.arc]
        
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }

}
