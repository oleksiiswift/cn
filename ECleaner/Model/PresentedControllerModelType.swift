//
//  PresentedControllerModelType.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation

enum PresentedControllerType {
	
	case permission
	case onboarding
	case subscription
	case settings
	case web
	
	var storyboardName: String {
		switch self {
			case .permission:
				return C.identifiers.storyboards.permissions
			case .onboarding:
				return C.identifiers.storyboards.onboarding
			case .subscription:
				return C.identifiers.storyboards.subscription
			case .settings:
				return C.identifiers.storyboards.settings
			case .web:
				return C.identifiers.storyboards.web
		}
	}
	
	var viewControllerIdentifier: String {
		switch self {
			case .permission:
				return C.identifiers.viewControllers.permissions
			case .onboarding:
				return C.identifiers.viewControllers.onboarding
			case .subscription:
				return C.identifiers.viewControllers.subscription
			case .settings:
				return C.identifiers.viewControllers.settings
			case .web:
				return C.identifiers.viewControllers.web
		}
	}
	
	var navigationController: UINavigationController {
		return UINavigationController.init(rootViewController: self.presentController)
	}
		
	var presentController: UIViewController {
		return self.getPresentedViewController(type: self, coordinator: Utils.sceneDelegate.coordinator)
	}
	
	private func getPresentedViewController(type: PresentedControllerType, coordinator: ApplicationCoordinator?) -> UIViewController {
			
		switch self {
			case .permission:
				let viewController = PermissionsViewController.instantiate(type: type)
				viewController.coordinator = coordinator
				return viewController
			case .onboarding:
				let viewController = OnboardingViewController.instantiate(type: type)
				viewController.coordinator = coordinator
				return viewController
			case .subscription:
				let viewController = SubscriptionViewController.instantiate(type: type)
				viewController.coordinator = coordinator
				return viewController
			case .settings:
				let viewController = SettingsViewController.instantiate(type: type)
				return viewController
			case .web:
				let viewController = WebViewController.instantiate(type: type)
				viewController.coordinator = coordinator
				return viewController
		}
	}
}
