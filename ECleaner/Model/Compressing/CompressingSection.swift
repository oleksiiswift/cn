//
//  CompressingSection.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.04.2022.
//

import Foundation
import Photos

struct CompressingSection {
	
	let cells: [ComprssionModel]
	let headerTitle: String?
	let headerHeight: CGFloat?
	let compressingPHAsset: PHAsset?
	
	init(cells: [ComprssionModel], compressingPHAsset: PHAsset? = nil, headerTitle: String? = nil, headerHeight: CGFloat? = nil) {
		self.cells = cells
		self.compressingPHAsset = compressingPHAsset
		self.headerTitle = headerTitle
		self.headerHeight = headerHeight
	}
}
