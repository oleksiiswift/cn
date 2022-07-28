//
//  UserNotifficationService.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.05.2022.
//

import Foundation
import UserNotifications

enum NotificationRepeatPattern {
	case seconds
	case daily
	case weekly
	case monthly
	case none
}

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
		
		if lastUsageDay == today {
			return UNNotificationPresentationOptions(arrayLiteral: [.alert, .sound, .badge])
		} else {
			return []
		}
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		DispatchQueue.main.async {
			guard let _ = response.notification.request.content.userInfo as [AnyHashable: Any]? else { return }
			
			let responceAction = response.localNotitficationAction
			
			switch responceAction {
				case .none:
					switch response.localNotificationType {
						case .deepClean:
							self.remoteLauncher.startRemoteClean(of: .deepClean)
						case .cleanPhotos:
							self.remoteLauncher.startRemoteClean(of: .photoScan)
						case .cleanVideo:
							self.remoteLauncher.startRemoteClean(of: .videoScan)
						case .cleanContacts:
							self.remoteLauncher.startRemoteClean(of: .contactsScan)
						default:
							return
					}
				default:
					self.remoteLauncher.startRemoteClean(of: responceAction)
			}
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
//		UNNotificationSound(named: UNNotificationSoundName("mixkit-flock-of-wild-geese-20.wav"))
		
		let categories = self.cleanNotificationCategory(of: type)
		let notificationRequest = UNNotificationRequest(identifier: type.request,
														content: content,
														trigger: triger)
		self.center.setNotificationCategories(categories)
		self.center.add(notificationRequest)
	}

	public func registerNotificationTriger(with rawValue: Int) {
				
		let trigger = getRepeatedTrigger(of: .daily)
		
		guard let type = UserNotificationType.allCases.first(where: {$0.rawValue == rawValue}) else { return }
	
		SettingsManager.notification.setNewRemoteNotificationVaule(value: rawValue + 1)
		
		debugPrint("register new notification from \(trigger.dateComponents) of type \(type)")
		
		self.sendCleanNotification(of: type, with: trigger)
	}
	
	public func registerRemoteNotification() {
		
		guard NotificationsPermissions().authorized else { return }
		
		let lastRegisteredNotificationRawValue = SettingsManager.notification.localUserNotificationRawValue
		self.registerNotificationTriger(with: lastRegisteredNotificationRawValue)
	}
	
	public func getRepeatedTrigger(of type: NotificationRepeatPattern) -> UNCalendarNotificationTrigger {
		
		let triggerDate = Date() - 5 * 60
		
		switch type {
			case .seconds:
				let date = Date().addingTimeInterval(10)
				return UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.second], from: date), repeats: true)
			case .daily:
				return UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.second], from: triggerDate), repeats: true)
			case .weekly:
				return UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.timeZone, .weekday, .hour, .minute, .second], from: triggerDate), repeats: true)
			case .monthly:
				return UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.timeZone, .weekOfMonth, .weekday, .hour, .minute, .second], from: triggerDate), repeats: true)
			case .none:
				return UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.timeZone, .year, .month, .day, .hour, .minute], from: triggerDate), repeats: true)
		}
	}
}





