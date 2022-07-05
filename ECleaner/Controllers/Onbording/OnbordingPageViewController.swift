//
//  OnboardingPageViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2022.
//

import UIKit
import Lottie

class OnboardingPageViewController: UIViewController {
	
	@IBOutlet weak var animationView: AnimationView!
	@IBOutlet weak var thumbnailView: UIImageView!
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var subtitleTextLabel: UILabel!
	@IBOutlet weak var thumbnailsCenterConstraint: NSLayoutConstraint!
	@IBOutlet weak var thumbnailWidthConstraint: NSLayoutConstraint!
	
	public var delegate: OnboardingControllDelegate?
	
	var onboarding: Onboarding?
	var sceneTitle: String?
	var currentIndex: Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupOnboarding()
		setupUI()
		updateColors()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		animationView.play()
		delegate?.didUpdatePageIndicator(with: self.currentIndex)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		animationView.stop()
	}
}

extension OnboardingPageViewController {
	
	private func setupOnboarding() {
		
		guard let onboarding = onboarding else { return }
		
		if let index = Onboarding.allCases.firstIndex(of: onboarding) {
			self.currentIndex = index
		}
		
		sceneTitle = onboarding.rawValue
		titleTextLabel.text = onboarding.title
		subtitleTextLabel.text = onboarding.description
		animationView.animation = Animation.named(onboarding.animationName)
		animationView.loopMode = .loop
		animationView.backgroundBehavior = .pauseAndRestore
		
		thumbnailView.image = onboarding.thumbnail
	}
}

extension OnboardingPageViewController: Themeble {
	
	private func setupUI() {
		
		animationView.isHidden = true
		
		titleTextLabel.font = FontManager.onboardingFont(of: .title)
		subtitleTextLabel.font = FontManager.onboardingFont(of: .subtitle)
		
		titleTextLabel.textAlignment = .center
		subtitleTextLabel.textAlignment = .center
		
		switch Screen.size {
				
			case .small:
				thumbnailWidthConstraint = thumbnailWidthConstraint.setMultiplier(multiplier: 0.7)
				thumbnailsCenterConstraint = thumbnailsCenterConstraint.setMultiplier(multiplier: 0.5)
			case .medium:
				thumbnailWidthConstraint = thumbnailWidthConstraint.setMultiplier(multiplier: 0.7)
				thumbnailsCenterConstraint = thumbnailsCenterConstraint.setMultiplier(multiplier: 0.5)
			case .plus:
				thumbnailsCenterConstraint = thumbnailsCenterConstraint.setMultiplier(multiplier: 0.6)
			default:
				thumbnailsCenterConstraint = thumbnailsCenterConstraint.setMultiplier(multiplier: 0.75)
		}
	}
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
		titleTextLabel.textColor = theme.titleTextColor
		subtitleTextLabel.textColor = theme.onboardingSubTitleTextColor
	}
}
