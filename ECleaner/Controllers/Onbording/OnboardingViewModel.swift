//
//  OnboardingViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2022.
//

import UIKit

public class OnboardingViewModel {
	
	let onboarding: [Onboarding]
	
	public var pageActionDidChange: ((_ index: Int) -> Void) = {_ in }
	public var pageIndicatorDidChange: ((_ index: Int) -> Void) = {_ in }
	public var didShowPermission: (() -> Void) = {}
	
	public var rawIndex: Int = 0
	
	init(onboarding: [Onboarding]) {
		self.onboarding = onboarding
	}
	
	public func getOnboarding(viewController: UIViewController, next: Bool) -> UIViewController? {
		
		guard let viewController = viewController as? OnbordingPageViewController else { return nil}
		
		for (index, value) in self.onboarding.enumerated() {
			if value.rawValue == viewController.sceneTitle {
				rawIndex = index
			}
		}
		next ? (rawIndex += 1) : (rawIndex -= 1)
		
		if next {
			if onboarding.count > rawIndex {
				return self.viewController(from: rawIndex)
			} else {
				return nil
			}
			
		} else {
			if rawIndex >= 0 {
				return self.viewController(from: rawIndex)
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
		viewController.delegate = self
		return viewController
	}
	
	public func getPresentationCount() -> Int {
		return self.onboarding.count
	}
}

extension OnboardingViewModel: OnboardingControllDelegate {
	
	func didUpdatePageIndicator(with index: Int) {
		self.pageIndicatorDidChange(index)
	}
	
	func didTapActionButton(for index: Int) {
		
		if onboarding.count == index {
			self.didShowPermission()
		} else if onboarding.count > index {
			self.pageActionDidChange(index)
		}
	}
}


