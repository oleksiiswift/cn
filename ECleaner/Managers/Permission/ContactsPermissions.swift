//
//  ContactsPermissions.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation
import Contacts

class ContactsPermissions: Permission {
	
	public override var permissionType: Permission.PermissionType {
		return .contacts
	}
	
	public override var status: Permission.Status {
		switch CNContactStore.authorizationStatus(for: .contacts) {
			case .authorized:
				return .authorized
			case .denied:
				return .denied
			case .notDetermined:
				return .notDetermined
			case .restricted:
				return .denied
			default:
				return .denied
		}
	}
	
	public override func requestForPermission(completionHandler: @escaping (Bool, Error?) -> Void) {
		let store = CNContactStore()
		
		store.requestAccess(for: .contacts) { granted, error in
			DispatchQueue.main.async {
				completionHandler(granted, error)
			}
		}
	}	
}

