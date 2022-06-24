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
				<#code#>
			case .subscription:
				<#code#>
		}
	}
		
	var presentController: UIViewController {
		switch self {
			case .permission:
				return getPresentedViewController(type: .permission)
			case .onboarding:
				<#code#>
			case .subscription:
				<#code#>
		}
	}
	
	private func getPresentedViewController(type: PresentedControllerType) -> UIViewController {
		
		let storyboard = UIStoryboard(name: type.storyboardName, bundle: nil)
		switch self {
			case .permission:
				return storyboard.instantiateViewController(withIdentifier: type.viewControllerIdentifier) as! PermissionsViewController
			case .onboarding:
				<#code#>
			case .subscription:
				<#code#>
		}
	}
}
