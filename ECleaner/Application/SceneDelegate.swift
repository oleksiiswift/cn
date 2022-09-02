//
//  SceneDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.06.2021.
//

import UIKit
import SwiftUI

var currentScene: UIScene?

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
	var presentedWindow: UIWindow?
	var coordinator: ApplicationCoordinator?
	
	public var shortCutItem: UIApplicationShortcutItem?
	
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		
		guard let scene = (scene as? UIWindowScene) else { return }
		currentScene = scene
		handleStartupRouting()
		handleConnectedScens(with: connectionOptions)
    }
	
	func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		U.notificationCenter.post(name: .incomingRemoteActionRecived, object: nil, userInfo: nil)
		let handled = RemoteLaunchServiceMediator.sharedInstance.handleShortCutItem(shortcutItem: shortcutItem)
		completionHandler(handled)
	}

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
		SubscriptionManager.instance.checkForCurrentSubscription { isSubscribe in
			debugPrint("is subscribe -> \(isSubscribe)")
			if !isSubscribe {
				SubscriptionManager.instance.saveSubscription(nil)
			}
		}
	}

    func sceneWillResignActive(_ scene: UIScene) {
		RemoteLaunchServiceMediator.sharedInstance.handlerRemoteShortcuts()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}

extension SceneDelegate {
	
	private func handleConnectedScens(with connectedOptions:  UIScene.ConnectionOptions) {
				
		if let shortcutItem = connectedOptions.shortcutItem {
			self.shortCutItem = shortcutItem
		} 
	}
	
	private func handleStartupRouting() {
	
		let navController = UINavigationController()
		coordinator = ApplicationCoordinator(navigationController: navController)
		devopmentEnviroment()
		coordinator?.start()
	}
}

extension SceneDelegate {
	
	private func devopmentEnviroment() {
		
		/// `handle staring from onboarding`
//		coordinator?.currentState = .onboarding
		
		/// `handle print all notification`
//		printAllNotifications()
		
//		Utils.delay(5) {
//			debugPrint("****")
//			debugPrint("is purchase premium -> \(SubscriptionManager.instance.purchasePremiumStatus())")
//			debugPrint("****")
//		}
		
		///  `remove all contacts from store`
//		ContactsManager.shared.deleteAllContatsFromStore()
	}
}

extension SceneDelegate {
	
	private func printAllNotifications() {
		
		NotificationCenter.default.addObserver(forName: nil, object: nil, queue: nil) { notification in
			debugPrint(notification)
		}
	}
}

