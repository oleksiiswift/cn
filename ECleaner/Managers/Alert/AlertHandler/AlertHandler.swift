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
			A.showAlert(type.titleHandler, message: self.deepCleanHandlerForKey(type), actions: [alertAction], withCancel: false, completion: nil)
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

