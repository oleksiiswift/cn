//
//  SettingsDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.02.2022.
//

import UIKit

class SettingsDataSource: NSObject {

	public var settingsViewModel: SettingsViewModel
	public var didSelectedSettings: ((SettingsModel) -> Void) = {_ in }
	
	public var delegate: SettingActionsDelegate?
	
	init(settingsViewModel: SettingsViewModel) {
		self.settingsViewModel = settingsViewModel
	}
}

extension SettingsDataSource {
	
	private func cellConfigure(cell: ContentTypeTableViewCell, at indexPath: IndexPath) {
		
		let settingsModel = settingsViewModel.getSettingsModel(at: indexPath)
		cell.settingsCellConfigure(with: settingsModel)
	}
	
	private func bannerCellConfigure(cell: HelperBannerTableViewCell, at indexPath: IndexPath) {
		let settingsModel = settingsViewModel.getSettingsModel(at: indexPath)
		cell.cellConfigure(with: settingsModel)
	}
}

extension SettingsDataSource: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return settingsViewModel.numbersOfSections()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settingsViewModel.numbersOfRows(in: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.helperBannerCell, for: indexPath) as! HelperBannerTableViewCell
				self.bannerCellConfigure(cell: cell, at: indexPath)
				return cell
			default:
				let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contentTypeCell, for: indexPath) as! ContentTypeTableViewCell
				self.cellConfigure(cell: cell, at: indexPath)
				return cell
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return settingsViewModel.getTitleForHeader(in: section)
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return settingsViewModel.getHeightOfHeader(in: section)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let model = settingsViewModel.getSettingsModel(at: indexPath)
		self.delegate?.setAction(at: model)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return settingsViewModel.getHeightForRow(at: indexPath)
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.contentView.backgroundColor = ThemeManager.theme.backgroundColor
		header.contentView.alpha = 0.8
		header.textLabel?.textColor = ThemeManager.theme.sectionTitleTextColor
		header.textLabel?.font = .systemFont(ofSize: 14, weight: .medium)
	}
}
