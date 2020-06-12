//
//  UIColor+SwiftHub.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/25.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

extension UIColor {
    static var text: UIColor {
        return themeService.type.associatedObject.primary
    }
    
    static var secondary: UIColor {
        return themeService.type.associatedObject.primaryDark
    }
    
    var brightnessAdjustedColor: UIColor {
        var components = self.cgColor.components
        let alpha = components?.last
        components?.removeLast()
        let color = CGFloat(1-(components?.max())! >= 0.5 ? 1.0 : 0.0)
        return UIColor(red: color, green: color, blue: color, alpha: alpha!)
    }
}
