//
//  CompressingSettingsViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.04.2022.
//

import Foundation
import Photos

class CompressingSettingsViewModel {
	
	private var sections: [CompressingSection]
	private var phasset: PHAsset
	
	
	init(sections: [CompressingSection], phasset: PHAsset) {
		self.sections = sections
		self.phasset = phasset
	}
	
	public func getCompressingPHAsset() -> PHAsset? {
		return self.sections[0].compressingPHAsset
	}
	
	public func numbersOfSections() -> Int {
		return self.sections.count
	}
	
	public func numbersOfRows(in section: Int) -> Int {
		return self.sections[section].cells.count
	}
	
	public func getSettingsModel(at indexPath: IndexPath) -> ComprssionModel {
		return self.sections[indexPath.section].cells[indexPath.row]
	}
	
	public func gettitleForHeader(in section: Int) -> String? {
		return self.sections[section].headerTitle
	}
	
	public func getHeightOfHeader(in section: Int) -> CGFloat {
		return self.sections[section].headerHeight ?? 0.0
	}
	
	public func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
		if self.phasset.isPortrait {
			return self.sections[indexPath.section].cells[indexPath.row].portraitHeightForRow
		} else {
			return self.sections[indexPath.section].cells[indexPath.row].heightForRow
		}
	}
}
