//
//  LifeTimeSubscriptionViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.07.2022.
//

import UIKit
import SwiftMessages

class LifeTimeSubscriptionViewController: UIViewController {
	
	@IBOutlet weak var mainContainerView: UIView!
	@IBOutlet weak var helperView: UIView!
	@IBOutlet weak var crownContainerView: UIView!
	@IBOutlet weak var crownImageView: UIImageView!
	@IBOutlet weak var topShevronView: UIView!
	@IBOutlet weak var titleTextLabel: UILabel!
	
	@IBOutlet weak var leadingStackView: UIStackView!
	@IBOutlet weak var trailingStackView: UIStackView!
	
	@IBOutlet weak var mainContaintainerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var bottomContainerHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var bottomContainerView: UIView!
	@IBOutlet weak var actionButtonContainerView: UIView!
	@IBOutlet weak var actionButtonContainerStackView: UIStackView!
	@IBOutlet weak var actionButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var actionButton: UIButton!
	
	@IBOutlet weak var lostConnectionView: UIView!
	@IBOutlet weak var lostConnectionViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var subscribeTitleTextLabel: UILabel!
	@IBOutlet weak var subscribeSubtitleTextLabel: UILabel!
	@IBOutlet weak var subscribePriceTextLabel: UILabel!
	@IBOutlet weak var subscribePriceInfoTextLabel: UILabel!
	@IBOutlet weak var actionButtonContainerViewWidthConstraint: NSLayoutConstraint!
	
	private var lostConnectionImageView = UIImageView()
	private var lostConnetctionMessage = UILabel()
	private let buttonShadow = ReuseShadowView()
	private lazy var activityIndicatorView = UIActivityIndicatorView(style: .medium)
	private var dissmissGestureRecognizer = UIPanGestureRecognizer()
	
	private var statusSubscriptionLoaded: SubscriptionSegmentStatus = .willLoading
	private var subscriptionActionProcessingState: SubscriptionActionProcessingState = .active
	private var subscriptionManager = SubscriptionManager.instance

	private var tapOutsideRecognizer: UITapGestureRecognizer!

	override func viewDidLoad() {
        super.viewDidLoad()
		
		lostConnectionViewSetup()
		loadLifeTimeSubscription()
		featuresConfigure(leadingFeatures: [.deepClean, .multiselect, .location, .compression], trailingFeautures: [])
		actionButtonSetup()
		setupActivityIndicator()
		setupUI()
        updateColors()
		setupObserver()
		setupGestureRecognizers()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.setupDissmissGestureRecognizer()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
		
		var buttonWidth: CGFloat {
			switch Screen.size {
				case .proMax:
					return Utils.screenWidth - 100
				default:
					return Utils.screenWidth - 80
			}
		}
		
		actionButtonContainerViewWidthConstraint.constant = buttonWidth
		lostConnectionViewWidthConstraint.constant = buttonWidth
		
		actionButtonContainerView.layoutIfNeeded()
		actionButtonContainerStackView.layoutIfNeeded()
	}
	
	@IBAction func didTapPurchaseLifeTimeActionButton(_ sender: Any) {
		
		guard statusSubscriptionLoaded != .disable else { return }
		
		self.actionButtonContainerView.animateButtonTransform()
		self.buttonShadow.animateButtonTransform()
		self.actionButtonHandler(for: .processing)
		
		Network.theyLive { status in
			switch status {
				case .connedcted:
					self.didTapPurchasePremium()
				case .unreachable:
					ErrorHandler.shared.showNetworkErrorAlert(.networkError, at: self)
					self.actionButtonHandler(for: .active)
			}
		}
	}
}

extension LifeTimeSubscriptionViewController {
	
	private func didTapPurchasePremium() {
		
		self.subscriptionManager.purchasePremium(of: .lifeTime) { purchased in
			Utils.UI {
				self.actionButtonHandler(for: .active)
				if purchased {
					self.closeController(sender: self.actionButton)
				} else {
					ErrorHandler.shared.showSubsriptionAlertError(for: .purchaseError, at: self)
				}
			}
		}
	}
	
