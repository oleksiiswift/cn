//
//  OnboardingViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2022.
//

import UIKit

public class OnboardingViewModel {
	
	let onboarding: [Onboarding]
	
	init(onboarding: [Onboarding]) {
		self.onboarding = onboarding
	}
	
	public func getOnboarding(viewController: UIViewController, next: Bool) -> UIViewController? {
		
		guard let viewController = viewController as? OnbordingPageViewController else { return nil}
		
		var rowIndex: Int = 0
		
		for (index, value) in self.onboarding.enumerated() {
			if value.rawValue == viewController.sceneTitle {
				rowIndex = index
			}
		}
		next ? (rowIndex += 1) : (rowIndex -= 1)
		
		if next {
			if onboarding.count > rowIndex {
				return self.viewController(from: rowIndex)
			} else {
				return nil
			}
			
		} else {
			if rowIndex >= 0 {
				return self.viewController(from: rowIndex)
			} else {
				return nil
			}
		}
	}

	public func viewController(from index: Int) -> UIViewController {
		let onboarding = onboarding[index]
		let stroryboard = UIStoryboard(name: Constants.identifiers.storyboards.onboarding, bundle: nil)
		let viewController = stroryboard.instantiateViewController(withIdentifier: Constants.identifiers.viewControllers.onbordingPage) as! OnbordingPageViewController
		viewController.onboarding = onboarding
		return viewController
	}
	
	public func getPresentationCount() -> Int {
		return self.onboarding.count
	}
}
