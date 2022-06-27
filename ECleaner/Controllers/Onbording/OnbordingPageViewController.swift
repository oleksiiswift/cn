//
//  OnbordingPageViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2022.
//

import UIKit
import Lottie

class OnbordingPageViewController: UIViewController {

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
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		animationView.play()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		animationView.stop()
	}
	
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

extension OnbordingPageViewController: Themeble {
	
	private func setupUI() {
	
	}
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
	}
}
