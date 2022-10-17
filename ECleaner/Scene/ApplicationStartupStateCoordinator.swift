//
//  ApplicationStartupStateCoordinator.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.06.2022.
//

import Foundation

enum PresentedType {
	case push
	case present
	case window
}

protocol Coordinator {
	
	var navigationController: UINavigationController { get set }
	func start()
}

enum ApplicationStartupState: CaseIterable {
	
	case onboarding
	case permission
	case subscription
	case application
	
	var key: String {
		return stateRawValue()
	}
	
	private func stateRawValue() -> String {
		switch self {
			case .application:
				return Constants.key.application.aplicationValue
			case .onboarding:
				return Constants.key.application.onboardingValue
			case .permission:
				return Constants.key.application.permissionValue
			case .subscription:
				return Constants.key.application.subscriptionValue
		}
	}
}

class ApplicationCoordinator: Coordinator {

	var navigationController: UINavigationController

	private let routingStateKey = Constants.key.application.applicationRoutingKey
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	public var currentState: ApplicationStartupState {
		get {
			return self.getRoutingState()
		} set {
			self.setRouting(state: newValue)
		}
	}
	
	public var stages: [ApplicationStartupState] {
		return ApplicationStartupState.allCases
	}
	
	func start() {
		self.present(state: self.currentState)
	}
	
	private func setRouting(state: ApplicationStartupState) {
		U.userDefaults.set(state.key, forKey: self.routingStateKey)
	}
	
	private func getRoutingState() -> ApplicationStartupState {
		if let value = U.userDefaults.string(forKey: routingStateKey) {
			switch value {
				case ApplicationStartupState.application.key:
					return .application
				case ApplicationStartupState.permission.key:
					return .permission
				case ApplicationStartupState.subscription.key:
					return .subscription
				default:
					return .onboarding
			}
		}
		self.setRouting(state: .onboarding)
		return .onboarding
	}
	
	private func present(state: ApplicationStartupState) {
		switch state {
			case .onboarding:
				UIPresenter.showViewController(of: .onboarding) { navigationController in
					if let navigationController = navigationController {
						self.navigationController = navigationController
					}
				}
			case .permission:
				UIPresenter.showViewController(of: .permission) { navigationController in
					if let navigationController = navigationController {
						self.navigationController = navigationController
					}
				}
			case .subscription:
				UIPresenter.showViewController(of: .subscription)
			case .application:
				return
		}
	}
	
	public func showPermissionViewController() {
		let viewcontroller = PermissionsViewController.instantiate(type: .permission)
		viewcontroller.coordinator = self
		self.navigationController.pushViewController(viewcontroller, animated: true)
	}
	
	public func showPermissionViewController(from navigationController: UINavigationController?) {
		let viewController = PermissionsViewController.instantiate(type: .permission)
		viewController.fromRootViewController = false
		navigationController?.pushViewController(viewController, animated: true)
	}
	
	public func showSubscriptionViewController() {
		let viewController = SubscriptionViewController.instantiate(type: .subscription)
		viewController.coordinator = self
		self.navigationController.pushViewController(viewController, animated: true)
	}
	
	public func showSettingsViewController(from navigationController: UINavigationController?) {
		let viewController = SettingsViewController.instantiate(type: .settings)
		viewController.coordinator = self
		navigationController?.pushViewController(viewController, animated: true)
	}
	
	public func routingWillPass() {
		self.currentState = .application
		UIPresenter.closePresentedWindow()
	}
}
