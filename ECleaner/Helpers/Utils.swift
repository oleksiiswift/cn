//
//  Utils.swift
//  ECleaner
//
//  Created by mac on 16.06.2021.
//

import Foundation
import UIKit

typealias U = Utils
class Utils {
    
//    MARK: - DEFAULT VALUES -
    
    static let userDefaults: UserDefaults = .standard
    
    static let application: UIApplication = .shared
    
    static let topLevel: UIWindow.Level = .statusBar
    
    static let device: UIDevice = .current
    
    static let appDelegate: AppDelegate = application.delegate as! AppDelegate
    
    static let locale: Locale = .current
    
    static let mainBundle: Bundle = .main
    
    static let bundleIdentifier = mainBundle.bundleIdentifier
    
//     MARK: - UI VALUES -
    
    static let mainScreen: UIScreen = .main
    
    static let screenBounds: CGRect = mainScreen.bounds
    
    static let screenHeight = screenBounds.height
    
    static let screenWidth = screenBounds.width
    
    static let ratio: CGFloat = U.screenWidth / U.screenHeight
    
    static let window = U.application.windows.filter { $0.isKeyWindow}.first
    
    static let statusBarHeight: CGFloat = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    
    static let topSafeAreaInset: CGFloat = U.screenHeight < 600 ? 5 : 10
    
    static let largeTitleTopSafeAreaInset: CGFloat = U.screenHeight < 600 ? 100 : 120
    
    static let navigationBarHeight: CGFloat = 44.0 + topSafeAreaInset
    
    static let statusAndNavigationBarsHeight: CGFloat = statusBarHeight + navigationBarHeight
    
    static let advertisementHeight: CGFloat = 50
    
    static let actualScreen: CGRect = {
        var rect = mainScreen.bounds
        rect.size.height -= statusAndNavigationBarsHeight
        return rect
    }()
    
    static let tabBarHeight: CGFloat = 49.0
    
    static let toolBarHeight: CGFloat = 44.0
    
//    MARK: - HELPERS -
    
    static let notificationCenter: NotificationCenter = .default
    
    static let pasteboard = UIPasteboard.general
    
    static let appSettings = UIApplication.openSettingsURLString
    
//    MARK: - DEVICES -
    
    static let isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    static let isSmallDevice: Bool = mainScreen.bounds.size.height <= 667
    
    static let isLandscapeOrientation = device.orientation.isLandscape
    
    static public var hasTopNotch: Bool {
        return window?.safeAreaInsets.top ?? 0 > 20
    }
    
    static let isSimulator = UIDevice.isSimulator
}

extension Utils {
    
    static func openSettings() {
        DispatchQueue.main.async {
            U.application.open(URL(string: appSettings)!)
        }
    }
    
    static func contains(_ key: String) -> Bool {
        return U.userDefaults.object(forKey: key) != nil
    }
    
    static func resetAllUserDefaults() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { (key) in
            userDefaults.removeObject(forKey: key)
        }
    }
}
