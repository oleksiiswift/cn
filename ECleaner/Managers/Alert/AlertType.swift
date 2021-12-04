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
    case allowDeleteSelectedPhotos
    case withCancel
    
    case noSimiliarPhoto
    case noDuplicatesPhoto
    case noScreenShots
    case noSelfie
    case noLivePhoto
    case noLargeVideo
    case noDuplicatesVideo
    case noSimilarVideo
    case noScreenRecording
    
    case noRecentlyDeletedPhotos
    case noRecentlyDeletedVideos
	
	case setBreakDeepCleanSearch
    


    
    /// `contacts module`
		/// empty
	case contactsIsEmpty
	case emptyContactsIsEmpty
	case duplicatesNamesIsEmpty
	case duplicatesNumbersIsEmpty
	case duplicatesEmailsIsEmpty
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
				
			case .contactsRestricted:
				return ErrorHandler.AccessRestrictedError.contactsRestrictedError.title
				
			case .photoLibraryRestricted:
				return ErrorHandler.AccessRestrictedError.photoLibraryRestrictedError.title
				
				
				

            case .allowNotification:
                return "locomark set title for allow notification"
            case .allowConstacStore:
                return "locomark set title for contacts"
            case .allowPhotoLibrary:
                return "locomark set title for photo library"
            case .withCancel:
                return ""
            case .allowDeleteSelectedPhotos:
                return "locomark delete assets?"
            case .noSimiliarPhoto:
                return "locomark no similar photos"
            case .noDuplicatesPhoto:
                return "locomark no duplicates photo"
            case .noScreenShots:
                return "locomark no screen shots"
            case .noSelfie:
                return "locomark no selfie"
            case .noLivePhoto:
                return "locomark no live photo"
            case .none:
                return ""
            case .noLargeVideo:
                return "locomark no large video files"
            case .noDuplicatesVideo:
                return "locomark no duplicated video"
            case .noSimilarVideo:
                return "locomark no similiar video"
            case .noScreenRecording:
                return "locomark no screen recordings"
            case .noRecentlyDeletedPhotos:
                return "locomark no recently deleted photos"
            case .noRecentlyDeletedVideos:
                return "locomark no recently deleted vides"
            case .contactsIsEmpty:
                return "contacts book is empty"
            case .emptyContactsIsEmpty:
                return "no empty contacts"
            case .duplicatesNamesIsEmpty:
                return "no duplicates"
            case .duplicatesNumbersIsEmpty:
                return "no duplicates"
            case .duplicatesEmailsIsEmpty:
                return "no duplicates"
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
			case .setBreakDeepCleanSearch:
				return "stop search process?"
		}
    }
    
    /// alert message
    var alertMessage: String? {
        
        switch self {
			case .contactsRestricted:
				return ErrorHandler.AccessRestrictedError.contactsRestrictedError.errorRawValue
			case .photoLibraryRestricted:
				return ErrorHandler.AccessRestrictedError.photoLibraryRestrictedError.errorRawValue
				
				
            case .allowNotification:
                return "locomark notification message"
            case .allowConstacStore:
                return "locomark contacts message"
            case .allowPhotoLibrary:
                return "locomark library photo"
            case .withCancel:
                return "cancel"
            case .none:
                return "none"
            case .allowDeleteSelectedPhotos:
                return "delete selecteds assets are you shure????"
            case .noSimiliarPhoto, .noDuplicatesPhoto, .noScreenShots, .noSelfie, .noLivePhoto, .noLargeVideo, .noDuplicatesVideo, .noSimilarVideo, .noScreenRecording:
                return "locomark no content"
            case .noRecentlyDeletedPhotos:
                return "recently deleted photos empty"
            case .noRecentlyDeletedVideos:
                return "recently deleted videos empty"
            case .contactsIsEmpty:
                return "contacts book is empty"
            case .emptyContactsIsEmpty:
                return "no empty contacts"
            case .duplicatesNamesIsEmpty:
                return "no duplicates"
            case .duplicatesNumbersIsEmpty:
                return "no duplicates"
            case .duplicatesEmailsIsEmpty:
                return "no duplicates"
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
			case .setBreakDeepCleanSearch:
				return "this will reset all search progress"
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
				
				
				
				
				
                
            case .allowNotification, .allowConstacStore, .allowPhotoLibrary, .allowDeleteSelectedPhotos, .withCancel:
                return true
            case .noSimiliarPhoto, .noDuplicatesPhoto, .noScreenShots, .noRecentlyDeletedPhotos, .noSelfie, .noLivePhoto:
                return false
            case .noLargeVideo, .noDuplicatesVideo, .noSimilarVideo, .noScreenRecording, .noRecentlyDeletedVideos:
                return false
			case .setBreakDeepCleanSearch:
				return true
            case .contactsIsEmpty, .emptyContactsIsEmpty, .duplicatesNamesIsEmpty, .duplicatesNumbersIsEmpty, .duplicatesEmailsIsEmpty:
                return false
            case .deleteContacts, .mergeContacts, .deleteContact, .mergeContact:
                return true
            case .suxxessDeleteContact, .suxxessDeleteContacts, .suxxessMergedContact, .suxxessMergedContacts:
                return false
            case .none:
                return false
        }
    }
}
