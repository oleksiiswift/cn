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
	
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var subtitleTextLabel: UILabel!
	
	var onboarding: Onboarding?
	var sceneTitle: String?
	
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
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		animationView.stop()
	}
}

extension OnbordingPageViewController {
	
	private func setupOnboarding() {
		
		guard let onboarding = onboarding else { return }
		
		sceneTitle = onboarding.rawValue
		titleTextLabel.text = onboarding.title
		subtitleTextLabel.text = onboarding.description
		animationView.animation = Animation.named(onboarding.animationName)
		animationView.loopMode = .loop
		animationView.backgroundBehavior = .pauseAndRestore
	}
}

extension OnbordingPageViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		debugPrint("next")
	}
}

extension OnbordingPageViewController: Themeble {
	
	private func setupUI() {
		
		self.bottomButtonView.setButtonSideOffset(40)
		self.bottomButtonView.setImageRight(I.systemItems.defaultItems.arrowLeft, with: CGSize(width: 24, height: 22))
		self.bottomButtonView.title(LocalizationService.Buttons.getButtonTitle(of: .next).uppercased())
		
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
	}
}
