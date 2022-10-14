//
//  File.swift
//  ECleaner
//
//  Created by alexey sorochan on 13.07.2022.
//

import UIKit

final public class DefaultAutoSlideConfiguration: AutoSlideConfiguration {

	public static var shared = DefaultAutoSlideConfiguration()

	init() {}

	// MARK: - AutoSlideConfiguration
	public var timeInterval: TimeInterval = 3.0
	public var transitionStyle: UIPageViewController.TransitionStyle = .scroll
	public var navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal
	public var navigationDirection: UIPageViewController.NavigationDirection = .forward
	public var interPageSpacing: Float = 0.0
	public var spineLocation: UIPageViewController.SpineLocation = .none
	public var hidePageControl: Bool = false

	public var currentPageIndicatorTintColor: UIColor = UIColor.gray
	public var pageIndicatorTintColor: UIColor = UIColor.lightGray
	public var pageControlBackgroundColor: UIColor = UIColor.clear

	public var shouldAnimateTransition: Bool = true

}


open class DLAutoSlidePageViewController: UIPageViewController {

	private (set) public var pages: [UIViewController] = []
	private (set) public var configuration: AutoSlideConfiguration = DefaultAutoSlideConfiguration.shared

	private var currentPageIndex: Int = 0
	private var nextPageIndex: Int = 0
	private var timer: Timer?

	private var transitionInProgress: Bool = false

	// MARK: - Computed properties
	public var pageControl: UIPageControl? {
		return UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
	}

	// MARK: - Lifecycle
	open override func willTransition(to newCollection: UITraitCollection,
									  with coordinator: UIViewControllerTransitionCoordinator) {
		super.willTransition(to: newCollection, with: coordinator)
		coordinator.animate(alongsideTransition: nil) { _ in
			self.transitionInProgress = false
			self.restartTimer()
		}
	}

	// MARK: - Initializers
	/**
	 * Initializes a newly created auto slide page view controller.
	 * - Parameters:
	 *      - pages: The view controllers to be set for the auto slide page view controller.
	 *      - configuration: The configuration of the auto slide page view controller.
	 */
	public init(pages: [UIViewController], configuration: AutoSlideConfiguration) {
		self.pages = pages
		self.configuration = configuration
		super.init(transitionStyle: configuration.transitionStyle,
				   navigationOrientation: configuration.navigationOrientation,
				   options: [UIPageViewController.OptionsKey.interPageSpacing: configuration.interPageSpacing,
							 UIPageViewController.OptionsKey.spineLocation: configuration.spineLocation])

		setupPageView()
		setupPageControl()
		setupPageTimer(with: configuration.timeInterval)
	}

	/**
	 * Initializes a newly created auto slide page view controller with a default configuration.
	 * - Parameters:
	 *      - pages: The view controllers to be set for the auto slide page view controller.
	 */
	public convenience init(pages: [UIViewController]) {
		let configuration = DefaultAutoSlideConfiguration.shared
		self.init(pages: pages, configuration: configuration)
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - Lifecycle
	
	deinit {
		stopTimer()
		NotificationCenter.default.removeObserver(self,
												  name: UIApplication.willEnterForegroundNotification,
												  object: nil);
	}
	
	override open func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
		dataSource = self
		setupObservers()
	}

	// MARK: - Private
	private func setupObservers() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(movedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
	}

	private func setupPageView() {
		guard let firstPage = pages.first else { return }
		currentPageIndex = 0

		let navigationDirection = configuration.navigationDirection
		setViewControllers([firstPage], direction: navigationDirection, animated: true, completion: nil)
	}

	private func setupPageControl() {
		pageControl?.currentPageIndicatorTintColor = configuration.currentPageIndicatorTintColor
		pageControl?.pageIndicatorTintColor = configuration.pageIndicatorTintColor
		pageControl?.backgroundColor = configuration.pageControlBackgroundColor
	}

	private func viewControllerAtIndex(_ index: Int) -> UIViewController {
		guard index < pages.count else { return UIViewController() }
		currentPageIndex = index
		return pages[index]
	}

	private func setupPageTimer(with timeInterval: TimeInterval) {
		guard timeInterval != 0.0 else { return }
		timer = Timer.scheduledTimer(timeInterval: timeInterval,
									 target: self,
									 selector: #selector(changePage),
									 userInfo: nil,
									 repeats: true)
	}

	private func stopTimer() {
		guard let _ = timer else { return }
		timer?.invalidate()
		timer = nil
	}

	private func restartTimer() {
		stopTimer()
		setupPageTimer(with: configuration.timeInterval)
	}

