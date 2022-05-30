//
//  NotificationType.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.05.2022.
//

import Foundation

enum UserNotificationType: CaseIterable {
	case cleanContacts
	case cleanPhotos
	case cleanVideo
	case deepClean
	case clean
	case none
	
	var rawValue: Int {
		switch self {
			case .cleanContacts:
				return 2
			case .cleanPhotos:
				return 3
			case .cleanVideo:
				return 4
			case .deepClean:
				return 1
			case .clean:
				return 0
			case .none:
				return 5
		}
	}
	
	var identifier: String {
		switch self {
			case .cleanContacts:
				return C.key.notification.identifier.contactsClean
			case .cleanPhotos:
				return C.key.notification.identifier.photoClean
			case .cleanVideo:
				return C.key.notification.identifier.videoClean
			case .deepClean:
				return C.key.notification.identifier.deepClean
			case .clean:
				return C.key.notification.identifier.clean
			default:
				return ""
		}
	}
	
	var request: String {
		switch self {
			case .cleanContacts:
				return C.key.notification.request.contactsClean
			case .cleanPhotos:
				return C.key.notification.request.photoClean
			case .cleanVideo:
				return C.key.notification.request.videoClean
			case .deepClean:
				return C.key.notification.request.deepClean
			case .clean:
				return C.key.notification.request.clean
			default:
				return ""
		}
	}
	
	var notificationBodyText: notificationBodyStrings {
		return TempText.getNotificationBodyText(of: self)
	}
}

typealias RemoteCleanType = NotificationAction
enum NotificationAction: CaseIterable {
	case deepClean
	case similarPhotoClean
	case duplicatedPhotoClean
	case similiarVideoClean
	case duplicatedVideoClean
	case duplicatedContactsClean
	case none
	case photoScan
	case videoScan
	case contactsScan
	
	var identifier: String {
		switch self {
			case .deepClean:
				return C.key.notification.notificationAction.deepClean
			case .similarPhotoClean:
				return C.key.notification.notificationAction.similarPhotoCleanAction
			case .duplicatedPhotoClean:
				return C.key.notification.notificationAction.duplicatedPhotoCleanAction
			case .similiarVideoClean:
				return C.key.notification.notificationAction.similarVideCleanAction
			case .duplicatedVideoClean:
				return C.key.notification.notificationAction.duplicatedVideoCleanAction
			case .duplicatedContactsClean:
				return C.key.notification.notificationAction.duplicatedContectsCleanAction
			case .photoScan:
				return C.key.notification.shortCutAction.photoScan
			case .videoScan:
				return C.key.notification.shortCutAction.videoScan
			case .contactsScan:
				return C.key.notification.shortCutAction.contactsScan
			default:
				return ""
		}
	}
	
	var actionIcon: String {
		return Images.getNotificationActionSystemImages(by: self)
	}
	
	var titleName: String {
		switch self {
			case .deepClean:
				return "Deep Cleaning"
			case .similarPhotoClean:
				return "Similar Photo Scan"
			case .duplicatedPhotoClean:
				return "Duplicated Photo Scan"
			case .similiarVideoClean:
				return "Similiar Video Scan"
			case .duplicatedVideoClean:
				return "Duplicated Video Scan"
			case .duplicatedContactsClean:
				return "Duplicated Contacts Clean"
			case .photoScan:
				return "Photo Clean"
			case .videoScan:
				return "Video Clean"
			case .contactsScan:
				return "Clean Contacts"
			default:
				return ""
		}
	}
	
	var subtitle: String {
		switch self {
			case .deepClean:
				return "Anylize your data"
			case .photoScan:
				return "Find Similar and Duplicates"
			case .videoScan:
				return "Scan For Duplicated Video"
			case .contactsScan:
				return "Find Empty and Similar Contacts"
			default:
				return ""
		}
	}
	
	public func getRawValue(of type: String) -> RemoteCleanType? {
		let value = Self.allCases.first(where: {$0.identifier == type})
		return value
	}
}

extension UNNotificationResponse {
	
	var localNotificationType: UserNotificationType {
		
		switch notification.request.identifier {
			case UserNotificationType.cleanContacts.request:
				return .cleanContacts
			case UserNotificationType.cleanPhotos.request:
				return .cleanPhotos
			case UserNotificationType.cleanVideo.request:
				return .cleanVideo
			case UserNotificationType.deepClean.request:
				return .deepClean
			default:
				return .none
		}
	}
		
	var localNotitficationAction: NotificationAction {
		switch actionIdentifier {
			case NotificationAction.deepClean.identifier:
				return .deepClean
			case NotificationAction.similarPhotoClean.identifier:
				return .similarPhotoClean
			case NotificationAction.similiarVideoClean.identifier:
				return .similiarVideoClean
			case NotificationAction.duplicatedPhotoClean.identifier:
				return .duplicatedPhotoClean
			case NotificationAction.duplicatedVideoClean.identifier:
				return .duplicatedVideoClean
			case NotificationAction.duplicatedContactsClean.identifier:
				return .duplicatedContactsClean
			default:
				return .none
		}
	}
}
