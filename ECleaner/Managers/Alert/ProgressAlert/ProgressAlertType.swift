//
//  ProgressAlertType.swift
//  ECleaner
//
//  Created by alexey sorochan on 31.05.2022.
//

import Foundation

enum ProgressAlertType {
	
	case mergeContacts
	case deleteContacts
	case deleteVideos
	case deletePhotos
	case compressing
	case updatingContacts
	case selectingContacts
	case selectingPhotos
	case selectingVideos
	case prepareDeepClean
	case videoSorting
	case parsingLocations
	case blank
	
	var progressTitle: String {
		switch self {
			case .mergeContacts:
				return Localization.AlertController.AlertTitle.mergingContacts
			case .deleteContacts:
				return Localization.AlertController.AlertTitle.deletingContact
			case .deleteVideos:
				return Localization.AlertController.AlertTitle.deletingVideo
			case .deletePhotos:
				return Localization.AlertController.AlertTitle.deletingPhoto
			case .compressing:
				return Localization.AlertController.AlertTitle.compressing
			case .updatingContacts:
				return Localization.AlertController.AlertTitle.updatingContacts
			case .selectingContacts:
				return Localization.AlertController.AlertTitle.selectingContactsWait
			case .selectingPhotos:
				return Localization.AlertController.AlertTitle.selectingPhotosWait
			case .selectingVideos:
				return Localization.AlertController.AlertTitle.selectingVideosWait
			case .prepareDeepClean:
				return Localization.AlertController.AlertTitle.prepareSearching
			case .videoSorting:
				return Localization.AlertController.AlertTitle.sortByFileSize
			case .parsingLocations:
				return Localization.AlertController.AlertTitle.parsingLocation
			case .blank:
				return Localization.empty
		}
	}
	
	var withCancel: Bool {
		switch self {
			case .mergeContacts, .deleteContacts:
				return true
			case .deleteVideos, .deletePhotos:
				return false
			case .compressing:
				return true
			case .selectingContacts, .selectingVideos, .selectingPhotos, .updatingContacts, .prepareDeepClean:
				return false
			case .videoSorting:
				return false
			case .parsingLocations:
				return false
			case .blank:
				return false
		}
	}
	
	var accentColor: UIColor {
		return self.contentType.screenAcentTintColor
	}
	
	private var contentType: MediaContentType {
		switch self {
			case .mergeContacts: 		return .userContacts
			case .deleteContacts: 		return .userContacts
			case .deleteVideos: 		return .userVideo
			case .deletePhotos: 		return .userPhoto
			case .compressing: 			return .userVideo
			case .updatingContacts: 	return .userContacts
			case .selectingContacts: 	return .userContacts
			case .selectingVideos: 		return .userVideo
			case .selectingPhotos: 		return .userPhoto
			case .prepareDeepClean: 	return .userPhoto
			case .videoSorting: 		return .userVideo
			case .parsingLocations:		return .userPhoto
			case .blank:				return .none
		}
	}
	
	static func progressDeleteAlertType(_ mediaType: MediaContentType) -> ProgressAlertType {
		switch mediaType {
			case .userPhoto:
				return .deletePhotos
			case .userVideo:
				return .deleteVideos
			case .userContacts:
				return .deleteContacts
			default:
				return .blank
		}
	}
}
