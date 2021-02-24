//
//  UIView+Extension.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/13.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
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

// MARK: - Borders

extension UIView {
    enum BorderSide {
        case left, top, right, bottom
    }
    
    var defaultBorderColor: UIColor { UIColor.separator }
    
    var defaultBorderDepth: CGFloat { Configs.BaseDimensions.borderWidth }
    
    /// 为带有默认参数的侧面添加边框
    ///
    /// Parameter side: Border Side
    /// Returns: Border View
    @discardableResult // 抑制 Result unused 警告的属性
    func addBorder(for side: BorderSide) -> UIView {
        return addBorder(for: side, color: defaultBorderColor, depth: defaultBorderDepth)
    }
    
    /// 使用默认参数添加底部边框
    @discardableResult
    func addBottomBorder(leftInset: CGFloat = 10.0, rightInset: CGFloat = 0.0) -> UIView {
        let border = UIView()
        border.backgroundColor = defaultBorderColor
        addSubview(border)
        
        border.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(leftInset)
            make.right.equalToSuperview().inset(rightInset)
            make.bottom.equalToSuperview()
            make.height.equalTo(self.defaultBorderDepth)
        }
        
        return border
    }
    
    /// 添加带有颜色、深度、长度和偏移量的侧面的边框
    ///
    /// - Parameters:
    ///     - side: 边框 边
    ///     - color: 边框 颜色
    ///     - depth: 边框 深度
    ///     - length: 边框 长度
    ///     - inset: 边框 inset
    ///     - cornersInset: 边框角 inset
    @discardableResult
    func addBorder(for side: BorderSide,
                   color: UIColor,
                   depth: CGFloat,
                   length: CGFloat = 0.0,
                   inset: CGFloat = 0.0,
                   cornersInset: CGFloat = 0.0) -> UIView {
        let border = UIView()
        border.backgroundColor = .clear
        addSubview(border)
        
        border.snp.makeConstraints { (make) in
            switch side {
            case .left:
                if length != 0.0 {
                    make.height.equalTo(length)
                    make.centerY.equalToSuperview()
                } else {
                    make.top.bottom.equalToSuperview().inset(cornersInset)
                }
                make.left.equalToSuperview().inset(inset)
                make.width.equalTo(depth)
            case .top:
                if length != 0.0 {
                    make.width.equalTo(length)
                    make.centerX.equalToSuperview()
                } else {
                    make.left.right.equalToSuperview().inset(cornersInset)
                }
                make.top.equalToSuperview().inset(inset)
                make.height.equalTo(depth)
            case .right:
                if length != 0.0 {
                    make.height.equalTo(length)
                    make.centerY.equalToSuperview()
                } else {
                    make.top.bottom.equalToSuperview().inset(cornersInset)
                }
                make.right.equalToSuperview().inset(inset)
                make.width.equalTo(depth)
            case .bottom:
                if length != 0.0 {
                    make.width.equalTo(length)
                    make.centerX.equalToSuperview()
                } else {
                    make.left.right.equalToSuperview().inset(cornersInset)
                }
                make.bottom.equalToSuperview().inset(inset)
                make.height.equalTo(depth)
            }
        }
        return border
    }
}

extension UIView {
    func makeRoundedCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func makeRoundedCorners() {
        makeRoundedCorners(bounds.size.width / 2)
    }
    
    func renderAsImage() -> UIImage? {
        var image: UIImage?
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: bounds.size)
            image = renderer.image(actions: { (ctx) in
                self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            })
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image
    }
    
    func blur(style: UIBlurEffect.Style) {
        unBlur()
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        insertSubview(blurEffectView, at: 0)
        blurEffectView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func unBlur() {
        subviews.filter { (view) -> Bool in
            view as? UIVisualEffectView != nil
        }.forEach { (view) in
            view.removeFromSuperview()
        }
    }
}
