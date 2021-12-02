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
                
                let currentDate = U.getString(from: Date(), format: C.dateFormat.fullDmy)
                self.endingSavedDate = currentDate
                return currentDate
            }
        } set {
            U.userDefaults.setValue(newValue, forKey: C.key.settings.endingSavedDate)
        }
    }
    
    static var lastSmartCleanDate: String? {
        get {
            return U.userDefaults.string(forKey: C.key.settings.lastSmartClean)
        } set {
            U.userDefaults.set(newValue, forKey: C.key.settings.lastSmartClean)
        }
    }
    
    static var timeMachine = "01-01-1970 00:00:00"
}


//  MARK: file sizez String values
    /// `phassetPhotoFilesSizes` -> disk space for all photos assets
    /// `phassetVideoFilesSizes` -> disk space for all videos assets
    /// `phassetFilesSize` -> disk space for all phassets

extension SettingsManager {
    
    static var phassetPhotoFilesSizes: Int64? {
        get {
            return U.userDefaults.value(forKey: C.key.settings.photoSpace) as? Int64
        } set {
            let info = [C.key.settings.photoSpace: newValue]
            U.userDefaults.setValue(newValue, forKey: C.key.settings.photoSpace)
            do {
                U.notificationCenter.post(name: .photoSpaceDidChange, object: nil, userInfo: info as [AnyHashable : Any])
            }
        }
    }
    
    static var phassetVideoFilesSizes: Int64? {
        get {
            return U.userDefaults.value(forKey: C.key.settings.videoSpace) as? Int64
        } set {
            let info = [C.key.settings.videoSpace: newValue]
            U.userDefaults.setValue(newValue, forKey: C.key.settings.videoSpace)
            do {
                U.notificationCenter.post(name: .videoSpaceDidChange, object: nil, userInfo: info as [AnyHashable : Any])
            }
        }
    }
    
    static var phassetFilesSize: Int64? {
        get {
            return U.userDefaults.value(forKey: C.key.settings.allMediaSpace) as? Int64
        } set {
            let info = [C.key.settings.allMediaSpace: newValue]
            U.userDefaults.setValue(newValue, forKey: C.key.settings.allMediaSpace)
            do {
                U.notificationCenter.post(name: .mediaSpaceDidChange, object: nil, userInfo: info as [AnyHashable : Any])
            }
        }
    }
    
    static func getDiskSpaceFiles(of type: MediaContentType) -> Int64? {
        switch type {
            case .userPhoto:
                return S.phassetPhotoFilesSizes
            case .userVideo:
                return S.phassetVideoFilesSizes
            case .userContacts:
                return 0
            case .none:
                return S.phassetFilesSize
        }
    }
    
    static func setDiskSpaceFiles(of type: MediaContentType, newValue: Int64) {
        switch type {
            case .userPhoto:
                S.phassetPhotoFilesSizes = newValue
            case .userVideo:
                S.phassetVideoFilesSizes = newValue
            case .none:
                S.phassetFilesSize = newValue
            default:
                return
        }
    }
}
extension SettingsManager {
	
	public static var isProcessingRunning: Bool {
		get {
			U.userDefaults.bool(forKey: "isProcessingRunning")
		} set {
			U.userDefaults.setValue(newValue, forKey: "isProcessingRunning")
		}
	}
}
