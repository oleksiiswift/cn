//
//  ProgressSearchNotificationManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 04.12.2021.
//

import Foundation

class ProgressSearchNotificationManager {
	
	class var instance: ProgressSearchNotificationManager {
		struct Static {
			static let instance: ProgressSearchNotificationManager = ProgressSearchNotificationManager()
		}
		return Static.instance
	}
	
		/// handle notification update according to progress calculate total percentage count in single browse clean controller
	public func sendSingleSearchProgressNotification(notificationtype: SingleContentSearchNotificationType, totalProgressItems: Int, currentProgressItem: Int) {
		
		let userInfo = [notificationtype.dictioanartyIndexName: currentProgressItem,
						notificationtype.dictionaryCountName: totalProgressItems]
		
		sleep(UInt32(0.1))
		NotificationCenter.default.post(name: notificationtype.notificationName, object: nil, userInfo: userInfo)
	}
	
		/// handle notification update according to progress calculate total percentage count in deep clean controller
	public func sendDeepProgressNotificatin(notificationType: DeepCleanNotificationType, totalProgressItems: Int, currentProgressItem: Int) {
		
		let infoDictionary = [notificationType.dictionaryIndexName: currentProgressItem,
							  notificationType.dictionaryCountName: totalProgressItems]
		sleep(UInt32(0.1))
		NotificationCenter.default.post(name: notificationType.notificationName, object: nil, userInfo: infoDictionary)
	}
}
