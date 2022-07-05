//
//  OnboardingViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.06.2022.
//

import UIKit

protocol OnboardingControllDelegate {
	func didUpdatePageIndicator(with index: Int)
}

class OnboardingViewController: UIPageViewController, Storyboarded {

	private var scrollView: UIScrollView?
	private var pageControl = UIPageControl()
	private var skipButton = UIButton()
	private var bottomButtonView = BottomButtonBarView()
	
	private var onboardingViewModel: OnboardingViewModel!
	private var onboardingDataSource: OnboardingDataSource!
	
	private var thisIsTheEnd: Bool = false
	
	weak var coordinator: ApplicationCoordinator?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		setupViewModel()
		setupDelegate()
		setupPageControl()
		setupBottomButtonView()
		setupControllers()
		setupSkipButton()
		updateColors()
		setupUI()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}
}

extension OnboardingViewController {
	
	private func onboardingWillPass() {
		self.coordinator?.currentState = .permission
		self.coordinator?.showPermissionViewController()
	}
	
	private func showNextPage(with index: Int) {
		
		guard self.onboardingViewModel.onboarding.count > index else { return }
		self.setViewControllers([self.onboardingViewModel.viewController(from: index)], direction: .forward, animated: true, completion: nil)
	}
}

extension OnboardingViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		
		let index = self.pageControl.currentPage + 1
		
		if onboardingViewModel.onboarding.count == index {
			self.onboardingWillPass()
		} else {
			self.showNextPage(with: index)
		}
	}
}
	
extension OnboardingViewController {
	
	private func setupViewModel() {
		
		self.onboardingViewModel = OnboardingViewModel(onboarding: Onboarding.allCases)
		self.onboardingDataSource = OnboardingDataSource(onboardingViewModel: self.onboardingViewModel)
		self.pageControl.numberOfPages = self.onboardingViewModel.onboarding.count
		self.pageControl.currentPage = 0
				
		self.onboardingViewModel.pageIndicatorDidChange = { index in
			self.pageControl.numberOfPages = self.onboardingViewModel.onboarding.count
			self.pageControl.currentPage = index
		}
	}
	
	private func setupDelegate() {
		
		self.dataSource = self.onboardingDataSource
		self.delegate = self.onboardingDataSource
		bottomButtonView.delegate = self
	}
	
	private func setupControllers() {
		setViewControllers([self.onboardingViewModel.viewController(from: 0)], direction: .forward, animated: true, completion: nil)
	}
		
	private func setupPageControl() {
		
		pageControl.addTarget(self, action: #selector(pageUpdater), for: .valueChanged)
		pageControl.currentPageIndicatorTintColor = UIColor().colorFromHexString("9DA6B7")
		pageControl.pageIndicatorTintColor =  UIColor().colorFromHexString("CBD1DC")
		
		if #available(iOS 14.0, *) {
			pageControl.allowsContinuousInteraction = true
			pageControl.backgroundStyle = .automatic
		}
		
		self.view.addSubview(pageControl)
		pageControl.translatesAutoresizingMaskIntoConstraints = false

		pageControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		pageControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
		pageControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	private func setupBottomButtonView() {
		
		self.view.addSubview(bottomButtonView)
		
		bottomButtonView.translatesAutoresizingMaskIntoConstraints = false
		bottomButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70).isActive = true
		bottomButtonView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		bottomButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		bottomButtonView.heightAnchor.constraint(equalToConstant: 80).isActive = true
		
		bottomButtonView.setButtonSideOffset(40)
		bottomButtonView.setImageRight(I.systemItems.defaultItems.arrowLeft, with: CGSize(width: 20, height: 18))
		bottomButtonView.title(LocalizationService.Buttons.getButtonTitle(of: .next).uppercased())
	}

	private func setupSkipButton() {
	
		self.view.addSubview(skipButton)
		skipButton.translatesAutoresizingMaskIntoConstraints = false
		skipButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
		skipButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: Utils.topSafeAreaHeight).isActive = true
		skipButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
		skipButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
		
		skipButton.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
		skipButton.setTitle(LocalizationService.Buttons.getButtonTitle(of: .skip), for: .normal)
		skipButton.titleLabel?.font = FontManager.onboardingFont(of: .subtitle)
	}
		
	@objc func pageUpdater() {
		let currentIndex = onboardingViewModel.rawIndex
		
		if pageControl.currentPage > currentIndex {
			self.navigateForward()
		} else if pageControl.currentPage < currentIndex {
			self.navigateBackward()
		}
	}
	
	@objc func didTapSkipButton() {
		coordinator?.currentState = .permission
		coordinator?.showPermissionViewController()
	}
}

extension OnboardingViewController: Themeble {

	private func setupUI() {
		
		scrollView = view.subviews.filter{ $0 is UIScrollView }.first as? UIScrollView
		scrollView?.delegate = self
	}
	
	func updateColors() {
	
		self.view.backgroundColor = theme.cellBackGroundColor
		skipButton.setTitleColor(theme.subTitleTextColor, for: .normal)
		
		let colors: [UIColor] = theme.onboardingButtonColors
		bottomButtonView.configureShadow = true
		bottomButtonView.addButtonShadhowIfLayoutError()
		bottomButtonView.addButtonGradientBackground(colors: colors)
		bottomButtonView.buttonTintColor = theme.activeTitleTextColor
		bottomButtonView.buttonTitleColor = theme.activeTitleTextColor
		bottomButtonView.updateColorsSettings()
	}
}

extension OnboardingViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if onboardingViewModel.rawIndex == onboardingViewModel.onboarding.count {
			let point = (scrollView.contentSize.width / 3) + Utils.screenWidth / 4.5
			if scrollView.contentOffset.x > point {

				if !thisIsTheEnd {
					thisIsTheEnd = !thisIsTheEnd
					scrollView.setContentOffset(scrollView.contentOffset, animated: false)
					
					if let view = Utils.Manager.viewByClassName(view: self.view, className: "_UIQueuingScrollView") {
						UIView.animate(withDuration: 0.5) {
							view.isHidden = true
						} completion: { _ in
							self.onboardingWillPass()
						}
//						UIView.animate(withDuration: 0.3) {
//							scrollView.layer.transform = CATransform3DMakeTranslation(-300, 0.0, 0.0)
//						} completion: { animated in
//							self.coordinator?.showPermissionViewController()
//						}
					}
				}
			}
		}
	}
}

extension UIPageViewController {
	
	func navigateForward(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
		guard let currentViewController = self.viewControllers?.first else { return }
		guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else { return }
		setViewControllers([nextViewController], direction: .forward, animated: animated, completion: completion)
	}
	
	func navigateBackward(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
	  guard let currentViewController = self.viewControllers?.first else { return }
	  guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }
	  setViewControllers([previousViewController], direction: .reverse, animated: animated, completion: completion)
	}
}
