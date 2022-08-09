//
//  SubscriptionViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.07.2022.
//

import UIKit

enum SubscriptionActionProcessingState {
	case processing
	case active
	case disabled
}

class SubscriptionViewController: UIViewController, Storyboarded {
	
	@IBOutlet weak var backgroundView: UIView!
	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet weak var premiumImageView: UIImageView!
	@IBOutlet weak var navigationBar: PremiumNavigationBar!
	@IBOutlet weak var dimmerView: UIView!
	@IBOutlet weak var titleContainerView: UIView!
	@IBOutlet weak var featuresContainerView: UIView!
	@IBOutlet weak var subscriptionItemsContainerView: UIView!
	@IBOutlet weak var subscribeContainerView: BottomButtonBarView!
	@IBOutlet weak var linksContainerView: UIView!
	@IBOutlet weak var infoContainerView: UIView!
	
	@IBOutlet weak var dimmerVewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var featuresContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var subscriptionItemsContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var subscribeContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var linksContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var titleStackContainerTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleStackContainerBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var backgroundImageViewTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var backgroundImageViewLeadingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var termsOfUseButton: UIButton!
	@IBOutlet weak var policyButton: UIButton!
	
	@IBOutlet weak var topTitlteTextLabel: TitleLabel!
	@IBOutlet weak var bottomTitleTextLabel: TitleLabel!
	
	@IBOutlet weak var termsTitleTextLabel: TitleLabel!
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var segmentControll: SubscriptionSegmentControll!
	
	private var premiumFeaturesViewModel: PremiumFeaturesViewModel!
	private var premiumFeaturesDataSource: PremiumFeutureDataSource!

	var coordinator: ApplicationCoordinator?
	
	private var subscriptionManager =  SubscriptionManager.instance
	private var currentSubscription: Subscriptions = .year
	private var statusSegmentLoaded: SubscriptionSegmentStatus = .willLoading
	
	override public var preferredStatusBarStyle: UIStatusBarStyle {
		return .darkContent
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupLayout()
		loadSubscriptionProducts()
		setupUI()
		setupNavigation()
		setupTitle()
		setupPremiumFeautiresViewModel()
		setupTableView()
		updateColors()
		setupObserver()
		setupDelegate()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	@IBAction func didTapShowPrivacyActionButton(_ sender: Any) {
		
	}
	
	@IBAction func didTapShowTermsActionButton(_ sender: Any) {
		
	}
}

extension SubscriptionViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		
		guard statusSegmentLoaded != .disable else { return }
		
		self.purchaseProcessingHandler(for: .processing)
		
		Network.theyLive { status in
			switch status {
				case .connedcted:
					self.didTapPurchasePremium()
				case .unreachable:
					ErrorHandler.shared.showNetworkErrorAlert(.networkError, at: self)
					self.purchaseProcessingHandler(for: .active)
			}
		}
	}
}

extension SubscriptionViewController {
	
	private func didTapPurchasePremium() {
		self.subscriptionManager.purchasePremium(of: self.currentSubscription) { purchased in
			self.purchaseProcessingHandler(for: .active)
			if purchased {
				self.closeSubscriptionController()
			} else {
				ErrorHandler.shared.showSubsriptionAlertError(for: .purchaseError, at: self)
			}
		}
	}
	
	private func didTapRestorePurchase() {
		
		self.subscriptionManager.restorePurchase { restored, requested, date in
			
			self.setLeftButtonAnimateButton(status: .stop)
			self.restoreProcessingHandler(for: .active)
		
			guard requested else { return }
			
			if !restored {
				if let date = date {
					let dateString = Utils.getString(from: date, format: Constants.dateFormat.expiredDateFormat)
					ErrorHandler.shared.showSubsriptionAlertError(for: .restoreError, at: self, expreDate: dateString)
				} else {
					ErrorHandler.shared.showSubsriptionAlertError(for: .restoreError, at: self)
				}
			} else {
				self.closeSubscriptionController()
			}
		}
	}
		
	private func loadSubscriptionProducts() {
		
		self.segmentControll.setSegment(status: .willLoading)
		
		Network.theyLive { status in
			Utils.UI {
				switch status {
					case .connedcted:
						self.tryLoadingProducts { status in
							self.statusSegmentLoaded = status
							self.segmentControll.setSegment(status: status)
							self.subscribeContainerView.setLockButtonAnimate(state: .active)
						}
					case .unreachable:
						self.segmentControll.setSegment(status: .disable)
						self.subscribeContainerView.setLockButtonAnimate(state: .disabled)
						self.statusSegmentLoaded = .disable
				}
			}
		}
	}
	
