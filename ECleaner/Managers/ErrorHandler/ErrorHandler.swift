//
//  ErrorHandler.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.11.2021.
//
import Foundation
import UIKit

class ErrorHandler {
    
    static let shared: ErrorHandler = {
        let instance = ErrorHandler()
        return instance
    }()
	
	enum errorTitle: Error {
		case error
		case fatalError
		case attention
		case notice
		
		var rawValue: String {
			switch self {
				case .error:
					return Localization.ErrorsHandler.Title.error
				case .fatalError:
					return Localization.ErrorsHandler.Title.fatalError
				case .attention:
					return Localization.ErrorsHandler.Title.atention
				case .notice:
					return Localization.ErrorsHandler.Title.notice
			}
		}
	}	
}

//	MARK: - Permission Access Restricted Errors -
extension ErrorHandler {
	
	enum AccessRestrictedError: Error {
		case contactsRestrictedError
		case photoLibraryRestrictedError
		
		var alertDescription: AlertDescription {
			return LocalizationService.Alert.Permissions.restrictedPermissionDescription(for: self)
		}
	}

	public func showRestrictedErrorAlert(_ errorType: AccessRestrictedError, at viewController: UIViewController, completionHandler: @escaping () -> Void) {
		switch errorType {
			case .contactsRestrictedError:
				AlertManager.showPermissionAlert(of: .restrictedContacts, at: viewController)
				completionHandler()
			case .photoLibraryRestrictedError:
				AlertManager.showPermissionAlert(of: .restrictedPhotoLibrary, at: viewController)
				completionHandler()
		}
	}
}

//	MARK: - Empty Search Results Errors -
extension ErrorHandler {
	
	enum EmptyResultsError: Error {
		case photoLibrararyIsEmpty
		case videoLibrararyIsEmpty
		case similarPhotoIsEmpty
		case duplicatedPhotoIsEmpty
		case screenShotsIsEmpty
		case similarSelfiesIsEmpty
		case livePhotoIsEmpty
		case similarLivePhotoIsEmpty
		case largeVideoIsEmpty
		case duplicatedVideoIsEmpty
		case similarVideoIsEmpty
		case screenRecordingIsEmpty
		case contactsIsEmpty
		case emptyContactsIsEmpty
		case duplicatedNamesIsEmpty
		case duplicatedNumbersIsEmpty
		case duplicatedEmailsIsEmpty
		case deepCleanResultsIsEmpty
	}
	
	public func showEmptySearchResultsFor(_ error: EmptyResultsError, completionHandler: (() -> Void)? = nil) {
		let errorDescription = LocalizationService.Errors.getEmptyErrorForKey(error)
		AlertManager.presentErrorAlert(with: errorDescription) {
			completionHandler?()
		}
	}
}

//	MARK: - Video Compression Errors Handler -

extension ErrorHandler {
	
	enum CompressionError: Error {
		case cantLoadFile
		case compressionFailed
		case resolutionIsBigger
		case errorSavedFile
		case noVideoFile
		case removeAudio
		case operationIsCanceled
	}
	
	public func showCompressionError(_ compressionError: CompressionError,_ error: Error? = nil , completionHandler: (() -> Void)? = nil) {
		let errorDescription = LocalizationService.Errors.getCompressionErrorDescriptionForKey(compressionError, error: error)
		AlertManager.presentErrorAlert(with: errorDescription) {
			completionHandler?()
		}
	}
}

extension ErrorHandler {
	
	enum DeepCleanProcessingError: Error {
		case error
	}
	
	public func showDeepCleanErrorForkey(_ error: DeepCleanProcessingError, completionHandler: (() -> Void)? = nil) {
		let errorDescription = LocalizationService.Errors.getDeepCleanDescriptionForKey(error)
		AlertManager.presentErrorAlert(with: errorDescription) {
			completionHandler?()
		}
	}
}

extension ErrorHandler {
		
	enum DeleteError: Error {
        case errorDeleteContacts
		case errorDeletePhoto
		case errorDeleteVideo
		
		var errorDescription: ErrorDescription {
			return LocalizationService.Errors.deleteErrorDescription(self)
		}
    }
	
	public func deleteErrorForKey(_ error: DeleteError) -> String {
		switch error {
			case .errorDeleteContacts:
				return Localization.ErrorsHandler.DeleteError.deleteContactsError
			case .errorDeletePhoto:
				return Localization.ErrorsHandler.DeleteError.deletePhotoError
			case .errorDeleteVideo:
				return Localization.ErrorsHandler.DeleteError.deleteVideoError
		}
	}
}

extension ErrorHandler {
    
	enum MeergeError: Error {
        case errorMergeContacts
        case mergeWithErrors
		
		var errorDescription: ErrorDescription {
			return LocalizationService.Errors.mergeErrorDescription(self)
		}
    }
	
	public func mergeErrorForKey(_ error: MeergeError) -> String {
		switch error {
			case .errorMergeContacts:
				return Localization.ErrorsHandler.MergeError.errorMergeContact
			case .mergeWithErrors:
				return Localization.ErrorsHandler.MergeError.mergeContactsError
		}
	}
}

extension ErrorHandler {

	enum LoadError: Error {
        case errorLoadContacts
        case errorCreateExportFile
		
		var errorDescription: ErrorDescription {
			return LocalizationService.Errors.leadErrorDescription(self)
		}
    }

	public func loadErrorForKey(_ error: LoadError) -> String {
		switch error {
			case .errorLoadContacts:
				return Localization.ErrorsHandler.Errors.errorLoadContact
			case .errorCreateExportFile:
				return Localization.ErrorsHandler.Errors.errorCreateExpoert
		}
	}
}

extension ErrorHandler {
	
	enum FatalError: Error {
		case datePickerMinimumDateError
		
		var errorRawValue: String {
			switch self {
				case .datePickerMinimumDateError:
					return Localization.ErrorsHandler.Errors.minimumPickerError
			}
		}
		
		var errorDescription: ErrorDescription {
			return LocalizationService.Errors.fatalErrorDescription(self)
		}
	}

	public func fatalErrorForKey(_ error: FatalError) -> String {
		switch error {
			case .datePickerMinimumDateError:
				return error.errorRawValue
		}
	}
}

extension ErrorHandler {
	
    public func showDeleteAlertError(_ errorType: DeleteError) {
		AlertManager.presentErrorAlert(with: errorType.errorDescription)
    }
    
    public func showLoadAlertError(_ errorType: LoadError) {
		AlertManager.presentErrorAlert(with: errorType.errorDescription)
    }
    
	public func showMergeAlertError(_ errorType: MeergeError, compltionHandler: (() -> Void)? = nil) {
		AlertManager.presentErrorAlert(with: errorType.errorDescription) {
			compltionHandler?()
		}
    }
	
	public func showFatalErrorAlert(_ errorType: FatalError) {
		AlertManager.presentErrorAlert(with: errorType.errorDescription)
	}
}
