//
//  SettingsManager.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import Foundation

typealias S = SettingsManager
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
    
    static var isLibraryAccessGranted: Bool {
        get {
            U.userDefaults.bool(forKey: C.key.settings.photoLibraryAccessGranted)
        } set {
            U.userDefaults.setValue(newValue, forKey: C.key.settings.photoLibraryAccessGranted)
        }
    }
    
    static var startingSavedDate: String {
        get {
            if let savedDate = U.userDefaults.string(forKey: C.key.settings.startingSavedDate) {
                return savedDate
            } else {
                self.startingSavedDate = timeMachine
                return timeMachine
            }
        } set {
            U.userDefaults.setValue(newValue, forKey: C.key.settings.startingSavedDate)
        }
    }
    
    static var endingSavedDate: String {
        get {
            if let endingDate = U.userDefaults.string(forKey: C.key.settings.endingSavedDate) {
                return endingDate
            } else {
                
                let currentDate = Date().convertDateFormatterFromDate(date: Date(), format: C.dateFormat.fullDmy)
                self.endingSavedDate = currentDate
                return currentDate
            }
        } set {
            U.userDefaults.setValue(newValue, forKey: C.key.settings.endingSavedDate)
        }
    }
    
    static var timeMachine = "01-01-1970 00:00:00"
}
