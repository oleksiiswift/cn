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
	
	@IBOutlet weak var bottomContainerView: UIView!
	@IBOutlet weak var actionButtonContainerView: UIView!
	@IBOutlet weak var actionButtonContainerStackView: UIStackView!
	@IBOutlet weak var actionButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var actionButton: UIButton!
	
	@IBOutlet weak var subscribeTitleTextLabel: UILabel!
	@IBOutlet weak var subscribeSubtitleTextLabel: UILabel!
	@IBOutlet weak var subscribePriceTextLabel: UILabel!
	@IBOutlet weak var subscribePriceInfoTextLabel: UILabel!
	@IBOutlet weak var actionButtonContainerViewWidthConstraint: NSLayoutConstraint!
	
	private let buttonShadow = ReuseShadowView()
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
		self.buttonShadow.animateButtonTransform()
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
		crownImageView.image = I.systemItems.navigationBarItems.premium
		crownImageView.contentMode = .scaleAspectFit
		crownImageView.setupForShadow(shadowColor: theme.bottomShadowColor, cornerRadius: 14, shadowOffcet: CGSize(width: 3, height: 3), shadowOpacity: 10, shadowRadius: 14)
	}
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
		mainContainerView.backgroundColor = theme.backgroundColor
		
		
		topShevronView.backgroundColor = theme.subTitleTextColor
		titleTextLabel.textColor = theme.titleTextColor
		
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
}


extension UIImage {
	/// Returns a new image with the specified shadow properties.
	/// This will increase the size of the image to fit the shadow and the original image.
	func withShadow(blur: CGFloat = 6, offset: CGSize = .zero, color: UIColor = UIColor(white: 0, alpha: 0.8)) -> UIImage {

		let shadowRect = CGRect(
			x: offset.width - blur,
			y: offset.height - blur,
			width: size.width + blur * 2,
			height: size.height + blur * 2
		)
		
		UIGraphicsBeginImageContextWithOptions(
			CGSize(
				width: max(shadowRect.maxX, size.width) - min(shadowRect.minX, 0),
				height: max(shadowRect.maxY, size.height) - min(shadowRect.minY, 0)
			),
			false, 0
		)
		
		let context = UIGraphicsGetCurrentContext()!

		context.setShadow(
			offset: offset,
			blur: blur,
			color: color.cgColor
		)
		
		draw(
			in: CGRect(
				x: max(0, -shadowRect.origin.x),
				y: max(0, -shadowRect.origin.y),
				width: size.width,
				height: size.height
			)
		)
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		
		UIGraphicsEndImageContext()
		return image
	}
}
