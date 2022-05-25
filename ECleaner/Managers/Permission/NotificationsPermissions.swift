//
//  NotificationsPermissions.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation

class NotitificationsPermissions: Permission {
		
	override var permissionType: Permission.PermissionType {
		return .notification
	}
	
	public override var status: Permission.Status {
		
		guard let status = fetchAuthorizationStatus() else { return .notDetermined}
		switch status {
			case .notDetermined:
				return .notDetermined
			case .denied:
				return .denied
			case .authorized:
				return .authorized
			case .provisional:
				return .authorized
			case .ephemeral:
				return .authorized
			default:
				return .denied
		}
	}
	
	public override func requestForPermission(completionHandler: @escaping (Bool, Error?) -> Void) {
		let notiticationCenter = UNUserNotificationCenter.current()
		notiticationCenter.requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
			DispatchQueue.main.async {
				completionHandler(granted, error)
			}
		}
	}
}

extension NotitificationsPermissions {
	
	private func fetchAuthorizationStatus() -> UNAuthorizationStatus? {
		var notificationSettings: UNNotificationSettings?
		let semaphore = DispatchSemaphore(value: 0)
		DispatchQueue.global().async {
			UNUserNotificationCenter.current().getNotificationSettings { setttings in
				notificationSettings = setttings
				semaphore.signal()
			}
		}
		semaphore.wait()
		return notificationSettings?.authorizationStatus
	}
}
