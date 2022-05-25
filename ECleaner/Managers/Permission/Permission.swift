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
	
	public var permissionImage: UIImage {
		return self.permissionType.permissionImage
	}
	
	public var permissionName: String {
		return self.permissionType.permissionName
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
		case helperUsage
		
		public var permissionName: String {
			return L.getTitle(for: self)
		}
		
		public var permissionDescription: String {
			return L.getDescription(for: self)
		}
		
		public var permissionImage: UIImage {
			return Images().getPermissionImage(for: self)
		}
	}
}
