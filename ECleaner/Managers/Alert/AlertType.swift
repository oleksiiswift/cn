//
//  AlertType.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.11.2021.
//

import UIKit

enum AlertType {
	
		/// `access module`
	case contactsRestricted
	case photoLibraryRestricted
	
	case allowNotification
	case allowConstacStore
	case allowPhotoLibrary
		///  `empty search`
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
	

		/// `permite delete`
    case allowDeleteSelectedPhotos
    case withCancel
		
		/// `set break alerts`
	case setBreakDeepCleanSearch
	case setBreakSingleCleanSearch
	case setBreakDeepCleanDelete
	case resetDeepCleanResults
    
    /// `contacts module`
        /// ask
    case deleteContacts
    case deleteContact
    case mergeContacts
    case mergeContact
        /// done
    case suxxessDeleteContact
    case suxxessDeleteContacts
    case suxxessMergedContact
    case suxxessMergedContacts
    
    case none
    
    /// alert title
    var alertTitle: String? {
        switch self {
				
//				MARK: access error
			case .contactsRestricted:
				return ErrorHandler.AccessRestrictedError.contactsRestrictedError.title
				
			case .photoLibraryRestricted:
				return ErrorHandler.AccessRestrictedError.photoLibraryRestrictedError.title
				
					//				MARK: permition alert
			case .allowNotification:
				return AlertHandler.AllowAccessHandler.notification.title
			case .allowConstacStore:
				return AlertHandler.AllowAccessHandler.contactStore.title
			case .allowPhotoLibrary:
				return AlertHandler.AllowAccessHandler.photoLibrary.title

//				MARK: no searching data
			case .similarPhotoIsEmpty,
					.duplicatedPhotoIsEmpty,
					.screenShotsIsEmpty,
					.selfiesIsEmpty,
					.livePhotoIsEmpty,
					.similarLivePhotoIsEmpty,
					.recentlyDeletedPhotosIsEmpty,
					.largeVideoIsEmpty,
					.duplicatedVideoIsEmpty,
					.similarVideoIsEmpty,
					.screenRecordingIsEmpty,
					.recentlyDeletedVideosIsEmpty,
					.contactsIsEmpty,
					.emptyContactsIsEmpty,
					.duplicatedNamesIsEmpty,
					.duplicatedNumbersIsEmpty,
					.duplicatedEmailsIsEmpty:
				return ErrorHandler.shared.emptyResultsErrorTitle()
				
			case .setBreakDeepCleanSearch, .setBreakSingleCleanSearch:
				return "stop search process?"
			case .setBreakDeepCleanDelete:
				return "stop cleaningProcess?"
			case .resetDeepCleanResults:
				return "Atension!"

            case .withCancel:
                return ""
            case .allowDeleteSelectedPhotos:
                return "locomark delete assets?"
            case .deleteContacts:
                return "delete contacts"
            case .deleteContact:
                return "delete contact"
            case .mergeContacts:
                return "merge selected"
            case .mergeContact:
                return "merge contact"
            case .suxxessDeleteContact, .suxxessDeleteContacts:
                return "good need locale"
            case .suxxessMergedContact, .suxxessMergedContacts:
                return "good merged locale"
			case .none:
				return ""
		}
    }
    
