//
//  AdvertisementManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.08.2022.
//

import Foundation
import GoogleMobileAds

enum AdvertisementStatus: Int {
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
	
	public var advertisementBannerStatus: AdvertisementStatus {
		get {
			let statusRawValue: Int = U.userDefaults.integer(forKey: C.key.advertisement.bannerStatus)
			return AdvertisementStatus(rawValue: statusRawValue)!
		} set {
			U.userDefaults.set(newValue.rawValue, forKey: C.key.advertisement.bannerStatus)
			let userInfo = [C.key.advertisement.bannerStatus: newValue]
			U.notificationCenter.post(name: .bannerStatusDidChanged, object: nil, userInfo: userInfo)
		}
	}
	
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
