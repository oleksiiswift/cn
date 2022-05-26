//
//  PermissionViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation

class PermissionViewModel {
	
	private var sections: [PermissionSectionModel]
	public var title = "Permissions"
	
	init(sections: [PermissionSectionModel]) {
		self.sections = sections
	}
	
	public func numbersOfSections() -> Int {
		return self.sections.count
	}
	
	public func numbersOfRows(in section: Int) -> Int {
		return self.sections[section].cells.count
	}
	
	public func getPermission(at indexPath: IndexPath) -> Permission {
		return self.sections[indexPath.section].cells[indexPath.row]
	}
	
	public func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
		let permission = self.getPermission(at: indexPath)
		return U.UIHelper.AppDimensions.Permissions.getHeightOfRow(at: permission.permissionType)
	}
}
