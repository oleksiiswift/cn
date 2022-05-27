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
	
	public var notificationsPermissions: NotitificationsPermissions {
		return NotitificationsPermissions()
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
				return "allowed"
			case .notDetermined:
				return "continue"
			default:
				return "denied"
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
			return L.getTitle(for: self)
		}
		
		public var permissionDescription: String {
			return L.getDescription(for: self)
		}
		
		public var permissionImage: UIImage {
			return Images().getPermissionImage(for: self)
		}
		
		public var permissionAccentColors: [UIColor] {
			return ThemeManager().getPermissionAccentColor(from: self)
		}
	}
}

class PermissionManager {
	
	static let shared: PermissionManager = {
		let instance = PermissionManager()
		return instance
	}()
	
	
	public func checkForStartingPemissions() {
		
		guard SettingsManager.permissions.permisssionDidShow else { return }
		
//					PhotoManager.shared.checkPhotoLibraryAccess()
			//        ContactsManager.shared.checkStatus { _ in }
		
		PhotoLibraryPermissions().requestForPermission { status, error in
			debugPrint(status)
		}
		
		ContactsPermissions().requestForPermission { status, error in
			debugPrint(status)
		}
	}
}

extension PermissionManager {
	

}





