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
	static var dash = "-"
	static var none = "none"
	
	struct Service {
		
		static let appName = U.appName
	}
	
	struct Permission {
		
		struct Title {
			static var permission = "Permission"
			static var permissionRequest = "Permission Request"
		}
		
		struct Subtitle {
			static var denied = "denied!"
		}
		
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
		
		struct Subtitle {
			static let willEnd = "Will end on"
			static let expired = "Expired"
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
			static var deselectAll = "Deselect All"
			static var select = "Select"
			static var deselect = "Deselect"
			static var merge = "Merge"
			static var changeLauout = "Change Layout"
			static var edit = "Edit"
			static var export = "Export"
			static var fullScreenPreview = "Full Screen Preview"
			static var deleteSelected = "Delete Selected"
			static var setAsBest = "Set as Best"
			static var mergeSelected = "Merge Selected:"
			static var compress = "Compress:"
			static var submit = "Submit"
			static var resetDefault = "Reset to Default"
			static var removeAudio = "Remove Audio"
			static var origin = "origin"
			static var manual = "manual"
		}
	}
	
	struct Settings {
		
		struct Title {
			static var premium = "Premium"
			static var restore = "Restore Purchase"
			static var subscription = "Subscription"
			static var largeVideo = "Large Video Size"
			static var storage = "Storage"
			static var permission = "Permission"
			static var support = "Support"
			static var share = "Share App"
			static var rateUS = "Rate Us"
			static let privacy = "Privacy Policy"
			static let terms = "Terms Of Use"
			static let videoCompression = "Video Comptes"
		}
		
		struct Subtitle {
			static let share = "Share %@ with your friends".localized().replacingOccurrences(of: "%@", with: "app name")
			static let facebook = "Facebook"
			static let telegram = "Telegram"
			static let email = "Email"
		}
	}
	
	struct Main {
		
		struct Title {
			static let settings = "Settings"
			static let permission = "Permissions"
			static let photoTitle = "Photo"
			static let videoTitle = "Video"
			static let contactsTitle = "Contacts"
			static let deepClean = "Deep Clean"
			static let subscription = "Subscription"
			static let onboarding = "Onboarding"
			static let main = "Main"
			static let videoCompresion = "Video Compression"
		}
		
		struct MediaCcontentTitle {
			static let similarPhoto = "Similar Photo"
			static let duplicatePhoto = "Duplicate Photo"
			static let singleScreenShots = "Screenshots"
			static let singleLivePhotos = "Live Photo"
			static let similarLivePhoto = "Similar Live Photo"
			static let similarSelfies = "Similar Selfies"
			static let largeVideo = "Large Video"
			static let duplicatedVideos = "Duplicated Video"
			static let similarVideo = "Similar Video"
			static let singleScreenRecordings = "Screen Recordings"
			static let compression = "Video Compression"
			static let allContacts = "All Contacts"
			static let emptyContacts = "Empty Contacts"
			static let duplicatedContacts = "Duplicated Contacts"
			static let duplicatedPhoneNumbers = "Duplicated Numbers"
			static let duplucatedEmails = "Duplicated Emails"
			static let backup = "Contacts Backup"
		}
		
		struct Subtitles {
			static let categories = "Categories:"
			static let of = "of"
			static let searchHere = "  search contacts here..."
			static let from = "From:"
			static let to = "To:"
			static let best = "best"
			static let new = "new"
			static let allAnalyzed = "All Data Analyzed"
			static let files = "files"
			static let memmory = "memmory"
			static let keepOriginResolution = "keep origin resolution"
			static let originResolution = "origin resolution"
		}
		
		struct HeaderTitle {
			static let compressionSettings = "Compression Settings"
			static let selectCompressionSettings = "select compression settings"
			static let selectFileFormat = "Select Format of File"
			static let sinceLastClean = "Since the Last Cleaning"
			static let selectLower = "Select Lower Date"
			static let selectUpper = "Select Upper Date"
			static let selectLargeVideo = "Select Large Video Size"
			static let permissionRequest = "Permission Request"
			
			static let resolution = "Resolution"
			static let fps = "FPS"
			static let videoBitrate = "Video Bitrate"
			static let keyframe = "Interval Between Keyframe"
			static let audioBitrate = "Audio Bitrate"
		}
		
		struct Descriptions {
			static let permissionDescription = "These are the permissions the app requires to work properly. Please see description for each permission."
			static let permissionInfo = "Permissions are necessary for the application to work and perform correctly."
			static let resolutionDescription = "if set to a lower value, the picture will be more pixelated and the file size will be smaller"
			static let fpsDescription = "a lower framerate means the video will be less smooth and the file size will be significantly smaller"
			static let videoBitrateDescription = "if set to a lower value, it will reduce video quality and considerably decrease file size"
			static let keyframeDescription = "if set to a higher value, video quality and size will decrease, it is recommended to choose higher values if your video has no dynamic scenes"
			static let audioBitrateDescription = "if set to a lower value, the audio quality will deteriorate and the file size will be insignificantly reduced"
		}
		
		struct ProcessingState {
			static let prepareForScanning = "Prepare for scanning"
			static let analyzingWait = "Analyzing, please wait"
			static let compare = "Compare results"
			static let anayzing = "analyzing"
			static let searchingComplete = "Searching complete!"
			
			struct ByGrouping {
				static let similarGroups = "similar groups"
				static let duplicatedGroups = "duplicated groups"
				static let duplicatedCotactsGroups = "duplicated contacts groups"
				///
				static let files = "files"
				static let contacts = "contacts"
				///
				static let selectedPhoto = "selected photos"
				static let selectedVideo = "selected videos"
				static let selectedContacts = "selected contacts"
			}
			
			struct ByEmptyState {
				static let emptySimilarPhoto = "no similiar photos"
				static let emptyDuplicatedPhoto = "no duplicated photos"
				static let emptyScreenShots = "no screen shots"
				static let emptyLivePhoto = "no live photos"
				static let emptySimilarLivePhotos = "no similar live photos"
				static let emptySimilarSelfies = "no similar selfies"
				static let emptyLargeVideos = "no large videos"
				static let noDuplicatedVideo = "no duplicated videos"
				static let noSimilarVideo = "no similar videos"
				static let noScreenRecording = "no screen recordings"
				static let noContacts = "no contacts"
				static let noContactsToClean = "no contacts to clean"
				static let noContent = "no content"
				static let missingNumber = "missing number"
				static let missingName = "missing name"
				static let missingAll = "all data missing"
			}
			
			struct DeepCleanProcessingTitle {
				static let photoClean = "deleting photo (video):"
				static let emptyContactsClean = "removing empty contacts:"
				static let contactsMergeClean = "merge selecting contacts:"
				static let contactsDeleteClean = "deleting selected contacts:"
				static let prepareClen = "prepare cleaning"
			}
			
			struct DeepCleanButtonState {
				static let startDeepClean = "start deep clean"
				static let startAnalyzing = "start analyzing"
				static let stopAnalyzing = "stop analyzing"
				static let startCleaning = "start cleaning"
			}
		}
	
		struct BannerHelpers {
			
			struct Title {
				static let videoTitle = "Compress Videos"
				static let contactTitle = "Sync Contacts"
			}
			
			struct Subtitle {
				static let videoSubtitle = "Optimaze your IPhone data"
				static let contactsSubtitle = "Optimaze your IPhone data"
			}
			
			struct Description {
				static let videoDescription = "Compression Level"
				static let videoDescriptionOne = "50x"
				static let videoDescriptionTwo = "Ultra"
				
				static let contactsDescription = "Save Your Contacts"
				static let contactsDescriptionOne = "With"
				static let contactsDescriptionTwo = "Back-Up"
			}
		}
	}
	
	struct AlertController {
		struct AlertTitle {
			static var deepCleanProcessing = "Deep Clean processing"
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

extension Localization {
	
	struct ServiceValues {
		
		static let mbs = "Mbs"
		static let gb = "Gb"
		static let tb = "Tb"
		static let mb = "Mb"
	}
}
