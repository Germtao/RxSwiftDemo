//
//  UIColor+SwiftHub.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/25.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit

extension UIColor {
    static var primary: UIColor {
        return themeService.type.associatedObject.primary
    }
    
    static var primaryDark: UIColor {
        return themeService.type.associatedObject.primaryDark
    }
    
    static var secondaryDark: UIColor {
        return themeService.type.associatedObject.secondaryDark
    }
    
    static var separator: UIColor {
        return themeService.type.associatedObject.separator
    }
    
    static var text: UIColor {
        return themeService.type.associatedObject.text
    }
    
    static var secondary: UIColor {
        return themeService.type.associatedObject.secondary
    }
    
    var brightnessAdjustedColor: UIColor {
        var components = self.cgColor.components
        let alpha = components?.last
        components?.removeLast()
        let color = CGFloat(1-(components?.max())! >= 0.5 ? 1.0 : 0.0)
        return UIColor(red: color, green: color, blue: color, alpha: alpha!)
    }
}
