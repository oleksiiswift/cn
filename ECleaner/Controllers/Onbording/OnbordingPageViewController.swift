//
//  OnbordingPageViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2022.
//

import UIKit
import Lottie

class OnbordingPageViewController: UIViewController {
	
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
	@IBOutlet weak var animationView: AnimationView!
	@IBOutlet weak var thumbnailView: UIImageView!
	
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var subtitleTextLabel: UILabel!
	
	public var delegate: OnboardingControllDelegate?
	
	var onboarding: Onboarding?
	var sceneTitle: String?
	var currentIndex: Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupOnboarding()
		setupUI()
		updateColors()
		setupDelegate()
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

extension OnbordingPageViewController {
	
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

extension OnbordingPageViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		delegate?.didTapActionButton(for: currentIndex + 1)
	}
}

extension OnbordingPageViewController: Themeble {
	
	private func setupUI() {
		
		thumbnailView.isHidden = true
	
		self.bottomButtonView.setButtonSideOffset(40)
		self.bottomButtonView.setImageRight(I.systemItems.defaultItems.arrowLeft, with: CGSize(width: 24, height: 22))
		self.bottomButtonView.title(LocalizationService.Buttons.getButtonTitle(of: .next).uppercased())
		
		titleTextLabel.font = FontManager.onboardingFont(of: .title)
		subtitleTextLabel.font = FontManager.onboardingFont(of: .subtitle)
		
		titleTextLabel.textAlignment = .center
		subtitleTextLabel.textAlignment = .center
	}
	
	private func setupDelegate() {
		bottomButtonView.delegate = self
	}
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
		self.bottomButtonView.configureShadow = true
		let colors: [UIColor] = theme.onboardingButtonColors
		self.bottomButtonView.addButtonShadow()
		self.bottomButtonView.addButtonGradientBackground(colors: colors)
		bottomButtonView.buttonTintColor = theme.activeTitleTextColor
		bottomButtonView.buttonTitleColor = theme.activeTitleTextColor
		bottomButtonView.updateColorsSettings()
		
		titleTextLabel.textColor = theme.titleTextColor
		subtitleTextLabel.textColor = theme.onboardingSubTitleTextColor
	}
}
