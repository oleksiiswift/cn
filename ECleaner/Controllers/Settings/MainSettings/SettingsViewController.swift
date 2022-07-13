//
//  SettingsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.02.2022.
//

import UIKit
import SwiftMessages

class SettingsViewController: UIViewController, Storyboarded {
	
	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var tableView: UITableView!
	
	weak var coordinator: ApplicationCoordinator?
	private var subscriptionManager = SubscriptionManager.instance
	
	private var settingsViewModel: SettingsViewModel!
	private var settingsDataSource: SettingsDataSource!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViewModel()
		setupNavigation()
		setupTableView()
		setupDelegate()
		updateColors()
		addSubscriptionChangeObserver()
    }
		
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		 switch segue.identifier {
			 case C.identifiers.segue.showSizeSelector:
				 self.setupShowVideoSizeSelectorController(segue: segue)
			 case C.identifiers.segue.lifeTime:
				 self.setupShowLifeTimeSubscriptionController(segue: segue)
			  default:
				   break
		 }
	}
}

extension SettingsViewController: SubscriptionObserver {
	
	func subscriptionDidChange() {
	
		Utils.delay(0.3) {
			self.setupViewModel()
			self.tableView.delegate = self.settingsDataSource
			self.tableView.dataSource = self.settingsDataSource
			self.tableView.reloadDataWithoutAnimation()
		}
	}
}

extension SettingsViewController {
	
	private func setupViewModel() {
		
		let premiumSectionCell = SettingsSection(cells: [.premium])
		let subscriptionSection = SettingsSection(cells: [.restore, .lifetime], headetHeight: 20)
		let lifeTimeSection = SettingsSection(cells: [.lifetime], headetHeight: 20)
		
		let permissionSectionCell = SettingsSection(cells: [.largeVideos,
														 .permissions],
													headerTitle: Localization.Main.HeaderTitle.system,
												 headetHeight: 20)
		
		let supportSectionCells = SettingsSection(cells: [.support,
														 .share,
														 .rate,
														 .privacypolicy,
														 .termsOfUse],
												  headerTitle: Localization.Main.HeaderTitle.termsSupport,
												 headetHeight: 20)

		var sections: [SettingsSection] {
			if self.subscriptionManager.purchasePremiumHandler() {
				if self.subscriptionManager.isLifeTimeSubscription() {
					return [premiumSectionCell, permissionSectionCell, supportSectionCells]
				} else {
					return [premiumSectionCell,lifeTimeSection, permissionSectionCell, supportSectionCells]
				}
			} else {
				return [premiumSectionCell, subscriptionSection, permissionSectionCell, supportSectionCells]
			}
		}
		
		self.settingsViewModel = SettingsViewModel(sections: sections)
		self.settingsDataSource = SettingsDataSource(settingsViewModel: self.settingsViewModel)
		
		self.settingsDataSource.didSelectedSettings = { settingModel in
			
			if settingModel == .premium {
				if self.subscriptionManager.purchasePremiumHandler() {
					self.changeCurrentSubscription()
				}
			}
		}
	}
}

extension SettingsViewController {
	
	private func setupNavigation() {
		
		navigationBar.setupNavigation(title: settingsViewModel.controllerTitle,
									  leftBarButtonImage: I.systemItems.navigationBarItems.back,
									  rightBarButtonImage: nil,
									  contentType: .none,
									  leftButtonTitle: nil,
									  rightButtonTitle: nil)
	}
	
	private func setupTableView() {
		
		self.tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
		self.tableView.register(UINib(nibName: C.identifiers.xibs.currentSubscription, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.currentSubscription)
		self.tableView.register(UINib(nibName: C.identifiers.xibs.premiumFeaturesSubcription, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.premiumFeaturesSubcription)
	
		self.tableView.delegate = settingsDataSource
		self.tableView.dataSource = settingsDataSource
		
		self.tableView.separatorStyle = .none
		let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: U.screenWidth, height: 20)))
		view.backgroundColor = .clear
		self.tableView.tableHeaderView = view
	}
	
	private func setupDelegate() {
		
		navigationBar.delegate = self
		settingsDataSource.delegate = self
	}
}

extension SettingsViewController: Themeble {
	
	func setupUI() {
		
		if !U.hasTopNotch {
			self.tableView.contentInset.bottom = 20
		}
	}
	
	func updateColors() {
		self.view.backgroundColor = theme.backgroundColor
		self.tableView.backgroundColor = .clear
	}
}

