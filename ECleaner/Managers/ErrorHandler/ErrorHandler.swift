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
    
    enum DeleteError {
        case errorDeleteContact
        case errorDeleteContacts
		case errorDeletePhasset
    }
    
    enum MeergeError {
        case errorMergeContact
        case errorMergeContacts
        case mergeWithErrors
    }
    
    enum LoadError {
        case errorLoadContacts
        case errorCreateExportFile
    }
	
	enum AccessRestrictedError {
		case contactsRestrictedError
		case photoLibraryRestrictedError
		
		var title: String {
			switch self {
				case .contactsRestrictedError:
					return "permission denied"
				case .photoLibraryRestrictedError:
					return "permission denied"
			}
		}
		
		var errorRawValue: String {
			switch self {
				case .contactsRestrictedError:
					return "\(U.appName) does not have access to contacts. Please, allow the application to access to your contacts."
				case .photoLibraryRestrictedError:
					return "\(U.appName) does not have access to photo library. Please, allow the application to access to your photo library."
			}
		}
	}
	
	
	enum FatalError {
		case datePickerMinimumDateError
		
		var errorRawValue: String {
			switch self {
				case .datePickerMinimumDateError:
					return "Cannot set a maximum date that is equal or less than the minimum date."
			}
		}
	}
	
	enum EmptyResultsError {
		case similarPhotoIsEmpty
		case duplicatedPhotoIsEmpty
		case screenShotsIsEmpty
		case selfiesIsEmpty
		case livePhotoIsEmpty
		case similarLivePhotoIsEmpty
		case recentlyDeletedPhotosIsEmpty
		
		case largeVideoIsEmpty
		case duplicatedVideoIsEmpty
		case similarVideoIsEmpty
		case screenRecordingIsEmpty
		case recentlyDeletedVideosIsEmpty
		
		case contactsIsEmpty
		case emptyContactsIsEmpty
		case duplicatedNamesIsEmpty
		case duplicatedNumbersIsEmpty
		case duplicatedEmailsIsEmpty
	}
	
	private func deepCleanHandlerForKey(_ handler: DeepCleanStateHandler) -> String {
		switch handler {
			case .deepCleanCompleteWithErrors:
				return "deep clean complete witgh errors"
			case .deepCleanCompleteSuxxessfull:
				return "deep clean complete suxxessfully"
			case .deepCleanCanceled:
				return "deep clean canseled"
		}
	}

    private func deleteErrorForKey(_ error: DeleteError) -> String {
        switch error {
            case .errorDeleteContact:
                return "can't delete contact"
            case .errorDeleteContacts:
                return "can't delete contacts"
			case .errorDeletePhasset:
				return "error delete assets"
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
	
	public func emptyResultsForKey(_ error: EmptyResultsError) -> String {
		switch error {
			case .similarPhotoIsEmpty:
				return "np similar photo"
			case .duplicatedPhotoIsEmpty:
				return "no duplicated photo"
			case .screenShotsIsEmpty:
				return "no screenshots"
			case .selfiesIsEmpty:
				return "no selfies"
			case .livePhotoIsEmpty:
				return "no live photo"
			case .similarLivePhotoIsEmpty:
				return "no similar live photo found"
			case .recentlyDeletedPhotosIsEmpty:
				return "no recently deleted"
			case .largeVideoIsEmpty:
				return "no large files"
			case .duplicatedVideoIsEmpty:
				return "no duolicated video"
			case .similarVideoIsEmpty:
				return "np similar video"
			case .screenRecordingIsEmpty:
				return "no screen recordings"
			case .recentlyDeletedVideosIsEmpty:
				return "no recently deleted video"
			case .contactsIsEmpty:
				return "contacts book is empty"
			case .emptyContactsIsEmpty:
				return "no empty contacts"
			case .duplicatedNamesIsEmpty:
				return "no duplicated contacts found"
			case .duplicatedNumbersIsEmpty:
				return "no duplicated phone numbers found"
			case .duplicatedEmailsIsEmpty:
				return "no duplicated emails found"
		}
	}
	
	public func emptyResultsErrorTitle() -> String {
		return "Sorry, no content)"
	}
}

extension ErrorHandler {
	
	public func deepCleanCompleteStateHandler(for type: DeepCleanStateHandler) {
		let alertAction = UIAlertAction(title: "ok", style: .default)
		
		DispatchQueue.main.async {
			A.showAlert(type.titleHandler, message: self.deepCleanHandlerForKey(type), actions: [alertAction], withCancel: false, completion: nil)
		}
	}

	
    public func showDeleteAlertError(_ errorType: DeleteError) {
        let alertTitle = "Error"
        let alertAction = UIAlertAction(title: "ok", style: .default)
        A.showAlert(alertTitle, message: deleteErrorForKey(errorType), actions: [alertAction], withCancel: false, completion: nil)
    }
    
    public func showLoadAlertError(_ errorType: LoadError) {
        let alertTitle = "Error"
        A.showAlert(alertTitle, message: loadErrorForKey(errorType), actions: [], withCancel: false, completion: nil)
    }
    
    public func showMergeAlertError(_ errorType: MeergeError, completion: (() -> Void)? = nil) {
        let alertTitle = "Error"
        A.showAlert(alertTitle, message: mergeErrorForKey(errorType), actions: [], withCancel: false) {
            completion?()
        }
    }
	
	public func showFatalErrorAlert(_ errorType: FatalError, completion: (() -> Void)? = nil) {
		let alertTitle = "Fatal Error"
		A.showAlert(alertTitle, message: fatalErrorForKey(errorType), actions: [], withCancel: false, completion: nil)
	}
}

//	MARK: no foud searching data
extension ErrorHandler {
	
	public func showEmptySearchResultsFor(_ alertType: AlertType, completion: (() -> Void)? = nil) {
		let alertAction = UIAlertAction(title: "ok", style: .default) { _ in
			completion?()
		}
		A.showAlert(alertType.alertTitle, message: alertType.alertMessage, actions: [alertAction], withCancel: alertType.withCancel, completion: nil)
	}
}
