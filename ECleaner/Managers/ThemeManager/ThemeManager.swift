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
    
    static func applyTheme(_ theme: CurrentTheme = ThemeManager.currentTheme) {
        
        ThemeManager.currentTheme = theme
        SettingsManager.sharedInstance.isDarkMode = theme == .light
    }
}

public class ThemeChangeViewController: UIViewController {
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
}

extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
}

extension UIViewController {
    
    var currentTheme: CurrentTheme {
        return ThemeManager.currentTheme
    }
}

extension UINavigationController {
    
    func updateNavigationColors() {
        navigationBar.updateColors()
    }
    
    func updateNavigationInsets() {
//        additionalSafeAreaInsets.top = 0
    }
    
    func largeTitleNavigationInsets() {
//        additionalSafeAreaInsets.top = 0
    }
}


extension UIView {
    
    var currentTheme: CurrentTheme {
        return ThemeManager.currentTheme
    }
    
    func updateBackground() {
        backgroundColor = currentTheme.backgroundColor
    }
}


extension UINavigationBar: UpdateColorsDelegate {
    
    func updateColors() {
        
        tintColor = currentTheme.navigationBarTextColor
        barTintColor = .red
        
        let customFontSize = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        let backButtonItemAppearance = UIBarButtonItem.appearance()
        let attributes = [NSAttributedString.Key.font:  UIFont(name: "Helvetica-Bold", size: 0.1)!, NSAttributedString.Key.foregroundColor: UIColor.clear]

        backButtonItemAppearance.setTitleTextAttributes(attributes, for: .normal)
        backButtonItemAppearance.setTitleTextAttributes(attributes, for: .highlighted)
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: currentTheme.navigationBarTextColor]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: currentTheme.navigationBarTextColor, .font: customFontSize]
        navigationBarAppearance.backgroundColor = currentTheme.backgroundColor
        
        navigationBarAppearance.shadowColor = .clear
        standardAppearance = navigationBarAppearance
        scrollEdgeAppearance = navigationBarAppearance
    }
}

