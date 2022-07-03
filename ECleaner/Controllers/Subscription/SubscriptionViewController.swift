//
//  SubscriptionViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.07.2022.
//

import UIKit

class SubscriptionViewController: UIViewController, Storyboarded {
	
	@IBOutlet weak var backgroundView: UIView!
	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet weak var navigationBar: PremiumNavigationBar!
	@IBOutlet weak var dimmerView: UIView!
	@IBOutlet weak var titleContainerView: UIView!
	@IBOutlet weak var featuresContainerView: UIView!
	@IBOutlet weak var subscriptionItemsContainerView: UIView!
	@IBOutlet weak var subcribeContainerView: BottomButtonBarView!
	@IBOutlet weak var linksContainerView: UIView!
	@IBOutlet weak var infoContainerView: UIView!
	
	@IBOutlet weak var dimmerVewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var featuresContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var subscriptionItemsContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var subscribeContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var linksContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var backggroundImageViewTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var backgroundImageViewLeadingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var termsOfUseButton: UIButton!
	@IBOutlet weak var policyButton: UIButton!
	
	@IBOutlet weak var topTitlteTextLabel: TitleLabel!
	@IBOutlet weak var bottomTitleTextLabel: TitleLabel!
	
	@IBOutlet weak var termsTitleTextLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	private var premiumFeaturesViewModel: PremiumFeaturesViewModel!
	private var premiumFeaturesDataSource: PremiumFeutureDataSource!
	
	private var premiumViewModel: PremiumViewModel!
	private var premiumDataSource: PremiumDataSource!
	
	var coordinator: ApplicationCoordinator?
	
	override public var preferredStatusBarStyle: UIStatusBarStyle {
		return .darkContent
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupLayout()
		setupUI()
		setupNavigation()
		setupTitle()
		setupPremiumViewModel()
		setupPremiumFeautiresViewModel()
		setupTableView()
		setupCollectionView()
		updateColors()
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
		
	}
}


extension SubscriptionViewController: PremiumNavigationBarDelegate {
	
	func didTapLeftBarButton(_sender: UIButton) {
		debugPrint("restore")
	}
	
	func didTapRightBarButton(_sender: UIButton) {
		if coordinator?.currentState == .onboarding {
			coordinator?.currentState = .application
			UIPresenter.closePresentedWindow()
		} else {
			UIPresenter.closePresentedWindow()
		}
	}
}

extension SubscriptionViewController {
	
	private func setupTitle() {
		
		let titleString = Localization.Subscription.Main.getPremium.components(separatedBy: " ")
		let first = titleString.first
		let second = titleString.last
		
		let firstColor = [UIColor().colorFromHexString("FF685C"), UIColor().colorFromHexString("764040")]
		let secondColor = [UIColor().colorFromHexString("687EAF"), UIColor().colorFromHexString("47526B")]
	
		if let topTitle = first {
			topTitlteTextLabel.contentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
			topTitlteTextLabel.addGradientText(string: topTitle, with: firstColor, font: FontManager.subscriptionFont(of: .title))
		}
		
		if let bottomTitle = second {
			bottomTitleTextLabel.contentInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
			bottomTitleTextLabel.addGradientText(string: bottomTitle, with: secondColor, font: FontManager.subscriptionFont(of: .title))
		}
	}
	
	private func setupPremiumFeautiresViewModel() {
		
		let features = PremiumFeature.allCases
		self.premiumFeaturesViewModel = PremiumFeaturesViewModel(features: features)
		self.premiumFeaturesDataSource = PremiumFeutureDataSource(premiumFeaturesViewModel: self.premiumFeaturesViewModel)
		self.tableView.dataSource = self.premiumFeaturesDataSource
		self.tableView.delegate = self.premiumFeaturesDataSource
	}
	
	private func setupPremiumViewModel() {
		
		let premium = Premium.allCases
		self.premiumViewModel = PremiumViewModel(premium: premium)
		self.premiumDataSource = PremiumDataSource(premiumViewModel: premiumViewModel)
		self.collectionView.dataSource = self.premiumDataSource
		self.collectionView.delegate = self.premiumDataSource
	}
}


extension SubscriptionViewController: Themeble {
	
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
	
	private func setupCollectionView() {
		self.collectionView.register(UINib(nibName: "PremiumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PremiumCollectionViewCell")
		
	}
	
	
	private func setupUI() {
		
		backgroundImageView.image = Images.subsctiption.rocket
		
		subcribeContainerView.delegate = self
		subcribeContainerView.setButtonSideOffset(20)
		subcribeContainerView.title(LocalizationService.Buttons.getButtonTitle(of: .activate).uppercased())
		termsOfUseButton.setTitle("terms of user", for: .normal)
		policyButton.setTitle("Privacy policy", for: .normal)
	}
	
	
	func updateColors() {
		
		self.view.backgroundColor = .clear
		self.backgroundView.backgroundColor = theme.backgroundColor
		
		subcribeContainerView.configureShadow = true
		subcribeContainerView.addButtonShadow()
		subcribeContainerView.addButtonGradientBackground(colors: theme.onboardingButtonColors)
		subcribeContainerView.buttonTintColor = theme.activeTitleTextColor
		subcribeContainerView.updateColorsSettings()
		termsTitleTextLabel.textColor = theme.featureTitleTextColor
		termsTitleTextLabel.font = FontManager.subscriptionFont(of: .helperText)
	}
}

extension SubscriptionViewController {
	
	
	private func setupLayout() {
		
		switch Screen.size {
				
			case .small:
				dimmerVewHeightConstraint.constant = 137
			case .medium:
				dimmerVewHeightConstraint.constant = 137
			case .plus:
				dimmerVewHeightConstraint.constant = 137
			case .large:
				
				
				
				backggroundImageViewTopConstraint.constant = -130
				backgroundImageViewLeadingConstraint.constant = -60
				
				dimmerVewHeightConstraint.constant = 137
			case .modern:
				dimmerVewHeightConstraint.constant = 137
			case .max:
				dimmerVewHeightConstraint.constant = 137
			case .madMax:
				dimmerVewHeightConstraint.constant = 137
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
		
		let gradientColors = colors.compactMap({$0.cgColor})
		let gradeintLayer = Utils.Manager.getGradientLayer(bounds: self.bounds, colors: gradientColors, startPoint: .topLeft, endPoint: .bottomRight)
		let gradientColor = Utils.Manager.gradientColor(bounds: self.bounds, gradientLayer: gradeintLayer)
		let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: gradientColor!]
		self.attributedText = NSMutableAttributedString(string: string, attributes: attributes)
	}
}
