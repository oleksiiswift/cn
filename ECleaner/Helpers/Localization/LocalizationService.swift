//
//  LocalizationService.swift
//  ECleaner
//
//  Created by alexey sorochan on 31.05.2022.
//

import Foundation

struct  LocalizationService {
	
	struct Main {
		
		static func getNavigationTitle(for controller: ControllerType) -> String {
			return controller.navigationTitle
		}
	}

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
	
	struct Menu {
		
		public static func getSortingTitle(of type: SortingType) -> String {
			switch type {
				case .date:
					return Localization.Standart.MenuItems.sortByDate
				case .size:
					return Localization.Standart.MenuItems.sortBySize
				case .dimension:
					return Localization.Standart.MenuItems.sortByDimension
				case .edit:
					return Localization.Standart.MenuItems.sortByEdit
				case .duration:
					return Localization.Standart.MenuItems.sortByDuration
			}
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
		
		struct Networking {
			
			static func alertDescription(for error: ErrorHandler.NetworkError) -> AlertDescription {
				switch error {
					case .networkError:
						return AlertDescription(title: Localization.ErrorsHandler.Title.noNetwork,
												description: Localization.ErrorsHandler.PurchaseError.networkError,
												action: LocalizationService.Buttons.getButtonTitle(of: .ok),
												cancel: Localization.empty)
				}
			}
			
		}
		
		
		struct DeleteAlerts {
			
			static func alertDescriptionFor(alert: AlertType) -> AlertDescription {
				return AlertDescription(title: alert.alertTitle,
										description: alert.alertMessage,
										action: LocalizationService.Buttons.getButtonTitle(of: .delete),
										cancel: LocalizationService.Buttons.getButtonTitle(of: .cancel))
			}
		}
		
		struct WorkWithMedia {
			static func alertDescriptionFor(alert: AlertType) -> AlertDescription {
				switch alert {
					case .mergeContacts:
						return AlertDescription(title: alert.alertTitle,
												description: alert.alertMessage,
												action: LocalizationService.Buttons.getButtonTitle(of: .merge),
												cancel: LocalizationService.Buttons.getButtonTitle(of: .cancel))
					case .mergeCompleted:
						return AlertDescription(title: alert.alertTitle,
												description: Localization.empty,
												action: LocalizationService.Buttons.getButtonTitle(of: .ok),
												cancel: Localization.empty)
					case .deleteContactsCompleted:
						return AlertDescription(title: alert.alertTitle,
												description: alert.alertMessage,
												action: LocalizationService.Buttons.getButtonTitle(of: .ok),
												cancel: Localization.empty)
					default:
						return AlertDescription(title: "", description: "", action: "", cancel: "")
				}
			}
		}
		
		struct DeepClean {
			
			static func deepCleanCompleted(for state: DeepCleanCompleteStateHandler) -> AlertDescription {
				switch state {
					case .successfull:
						return AlertDescription(title: Localization.AlertController.AlertTitle.completeSuccessfully,
												description: Localization.AlertController.AlertMessage.deepCleanComplete,
												action: LocalizationService.Buttons.getButtonTitle(of: .ok),
												cancel: Localization.empty)
					case .canceled:
						return AlertDescription(title: Localization.AlertController.AlertTitle.operationIsCancel,
												description: Localization.AlertController.AlertMessage.deepCleanCancel,
												action: LocalizationService.Buttons.getButtonTitle(of: .ok),
												cancel: Localization.empty)
				}
			}
		}
		
		struct CleanOperationState {
			static func operationDescription(for state: SearchOperationStateHandler) -> AlertDescription {
				switch state {
					case .resetDeepCleanSearch:
						return AlertDescription(title: Localization.AlertController.AlertTitle.stopSearch,
												description: Localization.AlertController.AlertMessage.resetDeepCleanSearch,
												action: LocalizationService.Buttons.getButtonTitle(of: .stop),
												cancel: LocalizationService.Buttons.getButtonTitle(of: .cancel))
					case .resetSingleCleanSearch:
						return AlertDescription(title: Localization.AlertController.AlertTitle.stopSearch,
												description: Localization.AlertController.AlertMessage.stopSearchingProcess, action: LocalizationService.Buttons.getButtonTitle(of: .stop),
												cancel: LocalizationService.Buttons.getButtonTitle(of: .cancel))
					case .resetSmartSingleCleanSearch:
						return AlertDescription(title: Localization.AlertController.AlertTitle.stopSearch,
												description: Localization.AlertController.AlertMessage.stopSearchingProcess, action: LocalizationService.Buttons.getButtonTitle(of: .stop),
												cancel: LocalizationService.Buttons.getButtonTitle(of: .cancel))
					case .resetDeepCleanDelete:
						return AlertDescription(title: Localization.AlertController.AlertTitle.notice,
												description: Localization.AlertController.AlertMessage.stopDeepCleanDeleteProcess, action: LocalizationService.Buttons.getButtonTitle(of: .stop),
												cancel: LocalizationService.Buttons.getButtonTitle(of: .cancel))
					case .resetDeepCleanResults:
						return AlertDescription(title: Localization.AlertController.AlertTitle.notice,
												description: Localization.AlertController.AlertMessage.resetResults,
												action: LocalizationService.Buttons.getButtonTitle(of: .exit),
												cancel: LocalizationService.Buttons.getButtonTitle(of: .cancel))
				}
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
					case .photoWithLocationIsEmpty:
						return Localization.ErrorsHandler.EmptyResultsError.photoWithLocationIsEmpty
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
			
			let description = ErrorDescription(title: title, message: message, buttonTitle: buttonTitle)
			return description
		}
		
		public static func getCompressionErrorDescriptionForKey(_ compressionError: ErrorHandler.CompressionError, error: Error?) -> ErrorDescription {
			
			let actionButtonTitle = LocalizationService.Buttons.getButtonTitle(of: .ok)
			
			var title: String {
				switch compressionError {
					case .operationIsCanceled, .resolutionIsBigger:
						return ErrorHandler.errorTitle.attention.rawValue
					default:
						return ErrorHandler.errorTitle.error.rawValue
				}
			}
			
			var message: String {
				switch compressionError {
						
					case .cantLoadFile:
						return Localization.ErrorsHandler.CompressionError.cantLoadFile
					case .compressionFailed:
						if let error = error {
							return Localization.ErrorsHandler.CompressionError.compressionFailed +  " \(error.localizedDescription)"
						} else {
							return Localization.ErrorsHandler.CompressionError.compressionFailed
						}
					case .resolutionIsBigger:
						return Localization.ErrorsHandler.CompressionError.resolutionError
					case .errorSavedFile:
						return Localization.ErrorsHandler.CompressionError.savedError
					case .noVideoFile:
						return Localization.ErrorsHandler.CompressionError.noVideoFile
					case .removeAudio:
						return Localization.ErrorsHandler.CompressionError.audioError
					case .operationIsCanceled:
						return Localization.ErrorsHandler.CompressionError.isCanceled
				}
			}
			return ErrorDescription(title: title, message: message, buttonTitle: actionButtonTitle)
		}
		
		public static func getDeepCleanDescriptionForKey(_ error: ErrorHandler.DeepCleanProcessingError) -> ErrorDescription {
			
			let actionButtonTitle = LocalizationService.Buttons.getButtonTitle(of: .ok)
			
			var title: String {
				switch error {
					case .error:
						return Localization.ErrorsHandler.Title.notice
				}
			}
			
			var message: String {
				switch error {
					case .error:
						return Localization.ErrorsHandler.DeepCleanError.completeWithError
				}
			}
			
			return ErrorDescription(title: title, message: message, buttonTitle: actionButtonTitle)
		}
		
		public static func deleteErrorDescription(_ error: ErrorHandler.DeleteError) -> ErrorDescription {
			let actionButton = LocalizationService.Buttons.getButtonTitle(of: .ok)
			let title = ErrorHandler.errorTitle.error.rawValue
			let message = ErrorHandler.shared.deleteErrorForKey(error)
			return ErrorDescription(title: title, message: message, buttonTitle: actionButton)
		}
		
		public static func mergeErrorDescription(_ error: ErrorHandler.MeergeError) -> ErrorDescription {
			let actionButton = LocalizationService.Buttons.getButtonTitle(of: .ok)
			let title = ErrorHandler.errorTitle.attention.rawValue
			let message = ErrorHandler.shared.mergeErrorForKey(error)
			return ErrorDescription(title: title, message: message, buttonTitle: actionButton)
		}
		
		public static func leadErrorDescription(_ error: ErrorHandler.LoadError) -> ErrorDescription {
			let actionButton = LocalizationService.Buttons.getButtonTitle(of: .ok)
			let title = ErrorHandler.errorTitle.error.rawValue
			let message = ErrorHandler.shared.loadErrorForKey(error)
			return ErrorDescription(title: title, message: message, buttonTitle: actionButton)
		}
		
		public static func fatalErrorDescription(_ error: ErrorHandler.FatalError) -> ErrorDescription {
			let actionButton = LocalizationService.Buttons.getButtonTitle(of: .ok)
			let title = ErrorHandler.errorTitle.fatalError.rawValue
			let message = ErrorHandler.shared.fatalErrorForKey(error)
			return ErrorDescription(title: title, message: message, buttonTitle: actionButton)
		}
	}
	
	struct MediaContent {
		
		public static func getContentName(of type: PhotoMediaType) -> String {
			switch type {
				case .similarPhotos:
					return Localization.Main.MediaContentTitle.similarPhoto
				case .duplicatedPhotos:
					return Localization.Main.MediaContentTitle.duplicatePhoto
				case .singleScreenShots:
					return Localization.Main.MediaContentTitle.singleScreenShots
				case .singleLivePhotos:
					return Localization.Main.MediaContentTitle.singleLivePhotos
				case .similarLivePhotos:
					return Localization.Main.MediaContentTitle.similarLivePhoto
				case .similarSelfies:
					return Localization.Main.MediaContentTitle.similarSelfies
				case .locationPhoto:
					return Localization.Main.Title.location
				case .singleLargeVideos:
					return Localization.Main.MediaContentTitle.largeVideo
				case .duplicatedVideos:
					return Localization.Main.MediaContentTitle.duplicatedVideos
				case .similarVideos:
					return Localization.Main.MediaContentTitle.similarVideo
				case .singleScreenRecordings:
					return Localization.Main.MediaContentTitle.singleScreenRecordings
				case .compress:
					return Localization.Main.MediaContentTitle.compression
				case .allContacts:
					return Localization.Main.MediaContentTitle.allContacts
				case .emptyContacts:
					return Localization.Main.MediaContentTitle.emptyContacts
				case .duplicatedContacts:
					return Localization.Main.MediaContentTitle.duplicatedContacts
				case .duplicatedPhoneNumbers:
					return Localization.Main.MediaContentTitle.duplicatedPhoneNumbers
				case .duplicatedEmails:
					return Localization.Main.MediaContentTitle.duplucatedEmails
				case .backup:
					return Localization.Main.MediaContentTitle.backup
				default:
					return L.empty
			}
		}
	}
	
	struct DeepClean {
		
		public static func getProgressTitle(of type: DeepCleaningType) -> String {
			switch type {
				case .prepareCleaning:
					return Localization.Main.ProcessingState.DeepCleanProcessingTitle.prepareClen
				case .photoCleaning:
					return Localization.Main.ProcessingState.DeepCleanProcessingTitle.photoClean
				case .contactsEmptyCleaning:
					return Localization.Main.ProcessingState.DeepCleanProcessingTitle.emptyContactsClean
				case .contactsMergeCleaning:
					return Localization.Main.ProcessingState.DeepCleanProcessingTitle.contactsMergeClean
				case .contactsDeleteCleaning:
					return Localization.Main.ProcessingState.DeepCleanProcessingTitle.contactsDeleteClean
			}
		}
		
		public static func getButtonTitle(by state: DeepCleanButtonState) -> String {
			switch state {
				case .startDeepClen:
					return Localization.Main.ProcessingState.DeepCleanButtonState.startDeepClean.uppercased()
				case .startAnalyzing:
					return Localization.Main.ProcessingState.DeepCleanButtonState.startAnalyzing.uppercased()
				case .stopAnalyzing:
					return Localization.Main.ProcessingState.DeepCleanButtonState.stopAnalyzing.uppercased()
				case .startCleaning:
					return Localization.Main.ProcessingState.DeepCleanButtonState.startCleaning.uppercased()
			}
		}
	}
	
	struct Compression {
		
		public static func getCompressionSectionName(of type: CustomCompressionSection) -> String {
			switch type {
				case .resolution:
					return Localization.Main.HeaderTitle.resolution
				case .fps:
					return Localization.Main.HeaderTitle.fps
				case .videoBitrate:
					return Localization.Main.HeaderTitle.videoBitrate
				case .keyframe:
					return Localization.Main.HeaderTitle.keyframe
				case .audioBitrate:
					return Localization.Main.HeaderTitle.audioBitrate
				case .none:
					return Localization.none
			}
		}
	}
	
	struct Subscription {
		
		public static func getPremiumFeaturesTitle(of type: PremiumFeature) -> String {
			switch type {
				case .deepClean:
					return Localization.Subscription.PremiumFeautures.deepClean
				case .multiselect:
					return Localization.Subscription.PremiumFeautures.multiselect
				case .compression:
					return Localization.Subscription.PremiumFeautures.compression
				case .location:
					return Localization.Subscription.PremiumFeautures.location
			}
		}
	}
}

extension LocalizationService {
	
