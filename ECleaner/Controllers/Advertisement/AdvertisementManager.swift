//
//  AdvertisementManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.08.2022.
//

import Foundation
import GoogleMobileAds

enum AdvertisementStatus {
	case active
	case hiden
}

enum GadUnitKey {
	case production
	case testing
}

class Advertisement {
	
	static var manager: Advertisement {
		return self.shared
	}
	
	private static let shared = Advertisement()
	
	public var advertimentBannerTag: Int {
		return Constants.gadAdvertisementKey.advertisementViewTag
	}
	
	public func getUnitID(for key: GadUnitKey) -> String {
		
		switch key {
			case .production:
				return Constants.gadAdvertisementKey.gadProductionKey
			case .testing:
				return Constants.gadAdvertisementKey.gadTestKey
		}
	}
	
	

	
}
