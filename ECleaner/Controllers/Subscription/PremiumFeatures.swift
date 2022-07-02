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
	case conpression
	case location
	
	var title: String {
		switch self {
			case .deepClean:
				return "deep clean"
			case .multiselect:
				return "mutiselect"
			case .conpression:
				return "comression"
			case .location:
				return "location"
		}
	
	}
	
	var thumbnail: UIImage {
		return UIImage()
	}
	
	var thumbnailColors: [UIColor] {
		return [UIColor()]
	}
}



