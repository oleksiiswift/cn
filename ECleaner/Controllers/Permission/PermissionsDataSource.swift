//
//  PermissionsDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation

protocol PermissionsActionsDelegate {
	func permissionActionChange(at cell: PermissionTableViewCell)
	func didTapContinueButton()
}

class PermissionsDataSource: NSObject {
	
	public var permissionViewModel: PermissionViewModel
	public var permissionActionDidChange: ((_ cell: PermissionTableViewCell,_ permission: Permission) -> Void) = {_, _ in}
	public var handleContinueButton: (() -> Void) = {}
	public var fromRootViewController: Bool = true
	
	init(permissionViewModel: PermissionViewModel) {
		self.permissionViewModel = permissionViewModel
	}
}

extension PermissionsDataSource: PermissionsActionsDelegate {

	func didTapContinueButton() {
		self.handleContinueButton()
	}
	
	func permissionActionChange(at cell: PermissionTableViewCell) {
			
		guard let permission = cell.permission else { return }
		self.permissionActionDidChange(cell, permission)
	}
}

extension PermissionsDataSource {
	
	private func permissionConfigure(cell: PermissionTableViewCell, at indexPath: IndexPath) {
		let permission = self.permissionViewModel.getPermission(at: indexPath)
		cell.delegate = self
		cell.configure(with: permission)
	}
	
	private func permissionBannerConfigure(cell: PermissionBannerTableViewCell, at indexPath: IndexPath) {
		cell.configureCell()
	}
	
	private func permissionContinueConfigure(cell: PermissionContinueTableViewCell, at indexPath: IndexPath) {
		cell.setupUI()
		cell.updateColors()
		cell.delegate = self
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
		
		if !fromRootViewController {
			let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.permissionCell, for: indexPath) as! PermissionTableViewCell
			self.permissionConfigure(cell: cell, at: indexPath)
			return cell
		} else {
			switch indexPath.section {
				case 0:
					let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.permissionBannerCell, for: indexPath) as! PermissionBannerTableViewCell
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
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let type = permissionViewModel.getPermission(at: indexPath)
		return AppDimensions.PermissionsCell.getHeightOfRow(at: type.permissionType)
	}
}
