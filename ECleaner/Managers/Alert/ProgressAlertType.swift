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
	
	var progressTitle: String {
		switch self {
			case .mergeContacts:
				return Localization.AlertController.AlertTitle.mergedContacts
			case .deleteContacts:
				return Localization.AlertController.AlertTitle.deleteContacts
			case .deleteVideos:
				return Localization.AlertController.AlertTitle.deleteVideos
			case .deletePhotos:
				return Localization.AlertController.AlertTitle.deletePhotos
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
		}
	}
}
