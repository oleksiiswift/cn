//
//  AlertHandler.swift
//  ECleaner
//
//  Created by alexey sorochan on 10.01.2022.
//

import UIKit

struct AlertHandler {}

extension AlertHandler {
	
	public static func getAlertTitle(for aletrType: AlertType) -> String {
		
		switch aletrType {
			case .deletePhoto:
				return Localization.AlertController.AlertTitle.deletePhoto.localizedWith(count: 1)
			case .deletePhotos:
				return Localization.AlertController.AlertTitle.deletePhoto.localizedWith(count: 2)
			case .deleteVideo:
				return Localization.AlertController.AlertTitle.deleteVideo.localizedWith(count: 1)
			case .deleteVideos:
				return Localization.AlertController.AlertTitle.deleteVideo.localizedWith(count: 2)
			case .deleteContact:
				return Localization.AlertController.AlertTitle.deleteContact.localizedWith(count: 1)
			case .deleteContacts:
				return Localization.AlertController.AlertTitle.deleteContact.localizedWith(count: 2)
			case .compressionvideoFileComplete:
				return L.AlertController.AlertTitle.compressionComplete
			case .mergeContacts:
				return Localization.AlertController.AlertTitle.mergeContacts
			case .mergeCompleted:
				return Localization.AlertController.AlertTitle.mergeCompleted
			case .deleteContactsCompleted:
				return Localization.AlertController.AlertTitle.deleteContactsCompleted
		}
	}
	
	public static func getAlertMessage(for alertType: AlertType, count: Int = 1) -> String {
		
		switch alertType {
			case .deletePhoto:
				return Localization.AlertController.AlertMessage.deletePhoto.localizedWith(count: 1)
			case .deletePhotos:
				return Localization.AlertController.AlertMessage.deletePhoto.localizedWith(count: 2)
			case .deleteVideo:
				return Localization.AlertController.AlertMessage.deleteVideo.localizedWith(count: 1)
			case .deleteVideos:
				return Localization.AlertController.AlertMessage.deleteVideo.localizedWith(count: 2)
			case .deleteContact:
				return Localization.AlertController.AlertMessage.deleteContact.localizedWith(count: 1)
			case .deleteContacts:
				return Localization.AlertController.AlertMessage.deleteContact.localizedWith(count: 2)
			case .compressionvideoFileComplete:
				return Localization.AlertController.AlertMessage.compresssionComplete
			case .mergeContacts:
				return Localization.AlertController.AlertMessage.mergeContacts
			case .mergeCompleted:
				return Localization.AlertController.AlertMessage.mergeCompleted
			case .deleteContactsCompleted:
				return Localization.AlertController.AlertMessage.deleteContactsCompleted
		}
	}
	
	public static func withCancelButton(for alertType: AlertType) -> Bool {
		switch alertType {
			case .mergeCompleted, .deleteContactsCompleted:
				return false
			default:
				return true
		}
	}
}




