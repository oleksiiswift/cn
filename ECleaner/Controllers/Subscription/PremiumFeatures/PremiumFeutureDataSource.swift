//
//  PremiumFeutureDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.07.2022.
//

import Foundation

class PremiumFeutureDataSource: NSObject {
	
	public var premiumFeaturesViewModel: PremiumFeaturesViewModel
	
	init(premiumFeaturesViewModel: PremiumFeaturesViewModel) {
		self.premiumFeaturesViewModel = premiumFeaturesViewModel
	}
}

extension PremiumFeutureDataSource {
	
	private func cellConfigure(cell: PremiumFeatureTableViewCell, at indexPath: IndexPath) {
		let featureModel = premiumFeaturesViewModel.getFeatureModel(at: indexPath)
		cell.configure(model: featureModel)
	}
}

extension PremiumFeutureDataSource: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return premiumFeaturesViewModel.numberOfSection()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return premiumFeaturesViewModel.numbersOfRows(in: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifiers.cells.premiumFeature, for: indexPath) as! PremiumFeatureTableViewCell
		self.cellConfigure(cell: cell, at: indexPath)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return AppDimensions.Subscription.Features.cellSize
	}
}
