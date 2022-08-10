//
//  LimitAccessType.swift
//  ECleaner
//
//  Created by alexey sorochan on 10.08.2022.
//

import Foundation

enum LimitAccessType {
	
	case selectAllPhotos
	case selectAllVideos
	case selectAllContacts
	case selectAllContactsGroups
	case exportAllContacts
	case multiplySearch
	case deepClean
		
	public var alertDescription: AlertDescription {
		return LocalizationService.getLimitAccessAlertDescription(for: self)
	}
	
	public var selectAllLimit: Int {
		
		switch self {
			case .selectAllPhotos:
				return 10
			case .selectAllVideos:
				return 10
			case .selectAllContacts:
				return 10
			case .selectAllContactsGroups:
				return 5
			default:
				return .max
		}
	}
}
