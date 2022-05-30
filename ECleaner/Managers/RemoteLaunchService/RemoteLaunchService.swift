//
//  RemoteLaunchService.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.05.2022.
//

import Foundation

@objc protocol RemoteLaunchServiceListener {
	func deepScan()
	@objc optional func similarPhotoScan()
	@objc optional func similarVideoScan()
	@objc optional func duplicatePhotoScan()
	@objc optional func duplicateVideoScan()
	@objc optional func duplicateContactsClean()
	func photoScan()
	func videoScan()
	func contactsScan()
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
			case .deepClean:
				listener?.deepScan()
			case .similarPhotoClean:
				listener?.similarPhotoScan?()
			case .duplicatedPhotoClean:
				listener?.duplicateVideoScan?()
			case .similiarVideoClean:
				listener?.similarVideoScan?()
			case .duplicatedVideoClean:
				listener?.duplicateVideoScan?()
			case .duplicatedContactsClean:
				listener?.duplicateContactsClean?()
			case .photoScan:
				listener?.photoScan()
			case .videoScan:
				listener?.videoScan()
			case .contactsScan:
				listener?.contactsScan()
			case .none:
				return
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
			switch actionTypeValue {
				case .deepClean:
					self.listener?.deepScan()
				case .contactsScan:
					self.listener?.contactsScan()
				case .photoScan:
					self.listener?.photoScan()
				case .videoScan:
					self.listener?.videoScan()
				default:
					debugPrint("")
			}
		}
		return true
	}
}
