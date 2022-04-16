//
//  AlertHandler.swift
//  ECleaner
//
//  Created by alexey sorochan on 10.01.2022.
//

import UIKit

struct AlertHandler {
	
	enum DeepCleanStateHandler {
		case deepCleanCompleteWithErrors
		case deepCleanCompleteSuxxessfull
		case deepCleanCanceled
		
		var titleHandler: String {
			switch self {
				case .deepCleanCompleteWithErrors:
					return "Complete with Errors"
				case .deepCleanCompleteSuxxessfull:
					return "Complete suxxessfully"
				case .deepCleanCanceled:
					return "canceled"
			}
		}
	}
	
	enum AllowAccessHandler {
		case notification
		case contactStore
		case photoLibrary
		
		var title: String {
			switch self {
				case .notification:
					return "permition request for notification"
				case .contactStore:
					return "permition request for contacts"
				case .photoLibrary:
					return "permition request for photolibrary"
			}
		}
	
		var message: String {
			switch self {
				case .notification:
					return "allow notification"
				case .contactStore:
					return "allow contacts store"
				case .photoLibrary:
					return "allow access photolibrary"
			}
		}
	}
		
	private static func deepCleanHandlerForKey(_ handler: DeepCleanStateHandler) -> String {
		switch handler {
			case .deepCleanCompleteWithErrors:
				return "deep clean complete witgh errors"
			case .deepCleanCompleteSuxxessfull:
				return "deep clean complete suxxessfully"
			case .deepCleanCanceled:
				return "deep clean canseled"
		}
	}
	
	public static func deepCleanCompleteStateHandler(for type: DeepCleanStateHandler) {
		let alertAction = UIAlertAction(title: "ok", style: .default)
		
		DispatchQueue.main.async {
			A.showAlert(type.titleHandler, message: self.deepCleanHandlerForKey(type), actions: [alertAction], withCancel: false, style: .alert, completion: nil)
		}
	}
}

extension AlertHandler {
	
	public static func getSelectableAutimaticAletMessage(for type: PhotoMediaType) -> String {
		
		switch type {
			case .similarPhotos:
				return "Select all similar photos?"
			case .duplicatedPhotos:
				return "Select all duplicated photos?"
			case .singleScreenShots:
				return "Select all screen shots?"
			case .similarLivePhotos:
				return "Select all similar live photo?"
			case .singleLargeVideos:
				return "Select all large videos?"
			case .duplicatedVideos:
				return "Select all duplicated video?"
			case .similarVideos:
				return "Select all similar videos?"
			case .singleScreenRecordings:
				return "Select all screen recordings videos"
			case .emptyContacts:
				return "Select all empty contacts?"
			case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
				return "Select all duplucated contacts?"
			default:
				return ""
		}
	}
}

extension AlertHandler {
	
	public enum AlertActionsButtons {
		case cancel
		case ok
		case settings
		case delete
		case merge
		case stop
		case exit
		case selectAll
		case share
		case save
		case deleteVideo
		case deleteVideos
		case deletePhoto
		case deletePhotos
	
		var title: String {
			switch self {
				case .cancel:
					return "cancel"
				case .ok:
					return "ok"
				case .settings:
					return "settings"
				case .delete:
					return "delete"
				case .merge:
					return "merge"
				case .stop:
					return "stop"
				case .exit:
					return "exit"
				case .selectAll:
					return "select all"
				case .share:
					return "share"
				case .save:
					return "save"
				case .deleteVideo:
					return "delete video"
				case .deleteVideos:
					return "delete videos"
				case .deletePhoto:
					return "delete photos"
				case .deletePhotos:
					return "delete photo"
			}
		}
	}
	
	public static func getAlertTitle(for aletrType: AlertType) -> String {
		
		switch aletrType {
			case .compressionvideoFileComplete:
				return "compression complete"
			default:
				return ""
		}
	}
	
	public static func getAlertMessage(for alertType: AlertType) -> String {
		
		switch alertType {
			case .compressionvideoFileComplete:
				return "video file compression is suxxesfully competed. file size: "
			default:
				return ""
		}
	}
}
