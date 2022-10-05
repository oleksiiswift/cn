//
//  AppTrackerPermissions.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation
import AppTrackingTransparency

@available(iOS 14.5, *)
class AppTrackerPermissions: Permission {
	
	override var permissionType: Permission.PermissionType {
		return .tracking
	}
	
	public override var status: Permission.Status {
		switch ATTrackingManager.trackingAuthorizationStatus {
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
		ATTrackingManager.requestTrackingAuthorization { status in
			DispatchQueue.main.async {
				completionHandler(status == .authorized, nil)
			}
		}
	}	
}
