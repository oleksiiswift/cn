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
		}
	}
	
	var viewControllerIdentifier: String {
		switch self {
			case .permission:
				return C.identifiers.viewControllers.permissions
			case .onboarding:
				return C.identifiers.viewControllers.onbording
			case .subscription:
				return C.identifiers.viewControllers.subscription
			case .settings:
				return C.identifiers.viewControllers.settings
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
				let viewController = OnbordingViewController.instantiate(type: type)
				viewController.coordinator = coordinator
				return viewController
			case .subscription:
				let viewController = SubscriptionViewController.instantiate(type: type)
				viewController.coordinator = coordinator
				return viewController
			case .settings:
				let viewController = SettingsViewController.instantiate(type: type)
				return viewController
		}
	}
}
