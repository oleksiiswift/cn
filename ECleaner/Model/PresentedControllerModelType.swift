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
	
	var storyboardName: String {
		switch self {
			case .permission:
				return C.identifiers.storyboards.permissions
			case .onboarding:
				return C.identifiers.storyboards.onboarding
			case .subscription:
				return C.identifiers.storyboards.subscription
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
		}
	}
	
	var navigationController: UINavigationController {
		return UINavigationController.init(rootViewController: self.presentController)
	}
		
	var presentController: UIViewController {
		return getPresentedViewController(type: self)
	}
	
	private func getPresentedViewController(type: PresentedControllerType) -> UIViewController {
			
		switch self {
			case .permission:
				return PermissionsViewController.instantiate(type: type)
			case .onboarding:
				return OnbordingViewController.instantiate(type: type)
			case .subscription:
				return SubscriptionViewController.instantiate(type: type)
		}
	}
}



protocol Storyboarded {
//	static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
	
	static func instantiate(type: PresentedControllerType) -> Self {
		let storyboard = UIStoryboard(name: type.storyboardName, bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: type.viewControllerIdentifier) as! Self
	}
}



