//
//  SubscriptionViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.07.2022.
//

import UIKit

class SubscriptionViewController: UIViewController, Storyboarded {
	
	@IBOutlet weak var navigationBar: PremiumNavigationBar!
	@IBOutlet weak var dimmerView: UIView!
	@IBOutlet weak var titleContainerView: UIView!
	@IBOutlet weak var featuresContainerView: UIView!
	@IBOutlet weak var subscriptionItemsContainerView: UIView!
	@IBOutlet weak var subcribeContainerView: UIView!
	@IBOutlet weak var linksContainerView: UIView!
	@IBOutlet weak var infoContainerView: UIView!
	
	@IBOutlet weak var titleContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var featuresContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var subscriptionItemsContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var subscribeContainerMultiplyerHeightConstraint: UIView!
	@IBOutlet weak var linksContainerMultiplyerHeightConstraint: NSLayoutConstraint!
	
	
	
	
	@IBOutlet weak var titleTextLabel: UILabel!
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	private var premiumFeaturesViewModel: PremiumFeaturesViewModel!
	private var premiumFeaturesDataSource: PremiumFeutureDataSource!
	
	var coordinator: ApplicationCoordinator?
	
	override public var preferredStatusBarStyle: UIStatusBarStyle {
		return .darkContent
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		setupNavigation()
		setupTitle()
		setupPremiumFeautiresViewModel()
		setupTableView()
		updateColors()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}

}


extension SubscriptionViewController: PremiumNavigationBarDelegate {
	
	func didTapLeftBarButton(_sender: UIButton) {
		debugPrint("restore")
	}
	
	func didTapRightBarButton(_sender: UIButton) {
		debugPrint("close")
	}
}

extension SubscriptionViewController {
	
	private func setupTitle() {
		
		titleTextLabel.text = "Get \n Premium"
		titleTextLabel.font = .systemFont(ofSize: 38, weight: .bold)
	}
	
	private func setupPremiumFeautiresViewModel() {
		
		let features = PremiumFeature.allCases
		self.premiumFeaturesViewModel = PremiumFeaturesViewModel(features: features)
		self.premiumFeaturesDataSource = PremiumFeutureDataSource(premiumFeaturesViewModel: self.premiumFeaturesViewModel)
		self.tableView.dataSource = self.premiumFeaturesDataSource
		self.tableView.delegate = self.premiumFeaturesDataSource
	}
}


extension SubscriptionViewController: Themeble {
	
	func setupNavigation() {
		
			navigationBar.delegate = self
			navigationBar.setUpNavigation(lefTitle: "Restore", leftImage: I.systemItems.defaultItems.circleArrow, rightImage: I.systemItems.navigationBarItems.dissmiss)
			navigationBar.configureLeftButtonAppearance(tintColor: theme.navigationBarButtonTintColor, textColor: theme.navigationBarButtonTintColor, font: .systemFont(ofSize: 12, weight: .medium))
			navigationBar.configureRightButtonAppearance(tintColor: theme.navigationBarButtonTintColor)
	}
	
	func setupTableView() {
		
		self.tableView.register(UINib(nibName: "PremiumFeatureTableViewCell", bundle: nil), forCellReuseIdentifier: "PremiumFeatureTableViewCell")
		self.tableView.separatorStyle = .none
		self.tableView.alwaysBounceVertical = false
	}
	
	func setupCollectionView() {
		
	}
	
	
	func updateColors() {
		

	}
}
