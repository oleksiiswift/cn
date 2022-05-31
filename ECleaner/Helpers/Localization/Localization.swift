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
			static var mergedContacts = "Merge Contacts"
			static var deleteContacts = "Delete Contacts"
			static var deleteVideos = "Delete Videos"
			static var deletePhotos = "Delete Photos"
			static var compressing = "Compressing"
			static var updatingContacts = "Updating Contacts"
			static var selectingContactsWait = "Selecting Contacts, wait"
			static var selectingVideosWait = "Selecting Videos, wait"
			static var selectingPhotosWait = "Selecting Photos, wait"
			static var prepareSearching = "Prepare Searching, wait"
			static var searchComplete = "Search complete!"
			
		}
		
		struct AlertMessage {
			static var compresssionComplete = "Video compression is successfully completed! filesize: "
		}
	}
	
	struct ErrorsHandler {
		
		struct Title {
			static var emptyResults = "Sorry, no content)"
			
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
	}
}
