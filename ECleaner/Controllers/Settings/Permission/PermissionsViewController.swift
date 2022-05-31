//
//  PermissionsViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import UIKit

class PermissionsViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
	
	private var permissionViewModel: PermissionViewModel!
	private var permissionDataSource: PermissionsDataSource!
	
	public var fromRootViewController: Bool = true
		
    override func viewDidLoad() {
        super.viewDidLoad()

		viewModelSetup()
		setupUI()
		tableViewSetup()
		setupNavigation()
		updateColors()
		setupDelegate()
		setupObservers()
    }
}

extension PermissionsViewController {
	
	private func handleContineButton() {
		
		if #available(iOS 14.5, *) {
			if AppTrackerPermissions().notDetermined {
				AlertManager.showPermissionAlert(of: .appTracker, at: self) {
					AppTrackerPermissions().requestForPermission { _, _ in }
				}
			} else {
				self.handleAtLeastOnePermission()
			}
		} else {
			self.handleAtLeastOnePermission()
		}
	}
	
	private func handleAtLeastOnePermission() {
		
		if PhotoLibraryPermissions().notDetermined && ContactsPermissions().notDetermined || PhotoLibraryPermissions().denied && ContactsPermissions().denied {
			AlertManager.showPermissionAlert(of: .onePermissionRule, at: self)
		} else {
			self.dismiss(animated: true) {
				SettingsManager.permissions.permisssionDidShow = true
				U.sceneDelegate.permissionWindow = nil
			}
		}
	}
	
	private func handlePermissionChange(at cell: PermissionTableViewCell, with permission: Permission) {

		switch permission.status {
			case .authorized, .denied:
				AlertManager.showPermissionAlert(of: .openSettings, at: self, for: permission)
			case .notDetermined:
				permission.requestForPermission { granted, error in
					cell.setButtonState(for: permission)
				}
			case .notSupported:
				return
		}
	}
	
	@objc func applicationDidBecomeActive() {
		UIView.performWithoutAnimation {
			self.tableView.reloadData()
		}
	}
}

extension PermissionsViewController: NavigationBarDelegate {
	func didTapLeftBarButton(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func didTapRightBarButton(_ sender: UIButton) {}
}

extension PermissionsViewController {
	
	private func viewModelSetup() {
		
		let blankPermission = [BlankPermission()]

		var permissionSections = [NotificationsPermissions(),
								  PhotoLibraryPermissions(),
								  ContactsPermissions()]
		
		if #available(iOS 14.5, *) {
			permissionSections.append(AppTrackerPermissions())
		}
		let blankModel = PermissionSectionModel(cells: blankPermission)
		let sectionModel = PermissionSectionModel(cells: permissionSections)
		
		let permissionModel = fromRootViewController ? PermissionViewModel(sections: [blankModel,sectionModel, blankModel]) : PermissionViewModel(sections: [sectionModel])
		self.permissionViewModel = permissionModel
		self.permissionDataSource = PermissionsDataSource(permissionViewModel: self.permissionViewModel)
		self.permissionDataSource.fromRootViewController = self.fromRootViewController
		
		self.permissionDataSource.permissionActionDidChange = { cell, permission in
			self.handlePermissionChange(at: cell, with: permission)
		}
		
		self.permissionDataSource.handleContinueButton = {
			self.handleContineButton()
		}
	}
	
	private func tableViewSetup() {
		
		self.tableView.register(UINib(nibName: C.identifiers.xibs.permissionBannerCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.permissionBannerCell)
		self.tableView.register(UINib(nibName: C.identifiers.xibs.permissionCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.permissionCell)
		self.tableView.register(UINib(nibName: C.identifiers.xibs.permissionContinueCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.permissionContinueCell)
		
		self.tableView.delegate = permissionDataSource
		self.tableView.dataSource = permissionDataSource
		self.tableView.contentInset.top = 0
		self.tableView.separatorStyle = .none
		self.tableView.allowsSelection = false
	}
}

extension PermissionsViewController: Themeble {
	
	private func setupUI() {
		
		self.navigationController?.navigationBar.isHidden = true
	}
	
	private func setupNavigation() {
		
		let navigationBarHeight = U.UIHelper.AppDimensions.NavigationBar.navigationBarHeight
		navigationBarHeightConstraint.constant = !fromRootViewController ? navigationBarHeight : 0
		
		navigationBar.layoutIfNeeded()
		self.view.layoutIfNeeded()
		
		if !fromRootViewController {
			navigationBar.setupNavigation(title: "permissions",
										  leftBarButtonImage: I.systemItems.navigationBarItems.back,
										  rightBarButtonImage: nil,
										  contentType: .none,
										  leftButtonTitle: nil,
										  rightButtonTitle: nil)
		} else {
			navigationBar.isHidden = true
		}
	}
	
	private func setupDelegate() {
		navigationBar.delegate = self
	}
	
	private func setupObservers() {
	
		NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
	}
	
	func updateColors() {
		self.view.backgroundColor = theme.backgroundColor
		self.tableView.backgroundColor = theme.backgroundColor
	}
}


