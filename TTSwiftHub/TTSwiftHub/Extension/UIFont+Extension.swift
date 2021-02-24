//
//  UIFont+Extension.swift
//  TTSwiftHub
//
//  Created by QDSG on 2021/2/24.
//  Copyright © 2021 tTao. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    static let navigationTitleFont = UIFont.systemFont(ofSize: 17.0)
    
    static let titleFont = UIFont.systemFont(ofSize: 17.0)
    
    static let descriptionFont = UIFont.systemFont(ofSize: 14.0)
    
    static var allSystemFontsNames: [String] {
        var fontsNames = [String]()
        let fontFamilies = UIFont.familyNames
        for fontFamily in fontFamilies {
            let fontsForFamily = UIFont.fontNames(forFamilyName: fontFamily)
            for fontName in fontsForFamily {
                fontsNames.append(fontName)
            }
        }
        return fontsNames
    }
    
    static func randomFont(ofSize size: CGFloat) -> UIFont {
        let allFontsNames = UIFont.allSystemFontsNames
        let fontsCount = UInt32(allFontsNames.count)
        let randomFontIndex = Int(arc4random_uniform(fontsCount))
        let randomFontName = allFontsNames[randomFontIndex]
        return UIFont(name: randomFontName, size: size)!
    }
}
