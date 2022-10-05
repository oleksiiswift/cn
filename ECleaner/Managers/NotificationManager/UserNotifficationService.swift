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
	
	var interval: TimeInterval {
		switch self {
			case .seconds:
				return .random(in: 60...150)
			case .daily:
				return 86400
			case .weekly:
				return 604800
			case .monthly:
				return 2592000
			case .none:
				return 1
		}
	}
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
		self.registerRemoteNotification()
		return UNNotificationPresentationOptions(arrayLiteral: [.alert, .sound, .badge])
		
		if lastUsageDay != today {
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
	
	private func sendCleanNotification(of type: UserNotificationType, with triger: UNTimeIntervalNotificationTrigger) {
		
		self.center.removeAllPendingNotificationRequests()
		
		let userInfo: [AnyHashable: Any] = ["usernotifcationType": "hello"]
		let content = UNMutableNotificationContent()
		content.title = type.notificationBodyText.title
		content.subtitle = type.notificationBodyText.subtitle
		content.body = type.notificationBodyText.body
		content.categoryIdentifier = type.identifier
		content.userInfo = userInfo
		content.sound = UNNotificationSound(named: UNNotificationSoundName("fading-colourized-percussion_150bpm_B_major.wav"))
		
		let categories = self.cleanNotificationCategory(of: type)
		let notificationRequest = UNNotificationRequest(identifier: type.request,
														content: content,
														trigger: triger)
		self.center.setNotificationCategories(categories)
		self.center.add(notificationRequest)
		self.center.add(notificationRequest) { error in
			debugPrint(error ?? "error nil")
		}
	}

	public func registerNotificationTriger(with rawValue: Int) {
		/// `set notification period`
		let trigger = getRepeatedTrigger(of: .daily)
		
		guard let type = UserNotificationType.allCases.first(where: {$0.rawValue == rawValue}) else { return }
	
		SettingsManager.notification.setNewRemoteNotificationVaule(value: rawValue + 1)
		
		debugPrint("register new notification from \(trigger) of type \(type)")
		
		self.sendCleanNotification(of: type, with: trigger)
	}
	
	public func registerRemoteNotification() {
		
		guard NotificationsPermissions().authorized else { return }
		
		let lastRegisteredNotificationRawValue = SettingsManager.notification.localUserNotificationRawValue
		self.registerNotificationTriger(with: lastRegisteredNotificationRawValue)
	}
	
	public func getRepeatedTrigger(of type: NotificationRepeatPattern) -> UNTimeIntervalNotificationTrigger {
		
		switch type {
			case .seconds, .none:
				return UNTimeIntervalNotificationTrigger(timeInterval: type.interval, repeats:  false)
			case .daily, .weekly, .monthly:
				let date = Date().addingTimeInterval(type.interval).localTimeFromUTCConvert()
				let timeInterval = getNotificationTimeAdjustment(from: date)
				return UNTimeIntervalNotificationTrigger(timeInterval:  timeInterval, repeats: false)
		}
	}
	
	private func getNotificationTimeAdjustment(from date: Date) -> TimeInterval {
		let calendar = Calendar.current
		var components = calendar.dateComponents([.year,.month, .day, .hour, .minute, .second], from: date)
		components.hour = .random(in: 10...20)
		components.minute = .random(in: 1...50)
		let triggerDate = calendar.date(from: components)?.localTimeFromUTCConvert()
		let triggeredInterval = triggerDate!.timeIntervalSince1970 - Date().localTimeFromUTCConvert().timeIntervalSince1970
		debugPrint(triggerDate ?? "", triggeredInterval, triggeredInterval / 60)
		return triggeredInterval
	}
}
