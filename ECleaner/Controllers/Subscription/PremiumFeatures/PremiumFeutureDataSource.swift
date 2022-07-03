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



class PremiumDataSource: NSObject {
	
	public var premiumViewModel: PremiumViewModel
	
	init(premiumViewModel: PremiumViewModel) {
		self.premiumViewModel = premiumViewModel
	}
}

extension PremiumDataSource {
	
	private func cellConfigure(cell: PremiumCollectionViewCell, at indexPath: IndexPath) {
		let premiumModel = premiumViewModel.getFeatureModel(at: indexPath)
		cell.configure(model: premiumModel)
	}
}

extension PremiumDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return premiumViewModel.numbersOfRows(in: section)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PremiumCollectionViewCell", for: indexPath) as! PremiumCollectionViewCell
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)

		//Briefly fade the cell on selection
		UIView.animate(withDuration: 0.5,
					   animations: {
						//Fade-out
						cell?.alpha = 0.5
		}) { (completed) in
			UIView.animate(withDuration: 0.5,
						   animations: {
							//Fade-out
							cell?.alpha = 1
			})
		}

	}
}
