//
//  Localization.swift
//  ECleaner
//
//  Created by alexey sorochan on 31.05.2022.
//

import Foundation

typealias L = Localization
struct Localization {
	
	static var empty: String = ""
	
	struct Service {
		
		static let appName = U.appName
	}
	
	struct Permission {
		
		struct Name {
			static var notification = "Notification"
			static var photoLibrary = "Photo Library"
			static var contacts = "Contacts"
			static var tracking = "Tracking"
			static var libraryContacts = "Photo Library & Contacts"
		}
		
		struct Description {
			static var notification = "Allow application recieve notification."
			static var photoLibrary = "Access for search duplicated, simmilar photos and video in your gallery."
			static var contacts = "Access for your Contacts and phones, delete, merge and clean Contacts."
			static var tracking = "Allow to access app related data."
			static var libraryContacts = "Allow access to Contacts and Photo Library."
		}
		
		struct AlertService {
			struct Title {
				static var permissionDenied = "Permission Denied!"
				static var permissionAllowed = "Permission Alowed!"
				static var appTrack = "Allow App to Request to Track!"
				static var onePermissionRule = "Allow Permission!"
			}
			
			struct Description {
				static var openSettings = "Please, go to Settings for allow/denied permission."
				static var allowContactsAndPhoto = "\(Service.appName) does not have acces to Photo Library and Contacts. Please, allow the application access to your data for use Deep Clean Feature."
				static var appTrackDescription = "Allow app to ask tot track your activity accross other companies apps and websites."
				static var onePermissionRule = "Please allow at least one permission (Photo Library or Contacts) to use app."
			}
			
			struct Restricted {
				static var contacts = "\(Service.appName) does not have access to contacts. Please, allow the application to access to your contacts."
				static var photoLibrary = "\(Service.appName) does not have access to Photo Library. Please, allow the application to access to your Photo Library."
			}
		}
	}
	
	struct Purchase {
		
		struct Title {
			static let restoreFail = "Restore failed"
			static let nothingRestore = "Nothing to restore"
			static let purchaseRestored = "Restore completed."
			static let congratulation = "Congratulation!"
		}
		
		struct Message {
			static let purchaseRestored = "Restore completed."
			static let restoreFailed = "Please try restore later or contact support"
			static let expire = "Product is expired since"
			static let noPreviousPurchse = "No previous purchases were found"
			static let cantRestore = "Purchases can't restored. Product is expired since"
			static let noReciept = "Error. No receipt data. Try again."
			static let network = "Network error while verifying receipt"
			static let verification = "Error. Receipt verification failed. Try again."
			static let nothing = "Nothing to restore. No previous purchases were found."
		}
	}
	
	struct Notification {
		struct Title {
			static var contacts = "Clean up your contacts 🤷🏻‍♂️"
			static var photos = "Clean Up your Photos 📷"
			static var videos = "Clean Up Your Videos 🎥"
			static var deepClean = "Free Up Storage With Deep Clean 🧹"
			static var storage =  "Clean Up Storage ☁️"
		}
		
		struct Subtitle {}
		
		struct Body {
			static var contacts = "Anazlize and delete empty and duplicated contacts"
			static var photos = "Analize photo data for similar and duplicateds"
			static var videos = "Analize video data for similar and duplicateds"
			static var deepClean = "Analize your photo and video, contacts"
			static var storage =  "Delete Your duplicated and similar photos and videos. Clean contacts"
		}
	}
	
	struct Standart {
		
		struct Buttons {
			static var allowed = "Allowed"
			static var `continue` = "Continue"
			static var denied = "Denied"
			static var ok = "OK"
			static var cancel = "Cancel"
			static var settings = "Settings"
			static var delete = "Delete"
			static var stop = "Stop"
			static var exit = "Exit"
			static var share = "Share"
			static var save = "Save"
			static var selectAll = "Select All"
			static var deselectAll = "Select All"
			static var select = "Select"
			static var deselect = "Deselect"
			static var merge = "Merge"
		}
	}
	
	struct AlertController {
		struct AlertTitle {
			static var compressionComplete = "Compression Complete!"
			static var mergingContacts = "Merging Contacts"
			static var compressing = "Compressing"
			static var updatingContacts = "Updating Contacts"
			static var selectingContactsWait = "Selecting Contacts, wait"
			static var selectingVideosWait = "Selecting Videos, wait"
			static var selectingPhotosWait = "Selecting Photos, wait"
			static var prepareSearching = "Prepare Searching, wait"
			static var searchComplete = "Search complete!"
			static var deletingContact = "Deleting Contacts"
			static var deletingVideo = "Deleting Videos"
			static var deletingPhoto = "Deletting Photos"
			static var deletePhoto = "_deletePhoto".localized()
			static var deleteVideo = "_deleteVideo".localized()
			static var deleteContact = "_deleteContact".localized()
			static var mergeContacts = "Merge Contacts"
			static var mergeCompleted = "Merge Completed!"
			static var deleteContactsCompleted = "Delete Completed!"
			static var completeSuccessfully = "Complete Successfully!"
			static var operationIsCancel = "Operation is Canceling!"
			static var stopSearch = "Stop search process?"
			static var notice = "Notice!"
		}
		
