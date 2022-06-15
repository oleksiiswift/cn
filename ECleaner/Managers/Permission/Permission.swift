//
//  Permission.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation

class Permission {
	
	public var contactsPermissions: ContactsPermissions {
		return ContactsPermissions()
	}
	
	public var notificationsPermissions: NotificationsPermissions {
		return NotificationsPermissions()
	}
	
	public var photoLibraryPermissions: PhotoLibraryPermissions {
		return PhotoLibraryPermissions()
	}
	
	@available(iOS 14.5, *)
	public var appTrackerPermissions: AppTrackerPermissions {
		return AppTrackerPermissions()
	}
	
	public var permissionType: PermissionType {
		preconditionFailure()
	}
	
	public var status: Status {
		preconditionFailure()
	}
	
	public var permissionRawValue: String {
		return self.permissionType.permissionRawValue
	}
	
	public func requestForPermission(completionHandler: @escaping (_ granted: Bool,_ error: Error?) -> Void) {
		preconditionFailure()
	}
	
	public var permissionAccentColors: [UIColor] {
		return self.permissionType.permissionAccentColors
	}
	
	public var permissionImage: UIImage {
		return self.permissionType.permissionImage
	}
	
	public var permissionName: String {
		return self.permissionType.permissionName
	}
	
	public var permissionDescription: String {
		return self.permissionType.permissionDescription
	}
	
	public var authorized: Bool {
		return self.status == .authorized
	}
	
	public var denied: Bool {
		return self.status == .denied
	}
	
	public var notDetermined: Bool {
		return self.status == .notDetermined
	}
	
	public var notSupported: Bool {
		return self.status == .notSupported
	}
	
	public var buttonTitle: String {
		switch self.status {
			case .authorized:
				return LocalizationService.Buttons.getButtonTitle(of: .allowed)
			case .notDetermined:
				return LocalizationService.Buttons.getButtonTitle(of: .continue)
			default:
				return LocalizationService.Buttons.getButtonTitle(of: .denied)
		}
	}
	
	public var buttonTitleColor: UIColor {
		switch self.status {
			case .authorized:
				return ThemeManager.theme.subTitleTextColor
			case .notDetermined:
				return ThemeManager.theme.titleTextColor
			default:
				return .red
		}
	}

	enum Status {
		case authorized
		case denied
		case notDetermined
		case notSupported
	}
	
	enum PermissionType {
		case notification
		case photolibrary
		case contacts
		case tracking
		case appUsage
		case blank
		
		public var permissionName: String {
			return LocalizationService.PermissionStings.getTitle(for: self)
		}
		
		public var permissionDescription: String {
			return LocalizationService.PermissionStings.getDescription(for: self)
		}
		
		public var permissionImage: UIImage {
			return Images.getPermissionImage(for: self)
		}
		
		public var permissionAccentColors: [UIColor] {
			return ThemeManager().getPermissionAccentColor(from: self)
		}
		
		public var permissionRawValue: String {
			switch self {
				case .notification:
					return C.key.permissions.rawValue.notification
				case .photolibrary:
					return C.key.permissions.rawValue.photolibrary
				case .contacts:
					return C.key.permissions.rawValue.contacts
				case .tracking:
					return C.key.permissions.rawValue.tracking
				case .appUsage:
					return C.key.permissions.rawValue.appUsage
				case .blank:
					return C.key.permissions.rawValue.blank
			}
		}
	}
}

