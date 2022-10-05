//
//  AlertType.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.11.2021.
//

import UIKit

enum AlertType {
	
	case deletePhoto
	case deletePhotos
	case deleteVideo
	case deleteVideos
	case deleteContact
	case deleteContacts
	case deleteLocations
	case mergeContacts
	case mergeCompleted
	case deleteContactsCompleted
	case compressionvideoFileComplete
	
	public var alertTitle: String {
		return AlertHandler.getAlertTitle(for: self)
	}
	
	public var alertMessage: String {
		return AlertHandler.getAlertMessage(for: self)
	}
	
	public var alertStyle: UIAlertController.Style {
		switch self {
			case .compressionvideoFileComplete:
				return .actionSheet
			default:
				return .alert
		}
	}
	
	public var withCancel: Bool {
		return AlertHandler.withCancelButton(for: self)
	}
	
	public var deleteAlertDesctiprtion: AlertDescription {
		return LocalizationService.Alert.DeleteAlerts.alertDescriptionFor(alert: self)
	}
		
	public var alertDescription: AlertDescription {
		return LocalizationService.Alert.WorkWithMedia.alertDescriptionFor(alert: self)
	}
}
