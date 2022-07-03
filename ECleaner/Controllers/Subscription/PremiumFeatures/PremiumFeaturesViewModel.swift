//
//  PremiumFeaturesViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.07.2022.
//

import Foundation

class PremiumFeaturesViewModel {
	
	let features: [PremiumFeature]
	
	init(features: [PremiumFeature]) {
		self.features = features
	}
	
	public func numberOfSection() -> Int {
		return 1
	}
	
	public func numbersOfRows(in section: Int) -> Int {
		return self.features.count
	}
	
	public func getFeatureModel(at indexPath: IndexPath) -> PremiumFeature {
		return self.features[indexPath.row]
	}
}
