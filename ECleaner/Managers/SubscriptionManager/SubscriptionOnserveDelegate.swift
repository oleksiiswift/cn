//
//  SubscriptionOnserveDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.07.2022.
//

import Foundation

typealias SubscriptionObserver = SubscriptionUpdateDelegate & SubscriptionObserveDelegate

protocol SubscriptionUpdateDelegate {
	
	func subscriptionDidChange()
}

protocol SubscriptionObserveDelegate: AnyObject {}

extension SubscriptionObserveDelegate {
	
	func addSubscriptionChangeObserver(notificationCenter: NotificationCenter = NotificationCenter.default) {
		
		notificationCenter.addObserver(forName: .premiumDidChange, object: nil, queue: nil) { [weak self] _ in
			if let subscriptionUpdateObject = self as? SubscriptionUpdateDelegate {
				subscriptionUpdateObject.subscriptionDidChange()
			}
		}
	}
}
