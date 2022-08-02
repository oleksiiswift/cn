//
//  PHAssetLocationViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.08.2022.
//

import Foundation
import Photos

class PHAssetLocationViewModel {
	
	public var phassets: [PHAsset]
	
	public var phassetsData: [DateComponents: [PHAsset]] = [:]
	public var phassetsSection: [DateComponents] = []
	
	init(phassets: [PHAsset]) {
		self.phassets = phassets
		self.setupData(phassets)
	}
	
	
	public func getSortAndGroupAssets(_ assets: [PHAsset]) -> [DateComponents: [PHAsset]] {
		return Dictionary(grouping: assets, by: {Calendar.current.dateComponents([.year, .day, .month], from: $0.creationDate!)})
	}

	private func setupData(_ phasset: [PHAsset]) {
		
		self.phassets = phasset
		self.sortSections(by: self.phassets)
	}
}

extension PHAssetLocationViewModel {
	
	private func sortSections(by phassets: [PHAsset]) {
		
		let calendar = Calendar.current
		self.phassetsData = self.getSortAndGroupAssets(phassets)
		var sortedSections = Array(self.phassetsData.keys)
		
		sortedSections = sortedSections.sorted(by: { first, second in
			if let firstDate = calendar.date(from: first), let secondDate = calendar.date(from: second) {
				return firstDate > secondDate
			}
			return false
		})
		self.phassetsSection = sortedSections
	}
}

extension PHAssetLocationViewModel {
	
	public func numberOfSection() -> Int {
		return phassetsSection.count
	}
	
	public func numberOfRows(at section: Int) -> Int {
		return phassetsData[self.phassetsSection[section]]?.count ?? 0
	}
	
	public func getPhasset(at indexPath: IndexPath) -> PHAsset? {
		let key = self.phassetsSection[indexPath.section]
		let phassets = self.phassetsData[key]
		return phassets?[indexPath.row]	
	}
	
	public func getPhassets(at section: Int) -> [PHAsset]? {
		let key = self.phassetsSection[section]
		let phassets = self.phassetsData[key]
		return phassets
	}
	
	public func getDateComponent(at section: Int) -> DateComponents {
		return phassetsSection[section]
	}
}

