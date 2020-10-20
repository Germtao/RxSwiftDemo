//
//  UIView+Rx.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/10/20.
//  Copyright © 2020 tTao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RAMAnimatedTabBarController
import KafkaRefresh

// MARK: - UIView
extension Reactive where Base: UIView {
    var backgroundColor: Binder<UIColor?> {
        Binder(self.base) { (view, attr) in
            view.backgroundColor = attr
        }
    }
}

// MARK: - UITextField
extension Reactive where Base: UITextField {
    var borderColor: Binder<UIColor?> {
        Binder(self.base) { (view, attr) in
            view.borderColor = attr
        }
    }
    
    var placeholderColor: Binder<UIColor?> {
        Binder(self.base) { (view, attr) in
            if let color = attr {
                view.setPlaceHolderTextColor(color)
            }
        }
    }
}

// MARK: - UITableView
extension Reactive where Base: UITableView {
    var separatorColor: Binder<UIColor?> {
        Binder(self.base) { (view, attr) in
            view.separatorColor = attr
        }
    }
}

// MARK: - RAMAnimatedTabBarItem
extension Reactive where Base: RAMAnimatedTabBarItem {
    var iconColor: Binder<UIColor> {
        Binder(self.base) { (view, attr) in
            view.iconColor = attr
            view.deselectAnimation()
        }
    }
    
    var textColor: Binder<UIColor> {
        Binder(self.base) { (view, attr) in
            view.textColor = attr
            view.deselectAnimation()
        }
    }
}

// MARK: - RAMItemAnimation
extension Reactive where Base: RAMItemAnimation {
    var iconSelectedColor: Binder<UIColor> {
        Binder(self.base) { (view, attr) in
            view.iconSelectedColor = attr
        }
    }
    
    var textSelectedColor: Binder<UIColor> {
        Binder(self.base) { (view, attr) in
            view.textSelectedColor = attr
        }
    }
}

// MARK: - UINavigationBar
extension Reactive where Base: UINavigationBar {
    @available(iOS 11.0, *)
    var largeTitleTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        Binder(self.base) { (view, attr) in
            view.largeTitleTextAttributes = attr
        }
    }
}

// MARK: - UIApplication
extension Reactive where Base: UIApplication {
    var statusBarStyle: Binder<UIStatusBarStyle> {
        return Binder(self.base) { (view, style) in
            globalStatusBarStyle.accept(style)
        }
    }
}

// MARK: - KafkaRefreshDefaults
extension Reactive where Base: KafkaRefreshDefaults {
    var themeColor: Binder<UIColor?> {
        return Binder(self.base) { (view, color) in
            view.themeColor = color
        }
    }
}

// MARK: - UISwitch
extension Reactive where Base: UISwitch {
    var onTintColor: Binder<UIColor?> {
        Binder(self.base) { (view, attr) in
            view.onTintColor = attr
        }
    }
    
    var thumbTintColor: Binder<UIColor?> {
        Binder(self.base) { (view, attr) in
            view.thumbTintColor = attr
        }
    }
}