    /// alert message
    var alertMessage: String? {
        
        switch self {
//				MARK: access error
			case .contactsRestricted:
				return ErrorHandler.AccessRestrictedError.contactsRestrictedError.errorRawValue
			case .photoLibraryRestricted:
				return ErrorHandler.AccessRestrictedError.photoLibraryRestrictedError.errorRawValue

//				MARK: allow access for content
			case .allowNotification:
				return AlertHandler.AllowAccessHandler.notification.message
			case .allowConstacStore:
				return AlertHandler.AllowAccessHandler.contactStore.message
			case .allowPhotoLibrary:
				return AlertHandler.AllowAccessHandler.photoLibrary.message
				
//				MARK: no searching data
			case .similarPhotoIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.similarPhotoIsEmpty)
			case .duplicatedPhotoIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.duplicatedPhotoIsEmpty)
			case .screenShotsIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.screenShotsIsEmpty)
			case .selfiesIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.selfiesIsEmpty)
			case .livePhotoIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.livePhotoIsEmpty)
			case .similarLivePhotoIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.similarLivePhotoIsEmpty)
			case .recentlyDeletedPhotosIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.recentlyDeletedPhotosIsEmpty)
			case .largeVideoIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.recentlyDeletedPhotosIsEmpty)
			case .duplicatedVideoIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.largeVideoIsEmpty)
			case .similarVideoIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.similarVideoIsEmpty)
			case .screenRecordingIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.screenRecordingIsEmpty)
			case .recentlyDeletedVideosIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.recentlyDeletedVideosIsEmpty)
			case .contactsIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.contactsIsEmpty)
			case .emptyContactsIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.emptyContactsIsEmpty)
			case .duplicatedNamesIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.duplicatedNamesIsEmpty)
			case .duplicatedNumbersIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.duplicatedNumbersIsEmpty)
			case .duplicatedEmailsIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.duplicatedEmailsIsEmpty)
				
			case .setBreakDeepCleanSearch:
				return "this will reset all search progress"
			case .setBreakSingleCleanSearch:
				return "stop executing search process"
			case .setBreakDeepCleanDelete:
				return "this will stop cleaning process"
			case .resetDeepCleanResults:
				return "by quitting all search results will be loose"
				
//				MARK: delete merge sections
			case .allowDeleteSelectedPhotos:
				return "delete selecteds assets are you shure????"
			case .deleteContacts:
				return "shure delete contacts"
			case .deleteContact:
				return "shure delete contact"
			case .mergeContacts:
				return "merge selected contacts"
			case .mergeContact:
				return "merge contacts"
			case .suxxessDeleteContact:
				return "contact deleted"
			case .suxxessDeleteContacts:
				return "contacts deleted"
			case .suxxessMergedContact:
				return "cintact suxx merged"
			case .suxxessMergedContacts:
				return "contacts suxx merged"
				
//				MARK: cancel none
            case .withCancel:
                return "cancel"
            case .none:
                return "none"
		}
    }
    
//    /// alert or action sheet
    var alertStyle: UIAlertController.Style {
        if U.isIpad {
            return .alert
        } else {
            return .alert
        }
    }
    
    var withCancel: Bool {
        switch self {
				
			case .contactsRestricted, .photoLibraryRestricted:
				return true
				
			case .similarPhotoIsEmpty,
					.duplicatedPhotoIsEmpty,
					.screenShotsIsEmpty,
					.selfiesIsEmpty,
					.livePhotoIsEmpty,
					.similarLivePhotoIsEmpty,
					.recentlyDeletedPhotosIsEmpty,
					.largeVideoIsEmpty,
					.duplicatedVideoIsEmpty,
					.similarVideoIsEmpty,
					.screenRecordingIsEmpty,
					.recentlyDeletedVideosIsEmpty,
					.contactsIsEmpty,
					.emptyContactsIsEmpty,
					.duplicatedNamesIsEmpty,
					.duplicatedNumbersIsEmpty,
					.duplicatedEmailsIsEmpty:
				return false
				
            case .allowNotification, .allowConstacStore, .allowPhotoLibrary, .allowDeleteSelectedPhotos, .withCancel:
                return true
			case .setBreakDeepCleanSearch, .setBreakSingleCleanSearch, .setBreakDeepCleanDelete, .resetDeepCleanResults:
				return true
            case .deleteContacts, .mergeContacts, .deleteContact, .mergeContact:
                return true
            case .suxxessDeleteContact, .suxxessDeleteContacts, .suxxessMergedContact, .suxxessMergedContacts:
                return false
            case .none:
                return false
        }
    }
}
