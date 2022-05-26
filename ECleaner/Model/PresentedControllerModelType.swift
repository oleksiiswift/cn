//
//  PresentedControllerModelType.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation

enum PresentedControllerType {
	
	case permission

	var storyboardName: String {
		switch self {
			case .permission:
				return C.identifiers.storyboards.permissions
		}
	}
	
	var viewControllerIdentifier: String {
		switch self {
			case .permission:
				return C.identifiers.viewControllers.permissions
		}
	}
		
	var presentController: UIViewController {
		switch self {
			case .permission:
				return getPresentedViewController(type: .permission)
		}
	}
	
	private func getPresentedViewController(type: PresentedControllerType) -> UIViewController {
		
		let storyboard = UIStoryboard(name: type.storyboardName, bundle: nil)
		switch self {
			case .permission:
				return storyboard.instantiateViewController(withIdentifier: type.viewControllerIdentifier) as! PermissionsViewController
		}
	}
}
