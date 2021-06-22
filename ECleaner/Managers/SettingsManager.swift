//
//  SettingsManager.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import Foundation

class SettingsManager {
    
    private static let shared = SettingsManager()
    
    static var sharedInstance: SettingsManager {
        return self.shared
    }
    
    public var isDarkMode: Bool {
        get {
            U.userDefaults.bool(forKey: C.key.settings.isDarkModeOn)
        } set {
            U.userDefaults.setValue(newValue, forKey: C.key.settings.isDarkModeOn)
        }
    }
}