extension SettingsViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func didTapRightBarButton(_ sender: UIButton) {}
}


extension SettingsViewController {
	
	
	private func setupShowVideoSizeSelectorController(segue: UIStoryboardSegue) {
		
		guard let segue = segue as? SwiftMessagesSegue else { return }
		
		segue.configure(layout: .bottomMessage)
		segue.dimMode = .gray(interactive: false)
		segue.interactiveHide = false
		segue.messageView.configureNoDropShadow()
		segue.messageView.backgroundHeight = Device.isSafeAreaiPhone ? 358 : 338
		
		if let destinationViewController = segue.destination as? VideoSpaceSelectorViewController {
			
		}
	}
	
	private func setupShowLifeTimeSubscriptionController(segue: UIStoryboardSegue) {
		
		guard let segue = segue as? SwiftMessagesSegue else { return }
		
		segue.configure(layout: .bottomMessage)
		segue.dimMode = .gray(interactive: true)
		segue.interactiveHide = true
		segue.messageView.configureNoDropShadow()
		
		segue.messageView.backgroundHeight = AppDimensions.Subscription.Features.lifeTimeConttolerHeigh
	}
}

extension SettingsViewController: SettingActionsDelegate {
	
	public func setAction(at cell: SettingsModel) {
		switch cell {
			case .premium:
				subscriptionManager.purchasePremiumHandler() ? self.changeCurrentSubscription() : self.showPremiumController()
			case .largeVideos:
				self.showLargeVideoSettings()
			case .dataStorage:
				self.showDataStorageInfo()
			case .permissions:
				self.showPermissionController()
			case .lifetime:
				self.showLifeTimeSubscription()
			case .restore:
				self.showRestorePurchaseAction()
			case .support:
				self.showSupportAction()
			case .share:
				self.showShareAppAction()
			case .rate:
				self.showRateUSAction()
			case .privacypolicy:
				self.showPrivacyPolicyAction()
			case .termsOfUse:
				self.showTermsOfUseAction()
			default:
				return
		}
	}
	
	private func changeCurrentSubscription() {
	
		Network.theyLive { isAlive in
			if isAlive {
				self.subscriptionManager.changeCurrentSubscription()
			} else {
				ErrorHandler.shared.showNetworkErrorAlert(.networkError, at: self)
			}
		}
	}
	
	private func showPremiumController() {
		UIPresenter.showViewController(of: .subscription)
	}
	
	private func showLargeVideoSettings() {
		
		performSegue(withIdentifier: C.identifiers.segue.showSizeSelector, sender: self)
	}
	
	private func showDataStorageInfo() {
		debugPrint("showDataStorageInfo")
	}
	
	private func showPermissionController() {
		self.coordinator?.showPermissionViewController(from: self.navigationController)
	}
	
	private func showLifeTimeSubscription() {
		performSegue(withIdentifier: Constants.identifiers.segue.lifeTime, sender: self)
	}
	
	private func showRestorePurchaseAction() {
	
		Network.theyLive { isAlive in
			if isAlive {
				UIPresenter.showIndicator(in: self)
				self.subscriptionManager.restorePurchase { restored, requested, date in
					
					UIPresenter.hideIndicator()
					
					guard requested else { return }
					
					if !restored {
						if let date = date {
							let dateString = Utils.getString(from: date, format: Constants.dateFormat.expiredDateFormat)
							ErrorHandler.shared.showSubsriptionAlertError(for: .restoreError, at: self, expreDate: dateString)
						} else {
							ErrorHandler.shared.showSubsriptionAlertError(for: .restoreError, at: self)
						}
					}
				}
			} else {
				ErrorHandler.shared.showNetworkErrorAlert(.networkError, at: self)
			}
		}
	}
	
	private func showSupportAction() {
		debugPrint("showSupportAction")
	}
	
	private func showShareAppAction() {
		debugPrint("showShareAppAction")
	}
	
	private func showRateUSAction() {
		debugPrint("showRateUSAction")
	}
	
	private func showPrivacyPolicyAction() {
		debugPrint("showPrivacyPolicyAction")
	}
	
	private func showTermsOfUseAction() {
		debugPrint("showTermsOfUseAction")
	}
}

extension SettingsViewController {
	
	private func showWebView(with url: URL) {
		
		Network.theyLive { isAlive in
			
			
		}
	}
}



