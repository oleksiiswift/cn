//
//  Colors.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit

enum Theme: Int {
    case light
    case dark
    
    var statusBarStyle: UIStatusBarStyle {
        switch self {
            case .light:
                return .darkContent
            case .dark:
                return .lightContent
        }
    }
//    MARK: - backgroud colors -
    
    var backgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("E3E8F1")
            case .dark:
                return UIColor().colorFromHexString("FFFFFF")
        }
    }
    
    var contentBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("F0F0F0")
            case .dark:
                return UIColor().colorFromHexString("F0F0F0")
        }
    }
    
    var accentBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("4F4F4F")
            case .dark:
                return UIColor().colorFromHexString("4F4F4F")
        }
    }
    
//    MARK: - Tint colors -
    
    var tintColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("4F4F4F")
            case .dark:
                return UIColor().colorFromHexString("4F4F4F")
        }
    }
    
//    MARK: - Title text colors -
    
    var navigationBarTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("4F4F4F")
            case .dark:
                return UIColor().colorFromHexString("4F4F4F")
        }
    }
    
    var titleTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("4F4F4F")
            case .dark:
                return UIColor().colorFromHexString("4F4F4F")
        }
    }
    
    var subTitleTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("4F4F4F").withAlphaComponent(0.5)
            case .dark:
                return UIColor().colorFromHexString("4F4F4F").withAlphaComponent(0.5)
        }
    }
    
    var activeTitleTextColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("FFFFFF")
            case .dark:
                return UIColor().colorFromHexString("FFFFFF")
        }
    }
    
    var sectionBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("C4C4C4")
            case .dark:
                return UIColor().colorFromHexString("C4C4C4")
        }
    }
    
    var progressBackgroundColor: UIColor {
        switch self {
            case .light:
                return UIColor().colorFromHexString("dedede")
            case .dark:
                return UIColor().colorFromHexString("dedede")
        }
    }
}

