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
	
	struct application {
		
		static var lastApplicationUsage: Date {
			get {
				if let date = U.userDefaults.getDate(forKey: C.key.application.applicationLastUsage) {
					return date
				} else {
					return Date()
				}
			} set {
				U.userDefaults.set(date: newValue, forKey: C.key.application.applicationLastUsage)
			}
		}
		
		static var firstTimeApplicationStart: Bool {
			get {
				U.userDefaults.bool(forKey: C.key.application.applicationFirstTimeStart)
			} set {
				U.userDefaults.set(newValue, forKey: C.key.application.applicationFirstTimeStart)
			}
		}
	}
	
	struct subscripton {
		
		static var currentSubscriptionID: String {
			get {
				U.userDefaults.string(forKey: C.key.subscription.subscriptionID) ?? ""
			} set {
				U.userDefaults.set(newValue, forKey: C.key.subscription.subscriptionID)
			}
		}
		
		static var currentExprireSubscriptionDate: String {
			get {
				U.userDefaults.string(forKey: C.key.subscription.subscriptionExpireDate) ?? ""
			} set {
				U.userDefaults.set(newValue, forKey: C.key.subscription.subscriptionExpireDate)
			}
		}
		
		static var isVerificationPassed: Bool {
			get {
				return U.userDefaults.bool(forKey: C.key.subscription.verificationPassed)
			} set {
				U.userDefaults.set(newValue, forKey: C.key.subscription.verificationPassed)
			}
		}
		
		static var expiredSubscription: Bool {
			get {
				return U.userDefaults.bool(forKey: C.key.subscription.expiredSubscription)
			} set {
				U.userDefaults.setValue(newValue, forKey: C.key.subscription.expiredSubscription)
			}
		}
	}
	
	struct permissions {
		
		static var photoPermissionSavedValue: Bool {
			get {
				return U.userDefaults.bool(forKey: C.key.permissions.settingsPhotoPermission)
			} set {
				if photoPermissionSavedValue != newValue {
					let userInfo = [C.key.notificationDictionary.permission.photoPermission: PhotoLibraryPermissions().permissionRawValue]
					U.userDefaults.set(newValue, forKey: C.key.permissions.settingsPhotoPermission)
					do {
						U.notificationCenter.post(name: .permisionDidChange, object: nil, userInfo: userInfo)
					}
				}
			}
		}
		
		static var contactsPermissionSavedValue: Bool {
			get {
				return U.userDefaults.bool(forKey: C.key.permissions.settingsContactsPermission)
			} set {
				if contactsPermissionSavedValue != newValue {
					let userInfo = [C.key.notificationDictionary.permission.contactsPermission: ContactsPermissions().permissionRawValue]
					U.userDefaults.set(newValue, forKey: C.key.permissions.settingsContactsPermission)
					do {
						U.notificationCenter.post(name: .permisionDidChange, object: nil, userInfo: userInfo)
					}
				}
			}
		}
	}
	
	struct notification {
		
		static var localUserNotificationRawValue: Int {
			get {
				return U.userDefaults.integer(forKey: C.key.localUserNotification.localNotificationRawValue)
			} set {
				U.userDefaults.set(newValue, forKey: C.key.localUserNotification.localNotificationRawValue)
			}
		}
		
		static func setNewRemoteNotificationVaule(value: Int) {
			self.localUserNotificationRawValue = self.localUserNotificationRawValue == 5 ? 1 : value
		}
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
	
	static var lastSavedLocalIdenifier: String? {
		get {
			return U.userDefaults.string(forKey: C.key.localIdentifiers.lastSavedNewLocalIdentifier)
		} set {
			U.userDefaults.set(newValue, forKey: C.key.localIdentifiers.lastSavedNewLocalIdentifier)
		}
	}
	
	static var largeVideoLowerSize: Int64 {
		get {
			if let fileSize = U.userDefaults.value(forKey: C.key.settings.largeVideoLowerSize) as? Int64 {
				return fileSize
			} else {
				return LargeVideoSize.medium.rawValue
			}
		} set {
			U.userDefaults.setValue(newValue, forKey: C.key.settings.largeVideoLowerSize)
		}
	}
}

extension SettingsManager {
	
	struct promt {
		
		static public var promtRateDelay: Double? {
			get {
				return U.userDefaults.double(forKey: C.key.settings.promt.promtDelay)
			} set {
				U.userDefaults.set(newValue, forKey: C.key.settings.promt.promtDelay)
			}
		}
		
		static public var sixHoursDelay: Double? {
			get {
				return U.userDefaults.double(forKey: C.key.settings.promt.sixHoursDelay)
			} set {
				U.userDefaults.set(newValue, forKey: C.key.settings.promt.sixHoursDelay)
			}
		}
		
		static public var firstTimePromtShow: Bool {
			get {
				return U.userDefaults.bool(forKey: C.key.settings.promt.firstTimePromtShow)
			} set {
				U.userDefaults.set(newValue, forKey: C.key.settings.promt.firstTimePromtShow)
			}
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

extension SettingsManager {
	
	public var changePremiumBunner: String {
		get {
			if let value = U.userDefaults.string(forKey: "changePremiumBunner") {
				return value
			} else {
				self.changePremiumBunner = "premiumFeaturesSubcription"
				return self.changePremiumBunner
			}
		} set {
			U.userDefaults.set(newValue, forKey: "changePremiumBunner")
		}
	}
}

enum PremiumAdvBunnerType {
	case stack
	case horizontal
	case alreadyPremium
	
	var rowValue: String {
		switch self {
			case .stack:
				return "premiumFeaturesSubcription"
			case .horizontal:
				return "featuresSubscription"
			case .alreadyPremium:
				return "currentSubscription"
		}
	}
}
