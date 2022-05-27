//
//  temotext.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation
typealias L = TempText
struct  TempText {
//	Localisation
	
	static func getTitle(for permission: Permission.PermissionType) -> String {
		switch permission {
			case .notification:
				return "Notification"
			case .photolibrary:
				return "Photo Library"
			case .contacts:
				return "Contacts"
			case .tracking:
				return "Tracking"
			default:
				return ""
		}
	}
	
	
	static func getDescription(for permission: Permission.PermissionType) -> String {
		switch permission {
				
			case .notification:
				return "Allow application recieve notification."
			case .photolibrary:
				return "Access for search duplicated, simmilar photos and video in your gallery."
			case .contacts:
				return "Access for your contacts and phones, delete, merge and clean contacts."
			case .tracking:
				return "Allow to access app related data"
			default:
				return ""
		}
	}
	
	static func getDeniedPermissionText() -> AlertTextStrings {
		
		return AlertTextStrings(title: "Permission denied",
								description: "Please, go to Settings and allow permission.",
								action: "Settings",
								cancel: "Cancel")
	}
	
	static func getApptrackerPermissionText() -> AlertTextStrings {
		
		return AlertTextStrings(title: "text for title",
								description: "description for use app tracker use or not",
								action: "ok",
								cancel: "")
	}
	
	static func getAtLeastOnePermissionText() -> AlertTextStrings {
		return AlertTextStrings(title: "at least one permission",
								description: "need text for description",
								action: "ok",
								cancel: "")
	}
}

class AlertTextStrings {
	
	var title: String
	var description: String
	var action: String
	var cancel: String
	
	init(title: String, description: String, action: String, cancel: String) {
		self.title = title
		self.description = description
		self.action = action
		self.cancel = cancel
	}
}



