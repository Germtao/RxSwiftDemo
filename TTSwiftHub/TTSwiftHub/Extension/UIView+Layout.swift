//
//  UIView+Layout.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/13.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

extension UIView {
    var inset: CGFloat {
        return Configs.BaseDimensions.inset
    }
    
    open func setPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) {
        self.setContentHuggingPriority(priority, for: axis)
        self.setContentCompressionResistancePriority(priority, for: axis)
    }
}
