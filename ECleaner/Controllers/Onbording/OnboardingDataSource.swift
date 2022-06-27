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
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return self.onboardingViewModel.getPresentationCount()
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		var rowIndex: Int = 0
		
		for (index, value) in self.onboardingViewModel.onboarding.enumerated() {
			if let viewController = pageViewController.children.first as? OnbordingPageViewController, viewController.sceneTitle == value.rawValue {
				rowIndex = index
			}
		}
		return rowIndex
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		self.onboardingViewModel.getOnboarding(viewController: viewController, next: false)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		self.onboardingViewModel.getOnboarding(viewController: viewController, next: true)
	}
}
