//
//  OnboardingDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2022.
//

import UIKit

class OnboardingDataSource: NSObject {
	
	public var onboardingViewModel: OnboardingViewModel
	
	public init(onboardingViewModel: OnboardingViewModel) {
		self.onboardingViewModel = onboardingViewModel
	}
}

extension OnboardingDataSource: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		return self.onboardingViewModel.getOnboarding(viewController: viewController, next: false)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		return self.onboardingViewModel.getOnboarding(viewController: viewController, next: true)
	}
}
