//
//  SettingsSection.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.02.2022.
//

import Foundation
import UIKit

struct SettingsSection {
	
	let cells: [SettingsModel]
	let headerTitle: String?
	let headerHeight: CGFloat?
	
	init(cells: [SettingsModel], headerTitle: String? = nil, headetHeight: CGFloat? = nil) {
		self.cells = cells
		self.headerTitle = headerTitle
		self.headerHeight = headetHeight
	}
}
