//
//  RemoteLaunchService.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.05.2022.
//

import Foundation

protocol RemoteLaunchServiceListener {
	func remoteProcessingClean(by cleanType: RemoteCleanType)
}

class RemoteLaunchServiceMediator {
	
	class var sharedInstance: RemoteLaunchServiceMediator {
		struct Static {
			static let sharedInstance: RemoteLaunchServiceMediator = RemoteLaunchServiceMediator()
		}
		return Static.sharedInstance
	}
	
	private var listener: RemoteLaunchServiceListener?
	
	public func setListener(listener: RemoteLaunchServiceListener) {
		self.listener = listener
	}
	
	public func startRemoteClean(of cleanType: RemoteCleanType) {
		
		U.notificationCenter.post(name: .incomingRemoteActionRecived, object: nil, userInfo: nil)
		
		switch cleanType {
			case .none:
				return
			default:
				listener?.remoteProcessingClean(by: cleanType)
		}
	}
}

extension RemoteLaunchServiceMediator {
	
	public func handlerRemoteShortcuts() {
		
		let application = UIApplication.shared
	
		let items: [UIApplicationShortcutItem] = [self.getShortcutItem(of: .deepClean),
												  self.getShortcutItem(of: .photoScan),
												  self.getShortcutItem(of: .videoScan),
												  self.getShortcutItem(of: .contactsScan)]
		application.shortcutItems = items
	}
	
	private func getShortcutItem(of cleanType: RemoteCleanType) -> UIApplicationShortcutItem {
		let icon = UIApplicationShortcutIcon(systemImageName: cleanType.actionIcon)
		return UIApplicationShortcutItem(type: cleanType.identifier,
										 localizedTitle: cleanType.titleName,
										 localizedSubtitle: cleanType.subtitle,
										 icon: icon)
	}
	
	public func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
	
		if let actionTypeValue = RemoteCleanType.allCases.first(where: {$0.identifier == shortcutItem.type})  {
			listener?.remoteProcessingClean(by: actionTypeValue)
		}
		return true
	}
}