	public static func getLimitAccessAlertDescription(for type: LimitAccessType) -> AlertDescription {
		
		var alertTitle: String {
			switch type {
				default:
					return L.empty
			}
		}
		
		let limitStringCount = String(type.selectAllLimit)
		
		var alertDescription: String {
			switch type {
				case .selectAllPhotos:
					return Localization.Subscription.LimitAlertMessage.selectAllPhotos.replacingOccurrences(of: "%20", with: limitStringCount)
				case .selectAllVideos:
					return Localization.Subscription.LimitAlertMessage.selectAllVideos.replacingOccurrences(of: "%20", with: limitStringCount)
				case .selectAllContacts:
					return Localization.Subscription.LimitAlertMessage.selectAllContacts.replacingOccurrences(of: "%20", with: limitStringCount)
				case .selectAllContactsGroups:
					return Localization.Subscription.LimitAlertMessage.selectAllContactsGroup.replacingOccurrences(of: "%20", with: limitStringCount)
				case .deepClean:
					return Localization.Subscription.LimitAlertMessage.deepClean
				default:
					return L.empty
			}
		}
		
		var action: String {
			switch type {
				case .deepClean:
					return LocalizationService.Buttons.getButtonTitle(of: .ok)
				default:
					return LocalizationService.Buttons.getButtonTitle(of: .learnMore)
			}
		}
		
		var cancelAction: String {
			switch type {
				case .deepClean:
					return L.empty
				default:
					return LocalizationService.Buttons.getButtonTitle(of: .cancel)
			}
		}
		
		return AlertDescription(title: alertTitle,
								description: alertDescription,
								action: action,
								cancel: cancelAction)
	}
	
	public static func getLimitMessageDescription(for type: LimitAccessType) -> MessageDescription {
		
		let title = Localization.Subscription.LimitMessage.unlock
		
		var message: String {
			switch type {
				case .selectPhotos:
					return Localization.Subscription.LimitMessage.photoSelectExceeded
				case .selectVideo:
					return Localization.Subscription.LimitMessage.videoSelectExceeded
				case .selectContact:
					return Localization.Subscription.LimitMessage.contactsSelectExceeded
				case .selectContactGroup:
					return Localization.Subscription.LimitMessage.contactsGroupSelectExceeded
				default:
					return L.empty
			}
		}
		
		var image: UIImage? {
			return Images.messages.getLimitExceededImage(of: type, with: 50)
		}
		
		return MessageDescription(title: title, message: message, image: image)
	}
}
