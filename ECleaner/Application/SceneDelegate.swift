//
//  SceneDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.06.2021.
//

import UIKit

var currentScene: UIScene?

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
	var presentedWindow: UIWindow?
	
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

    func sceneDidDisconnect(_ scene: UIScene) {
  
    }

    func sceneDidBecomeActive(_ scene: UIScene) {

	}

    func sceneWillResignActive(_ scene: UIScene) {
		RemoteLaunchServiceMediator.sharedInstance.handlerRemoteShortcuts()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}

extension SceneDelegate {
	
	private func handleConnectedScens(with connectedOptions:  UIScene.ConnectionOptions) {
				
		if let shortcutItem = connectedOptions.shortcutItem {
			self.shortCutItem = shortcutItem
		} 
	}
	
	private func handleStartupRouting() {
		
		switch AplicationStartupState.state {
			case .tryPassApplication:
				return
			case .tryPassOnboarding:
				UIPresenter.showViewController(of: .onboarding)
			case .tryPassPermission:
				UIPresenter.showViewController(of: .permission)
			case .tryPassSubscription:
				UIPresenter.showViewController(of: .subscription)
		}
	}
}

struct AplicationStartupState {
	
	private static var routingKey = Constants.key.application.aplicationRoutingKey
	
	public static var state: [State : StateValue] {
		get {
			
		} set {
			
		}
	}
	
//	public static var state: State {
//		get {
//			return self.currentState()
//		} set {
//			self.set(state: newValue)
//		}
//	}
	
	enum StateValue {
		case willPass
		case didPass
		case unknown
	}
		
	enum State {
		
		case aplication
		case onbording
		case permission
		case subbscription

		var key: String {
			switch self {
				case .onbording:
					return Constants.key.application.onboardingValue
				case .permission:
					return Constants.key.application.permissionValue
				case .subbscription:
					return Constants.key.application.subscriptionValue
				case .aplication:
					return Constants.key.application.aplicationValue
			}
		}
		
		var progress: StateValue {
			
			if !Utils.contains() {
				return .unknown
			}
			
			
			switch self {
				case .aplication:
					<#code#>
				case .onbording:
					<#code#>
				case .permission:
					<#code#>
				case .subbscription:
					<#code#>
			}
		}
	}
	
	
	private static func current() -> StateValue {
		
	
		
		var storedDictionary: [String: StateValue] = [:]
		
		if let dictionary = Utils.userDefaults.object(forKey: self.routingKey) as? [String : StateValue] {
			storedDictionary = dictionary
		}
		
		
		if let currentState = storedDictionary[self.k]
		
		
		
		
		
	}
	
	
	
	private static func currentState() -> [State : StateValue] {
		
		let storedState = Utils.userDefaults.object(forKey: <#T##String#>)
		
		if Utils.contains(self.routingKey) {
		
		
		} else {
			
			
			
		}
		
//		let stateValue = Utils.userDefaults.string(forKey: self.routingKey)
//
//		switch stateValue {
//			case State.aplication.key:
//				return .aplication
//			case State.onbording.key:
//				return .onbording
//			case State.permission.key:
//				return .permission
//			case State.subbscription.key:
//				return .subbscription
//			default:
//				return .onbording
//		}
	}
	
	private static func set(value: StateValue, for state: State) {
		
		var storedDictionary: [State: StateValue] = [:]
				
		if let dictionary = Utils.userDefaults.object(forKey: self.routingKey) as? [State: StateValue] {
			storedDictionary = dictionary
		}
		
		storedDictionary[state] = value
	}
	
	private static func saveState(state: [State: StateValue]) {
		Utils.userDefaults.set(state, forKey: self.routingKey)
	}
}



