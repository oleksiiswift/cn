//
//  UINavigationController+Completion.swift
//  ECleaner
//
//  Created by alexey sorochan on 13.03.2022.
//

import Foundation

extension UINavigationController {
	
	func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
		pushViewController(viewController, animated: animated)

		if animated, let coordinator = transitionCoordinator {
			coordinator.animate(alongsideTransition: nil) { _ in
				completion()
			}
		} else {
			completion()
		}
	}

	func popViewController(animated: Bool, completion: @escaping () -> Void) {
		popViewController(animated: animated)

		if animated, let coordinator = transitionCoordinator {
			coordinator.animate(alongsideTransition: nil) { _ in
				completion()
			}
		} else {
			completion()
		}
	}
}
