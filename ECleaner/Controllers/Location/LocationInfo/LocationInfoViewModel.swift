//
//  LocationInfoViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 04.08.2022.
//

import Foundation

enum LocationInfo: CaseIterable {
	case latitude
	case longitude
	case altitude
	case location
	
	var title: String {
		switch self {
			case .latitude:
				return Localization.Main.HeaderTitle.latitude
			case .longitude:
				return Localization.Main.HeaderTitle.longitude
			case .altitude:
				return Localization.Main.HeaderTitle.altitude
			case .location:
				return Localization.Main.HeaderTitle.location
		}
	}
}

class LocationInfoViewModel {
	
	let info: [LocationInfo]
	
	init(info: [LocationInfo]) {
		self.info = info
	}
}

class LocationDescriptionModel {
	
	var title: String
	var info: String
	
	var locationInfo: LocationInfo
	
	init(title: String, info: String, locationInfo: LocationInfo) {
		self.title = title
		self.info = info
		self.locationInfo = locationInfo
	}
}
