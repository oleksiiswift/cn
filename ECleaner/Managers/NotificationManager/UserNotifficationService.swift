//
//  UserNotifficationService.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.05.2022.
//

import Foundation

class UserNotificationService: NSObject {
	
	class var sharedInstance: UserNotificationService {
		struct Static {
			static let sharedInstance: UserNotificationService = UserNotificationService()
		}
		return Static.sharedInstance
	}
	
	private let center = UNUserNotificationCenter.current()
	private var remoteLauncher = RemoteLaunchServiceMediator.sharedInstance
	
	private override init() {
		super.init()
		
		center.delegate = self
	}
}

extension UserNotificationService: UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
		let lastUsageDay = SettingsManager.application.lastApplicationUsage.getDay()
		let today = Date().getDay()
		
		if lastUsageDay != today {
			return UNNotificationPresentationOptions(arrayLiteral: [.alert, .sound, .badge])
		} else {
			return []
		}
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		DispatchQueue.main.async {
			guard let _ = response.notification.request.content.userInfo as [AnyHashable: Any]? else { return }
			self.remoteLauncher.startRemoteClean(of: response.localNotitficationAction)
		}
	}
}

extension UserNotificationService {
	
	private func cleanNotificationCategory(of type: UserNotificationType) -> Set<UNNotificationCategory> {
		
		guard #available(iOS 15.0, *) else { return [] }
		
		let similarPhotoActionType: NotificationAction = .similarPhotoClean
		let duplicatedPhotoActionType: NotificationAction = .duplicatedPhotoClean
		let similarVideActionType: NotificationAction = .similiarVideoClean
		let duplicatedVideoActionType: NotificationAction = .duplicatedVideoClean
		let deepCleanActionType: NotificationAction = .deepClean
		let contactsDuplicateType: NotificationAction = .duplicatedContactsClean
		
		let similarPhotoActionIcon: UNNotificationActionIcon = .init(systemImageName: similarPhotoActionType.actionIcon)
		let duplicatedPhotoActionIcon: UNNotificationActionIcon = .init(systemImageName: duplicatedPhotoActionType.actionIcon)
		let similarVideActionIcon: UNNotificationActionIcon = .init(systemImageName: similarVideActionType.actionIcon)
		let duplicatedVideoActionIcon: UNNotificationActionIcon = .init(systemImageName: duplicatedVideoActionType.actionIcon)
		let deepCleanActionIcon: UNNotificationActionIcon = .init(systemImageName: deepCleanActionType.actionIcon)
		let contactsDuplicateIcon: UNNotificationActionIcon = .init(systemImageName: contactsDuplicateType.actionIcon)
		
		let similarPhotoAction = UNNotificationAction(identifier: similarPhotoActionType.identifier,
													  title: similarPhotoActionType.titleName,
													  options: [.foreground],
													  icon: similarPhotoActionIcon)
		let duplicatePhotoAction = UNNotificationAction(identifier: duplicatedPhotoActionType.identifier,
													  title: duplicatedPhotoActionType.titleName,
													  options: [.foreground],
													  icon: duplicatedPhotoActionIcon)
		
		let similarVideoAction = UNNotificationAction(identifier: similarVideActionType.identifier,
													  title: similarVideActionType.titleName,
													  options: [.foreground],
													  icon: similarVideActionIcon)
		
		let duplicateVideoAction = UNNotificationAction(identifier: duplicatedVideoActionType.identifier,
													  title: duplicatedVideoActionType.titleName,
													  options: [.foreground],
													  icon: duplicatedVideoActionIcon)
		
		let deepCleanAction = UNNotificationAction(identifier: deepCleanActionType.identifier,
													  title: deepCleanActionType.titleName,
													  options: [.foreground],
													  icon: deepCleanActionIcon)
		
		let contactCleanAction = UNNotificationAction(identifier: contactsDuplicateType.identifier,
													  title: contactsDuplicateType.titleName,
													  options: [.foreground],
													  icon: contactsDuplicateIcon)
		let cleanContactsActions = [contactCleanAction, deepCleanAction]
		let photoClean = [similarPhotoAction, duplicatePhotoAction, deepCleanAction]
		let videoClean = [similarVideoAction, duplicateVideoAction, deepCleanAction]
		let deepClean = [deepCleanAction]
		
		var clean: [UNNotificationAction] = Array(Set([cleanContactsActions, photoClean, videoClean].joined()))
		if let firstindex = clean.firstIndex(of: deepCleanAction) {
			clean.remove(at: firstindex)
			clean.append(deepCleanAction)
		}
		
		switch type {
			case .cleanContacts:
				let identifiers = cleanContactsActions.map({$0.identifier})
				return [UNNotificationCategory(identifier: type.identifier,
											  actions: cleanContactsActions,
											  intentIdentifiers: identifiers,
											  options: .allowAnnouncement)]
			case .cleanPhotos:
				let identifiers = photoClean.map({$0.identifier})
				return [UNNotificationCategory(identifier: type.identifier,
											  actions: photoClean,
											  intentIdentifiers: identifiers,
											  options: .allowAnnouncement)]
			case .cleanVideo:
				let identifiers = videoClean.map({$0.identifier})
				return [UNNotificationCategory(identifier: type.identifier,
											  actions: videoClean,
											  intentIdentifiers: identifiers,
											  options: .allowAnnouncement)]
			case .deepClean:
				let identifiers = deepClean.map({$0.identifier})
				return [UNNotificationCategory(identifier: type.identifier,
											  actions: deepClean,
											  intentIdentifiers: identifiers,
											  options: .allowAnnouncement)]
			case .clean:
				let identifiers = clean.map({$0.identifier})
				return [UNNotificationCategory(identifier: type.identifier,
											  actions: clean,
											  intentIdentifiers: identifiers,
											  options: .allowAnnouncement)]
			case .none:
				return []
		}
	}
	
	private func sendCleanNotification(of type: UserNotificationType, with triger: UNCalendarNotificationTrigger) {
		
		self.center.removeAllPendingNotificationRequests()
		
		let userInfo: [AnyHashable: Any] = ["usernotifcationType": "hello"]
		let content = UNMutableNotificationContent()
		content.title = type.notificationBodyText.title
		content.subtitle = type.notificationBodyText.subtitle
		content.body = type.notificationBodyText.body
		content.categoryIdentifier = type.identifier
		content.userInfo = userInfo
		content.sound = .default
		
		let categories = self.cleanNotificationCategory(of: type)
		let notificationRequest = UNNotificationRequest(identifier: type.request,
														content: content,
														trigger: triger)
		self.center.setNotificationCategories(categories)
		self.center.add(notificationRequest)
	}

	public func registerNotificationTriger(with rawValue: Int) {
		
		var dateComponents = DateComponents()
		dateComponents.hour = Date().getHour()
		dateComponents.minute = Date().getMinute()
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
		
		guard let type = UserNotificationType.allCases.first(where: {$0.rawValue == rawValue}) else { return }
	
		SettingsManager.notification.setNewRemoteNotificationVaule(value: rawValue + 1)
		
		debugPrint("register new notification from \(dateComponents) of type \(type)")
		
		self.sendCleanNotification(of: type, with: trigger)
	}
	
	public func registerRemoteNotification() {
		
		guard NotificationsPermissions().authorized else { return }
		
		let lastRegisteredNotificationRawValue = SettingsManager.notification.localUserNotificationRawValue
		self.registerNotificationTriger(with: lastRegisteredNotificationRawValue)
	}
}
