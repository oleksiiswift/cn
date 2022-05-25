//
//  PermissionSectionModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.05.2022.
//

import Foundation

struct PermissionSectionModel {
	
	let cells: [Permission.PermissionType]
	
	init(cells: [Permission.PermissionType]) {
		self.cells = cells
	}
}