	private func actionButtonHandler(for state: SubscriptionActionProcessingState) {
		
		self.subscriptionActionProcessingState = state
		
		Utils.UI {
			switch state {
				case .processing:
					self.actionButton.isEnabled = false
					self.setActivityIndicator(true)
					UIView.animate(withDuration: 0.3) {
						self.actionButtonContainerStackView.isHidden = true
						self.actionButtonContainerView.alpha = 1
					}
				case .active:
					self.setActivityIndicator(false)
					self.actionButton.isEnabled = true
					UIView.animate(withDuration: 0.3) {
						self.actionButtonContainerStackView.isHidden = false
						self.actionButtonContainerView.alpha = 1
					}
				case .disabled:
					self.setActivityIndicator(false)
					self.actionButton.isEnabled = false
					UIView.animate(withDuration: 0.3) {
						self.actionButtonContainerStackView.isHidden = false
						self.actionButtonContainerView.alpha = 0.5
					}
			}
		}
	}
}

extension LifeTimeSubscriptionViewController {
	
	private func featuresConfigure(leadingFeatures: [PremiumFeature], trailingFeautures: [PremiumFeature]) {

		for feature in leadingFeatures {
			let featureView = PremiumFeatureView()
			featureView.configureLifeTimeFeatures(from: feature)
			leadingStackView.addArrangedSubview(featureView)
		}
		
		for feature in trailingFeautures {
			let featureView = PremiumFeatureView()
			featureView.configureLifeTimeFeatures(from: feature)
			trailingStackView.addArrangedSubview(featureView)
		}
	}
	
	private func loadLifeTimeSubscription() {
		
		Network.theyLive { status in
			switch status {
				case .connedcted:
					self.handledContainer(for: .willLoading)
					self.subscriptionManager.getLifeTimeDescription { model in
						Utils.UI {
							if let model = model {
								self.handledContainer(for: .didLoad)
								
								var name: String {
									if model.productName.isEmpty {
										return "Life Time"
									} else {
										return model.productName
									}
								}
								
								self.subscribeTitleTextLabel.text =  name
								
								self.subscribePriceTextLabel.text = model.productPrice
							} else {
								self.handledContainer(for: .empty)
								Utils.delay(1) {
									self.loadLifeTimeSubscription()
								}
							}
						}
					}
				case .unreachable:
					self.handledContainer(for: .disable)
			}
		}
	}
	
	private func handledContainer(for status: SubscriptionSegmentStatus) {
		
		switch status {
			case .willLoading:
				self.actionButtonHandler(for: .processing)
			case .didLoad:
				self.actionButtonHandler(for: .active)
			case .disable, .empty:
				self.actionButtonHandler(for: .disabled)
		}
		
		self.statusSubscriptionLoaded = status
		self.setLostConnectionContainer(status: status)
	}
	
	private func setLostConnectionContainer(status: SubscriptionSegmentStatus) {
		
		let networkImage = Images.systemElementsItems.connectionLost
		let disabledImage = Images.systemElementsItems.noContent
		
		lostConnetctionMessage.text = Localization.ErrorsHandler.PurchaseError.networkError
		Utils.animate(0.5) { [self] in
			switch status {
				case .willLoading, .didLoad:
					lostConnectionImageView.image = nil
					actionButtonContainerView.isHidden = false
					bottomContainerView.isHidden = false
					buttonShadow.isHidden = false
				case .disable:
					lostConnectionImageView.image = networkImage
					actionButtonContainerView.isHidden = true
					bottomContainerView.isHidden = true
					lostConnectionView.isHidden = false
					buttonShadow.isHidden = true
				case .empty:
					lostConnectionImageView.image = disabledImage
					actionButtonContainerView.isHidden = true
					bottomContainerView.isHidden = true
					lostConnectionView.isHidden = false
					buttonShadow.isHidden = true
			}
		}
	}
	
	private func setActivityIndicator(_ isStarting: Bool) {
		
		if isStarting {
			self.actionButtonContainerView.addSubview(activityIndicatorView)
			activityIndicatorView.isHidden = false
			activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
			activityIndicatorView.centerXAnchor.constraint(equalTo: self.actionButtonContainerView.centerXAnchor).isActive = true
			activityIndicatorView.centerYAnchor.constraint(equalTo: self.actionButtonContainerView.centerYAnchor).isActive = true
			activityIndicatorView.widthAnchor.constraint(equalToConstant: 20).isActive = true
			activityIndicatorView.heightAnchor.constraint(equalToConstant: 20).isActive = true
			activityIndicatorView.startAnimating()
		} else {
			activityIndicatorView.stopAnimating()
			activityIndicatorView.removeFromSuperview()
		}
		activityIndicatorView.layoutIfNeeded()
	}
	
