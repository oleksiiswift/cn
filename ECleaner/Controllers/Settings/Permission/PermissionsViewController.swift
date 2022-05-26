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
	
	public var navigationControllerIsVisible: Bool = false
		
    override func viewDidLoad() {
        super.viewDidLoad()

		viewModelSetup()
		setupUI()
		tableViewSetup()
		setupNavigation()
		updateColors()
		setupDelegate()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
}

extension PermissionsViewController: PermissionsActionsDelegate {
	
	func permissionSwitchDidChange(at cell: Permission.PermissionType, isActive: Bool) {
		debugPrint("changeSwitch to \(isActive) at type \(cell)")
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

		var permissionSections = [NotitificationsPermissions(),
								  PhotoLibraryPermissions(),
								  ContactsPermissions()]
		
		if #available(iOS 14.5, *) {
			permissionSections.append(AppTrackerPermissions())
		}
		let blankModel = PermissionSectionModel(cells: blankPermission)
		let sectionModel = PermissionSectionModel(cells: permissionSections)
		self.permissionViewModel = PermissionViewModel(sections: [blankModel,sectionModel, blankModel])
		self.permissionDataSource = PermissionsDataSource(permissionViewModel: self.permissionViewModel)
	}
	
	private func tableViewSetup() {
		
		self.tableView.register(UINib(nibName: C.identifiers.xibs.permissionBannerCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.permissionBannerCell)
		self.tableView.register(UINib(nibName: C.identifiers.xibs.permissionCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.permissionCell)
		self.tableView.register(UINib(nibName: C.identifiers.xibs.permissionContinueCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.permissionContinueCell)
		
		self.tableView.delegate = permissionDataSource
		self.tableView.dataSource = permissionDataSource
		self.tableView.contentInset.top = 20
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
		navigationBarHeightConstraint.constant = navigationControllerIsVisible ? navigationBarHeight : 0
		
		
		navigationBar.layoutIfNeeded()
		self.view.layoutIfNeeded()
		
		if navigationControllerIsVisible {
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
		permissionDataSource.delegate = self
	}
	
	func updateColors() {
		self.view.backgroundColor = theme.backgroundColor
		self.tableView.backgroundColor = theme.backgroundColor
		
	}
}


