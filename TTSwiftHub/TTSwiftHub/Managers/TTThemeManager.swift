//
//  TTThemeManager.swift
//  TTSwiftHub
//
//  Created by QDSG on 2020/5/15.
//  Copyright © 2020 tTao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxTheme

let globalStatusBarStyle = BehaviorRelay<UIStatusBarStyle>(value: .default)

let themeService = TTThemeType.service(initial: TTThemeType.currentTheme())

protocol TTTheme {
    var primary: UIColor { get }
    var primaryDark: UIColor { get }
    var secondary: UIColor { get }
    var secondaryDark: UIColor { get }
    var separator: UIColor { get }
    var text: UIColor { get }
    var textGray: UIColor { get }
    var background: UIColor { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var barStyle: UIBarStyle { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var blurStyle: UIBlurEffect.Style { get }
    
    init(themeColor: TTThemeColor)
}

struct TTLightTheme: TTTheme {
    let primary = UIColor.Material.white
    let primaryDark = UIColor.Material.grey200
    var secondary = UIColor.Material.red
    var secondaryDark = UIColor.Material.red900
    let separator = UIColor.Material.grey50
    let text = UIColor.Material.grey900
    let textGray = UIColor.Material.grey
    let background = UIColor.Material.white
    let statusBarStyle = UIStatusBarStyle.default
    let barStyle = UIBarStyle.default
    let keyboardAppearance = UIKeyboardAppearance.light
    let blurStyle = UIBlurEffect.Style.extraLight
    
    init(themeColor: TTThemeColor) {
        secondary = themeColor.color
        secondaryDark = themeColor.colorDark
    }
}

struct TTDarkTheme: TTTheme {
    let primary = UIColor.Material.grey800
    let primaryDark = UIColor.Material.grey900
    var secondary = UIColor.Material.red
    var secondaryDark = UIColor.Material.red900
    let separator = UIColor.Material.grey900
    let text = UIColor.Material.grey50
    let textGray = UIColor.Material.grey
    let background = UIColor.Material.grey800
    let statusBarStyle = UIStatusBarStyle.lightContent
    let barStyle = UIBarStyle.black
    let keyboardAppearance = UIKeyboardAppearance.dark
    let blurStyle = UIBlurEffect.Style.dark
    
    init(themeColor: TTThemeColor) {
        secondary = themeColor.color
        secondaryDark = themeColor.colorDark
    }
}

enum TTThemeColor: Int {
    case red, pink, purple, deepPurple, indigo, blue, lightBlue, cyan, teal, green, lightGreen, lime, yellow, amber, orange, deepOrange, brown, gray, blueGray
    
    static let allValues = [red, pink, purple, deepPurple, indigo, blue, lightBlue, cyan, teal, green, lightGreen, lime, yellow, amber, orange, deepOrange, brown, gray, blueGray]
    
    var color: UIColor {
        switch self {
        case .red: return UIColor.Material.red
        case .pink: return UIColor.Material.pink
        case .purple: return UIColor.Material.purple
        case .deepPurple: return UIColor.Material.deepPurple
        case .indigo: return UIColor.Material.indigo
        case .blue: return UIColor.Material.blue
        case .lightBlue: return UIColor.Material.lightBlue
        case .cyan: return UIColor.Material.cyan
        case .teal: return UIColor.Material.teal
        case .green: return UIColor.Material.green
        case .lightGreen: return UIColor.Material.lightGreen
        case .lime: return UIColor.Material.lime
        case .yellow: return UIColor.Material.yellow
        case .amber: return UIColor.Material.amber
        case .orange: return UIColor.Material.orange
        case .deepOrange: return UIColor.Material.deepOrange
        case .brown: return UIColor.Material.brown
        case .gray: return UIColor.Material.grey
        case .blueGray: return UIColor.Material.blueGrey
        }
    }
    
    var colorDark: UIColor {
        switch self {
        case .red: return UIColor.Material.red900
        case .pink: return UIColor.Material.pink900
        case .purple: return UIColor.Material.purple900
        case .deepPurple: return UIColor.Material.deepPurple900
        case .indigo: return UIColor.Material.indigo900
        case .blue: return UIColor.Material.blue900
        case .lightBlue: return UIColor.Material.lightBlue900
        case .cyan: return UIColor.Material.cyan900
        case .teal: return UIColor.Material.teal900
        case .green: return UIColor.Material.green900
        case .lightGreen: return UIColor.Material.lightGreen900
        case .lime: return UIColor.Material.lime900
        case .yellow: return UIColor.Material.yellow900
        case .amber: return UIColor.Material.amber900
        case .orange: return UIColor.Material.orange900
        case .deepOrange: return UIColor.Material.deepOrange900
        case .brown: return UIColor.Material.brown900
        case .gray: return UIColor.Material.grey900
        case .blueGray: return UIColor.Material.blueGrey900
        }
    }
    
    var title: String {
        switch self {
        case .red: return "Red"
        case .pink: return "Pink"
        case .purple: return "Purple"
        case .deepPurple: return "Deep Purple"
        case .indigo: return "Indigo"
        case .blue: return "Blue"
        case .lightBlue: return "Light Blue"
        case .cyan: return "Cyan"
        case .teal: return "Teal"
        case .green: return "Green"
        case .lightGreen: return "Light Green"
        case .lime: return "Lime"
        case .yellow: return "Yellow"
        case .amber: return "Amber"
        case .orange: return "Orange"
        case .deepOrange: return "Deep Orange"
        case .brown: return "Brown"
        case .gray: return "Gray"
        case .blueGray: return "Blue Gray"
        }
    }
}

enum TTThemeType: ThemeProvider {
    case light(color: TTThemeColor)
    case dark(color: TTThemeColor)
    
    var associatedObject: TTTheme {
        switch self {
        case .light(let color): return TTLightTheme(themeColor: color)
        case .dark(let color): return TTDarkTheme(themeColor: color)
        }
    }
    
    var isDark: Bool {
        switch self {
        case .dark: return true
        case .light: return false
        }
    }
    
    func toggled() -> TTThemeType {
        var themeType: TTThemeType
        switch self {
        case .light(let color): themeType = .light(color: color)
        case .dark(let color): themeType = .dark(color: color)
        }
        themeType.save()
        return themeType
    }
    
    func withColor(color: TTThemeColor) -> TTThemeType {
        var theme: TTThemeType
        switch self {
        case .light:
            theme = TTThemeType.light(color: color)
        case .dark:
            theme = TTThemeType.dark(color: color)
        }
        theme.save()
        return theme
    }
}

extension TTThemeType {
    static func currentTheme() -> TTThemeType {
        let defaults = UserDefaults.standard
        let isDark = defaults.bool(forKey: "IsDarkKey")
        let themeColor = TTThemeColor(rawValue: defaults.integer(forKey: "ThemeKey")) ?? TTThemeColor.red
        let themeType = isDark ? TTThemeType.dark(color: themeColor) : TTThemeType.light(color: themeColor)
        themeType.save()
        return themeType
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(isDark, forKey: "IsDarkKey")
        switch self {
        case .light(let color): defaults.set(color.rawValue, forKey: "ThemeKey")
        case .dark(let color): defaults.set(color.rawValue, forKey: "ThemeKey")
        }
    }
}
