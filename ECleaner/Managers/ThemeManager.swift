//
//  ThemeManager.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit


class ThemeManager {
    
    static var currentTheme: CurrentTheme = {
        return SettingsManager.sharedInstance.isDarkMode ? .dark : .light
    }()
    
    static var themeBaseOnSystemAppearance: CurrentTheme? {
        if let window = U.application.delegate?.window, let baseWindow = window {
            return baseWindow.traitCollection.userInterfaceStyle == .dark ? .dark : .light
        }
        return .light
    }

}

//    static func applyTheme(_ theme: Theme = ThemeManager.theme) {
//
//        ThemeManager.theme = theme
//
//        SettingManager.shared.isDarkMode = theme == .dark
//    }
//}
//
//
//public class ThemableViewController: UIViewController {
//    override public var preferredStatusBarStyle: UIStatusBarStyle {
//        return theme.statusBarStyle
//    }
//}
//
//
//extension UINavigationController {
//    override open var preferredStatusBarStyle: UIStatusBarStyle {
//        return theme.statusBarStyle
//    }
//}
