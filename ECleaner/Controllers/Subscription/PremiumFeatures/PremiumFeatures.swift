//
//  PremiumFeatures.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.07.2022.
//

import Foundation

enum PremiumFeature: CaseIterable {
	case deepClean
	case multiselect
	case compression
	case location
	
	var title: String {
		return LocalizationService.Subscription.getPremiumFeaturesTitle(of: self)
	}
	
	var thumbnail: UIImage {
		return Images.subsctiption.getFeaturesImages(for: self)
	}
	
	var thumbnailColors: [UIColor] {
		return Theme.getSubscriptionFeatureColorGradient(for: self)
	}
}

enum Premium: CaseIterable {
	case week
	case month
	case yeaer
}
