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
















	

#warning("REFACTORING->>>> ")
extension ErrorHandler {
	

	enum errorTitle: Error {
		case error
		case fatalError
		case attention
		
		var title: String {
			switch self {
				case .error:
					return "Error"
				case .fatalError:
					return "Fatal Error"
				case .attention:
					return "Atention"
			}
		}
	}
	
	enum DeleteError: Error {
        case errorDeleteContact
        case errorDeleteContacts
		case errorDeletePhoto
		case errorDeleteVideo
    }
    
	enum MeergeError: Error {
        case errorMergeContact
        case errorMergeContacts
        case mergeWithErrors
    }
    
	enum LoadError: Error {
        case errorLoadContacts
        case errorCreateExportFile
    }
	

	

	enum FatalError: Error {
		case datePickerMinimumDateError
		
		var errorRawValue: String {
			switch self {
				case .datePickerMinimumDateError:
					return "Cannot set a maximum date that is equal or less than the minimum date."
			}
		}
	}
	
	enum CompressionError: Error {
		case cantLoadFile
		case compressionFailed
		case resolutionIsBigger
		case errorSavedFile
		case noVideoFile
		case removeAudio
		case operationIsCanceled
		
		var withCancel: Bool {
			switch self {
				case .cantLoadFile:
					return false
				case .compressionFailed:
					return false
				case .resolutionIsBigger:
					return true
				case .errorSavedFile:
					return false
				case .noVideoFile:
					return false
				case .removeAudio:
					return false
				case .operationIsCanceled:
					return false
			}
		}
		
		var title: String {
			switch self {
				case .cantLoadFile:
					return errorTitle.error.title
				case .compressionFailed:
					return errorTitle.error.title
				case .resolutionIsBigger:
					return errorTitle.attention.title
				case .errorSavedFile:
					return errorTitle.error.title
				case .noVideoFile:
					return errorTitle.error.title
				case .removeAudio:
					return errorTitle.error.title
				case .operationIsCanceled:
					return errorTitle.attention.title
			}
		}
		
		var errorMessage: String {
			switch self {
				case .cantLoadFile:
					return "cant load video file"
				case .compressionFailed:
					return "compression vide file are failed"
				case .resolutionIsBigger:
					return "resolution in settings are bigger than original video resolution"
				case .errorSavedFile:
					return "cant save compressed file"
				case .noVideoFile:
					return "no video file"
				case .removeAudio:
					return "cant remove audioComponent"
				case .operationIsCanceled:
					return "operation is canceled"
			}
		}

	}
	
    private func deleteErrorForKey(_ error: DeleteError) -> String {
        switch error {
            case .errorDeleteContact:
                return "can't delete contact"
            case .errorDeleteContacts:
                return "can't delete contacts"
			case .errorDeletePhoto:
				return "error delete photo"
			case .errorDeleteVideo:
				return "error delete video"
		}
    }
    
    private func mergeErrorForKey(_ error: MeergeError) -> String {
        switch error {
            case .errorMergeContact:
                return "error merge contact"
            case .errorMergeContacts:
                return "error merge contacts"
            case .mergeWithErrors:
                return "merge with errors"
        }
    }
    
    private func loadErrorForKey(_ error: LoadError) -> String {
        switch error {
            case .errorLoadContacts:
                return "error loading contacts"
            case .errorCreateExportFile:
                return "error create export file"
        }
    }
	
	private func fatalErrorForKey(_ error: FatalError) -> String {
		switch error {
			case .datePickerMinimumDateError:
				return error.errorRawValue
		}
	}
}

extension ErrorHandler {
	
    public func showDeleteAlertError(_ errorType: DeleteError) {
        let alertTitle = ""
		let alertAction = UIAlertAction(title: AlertHandler.AlertActionsButtons.ok.title, style: .default)
		A.showAlert(alertTitle, message: deleteErrorForKey(errorType), actions: [alertAction], withCancel: false, style: .alert, completion: nil)
    }
    
    public func showLoadAlertError(_ errorType: LoadError) {
		let alertTitle = errorTitle.error.title
		A.showAlert(alertTitle, message: loadErrorForKey(errorType), actions: [], withCancel: false, style: .alert, completion: nil)
    }
    
    public func showMergeAlertError(_ errorType: MeergeError, completion: (() -> Void)? = nil) {
		let alertTitle = errorTitle.error.title
		A.showAlert(alertTitle, message: mergeErrorForKey(errorType), actions: [], withCancel: false, style: .alert) {
            completion?()
        }
    }
	
	public func showFatalErrorAlert(_ errorType: FatalError, completion: (() -> Void)? = nil) {
		let alertTitle = errorTitle.fatalError.title
		A.showAlert(alertTitle, message: fatalErrorForKey(errorType), actions: [], withCancel: false, style: .alert, completion: nil)
	}
	

}



extension ErrorHandler {
	
	public func showCompressionErrorFor(_ errorType: CompressionError, completion: @escaping () -> Void) {
		
		let errorAction = UIAlertAction(title: errorType.title, style: .default) { _ in
			completion()
		}
		
		let actions = errorType.withCancel ? [errorAction] : []
		
		A.showAlert(errorType.title, message: errorType.errorMessage, actions: actions, withCancel: errorType.withCancel, style: .alert) {}
	}
}

