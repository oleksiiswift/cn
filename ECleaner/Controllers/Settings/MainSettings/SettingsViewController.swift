//
//  SettingsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.02.2022.
//

import UIKit
import SwiftMessages

class SettingsViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var tableView: UITableView!
	
	private var settingsViewModel: SettingsViewModel!
	private var settingsDataSource: SettingsDataSource!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setupViewModel()
		setupNavigation()
		setupTableView()
		setupDelegate()
		updateColors()
    }
		
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		 switch segue.identifier {
			 case C.identifiers.segue.showSizeSelector:
				 self.setupShowVideoSizeSelectorController(segue: segue)
			  default:
				   break
		 }
	}
}

extension SettingsViewController {
	
	private func setupViewModel() {
		
		let firstSectionCells =  SettingsSection(cells: [.premium])
		let secondSectionCells = SettingsSection(cells: [.restore], headetHeight: 40)
		
		let thirdSectionsCells = SettingsSection(cells: [.largeVideos,
														 .dataStorage,
														 .permissions],
												 headerTitle: "settings one sections title",
												 headetHeight: 40)
		
		let fouthSectionsCells = SettingsSection(cells: [.support,
														 .share,
														 .rate,
														 .privacypolicy,
														 .termsOfUse],
												 headerTitle: "settings optional title two",
												 headetHeight: 40)
		
		let sections: [SettingsSection] = [firstSectionCells, secondSectionCells, thirdSectionsCells, fouthSectionsCells]
		
		self.settingsViewModel = SettingsViewModel(sections: sections)
		self.settingsDataSource = SettingsDataSource(settingsViewModel: self.settingsViewModel)
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
		
		self.tableView.register(UINib(nibName: C.identifiers.xibs.bannerCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.helperBannerCell)
		self.tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
		
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
}


extension SettingsViewController: SettingActionsDelegate {
	
	public func setAction(at cell: SettingsModel) {
		switch cell {
			case .premium:
				self.showPremiumController()
			case .largeVideos:
				self.showLargeVideoSettings()
			case .dataStorage:
				self.showDataStorageInfo()
			case .permissions:
				self.showPermissionController()
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
	
	private func showPremiumController() {
		debugPrint("showPremiumController")
	}
	
	private func showLargeVideoSettings() {
		
		performSegue(withIdentifier: C.identifiers.segue.showSizeSelector, sender: self)
	}
	
	private func showDataStorageInfo() {
		debugPrint("showDataStorageInfo")
	}
	
	private func showPermissionController() {
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.permissions, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.permissions) as! PermissionsViewController
		viewController.fromRootViewController = false
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	private func showRestorePurchaseAction() {
		SubscriptionManager.instance.restorePurchase()
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
		
	}
}



