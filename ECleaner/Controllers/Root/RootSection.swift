//
//  RootSection.swift
//  ECleaner
//
//  Created by alexey sorochan on 13.10.2022.
//

import Foundation

struct RootSection {
	
	let cells: [MediaContentType]
	
	var contentCount: [MediaContentType: Int] = [:]
	var diskSpace: [MediaContentType: Int64] = [:]
	
	init(cells: [MediaContentType]) {
		self.cells = cells
	}
}