	private func tryLoadingProducts(completionHandler: @escaping (_ status: SubscriptionSegmentStatus) -> Void) {
		
		subscriptionManager.descriptionModel { model in
			
			var currentModel = model
			if let monthlyIndex = model.firstIndex(where: {$0.id == Subscriptions.month.rawValue}) {
				currentModel.move(from: monthlyIndex, to: 0)
			}
			
			if let yearlyIndex = model.firstIndex(where: {$0.id == Subscriptions.year.rawValue}) {
				currentModel.move(from: yearlyIndex, to: 1)
			}
			
			if model.isEmpty {
				completionHandler(.empty)
				Utils.delay(1) {
					self.loadSubscriptionProducts()
				}
			} else {
				self.segmentControll.setSubscription(subscriptions: currentModel)
				self.setupSubscriptionSegment()
				completionHandler(.didLoad)
				self.selectPriorytySubscription()
			}
		}
	}

	private func selectPriorytySubscription() {
		
		guard segmentControll.subscriptions != nil else { return }
		
		if let index = segmentControll.subscriptions.firstIndex(where: {$0.id == self.currentSubscription.rawValue}) {
			segmentControll.setupDefaultIndex(index: index)
		}
	}
	
	private func closeSubscriptionController() {
		Utils.UI {
			if self.coordinator?.currentState == .onboarding || self.coordinator?.currentState == .subscription {
				self.coordinator?.currentState = .application
				UIPresenter.closePresentedWindow()
			} else {
				UIPresenter.closePresentedWindow()
			}
		}
	}
	
	@objc func networkStatusDidChange() {
		loadSubscriptionProducts()
	}
}

extension SubscriptionViewController {
	
	private func restoreProcessingHandler(for state: SubscriptionActionProcessingState) {
		
		setActionButtonProcessingFor(state: state)
		Utils.UI {
			self.subscribeContainerView.actionButton.isEnabled = state == .active
		}
	}
	
	private func purchaseProcessingHandler(for state: SubscriptionActionProcessingState) {
		
		self.subscribeContainerView.setLockButtonAnimate(state: state)
		self.setActionButtonProcessingFor(state: state)
	}
	
	private func setActionButtonProcessingFor(state: SubscriptionActionProcessingState) {
		Utils.UI {
			self.navigationBar.leftBarButton.isEnabled = state == .active
			self.navigationBar.rightBarButton.isEnabled = state == .active
			self.termsOfUseButton.isEnabled = state == .active
			self.policyButton.isEnabled = state == .active
		}
	}
}

extension SubscriptionViewController: PremiumNavigationBarDelegate {
	
	func didTapLeftBarButton(_sender: UIButton) {
		
		self.setLeftButtonAnimateButton(status: .start)
		self.restoreProcessingHandler(for: .processing)
		
		Network.theyLive { status in
			switch status {
				case .connedcted:
					self.didTapRestorePurchase()
				case .unreachable:
					ErrorHandler.shared.showNetworkErrorAlert(.networkError, at: self)
					self.setLeftButtonAnimateButton(status: .stop)
					self.restoreProcessingHandler(for: .active)
			}
		}
	}
	
	func didTapRightBarButton(_sender: UIButton) {
		self.closeSubscriptionController()
	}
}

extension SubscriptionViewController {
	
	private func setupSubscriptionSegment() {
		
   		segmentControll.configureSelectableGradient(width: 3, colors: theme.subscribeGradientColors, startPoint: .top, endPoint: .bottom, cornerRadius: 12)
		segmentControll.setFont(title: FontManager.subscriptionFont(of: .buttonTitle),
								price: nil,
								description: FontManager.subscriptionFont(of: .buttonDescription))
		segmentControll.setTextColorForTitle(theme.subscribeTitleTextColor)
		segmentControll.setTextGradientColorsforPrice(theme.subscribeGradientColors, font: FontManager.subscriptionFont(of: .buttonPrice))
		segmentControll.setTextColorForSubtitle(theme.subscribeDescriptionTextColor)
	}
	
