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
	case selectPhotos
	case selectVideo
	case selectContact
	case selectContactGroup
		
	public var alertDescription: AlertDescription {
		return LocalizationService.getLimitAccessAlertDescription(for: self)
	}
	
	public var messageDescription: MessageDescription {
		return LocalizationService.getLimitMessageDescription(for: self)
	}
	
	public var selectAllLimit: Int {
		switch self {
			case .selectAllPhotos, .selectPhotos:
				return 10
			case .selectAllVideos, .selectVideo:
				return 10
			case .selectAllContacts, .selectContact:
				return 10
			case .selectAllContactsGroups, .selectContactGroup:
				return 5
			default:
				return .max
		}
	}
}
