//
//  LocalizationService.swift
//  ECleaner
//
//  Created by alexey sorochan on 31.05.2022.
//

import Foundation

struct  LocalizationService {
	
	struct PermissionStings {
	
		static func getTitle(for permission: Permission.PermissionType) -> String {
			switch permission {
				case .notification:
					return Localization.Permission.Name.notification
				case .photolibrary:
					return Localization.Permission.Name.photoLibrary
				case .contacts:
					return Localization.Permission.Name.contacts
				case .tracking:
					return Localization.Permission.Name.tracking
				default:
					return Localization.Permission.Name.libraryContacts
			}
		}
		
		static func getDescription(for permission: Permission.PermissionType) -> String {
			switch permission {
					
				case .notification:
					return Localization.Permission.Description.notification
				case .photolibrary:
					return Localization.Permission.Description.photoLibrary
				case .contacts:
					return Localization.Permission.Description.contacts
				case .tracking:
					return Localization.Permission.Description.tracking
				default:
					return Localization.Permission.Description.libraryContacts
			}
		}
	}
	
	struct Buttons {
		
		static func getButtonTitle(of buttonType: ButtonType) -> String {
			return buttonType.rawValue
		}
	}
	
	struct Alert {
		
		struct Permissions {
		
			static func getOpenSettingsPermissionDescription(for auth: Bool) -> AlertDescription {
				return AlertDescription(title: auth ? L.Permission.AlertService.Title.permissionAllowed : L.Permission.AlertService.Title.permissionDenied,
										description: L.Permission.AlertService.Description.openSettings,
										action: Buttons.getButtonTitle(of: .settings),
										cancel: Buttons.getButtonTitle(of: .cancel))
			}
			
			static func getDeniedDeepCleanPermissionDescription() -> AlertDescription {
				return AlertDescription(title: L.Permission.AlertService.Title.permissionDenied,
										description: L.Permission.AlertService.Description.allowContactsAndPhoto,
										action: Buttons.getButtonTitle(of: .settings),
										cancel: Buttons.getButtonTitle(of: .cancel))
			}
			
			static func getApptrackerPermissionDescription() -> AlertDescription {
				
				return AlertDescription(title: L.Permission.AlertService.Title.appTrack,
										description: L.Permission.AlertService.Description.appTrackDescription,
										action: Buttons.getButtonTitle(of: .ok),
										cancel: L.empty)
			}
			
			static func getAtLeastOnePermissionDescription() -> AlertDescription {
				return AlertDescription(title: L.Permission.AlertService.Title.onePermissionRule,
										description: L.Permission.AlertService.Description.onePermissionRule,
										action: Buttons.getButtonTitle(of: .ok),
										cancel: L.empty)
			}
			
			static func restrictedPermissionDescription(for error: ErrorHandler.AccessRestrictedError) -> AlertDescription {
				let contactsPermissionRestricted = L.Permission.AlertService.Restricted.contacts
				let photoPermissionRestricted = L.Permission.AlertService.Restricted.photoLibrary
				let description = error == .contactsRestrictedError ? contactsPermissionRestricted : photoPermissionRestricted
				return AlertDescription(title: L.Permission.AlertService.Title.permissionDenied,
										description: description,
										action: Buttons.getButtonTitle(of: .settings),
										cancel: Buttons.getButtonTitle(of: .cancel))
			}
		}
	}
	
	struct Notification {
		
		static func getNotificationBodyText(of type: UserNotificationType) -> NotificationBodyDescription {
			switch type {
				case .cleanContacts:
					return NotificationBodyDescription(title: L.Notification.Title.contacts,
												   subtitle: L.empty,
												   body: L.Notification.Body.contacts)
				case .cleanPhotos:
					return NotificationBodyDescription(title: L.Notification.Title.photos,
												   subtitle: L.empty,
												   body: L.Notification.Body.photos)
				case .cleanVideo:
					return NotificationBodyDescription(title: L.Notification.Title.videos,
												   subtitle: L.empty,
												   body: L.Notification.Body.videos)
				case .deepClean:
					return NotificationBodyDescription(title: L.Notification.Title.deepClean,
												   subtitle: L.empty,
												   body: L.Notification.Body.deepClean)
				case .clean:
					return NotificationBodyDescription(title: L.Notification.Title.storage,
												   subtitle: L.empty,
												   body: L.Notification.Body.storage)
				default:
					return NotificationBodyDescription(title: L.empty, subtitle: L.empty, body: L.empty)
			}
		}
	}
	
	struct Errors {
		
		static func getEmptyErrorForKey(_ error: ErrorHandler.EmptyResultsError) -> ErrorDescription {
			
			let buttonTitle = LocalizationService.Buttons.getButtonTitle(of: .ok)
			
			var title: String {
				switch error {
					case .deepCleanResultsIsEmpty:
						return Localization.AlertController.AlertTitle.searchComplete
					default:
						return Localization.ErrorsHandler.Title.emptyResults
				}
			}
		
			var message: String {
				switch error {
					case .photoLibrararyIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.photoLibrararyIsEmpty
					case .videoLibrararyIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.videoLibrararyIsEmpty
					case .similarPhotoIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.similarPhotoIsEmpty
					case .duplicatedPhotoIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.duplicatedPhotoIsEmpty
					case .screenShotsIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.screenShotsIsEmpty
					case .similarSelfiesIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.similarSelfiesIsEmpty
					case .livePhotoIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.livePhotoIsEmpty
					case .similarLivePhotoIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.similarLivePhotoIsEmpty
					case .largeVideoIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.largeVideoIsEmpty
					case .duplicatedVideoIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.duplicatedVideoIsEmpty
					case .similarVideoIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.similarVideoIsEmpty
					case .screenRecordingIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.screenRecordingIsEmpty
					case .contactsIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.contactsIsEmpty
					case .emptyContactsIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.emptyContactsIsEmpty
					case .duplicatedNamesIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.duplicatedNamesIsEmpty
					case .duplicatedNumbersIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.duplicatedNumbersIsEmpty
					case .duplicatedEmailsIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.duplicatedEmailsIsEmpty
					case .deepCleanResultsIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.deepCleanResultsIsEmpty
				}
			}
			return ErrorDescription(title: title, message: message, buttonTitle: buttonTitle)
		}
	}
}