		struct AlertMessage {
			static var compresssionComplete = "Video compression is successfully completed! filesize: "
			static var deletePhoto = "_deletingPhotos".localized()
			static var deleteVideo = "_deletingVideos".localized()
			static var deleteContact = "_deletingContacts".localized()
			static var mergeContacts = "Thess contacts will be merged. After the merging process is completed, unnecessary contacts will be automatically deleted."
			static var mergeCompleted = "Merge contacts successfully completed!"
			static var deleteContactsCompleted = "Delete successfully completed!"
			static var deepCleanComplete = "Deep Clean processing complete successfully!"
			static var deepCleanCancel = "Deep Clean Processing is Canceled!"
			static var resetDeepCleanSearch = "This will be reset all searching process!"
			static var stopSearchingProcess = "This will be stop searching process!"
			static var stopDeepCleanDeleteProcess = "This will be stop deleting process and reset all searching data!"
			static var resetResults = "By quiting all search results will be lose!"
		}
	}
	
	struct ErrorsHandler {
		
		struct Title {
			static var emptyResults = "Sorry, no content)"
			static var error = "Error!"
			static var fatalError = "Fatal Error!"
			static var atention = "Atention!"
			static var notice = "Notice!"
		}
		
		struct EmptyResultsError {
			static var photoLibrararyIsEmpty = "Photo Library is empty."
			static var videoLibrararyIsEmpty = "Video Library is empty."
			static var similarPhotoIsEmpty = "No similar photo."
			static var duplicatedPhotoIsEmpty = "No duplicated photo."
			static var screenShotsIsEmpty = "No screenshots."
			static var similarSelfiesIsEmpty = "No similar selfies."
			static var livePhotoIsEmpty = "No live photo."
			static var similarLivePhotoIsEmpty = "No similar live photo."
			static var largeVideoIsEmpty = "No large video."
			static var duplicatedVideoIsEmpty = "No duplucated video."
			static var similarVideoIsEmpty = "No similar video."
			static var screenRecordingIsEmpty = "No screen recording."
			static var contactsIsEmpty = "No Contacts found."
			static var emptyContactsIsEmpty = "No empty contacts."
			static var duplicatedNamesIsEmpty = "No duplicated contacts."
			static var duplicatedNumbersIsEmpty = "No duplicated phone numbers found."
			static var duplicatedEmailsIsEmpty = "No duplicated email found."
			static var deepCleanResultsIsEmpty = "Deep Clean search complete with with no similar or duplicated data found."
		}
		
		struct CompressionError {
			static var cantLoadFile = "Can't load video file."
			static var compressionFailed = "Video file compression failed."
			static var resolutionError = "Resolution saved in settings are bigger the origin video file resolution."
			static var savedError = "Can't save compressed video file."
			static var noVideoFile = "No video file."
			static var audioError = "Can't remove audio component from vide file."
			static var isCanceled = "Compression operation is canceled"
		}
		
		struct DeepCleanError {
			static var completeWithError = "Deep Clean processing complete with error!"
		}
		
		struct DeeleteError {
			static var deleteContactsError = "There is an error deleting contact(s)."
			static var deletePhotoError = "There is an error deleting photo(s)."
			static var deleteVideoError = "There is and error deleting video(s)."
		}
		
		struct MergeError {
			static var errorMergeContact = "Error merge contacts."
			static var mergeContactsError = "Contacts merge with errors!"
		}
		
		struct Errors {
			static var minimumPickerError = "Cannot set a maximum date that is equal or less than the minimum date."
			static var errorLoadContact = "Error loading contacts!"
			static var errorCreateExpoert = "Can't create export file!"
		}
		
		struct PurchaseError {

				static var defaultPurchseError = "Purchase Error!"
				static var purchaseIsCanceled = "Purchase is canceled!"
				static var refundsCanceled = "Refaund is canceled!"
				static var purchaseIsPending = "Purchase is pending!"
				static var verificationError = "Verification error!"
				static var error = "App Store purchase error!"
				static var productsError = "The products is not available on the store"
				static var networkError = "A network error occurred when communicating with the App Store"
				static var systemError = "Failure due to an unknown, unrecoverable error."
				static var userCancelled = "The action failed because purchse did not complete some necessary interaction."
				static var notAvailableInStorefront = "The product is not available in the current storefront."
				static var unknown = "Error, trying again at a later time will work."
				static var restorePurchseFailed = "Restore purchase failed"
			}
		
	}
}
