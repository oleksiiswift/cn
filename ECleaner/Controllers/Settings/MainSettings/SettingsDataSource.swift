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
	
	private func getCurrentSubscriptionCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CurrentSubscriptionTableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.currentSubscription, for: indexPath) as! CurrentSubscriptionTableViewCell
		self.subscriptionCellConfiguration(cell: cell)
		return cell
	}
	
	private func getPremiumFeatureSubscriptionCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> PremiumFeaturesSubscriptionTableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.premiumFeaturesSubcription, for: indexPath) as! PremiumFeaturesSubscriptionTableViewCell
		self.featuresCellConfigure(cell: cell)
		return cell
	}
	
	private func getContentTypeCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ContentTypeTableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contentTypeCell, for: indexPath) as! ContentTypeTableViewCell
		self.cellConfigure(cell: cell, at: indexPath)
		return cell
	}
	
	private func cellConfigure(cell: ContentTypeTableViewCell, at indexPath: IndexPath) {
		
		let settingsModel = settingsViewModel.getSettingsModel(at: indexPath)
		cell.settingsCellConfigure(with: settingsModel)
	}
	
	private func featuresCellConfigure(cell: FeaturesSubscriptionTableViewCell) {
		cell.featuresConfigure(features: PremiumFeature.allCases)
	}

	private func featuresCellConfigure(cell: PremiumFeaturesSubscriptionTableViewCell) {
		cell.featuresConfigure(leadingFeatures: [.deepClean, .multiselect], trailingFeautures: [.location, .compression])
	}
	
	private func subscriptionCellConfiguration(cell: CurrentSubscriptionTableViewCell) {
		cell.delegate = self
		settingsViewModel.getCurrentSubscription { model in
			Utils.UI {
				cell.configure(model: model)				
			}
		}
	}
}

extension SettingsDataSource: CurrentSubscriptionChangeDelegate {
	
	func didTapChangeSubscription() {
		didSelectedSettings(.premium)
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
		
		if SubscriptionManager.instance.isLifeTimeSubscription() {
			return getContentTypeCell(tableView, cellForRowAt: indexPath)
		} else  {
			switch indexPath.section {
				case 0:
					switch SubscriptionManager.instance.purchasePremiumStatus() {
						case .lifetime, .purchasedPremium:
							return getCurrentSubscriptionCell(tableView, cellForRowAt: indexPath)
						case .nonPurchased:
							return getPremiumFeatureSubscriptionCell(tableView, cellForRowAt: indexPath)
					}
				default:
					return getContentTypeCell(tableView, cellForRowAt: indexPath)
			}
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