	private func setupTitle() {
		
		let titleString = Localization.Subscription.Main.getPremium.components(separatedBy: " ")
		let first = titleString.first
		let second = titleString.last
			
		if let topTitle = first {
			topTitlteTextLabel.font = FontManager.subscriptionFont(of: .title)
			topTitlteTextLabel.textColor = theme.premiumColor
			topTitlteTextLabel.text = topTitle
		}
		
		if let bottomTitle = second {
			bottomTitleTextLabel.font = FontManager.subscriptionFont(of: .title)
			bottomTitleTextLabel.textColor = theme.titleTextColor
			bottomTitleTextLabel.text = bottomTitle
		}
	}
	
	private func setLeftButtonAnimateButton(status: AnimationStatus) {
		navigationBar.setLeftButton(animation: status)
	}
	
	private func setupPremiumFeautiresViewModel() {
		
		let features = PremiumFeature.allCases
		self.premiumFeaturesViewModel = PremiumFeaturesViewModel(features: features)
		self.premiumFeaturesDataSource = PremiumFeutureDataSource(premiumFeaturesViewModel: self.premiumFeaturesViewModel)
		self.tableView.dataSource = self.premiumFeaturesDataSource
		self.tableView.delegate = self.premiumFeaturesDataSource
	}
}

extension SubscriptionViewController: SubscriptionSegmentControllDelegate {
	
	func didChange(to subscription: Subscriptions) {
		self.currentSubscription = subscription
	}
}

extension SubscriptionViewController: Themeble {
	
	private func setupObserver() {
		
		U.notificationCenter.addObserver(self, selector: #selector(networkStatusDidChange), name: .ConnectivityDidChange, object: nil)
	}
	
	private func setupDelegate() {
		
		segmentControll.delegate = self
	}
	
	private func setupNavigation() {
		
		navigationBar.delegate = self
		navigationBar.setUpNavigation(lefTitle: LocalizationService.Buttons.getButtonTitle(of: .restore),
									  leftImage: I.systemItems.defaultItems.circleArrow,
									  rightImage: I.systemItems.navigationBarItems.dissmiss)
		navigationBar.configureLeftButtonAppearance(tintColor: theme.navigationBarButtonTintColor,
													textColor: theme.navigationBarButtonTintColor,
													font: .systemFont(ofSize: 12, weight: .medium))
		navigationBar.configureRightButtonAppearance(tintColor: theme.navigationBarButtonTintColor)
	}
	
	private func setupTableView() {
		
		self.tableView.register(UINib(nibName: Constants.identifiers.xibs.premiumFeature, bundle: nil), forCellReuseIdentifier: Constants.identifiers.cells.premiumFeature)
		self.tableView.separatorStyle = .none
		self.tableView.alwaysBounceVertical = false
	}
	
	private func setupUI() {
		
		premiumImageView.isHidden = true
		backgroundImageView.image = Images.subsctiption.rocket
		
		subscribeContainerView.delegate = self
		subscribeContainerView.setButtonSideOffset(25)
		subscribeContainerView.title(LocalizationService.Buttons.getButtonTitle(of: .activate).uppercased())
		termsOfUseButton.setTitle(Localization.Subscription.Helper.termsOfUse, for: .normal)
		termsOfUseButton.titleLabel?.font = FontManager.subscriptionFont(of: .links)
		policyButton.setTitle(Localization.Subscription.Helper.privicy, for: .normal)
		policyButton.titleLabel?.font = FontManager.subscriptionFont(of: .links)
		
		switch Screen.size {
			case .small:
				termsTitleTextLabel.contentInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
			default:
				termsTitleTextLabel.contentInsets = .init(top: -10, left: 5, bottom: 0, right: 5)
		}
	}
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
		self.backgroundView.backgroundColor = theme.backgroundColor
		
		subscribeContainerView.configureShadow = true
		subscribeContainerView.addButtonShadow()
		subscribeContainerView.addButtonGradientBackground(colors: theme.onboardingButtonColors)
		subscribeContainerView.buttonTintColor = theme.activeTitleTextColor
		subscribeContainerView.updateColorsSettings()
		termsTitleTextLabel.textColor = theme.featureTitleTextColor
		termsTitleTextLabel.font = FontManager.subscriptionFont(of: .helperText)
		
		termsOfUseButton.setTitleColor(theme.subTitleTextColor, for: .normal)
		policyButton.setTitleColor(theme.subTitleTextColor, for: .normal)
		
		policyButton.underline()
		termsOfUseButton.underline()
		
		self.segmentControll.configureSelectableGradient(width: 3, colors: theme.subscribeGradientColors, startPoint: .top, endPoint: .bottom, cornerRadius: 12)
	}
}

