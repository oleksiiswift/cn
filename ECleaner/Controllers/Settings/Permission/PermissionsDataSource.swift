//
//  PermissionsDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation

protocol PermissionsActionsDelegate {
	func permissionSwitchDidChange(at cell: Permission.PermissionType, isActive: Bool)
}

class PermissionsDataSource: NSObject {
	
	public var permissionViewModel: PermissionViewModel
	public var permissionValueDidChange: ((_ model: Permission.PermissionType,_ value: Bool) -> Void) = {_,_ in}
	public var delegate: PermissionsActionsDelegate?
	
	init(permissionViewModel: PermissionViewModel) {
		self.permissionViewModel = permissionViewModel
	}
}

extension PermissionsDataSource {
	
	private func permissionConfigure(cell: PermissionTableViewCell, at indexPath: IndexPath) {
		
	}
	
	private func permissionBannerConfigure(cell: PermissionBannerTableViewCell, at indexPath: IndexPath) {
		
	}
	
	private func permissionContinueConfigure(cell: PermissionContinueTableViewCell, at indexPath: IndexPath) {
		
	}
}

extension PermissionsDataSource: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.permissionViewModel.numbersOfSections()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.permissionViewModel.numbersOfRows(in: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.helperBannerCell, for: indexPath) as! PermissionBannerTableViewCell
				self.permissionBannerConfigure(cell: cell, at: indexPath)
				return cell
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.permissionCell, for: indexPath) as! PermissionTableViewCell
				self.permissionConfigure(cell: cell, at: indexPath)
				return cell
			default:
				let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.permissionContinueCell, for: indexPath) as! PermissionContinueTableViewCell
				self.permissionContinueConfigure(cell: cell, at: indexPath)
				return cell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let type = permissionViewModel.getPermission(at: indexPath)
		return U.UIHelper.AppDimensions.Permissions.getHeightOfRow(at: type)
	}
}
