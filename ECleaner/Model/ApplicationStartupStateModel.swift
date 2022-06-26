//
//  ApplicationStartupStateModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.06.2022.
//

import Foundation

protocol Coordinator {
	
	var navigationController: UINavigationController? { get set }
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

class ApplicationStartupStateCoordinator: Coordinator {

	var navigationController: UINavigationController?

	private let routingStateKey = Constants.key.application.applicationRoutingKey
	
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
					self.navigationController = navigationController
				}
			case .permission:
				UIPresenter.showViewController(of: .permission) { navigationController in
					self.navigationController = navigationController
				}
			case .subscription:
				UIPresenter.showViewController(of: .subscription)
			case .application:
				return
		}
	}
	
	public func showPermission() {
		let viewcontroller = PermissionsViewController.instantiate(type: .permission)
		viewcontroller.coordinator = self
		self.navigationController?.pushViewController(viewcontroller, animated: true)
	}
	
	public func showSubscription() {
		let viewController = SubscriptionViewController.instantiate(type: .subscription)
		viewController.coordinator = self
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}