	// MARK: - Selectors
	@objc private func movedToForeground() {
		transitionInProgress = false
		restartTimer()
	}

	@objc private func changePage() {
		let navigationDirection = configuration.navigationDirection
		let shouldAnimateTransition = configuration.shouldAnimateTransition
		currentPageIndex = AutoSlideHelper.pageIndex(for: currentPageIndex,
													 totalPageCount: pages.count,
													 direction: navigationDirection)
		guard let viewController = viewControllerAtIndex(currentPageIndex) as UIViewController? else { return }
		if !transitionInProgress {
			transitionInProgress = true
			setViewControllers([viewController], direction: navigationDirection, animated: shouldAnimateTransition, completion: { finished in
				self.transitionInProgress = false
			})
		}
	}

}

// MARK: - UIPageViewControllerDelegate
extension DLAutoSlidePageViewController: UIPageViewControllerDelegate {

	open func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		guard let viewController = pendingViewControllers.first,
			  let index = pages.firstIndex(of: viewController) else {
			return
		}
		nextPageIndex = index
	}

	open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed {
			currentPageIndex = nextPageIndex
		}
		nextPageIndex = 0
	}

}

// MARK: - UIPageViewControllerDataSource
extension DLAutoSlidePageViewController: UIPageViewControllerDataSource {

	open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		restartTimer()
		guard var currentIndex = pages.firstIndex(of: viewController) else { return nil }
		if currentIndex > 0 {
			currentIndex = (currentIndex - 1) % pages.count
			return pages[currentIndex]
		} else {
			return nil
		}
	}

	open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		restartTimer()
		guard var currentIndex = pages.firstIndex(of: viewController) else { return nil }
		if currentIndex < pages.count - 1 {
			currentIndex = (currentIndex + 1) % pages.count
			return pages[currentIndex]
		} else {
			return nil
		}
	}

	open func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return configuration.hidePageControl ? 0 : pages.count
	}

	open func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return configuration.hidePageControl ? 0 : currentPageIndex
	}

}

final class AutoSlideHelper {

	class func pageIndex(for currentPageIndex: Int,
						 totalPageCount: Int,
						 direction: UIPageViewController.NavigationDirection) -> Int {
		switch direction {
		case .reverse:
			return currentPageIndex > 0 ? currentPageIndex - 1 : totalPageCount - 1
		case .forward:
			fallthrough
		@unknown default:
			return currentPageIndex < totalPageCount - 1 ? currentPageIndex + 1 : 0
		}
	}

}

public protocol AutoSlideConfiguration {

	/// Time interval to be used for each page automatic transition.
	var timeInterval: TimeInterval { get }

	/// Styles for the page-turn transition.
	var transitionStyle: UIPageViewController.TransitionStyle { get }

	/// Orientations for page-turn transitions.
	var navigationOrientation: UIPageViewController.NavigationOrientation { get }

	/// Directions for page-turn transitions.
	var navigationDirection: UIPageViewController.NavigationDirection { get }

	/// Space between pages.
	var interPageSpacing: Float { get }

	/// Locations for the spine. Only valid if the transition style is UIPageViewController.TransitionStyle.pageCurl.
	var spineLocation: UIPageViewController.SpineLocation { get }

	/// Decides if page control is going to be shown or not.
	var hidePageControl: Bool { get }

	/// The tint color to be used for the current page indicator.
	var currentPageIndicatorTintColor: UIColor { get }

	/// The tint color to be used for the page indicator.
	var pageIndicatorTintColor: UIColor { get }

	/// The background color to be used for the page control.
	var pageControlBackgroundColor: UIColor { get }

	/// Indicates whether the automatic transition is to be animated.
	var shouldAnimateTransition: Bool { get }

}

// MARK: - Default values
public extension AutoSlideConfiguration {

	var timeInterval: TimeInterval { 3.0 }
	var transitionStyle: UIPageViewController.TransitionStyle { .scroll }
	var navigationOrientation: UIPageViewController.NavigationOrientation { .horizontal }
	var navigationDirection: UIPageViewController.NavigationDirection { .forward }
	var interPageSpacing: Float { 0.0 }
	var spineLocation: UIPageViewController.SpineLocation { .none }
	var hidePageControl: Bool { false }

	var currentPageIndicatorTintColor: UIColor { UIColor.gray }
	var pageIndicatorTintColor: UIColor { UIColor.lightGray }
	var pageControlBackgroundColor: UIColor { UIColor.clear }

	var shouldAnimateTransition: Bool { true }

}
