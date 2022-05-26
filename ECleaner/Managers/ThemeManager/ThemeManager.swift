//
//  ThemeManager.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit

class ThemeManager {
    
    static var theme: Theme = {
        return SettingsManager.sharedInstance.isDarkMode ? .dark : .light
    }()
    
    static var themeBaseOnSystemAppearance: Theme? {
        if let window = U.application.delegate?.window, let baseWindow = window {
            return baseWindow.traitCollection.userInterfaceStyle == .dark ? .dark : .light
        }
        return .light
    }
    
    static func applyTheme(_ theme: Theme = ThemeManager.theme) {
        
        ThemeManager.theme = theme
        SettingsManager.sharedInstance.isDarkMode = theme == .light
    }
}

public class ThemeChangeViewController: UIViewController {
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
}

extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
}

extension UIViewController {
    
    var theme: Theme {
        return ThemeManager.theme
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
    
    var theme: Theme {
        return ThemeManager.theme
    }
    
    func updateBackground() {
        backgroundColor = theme.backgroundColor
    }
}

extension UINavigationBar: UpdateColorsDelegate {
    
    func updateColors() {
        
        tintColor = theme.navigationBarTextColor
        barTintColor = .red
        
        let customFontSize = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        let backButtonItemAppearance = UIBarButtonItem.appearance()
        let attributes = [NSAttributedString.Key.font:  UIFont(name: "Helvetica-Bold", size: 0.1)!, NSAttributedString.Key.foregroundColor: UIColor.clear]

        backButtonItemAppearance.setTitleTextAttributes(attributes, for: .normal)
        backButtonItemAppearance.setTitleTextAttributes(attributes, for: .highlighted)
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: theme.navigationBarTextColor]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: theme.navigationBarTextColor, .font: customFontSize]
        navigationBarAppearance.backgroundColor = theme.backgroundColor
        
        navigationBarAppearance.shadowColor = .clear
        standardAppearance = navigationBarAppearance
        scrollEdgeAppearance = navigationBarAppearance
    }
}


extension ThemeManager {
	
	public func getPermissionAccentColor(from permission: Permission.PermissionType) -> [UIColor] {
		switch permission {
			case .notification:
				return Self.theme.permissionNotificationAccentColors
			case .photolibrary:
				return Self.theme.permissionPhotoLibraryAccentColors
			case .contacts:
				return Self.theme.permissionContantsAccentColors
			case .tracking:
				return Self.theme.permissionTrackingAccentColors
			default:
				return [UIColor()]
		}
	}
}
