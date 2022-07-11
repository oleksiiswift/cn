//
//  LifeTimeSubscriptionViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.07.2022.
//

import UIKit

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
	
	@IBOutlet weak var actionButtonContainerView: UIView!
	@IBOutlet weak var actionButtonContainerStackView: UIStackView!
	@IBOutlet weak var actionButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var actionButton: UIButton!
	
	@IBOutlet weak var subscribeTitleTextLabel: UILabel!
	@IBOutlet weak var subscribeSubtitleTextLabel: UILabel!
	@IBOutlet weak var subscribePriceTextLabel: UILabel!
	@IBOutlet weak var subscribePriceInfoTextLabel: UILabel!
	@IBOutlet weak var actionButtonContainerViewWidthConstraint: NSLayoutConstraint!
	
	private lazy var activityIndicatorView = UIActivityIndicatorView(style: .medium)
	
	private var statusSubscriptionLoaded: SubscriptionSegmentStatus = .willLoading
	
	private var subscriptionManager = SubscriptionManager.instance
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		loadLifeTimeSubscription()
		featuresConfigure(leadingFeatures: [.deepClean, .multiselect, .location, .compression], trailingFeautures: [])
		actionButtonSetup()
		setupActivityIndicator()
		setupUI()
        updateColors()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		mainContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 20)
		actionButtonContainerViewWidthConstraint.constant = U.screenWidth - 80
	}
	
	@IBAction func didTapPurchaseLifeTimeActionButton(_ sender: Any) {
		
		guard statusSubscriptionLoaded != .disable else { return }
		
		self.actionButtonContainerView.animateButtonTransform()
		
		self.actionButtonHandler(for: .processing)
		
		Network.theyLive { isAlive in
			if isAlive {
				self.didTapPurchasePremium()
			} else {
				ErrorHandler.shared.showNetworkErrorAlert(.networkError, at: self)
				self.actionButtonHandler(for: .active)
			}
		}
	}
}

extension LifeTimeSubscriptionViewController {
	
	private func didTapPurchasePremium() {
		
		self.subscriptionManager.purchasePremium(of: .lifeTime) { purchased in
			self.actionButtonHandler(for: .active)
			if purchased {
				self.dismiss(animated: true)
			} else {
				ErrorHandler.shared.showSubsriptionAlertError(for: .purchaseError, at: self)
			}
		}
	}
	
	private func actionButtonHandler(for state: SubscriptionActionProcessingState) {
		
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
		
		statusSubscriptionLoaded = .willLoading
		
		subscriptionManager.getLifeTimeDescription { model in
			Utils.UI {
				
				if let model = model {
					self.statusSubscriptionLoaded = .didLoad
					self.subscribeTitleTextLabel.text = model.productName
					self.subscribePriceTextLabel.text = model.productPrice
				} else {
					self.actionButtonHandler(for: .disabled)
					self.statusSubscriptionLoaded = .empty
				}
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
	
	private func setupUI() {
		
		self.trailingStackView.isHidden = true
		self.subscribeSubtitleTextLabel.isHidden = true
		self.subscribePriceInfoTextLabel.isHidden = true
		
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

		let colors = theme.getColorsGradient(for: .lifetime).compactMap({$0.cgColor})
		crownImageView.image = Images.subsctiption.crown?.tintedWithLinearGradientColors(colorsArr: colors.reversed())
		crownImageView.contentMode = .scaleAspectFit
	}
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
		mainContainerView.backgroundColor = theme.backgroundColor
		
		
		topShevronView.backgroundColor = theme.subTitleTextColor
		titleTextLabel.textColor = theme.titleTextColor
		
		let colors = theme.onboardingButtonColors.compactMap({$0.cgColor})
		actionButtonContainerView.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colors: colors, type: .axial)
		
		
		subscribeTitleTextLabel.textColor = theme.activeTitleTextColor
		subscribeSubtitleTextLabel.textColor = theme.activeTitleTextColor
		subscribePriceTextLabel.textColor = theme.activeTitleTextColor
		subscribePriceInfoTextLabel.textColor = theme.activeTitleTextColor
	}
}
