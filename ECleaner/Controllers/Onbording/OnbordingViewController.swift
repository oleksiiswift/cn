//
//  OnbordingViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.06.2022.
//

import UIKit

protocol OnboardingControllDelegate {
	
}

class OnbordingViewController: UIPageViewController, Storyboarded {
	
	private var onboardingViewModel: OnboardingViewModel!
	private var onboardingDataSource: OnboardingDataSource?!
	
	weak var coordinator: ApplicationCoordinator?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupViewModel()
		setupDelegate()
		setupPageControl()
		setupControllers()
		updateColors()
		setupUI()
	}
}
	
extension OnbordingViewController {
	
	private func setupViewModel() {
		
		self.onboardingViewModel = OnboardingViewModel(onboarding: Onboarding.allCases)
		self.onboardingDataSource = OnboardingDataSource(onboardingViewModel: self.onboardingViewModel)
	}
	
	private func setupDelegate() {
		
		self.dataSource = self.onboardingDataSource
		self.delegate = self.onboardingDataSource
	}
	
	private func setupControllers() {
		setViewControllers([self.onboardingViewModel.viewController(from: 0)], direction: .forward, animated: true, completion: nil)
	}
	
	func setupPageControl() {
		
		UIPageControl.appearance(whenContainedInInstancesOf: [OnbordingViewController.self]).currentPageIndicatorTintColor = UIColor().colorFromHexString("9DA6B7")
		UIPageControl.appearance(whenContainedInInstancesOf: [OnbordingViewController.self]).pageIndicatorTintColor =  UIColor().colorFromHexString("CBD1DC")

	}
}

extension OnbordingViewController: Themeble {

	private func setupUI() {
		
	}
	
	func updateColors() {
	
		self.view.backgroundColor = theme.cellBackGroundColor
	}
}


