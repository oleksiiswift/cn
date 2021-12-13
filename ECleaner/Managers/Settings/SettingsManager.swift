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
	
	static var defaultLowerDateValue: Date {
		get {
			return Date(timeIntervalSince1970: 0)
		}
	}
	
	static var defaultUpperDateValue: Date {
		get {
			return U.getDateFromComponents(day: 1, month: 1, year: 2666)
		}
	}
	
	static var lowerBoundSavedDate: Date {
		get {
			if let date = U.userDefaults.getDate(forKey: C.key.settings.lowerBoundSavedDate) {
				return date
			} else {
				return Date(timeIntervalSince1970: 0)
			}
		} set {
			U.userDefaults.set(date: newValue, forKey: C.key.settings.lowerBoundSavedDate)
		}
	}
	
	static var upperBoundSavedDate: Date {
		get {
			if let date = U.userDefaults.getDate(forKey: C.key.settings.upperBoundSavedDate) {
				return date
			} else {
				let currentDate = Date()
				let days = U.numbersOfDays(at: currentDate.getMonth(), in: currentDate.getYear())
				let date = U.getDateFromComponents(day: days, month: currentDate.getMonth(), year: currentDate.getYear())
				return date
			}
		} set {
			U.userDefaults.set(date: newValue, forKey: C.key.settings.upperBoundSavedDate)
		}
	}
    
    static var lastSmartCleanDate: Date? {
        get {
			return U.userDefaults.getDate(forKey: C.key.settings.lastSmartClean)
        } set {
			U.userDefaults.set(date: newValue, forKey: C.key.settings.lastSmartClean)
        }
    }
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