extension SubscriptionViewController {
	
	private func setupLayout() {
		
		switch Screen.size {
				
			case .small:
				dimmerVewHeightConstraint.constant = 85
				titleContainerMultiplyerHeightConstraint = titleContainerMultiplyerHeightConstraint.setMultiplier(multiplier: 0.8)
				subscribeContainerMultiplyerHeightConstraint = subscribeContainerMultiplyerHeightConstraint.setMultiplier(multiplier: 0.7)
				subscriptionItemsContainerMultiplyerHeightConstraint = subscriptionItemsContainerMultiplyerHeightConstraint.setMultiplier(multiplier: 1.5)
				
				titleStackContainerBottomConstraint.constant = -10
				titleStackContainerTopConstraint.constant = 0
				
				backgroundImageViewTopConstraint.constant = -180
				backgroundImageViewLeadingConstraint.constant = -60
			case .medium:
				dimmerVewHeightConstraint.constant = 103
				titleContainerMultiplyerHeightConstraint = titleContainerMultiplyerHeightConstraint.setMultiplier(multiplier: 0.8)
				subscribeContainerMultiplyerHeightConstraint = subscribeContainerMultiplyerHeightConstraint.setMultiplier(multiplier: 0.6)
				subscriptionItemsContainerMultiplyerHeightConstraint = subscriptionItemsContainerMultiplyerHeightConstraint.setMultiplier(multiplier: 1.4)
				
				titleStackContainerBottomConstraint.constant = -10
				titleStackContainerTopConstraint.constant = 0
				
				backgroundImageViewTopConstraint.constant = -240
				backgroundImageViewLeadingConstraint.constant = -90
			case .plus:
				dimmerVewHeightConstraint.constant = 120
				subscriptionItemsContainerMultiplyerHeightConstraint = subscriptionItemsContainerMultiplyerHeightConstraint.setMultiplier(multiplier: 1.3)
				backgroundImageViewTopConstraint.constant = -260
				backgroundImageViewLeadingConstraint.constant = -100
			case .large:
				dimmerVewHeightConstraint.constant = 135
				
				backgroundImageViewTopConstraint.constant = -170
				backgroundImageViewLeadingConstraint.constant = -80
			case .modern:
				dimmerVewHeightConstraint.constant = 140
				
				backgroundImageViewTopConstraint.constant = -190
				backgroundImageViewLeadingConstraint.constant = -90
			case .max:
				dimmerVewHeightConstraint.constant = 153
				
				backgroundImageViewTopConstraint.constant = -195
				backgroundImageViewLeadingConstraint.constant = -100
				
			case .madMax:
				dimmerVewHeightConstraint.constant = 155
				
				backgroundImageViewTopConstraint.constant = -200
				backgroundImageViewLeadingConstraint.constant = -100
		}
	}
}

class TitleLabel: UILabel {

	var contentInsets = UIEdgeInsets.zero

	override func drawText(in rect: CGRect) {
		let insetRect = rect.inset(by: contentInsets)
		
		super.drawText(in: insetRect)
	}

	override var intrinsicContentSize: CGSize {
		return addInsets(to: super.intrinsicContentSize)
	}

	override func sizeThatFits(_ size: CGSize) -> CGSize {
		return addInsets(to: super.sizeThatFits(size))
	}

	private func addInsets(to size: CGSize) -> CGSize {
		let width = size.width + contentInsets.left + contentInsets.right
		let height = size.height + contentInsets.top + contentInsets.bottom
		return CGSize(width: width, height: height)
	}
	
	public func addGradientText(string: String, with colors: [UIColor], font: UIFont) {
		
		guard self.bounds != .zero else { return }
		
		let gradientColors = colors.compactMap({$0.cgColor})
		let gradeintLayer = Utils.Manager.getGradientLayer(bounds: self.bounds, colors: gradientColors, startPoint: .topLeft, endPoint: .bottomRight)
		let gradientColor = Utils.Manager.gradientColor(bounds: self.bounds, gradientLayer: gradeintLayer)
		let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: gradientColor!]
		self.attributedText = NSMutableAttributedString(string: string, attributes: attributes)
	}
}
