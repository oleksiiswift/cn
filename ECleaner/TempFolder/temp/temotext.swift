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
				return "Photo library & contacts"
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
				return "Allow access to contacts and photo library"
		}
	}
	
	static func getDeniedPermissionText() -> AlertTextStrings {
		
		return AlertTextStrings(title: "Permission denied",
								description: "Please, go to Settings and allow permission.",
								action: "Settings",
								cancel: "Cancel")
	}
	
	static func getDeniedDeepCleanPermission() -> AlertTextStrings {
		return AlertTextStrings(title: "Permission denied",
								description: "Allow access to contacts and photo library to get deep clean feature",
								action: "settings", cancel: "cancel")
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

extension TempText {
	
	static func getNotificationBodyText(of type: UserNotificationType) -> notificationBodyStrings {
		switch type {
			case .cleanContacts:
				return notificationBodyStrings(title: "Clean up your contacts 🤷🏻‍♂️",subtitle: "", body: "Anazlize and delete empty and duplicated contacts")
			case .cleanPhotos:
				return notificationBodyStrings(title: "Clean Up your Photos 📷", subtitle: "", body: "Analize photo data for similar and duplicateds")
			case .cleanVideo:
				return notificationBodyStrings(title: "Clean Up Your Videos 🎥", subtitle: "", body: "Analize video data for similar and duplicateds")
			case .deepClean:
				return notificationBodyStrings(title: "Free Up Storage With Deep Clean 🧹", subtitle: "", body: "Analize your photo and video, contacts")
			case .clean:
				return notificationBodyStrings(title: "Clean Up Storage ☁️", subtitle: "", body: "Delete Your duplicated and similar photos and videos. Clean contacts")
			default:
				return notificationBodyStrings(title: "", subtitle: "", body: "")
		}
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

class notificationBodyStrings {
	var title: String
	var subtitle: String
	var body: String
	
	init(title: String, subtitle: String, body: String) {
		self.title = title
		self.subtitle = subtitle
		self.body = body
	}
}
