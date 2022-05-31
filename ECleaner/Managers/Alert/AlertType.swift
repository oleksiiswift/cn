//
//  AlertType.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.11.2021.
//

import UIKit





enum AlertTypeOLD {
	
	
	
		/// `permite delete`
    case allowDeleteSelectedPhotos
	case allowDeleteSelectedPhoto
	case allowDeleteSelectedVideos
	case allowDeleteSelectedVideo
	
    case withCancel
		
		/// `set break alerts`
	case setBreakDeepCleanSearch
	case setBreakSingleCleanSearch
	case setBreakSmartSingleCleanSearch
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
			
			case .photoLibraryIsEmpty:
				return ErrorHandler.errorTitle.error.title

//				MARK: no searching data
			case .similarPhotoIsEmpty,
					.duplicatedPhotoIsEmpty,
					.screenShotsIsEmpty,
					.similarSelfiesIsEmpty,
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
			case .deepCleanSearchinResultsIsEmpty:
				return ErrorHandler.shared.emptyResultsTitle(for: .deepCleanResultsIsEmpty)
			case .setBreakDeepCleanSearch, .setBreakSingleCleanSearch, .setBreakSmartSingleCleanSearch:
				return "stop search process?"
			case .setBreakDeepCleanDelete:
				return "stop cleaningProcess?"
			case .resetDeepCleanResults:
				return "Atension!"
            case .withCancel:
                return ""
            case .allowDeleteSelectedPhotos:
                return "locomark delete assets?"
			case .allowDeleteSelectedPhoto:
				return "locomark delete photo?"
			case .allowDeleteSelectedVideos:
				return "locomark delete videos"
			case .allowDeleteSelectedVideo:
				return "locomark delete video"
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
				
//				MARK: no searching data
			case .photoLibraryIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.photoLibrararyIsEmpty)
			case .similarPhotoIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.similarPhotoIsEmpty)
			case .duplicatedPhotoIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.duplicatedPhotoIsEmpty)
			case .screenShotsIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.screenShotsIsEmpty)
			case .similarSelfiesIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.similarSelfiesIsEmpty)
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
			case .deepCleanSearchinResultsIsEmpty:
				return ErrorHandler.shared.emptyResultsForKey(.deepCleanResultsIsEmpty)
				
			case .setBreakDeepCleanSearch:
				return "this will reset all search progress"
			case .setBreakSingleCleanSearch, .setBreakSmartSingleCleanSearch:
				return "stop executing search process"
			case .setBreakDeepCleanDelete:
				return "this will stop cleaning process"
			case .resetDeepCleanResults:
				return "by quitting all search results will be loose"
				
//				MARK: delete merge sections
			case .allowDeleteSelectedPhotos:
				return "delete selecteds assets are you shure????"
			case .allowDeleteSelectedPhoto:
				return "delete selected photo?"
			case .allowDeleteSelectedVideos:
				return "delete selected videos?"
			case .allowDeleteSelectedVideo:
				return "allow delete video"
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
            case .withCancel:
                return "cancel"
            case .none:
                return "none"
		}
    }
	

    
//    /// alert or action sheet
    var alertStyle: UIAlertController.Style {
		switch self {
			case .compressionvideoFileComplete:
				return .actionSheet
			default:
				return .alert
		}
    }
    
    var withCancel: Bool {
        switch self {
				
			case .photoLibraryIsEmpty,
					.similarPhotoIsEmpty,
					.duplicatedPhotoIsEmpty,
					.screenShotsIsEmpty,
					.similarSelfiesIsEmpty,
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
					.duplicatedEmailsIsEmpty,
					.deepCleanSearchinResultsIsEmpty:
				return false
				
            case .withCancel:
                return true
			case .allowDeleteSelectedPhotos, .allowDeleteSelectedPhoto, .allowDeleteSelectedVideos, .allowDeleteSelectedVideo:
				return true
			case .setBreakDeepCleanSearch, .setBreakSingleCleanSearch, .setBreakDeepCleanDelete, .resetDeepCleanResults, .setBreakSmartSingleCleanSearch:
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


enum AlertType {
	
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
}