	@objc func networkStatusDidChange() {
		loadLifeTimeSubscription()
	}
}

extension LifeTimeSubscriptionViewController {
	
	private func setupDissmissGestureRecognizer() {
		
		guard self.tapOutsideRecognizer == nil else { return }
		
		self.tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapBehind))
		self.tapOutsideRecognizer.numberOfTapsRequired = 1
		self.tapOutsideRecognizer.cancelsTouchesInView = false
		self.tapOutsideRecognizer.delegate = self
		U.sceneDelegate.window?.addGestureRecognizer(self.tapOutsideRecognizer)
	}
	
	private func removeDissmissGestureRecognizer() {
		
		guard self.tapOutsideRecognizer != nil else { return }
		
		Utils.sceneDelegate.window?.removeGestureRecognizer(self.tapOutsideRecognizer)
		self.tapOutsideRecognizer = nil
	}
	
	private func setupGestureRecognizers() {
		
		let animator = TopBottomAnimation(style: .bottom)
		dissmissGestureRecognizer = animator.panGestureRecognizer
		dissmissGestureRecognizer.cancelsTouchesInView = false
		animator.panGestureRecognizer.delegate = self
		self.view.addGestureRecognizer(dissmissGestureRecognizer)
	}
	
	@objc func handleTapBehind(sender: UITapGestureRecognizer) {
		
		if sender.state == UIGestureRecognizer.State.ended {
			
			let location: CGPoint = sender.location(in: nil)

			if !self.view.point(inside: self.view.convert(location, from: self.view.window), with: nil) {
				self.view.window?.removeGestureRecognizer(sender)
				self.closeController(sender: sender)
			}
		}
	}
	
	private func closeController(sender: AnyObject) {
		guard self.subscriptionActionProcessingState != .processing else { return }
		self.dismiss(animated: true) {
			self.removeDissmissGestureRecognizer()
		}
	}
}

extension LifeTimeSubscriptionViewController: Themeble {
	
	private func actionButtonSetup() {
		
		subscribeTitleTextLabel.textAlignment = .left
		subscribeSubtitleTextLabel.textAlignment = .left
		subscribePriceTextLabel.textAlignment = .right
		subscribePriceInfoTextLabel.textAlignment = .right
		subscribeTitleTextLabel.numberOfLines = 2
		
		subscribeTitleTextLabel.font = FontManager.subscriptionFont(of: .buttonTitle)
		subscribePriceTextLabel.font = FontManager.subscriptionFont(of: .buttonPrice)
		
		actionButtonContainerView.setCorner(12)
	}
	
	private func setupActivityIndicator() {
		
		self.activityIndicatorView.color = .white
		self.activityIndicatorView.isHidden = true
	}
	
	private func lostConnectionViewSetup() {
		
		self.lostConnectionView.isHidden = true
		
		let reuseView = ReuseShadowView()
		self.lostConnectionView.insertSubview(reuseView, at: 0)
		reuseView.translatesAutoresizingMaskIntoConstraints = false
		reuseView.leadingAnchor.constraint(equalTo: self.lostConnectionView.leadingAnchor).isActive = true
		reuseView.trailingAnchor.constraint(equalTo: self.lostConnectionView.trailingAnchor).isActive = true
		reuseView.topAnchor.constraint(equalTo: self.lostConnectionView.topAnchor).isActive = true
		reuseView.bottomAnchor.constraint(equalTo: self.lostConnectionView.bottomAnchor).isActive = true
		
		self.lostConnectionView.addSubview(self.lostConnectionImageView)
		self.lostConnectionImageView.translatesAutoresizingMaskIntoConstraints = false
		self.lostConnectionImageView.leadingAnchor.constraint(equalTo: self.lostConnectionView.leadingAnchor, constant: 20).isActive = true
		self.lostConnectionImageView.centerYAnchor.constraint(equalTo: self.lostConnectionView.centerYAnchor).isActive = true
		self.lostConnectionImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
		self.lostConnectionImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
		
		self.lostConnectionView.addSubview(self.lostConnetctionMessage)
		self.lostConnetctionMessage.translatesAutoresizingMaskIntoConstraints = false
		
		self.lostConnetctionMessage.leadingAnchor.constraint(equalTo: self.lostConnectionImageView.trailingAnchor, constant: 20).isActive = true
		self.lostConnetctionMessage.topAnchor.constraint(equalTo: self.lostConnectionView.topAnchor).isActive = true
		self.lostConnetctionMessage.bottomAnchor.constraint(equalTo: self.lostConnectionView.bottomAnchor).isActive = true
		self.lostConnetctionMessage.trailingAnchor.constraint(equalTo: self.lostConnectionView.trailingAnchor, constant: -20).isActive = true
	}
	
