//
//  UIImage+Extension.swift
//  TTSwiftHub
//
//  Created by QDSG on 2021/2/24.
//  Copyright © 2021 tTao. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func filled(withColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        guard let mask = cgImage else { return self }
        
        context.clip(to: rect, mask: mask)
        context.fill(rect)
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
