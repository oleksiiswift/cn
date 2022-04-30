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
	public func sendSingleSearchProgressNotification(notificationtype: SingleContentSearchNotificationType, status: ProcessingProgressOperationState, totalProgressItems: Int, currentProgressItem: Int) {
		
		let userInfo = [notificationtype.dictionaryProcessingState: status,
						notificationtype.dictioanartyIndexName: currentProgressItem,
						notificationtype.dictionaryCountName: totalProgressItems] as [String: Any]
		
//		sleep(UInt32(0.1))
		NotificationCenter.default.post(name: notificationtype.notificationName, object: nil, userInfo: userInfo)
	}
	
		/// handle notification update according to progress calculate total percentage count in deep clean controller
	public func sendDeepProgressNotification(notificationType: DeepCleanNotificationType, status: ProcessingProgressOperationState, totalProgressItems: Int, currentProgressItem: Int) {
		
		let infoDictionary = [notificationType.dictionaryProcessingState: status,
							  notificationType.dictionaryIndexName: currentProgressItem,
							  notificationType.dictionaryCountName: totalProgressItems] as [String : Any]
		
//		sleep(UInt32(0.1))
		NotificationCenter.default.post(name: notificationType.notificationName, object: nil, userInfo: infoDictionary)
	}
	
	public func sentSizeFilesCheckerNotification(notificationtype: DeepCleanNotificationType, value: Int64, currentIndex: Int, totlelFiles: Int) {
		let infoDictionary = [notificationtype.dictionaryProcessingSizeValue: value,
							  notificationtype.dictionaryIndexName: currentIndex,
							  notificationtype.dictionaryCountName: totlelFiles] as [String : Any]
		NotificationCenter.default.post(name: notificationtype.notificationName, object: nil, userInfo: infoDictionary)
	}
}