	private func setupUI() {
		
		self.trailingStackView.isHidden = true
		self.subscribeSubtitleTextLabel.isHidden = true
		self.subscribePriceInfoTextLabel.isHidden = true
		
		self.actionButtonContainerView.isHidden = true
		buttonShadow.isHidden = true
		
		actionButtonContainerViewWidthConstraint.constant = U.screenWidth - 80
		bottomContainerHeightConstraint.constant = AppDimensions.BottomButton.bottomBarDefaultHeight
		
		let containerHeight = AppDimensions.Subscription.Features.lifeTimeConttolerHeigh
		self.view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: containerHeight)
		mainContaintainerHeightConstraint.constant = containerHeight
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
		
		topShevronView.setCorner(3)
		
		titleTextLabel.textAlignment = .center
		titleTextLabel.font = FontManager.subscriptionFont(of: .lifeTimeTitle)
		
		titleTextLabel.text = Localization.Settings.Title.lifeTime
		crownImageView.image = I.systemItems.navigationBarItems.premium
		crownImageView.contentMode = .scaleAspectFit
		crownImageView.setupForShadow(shadowColor: theme.bottomShadowColor, cornerRadius: 14, shadowOffcet: CGSize(width: 3, height: 3), shadowOpacity: 10, shadowRadius: 14)
		
		lostConnectionImageView.tintColor = theme.tintColor
		lostConnetctionMessage.font = FontManager.subscriptionFont(of: .helperText)
		lostConnetctionMessage.numberOfLines = 2
		lostConnectionView.backgroundColor = .clear
	}
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
		mainContainerView.backgroundColor = theme.backgroundColor
		
		topShevronView.backgroundColor = theme.subTitleTextColor
		titleTextLabel.textColor = theme.titleTextColor
		
//		actionButtonContainerView.layoutIfNeeded()
//
		let colors = theme.onboardingButtonColors.compactMap({$0.cgColor})
		actionButtonContainerView.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colors: colors, type: .axial)
	
		
		self.bottomContainerView.insertSubview(buttonShadow, at: 0)
		buttonShadow.translatesAutoresizingMaskIntoConstraints = false
		buttonShadow.leadingAnchor.constraint(equalTo: self.actionButtonContainerView.leadingAnchor).isActive = true
		buttonShadow.trailingAnchor.constraint(equalTo: self.actionButtonContainerView.trailingAnchor).isActive = true
		buttonShadow.bottomAnchor.constraint(equalTo: self.actionButtonContainerView.bottomAnchor).isActive = true
		buttonShadow.topAnchor.constraint(equalTo: self.actionButtonContainerView.topAnchor).isActive = true
		
		subscribeTitleTextLabel.textColor = theme.activeTitleTextColor
		subscribeSubtitleTextLabel.textColor = theme.activeTitleTextColor
		subscribePriceTextLabel.textColor = theme.activeTitleTextColor
		subscribePriceInfoTextLabel.textColor = theme.activeTitleTextColor
	}
	
	private func setupObserver() {
		
		U.notificationCenter.addObserver(self, selector: #selector(networkStatusDidChange), name: .ConnectivityDidChange, object: nil)
	}
}

extension LifeTimeSubscriptionViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return gestureRecognizer is UISwipeGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
	
		if gestureRecognizer == dissmissGestureRecognizer && self.subscriptionActionProcessingState == .processing {
			let point = gestureRecognizer.location(in: self.view)
			if self.view.bounds.contains(point) {
				return false
			}
		}
		return true
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
	
		if gestureRecognizer == dissmissGestureRecognizer && self.subscriptionActionProcessingState == .processing {
			let point = gestureRecognizer.location(in: self.view)
			
			if self.view.bounds.contains(point) {
				return true
			}
		}
		return true
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
