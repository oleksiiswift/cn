//
//  RootViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 13.10.2022.
//

import Foundation


protocol RootViewModelDelegate {
	
}

class RootViewModel {
	
	private var sections: [RootSection]
	
	init(sections: [RootSection]) {
		self.sections = sections
	}
	
	public func numberOfSections() -> Int {
		return self.sections.count
	}
	
	public func numberOfRows(in section: Int) -> Int {
		return self.sections[section].cells.count
	}
	
	public func getRootModel(at indexPath: IndexPath) -> MediaContentType {
		return self.sections[indexPath.section].cells[indexPath.row]
	}
	
	public func getContentCount(at indexPath: IndexPath) -> Int {
		
		let section = self.sections[indexPath.section]
		let model = section.cells[indexPath.row]
		
		return section.contentCount[model] ?? 0
	}
	
	private func getSpaceCount(at indexPath: IndexPath) -> Int64 {
		let section = self.sections[indexPath.section]
		let model = section.cells[indexPath.row]
		
		return section.diskSpace[model] ?? 0
	}
	
	public func getContentCount(of model: MediaContentType) -> Int {
		
		if let indexPath = self.indexPath(of: model) {
			return getContentCount(at: indexPath)
		}
		return 0
	}
	
	public func getDiskSpace(of model: MediaContentType) -> Int64 {
		
		if let indexPath = self.indexPath(of: model) {
			return self.getSpaceCount(at: indexPath)
		}
		return 0
	}
	
	public func setContentCount(model: MediaContentType, itemsCount: Int) {
		
		guard let indexPath = self.indexPath(of: model) else { return }
		
		self.sections[indexPath.section].contentCount[model] = itemsCount
	}
	
	public func indexPath(of model: MediaContentType) -> IndexPath? {
		
		if let section = sections.firstIndex(where: {$0.cells.containsElements([model])}) {
			if let index = sections[section].cells.firstIndex(of: model) {
				return IndexPath(item: index, section: section)
			}
		}
		return nil
	}
}
