//
//  PermissionManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 31.05.2022.
//

import Foundation

class PermissionManager {
	
	static let shared: PermissionManager = {
		let instance = PermissionManager()
		return instance
	}()
	
	
	public func checkForStartingPemissions() {
		#warning("TODO")
//		guard SettingsManager.permissions.permisssionDidShow else { return }
		
		PhotoLibraryPermissions().authorized ? PhotoManager.shared.getPhotoLibraryContentAndCalculateSpace() : ()
		ContactsPermissions().authorized ? ContactsManager.shared.contactsProcessingStore() : ()
	}
}

extension PermissionManager {
	
	public func photolibraryPermissionAccess(_ completionHandler: @escaping (_ status: Permission.Status) -> Void) {
		let status = PhotoLibraryPermissions().status
		switch status {
			case .authorized:
				completionHandler(status)
			case .denied:
				guard let topController = getTheMostTopController() else { return }
				ErrorHandler.shared.showRestrictedErrorAlert(.photoLibraryRestrictedError, at: topController) {
					completionHandler(status)
				}
			case .notDetermined:
				PhotoLibraryPermissions().requestForPermission { accessGranted, error in
					completionHandler(PhotoLibraryPermissions().status)
				}
			case .notSupported:
				return
		}
	}
	
	public func contactsPermissionAccess(_ completionHandler: @escaping (_ status: Permission.Status) -> Void) {
		let status = ContactsPermissions().status
		switch status {
			case .authorized:
				completionHandler(status)
			case .denied:
				guard let topController = getTheMostTopController() else { return }
				ErrorHandler.shared.showRestrictedErrorAlert(.contactsRestrictedError, at: topController) {
					completionHandler(status)
				}
			case .notDetermined:
				ContactsPermissions().requestForPermission { acessGranted, error in
					completionHandler(ContactsPermissions().status)
				}
			case .notSupported:
				return
		}
	}
}





