//
//  SettingsViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.02.2022.
//

import UIKit

class SettingsViewModel {
	
	private var sections: [SettingsSection]
	public var controllerTitle = LocalizationService.Main.getNavigationTitle(for: .settings)
	
	init(sections: [SettingsSection]) {
		self.sections = sections
	}
	
	public func numbersOfSections() -> Int {
		return sections.count
	}
	
	public func numbersOfRows(in section: Int) -> Int {
		return self.sections[section].cells.count
	}
	
	public func getSettingsModel(at indexPath: IndexPath) -> SettingsModel {
		return self.sections[indexPath.section].cells[indexPath.row]
	}
	
	public func getTitleForHeader(in section: Int) -> String? {
		return self.sections[section].headerTitle
	}
	
	public func getHeightOfHeader(in section: Int) -> CGFloat {
		return self.sections[section].headerHeight ?? 0.0
	}
	
	public func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
		return self.sections[indexPath.section].cells[indexPath.row].heightForRow
	}
	
	public func getCurrentSubscription(completionHandler: @escaping (_ model: CurrentSubscriptionModel) -> Void) {
		
		SubscriptionManager.instance.getCurrentSubscriptionModel { subsctiptionModel in
			if let model = subsctiptionModel {
				completionHandler(model)
			}
		}
	}
}

