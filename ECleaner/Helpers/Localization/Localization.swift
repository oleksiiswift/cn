//
//  Localization.swift
//  ECleaner
//
//  Created by alexey sorochan on 31.05.2022.
//

import Foundation

typealias L = Localization
struct Localization {
	
	static var empty = ""
	static var dash = "-"
	static var whitespace = " "
	static var none = "none"
	static var replacingString = "%@"
	
	struct Service {
		
		static let appName = U.appName.localized()
	}
	
	struct Permission {
		
		struct Title {
			static var permission = "Permission".localized()
			static var permissionRequest = "Permission Request".localized()
		}
		
		struct Subtitle {
			static var denied = "denied!".localized()
		}
		
		struct Name {
			static var notification = "Notification".localized()
			static var photoLibrary = "Photo Library".localized()
			static var contacts = "Contacts".localized()
			static var tracking = "Tracking".localized()
			static var libraryContacts = "Photo Library & Contacts".localized()
		}
		
		struct Description {
			static var notification = "Allow application recieve notification.".localized()
			static var photoLibrary = "Access for search duplicated, simmilar photos and video in your gallery.".localized()
			static var contacts = "Access for your Contacts and phones, delete, merge and clean Contacts.".localized()
			static var tracking = "Allow to access app related data.".localized()
			static var libraryContacts = "Allow access to Contacts and Photo Library.".localized()
		}
		
		struct AlertService {
			
			struct Title {
				static var permissionDenied = "Permission Denied!".localized()
				static var permissionAllowed = "Permission Alowed!".localized()
				static var appTrack = "Allow App to Request to Track!".localized()
				static var onePermissionRule = "Allow Permission!".localized()
			}
			
			struct Description {
				static var openSettings = "Please, go to Settings for allow/denied permission.".localized()
				static var allowContactsAndPhoto = "%@ does not have acces to Photo Library and Contacts. Please, allow the application access to your data for use Deep Clean Feature.".localized().replacingOccurrences(of: L.replacingString, with: Service.appName)
				static var appTrackDescription = "Allow app to ask tot track your activity accross other companies apps and websites.".localized()
				static var onePermissionRule = "Please allow at least one permission (Photo Library or Contacts) to use app.".localized()
			}
			
			struct Restricted {
				static var contacts = "%@ does not have access to contacts. Please, allow the application to access to your contacts.".localized().replacingOccurrences(of: L.replacingString, with: Service.appName)
				static var photoLibrary = "%@ does not have access to Photo Library. Please, allow the application to access to your Photo Library.".localized().replacingOccurrences(of: L.replacingString, with: Service.appName)
			}
		}
	}
	
	struct Purchase {
		
		struct Title {
			static let restoreFail = "Restore failed".localized()
			static let nothingRestore = "Nothing to restore".localized()
			static let purchaseRestored = "Restore completed.".localized()
			static let congratulation = "Congratulation!".localized()
		}
		
		struct Message {
			static let purchaseRestored = "Restore completed.".localized()
			static let restoreFailed = "Please try restore later or contact support".localized()
			static let expire = "Product is expired since".localized()
			static let noPreviousPurchse = "No previous purchases were found".localized()
			static let cantRestore = "Purchases can't restored. Product is expired since".localized()
			static let noReciept = "Error. No receipt data. Try again.".localized()
			static let network = "Network error while verifying receipt".localized()
			static let verification = "Error. Receipt verification failed. Try again.".localized()
			static let nothing = "Nothing to restore. No previous purchases were found.".localized()
		}
		
		struct Subtitle {
			static let willEnd = "Will end on".localized()
			static let expired = "Expired".localized()
		}
	}
	
	struct Notification {
		struct Title {
			static var contacts = "Clean up your contacts 🤷🏻‍♂️".localized()
			static var photos = "Clean Up your Photos 📷".localized()
			static var videos = "Clean Up Your Videos 🎥".localized()
			static var deepClean = "Free Up Storage With Deep Clean 🧹".localized()
			static var storage =  "Clean Up Storage ☁️".localized()
		}
		
		struct Subtitle {}
		
		struct Body {
			static var contacts = "Anazlize and delete empty and duplicated contacts".localized()
			static var photos = "Analize photo data for similar and duplicateds".localized()
			static var videos = "Analize video data for similar and duplicateds".localized()
			static var deepClean = "Analize your photo and video, contacts".localized()
			static var storage =  "Delete Your duplicated and similar photos and videos. Clean contacts".localized()
		}
	}
	
	struct Standart {
		
		struct Buttons {
			static var allowed = "Allowed".localized()
			static var `continue` = "Continue".localized()
			static var denied = "Denied".localized()
			static var ok = "OK".localized()
			static var cancel = "Cancel".localized()
			static var settings = "Settings".localized()
			static var delete = "Delete".localized()
			static var stop = "Stop".localized()
			static var exit = "Exit".localized()
			static var share = "Share".localized()
			static var save = "Save".localized()
			static var selectAll = "Select All".localized()
			static var deselectAll = "Deselect All".localized()
			static var select = "Select".localized()
			static var deselect = "Deselect".localized()
			static var merge = "Merge".localized()
			static var changeLauout = "Change Layout".localized()
			static var edit = "Edit".localized()
			static var export = "Export".localized()
			static var fullScreenPreview = "Full Screen Preview".localized()
			static var deleteSelected = "Delete Selected".localized()
			static var setAsBest = "Set as Best".localized()
			static var mergeSelected = "Merge Selected:".localized()
			static var compress = "Compress:".localized()
			static var submit = "Submit".localized()
			static var resetDefault = "Reset to Default".localized()
			static var removeAudio = "Remove Audio".localized()
			static var origin = "origin".localized()
			static var manual = "manual".localized()
			static var skip = "Skip".localized()
			static var next = "Next".localized()
			static var restore = "Restore".localized()
			static var activate = "Activate".localized()
			static var changePlan = "Change Plan".localized()
			static var startBackup = "Start Backup".localized()
			static var view = "View".localized()
			static var removeLocation = "Remove Location".localized()
		}
		
		struct MenuItems {
			static var sortByDate = "Sort by Creation Date".localized()
			static var sortBySize = "Sort by File Size".localized()
			static var sortByDimension = "Sort by Video Dimension".localized()
			static var sortByEdit = "Sort by Last Edit".localized()
			static var sortByDuration = "Sort by Duration".localized()
		}
	}
	
	struct Settings {
		
		struct Title {
			static var premium = "Premium".localized()
			static var restore = "Restore Purchase".localized()
			static var lifeTime = "Lifetime".localized()
			static var subscription = "Subscription".localized()
			static var largeVideo = "Large Video Size".localized()
			static var storage = "Storage".localized()
			static var permission = "Permission".localized()
			static var support = "Support".localized()
			static var share = "Share App".localized()
			static var rateUS = "Rate Us".localized()
			static let privacy = "Privacy Policy".localized()
			static let terms = "Terms Of Use".localized()
			static let videoCompression = "Video Comptes".localized()
		}
		
		struct Subtitle {
			static let share = "Share %@ with your friends".localized().replacingOccurrences(of: L.replacingString, with: Service.appName)
			static let facebook = "Facebook".localized()
			static let telegram = "Telegram".localized()
			static let email = "Email".localized()
		}
	}
	
	struct Backup {
		static let currentContact = "Current contact:".localized()
		static let archiveProcessing = "Archived processing...".localized()
		static let backupCreated = "Backup created:".localized()
		static let error = "Backup Error".localized()
	}
	
	struct Main {
		
		struct Title {
			static let settings = "Settings".localized()
			static let permission = "Permissions".localized()
			static let photoTitle = "Photo".localized()
			static let videoTitle = "Video".localized()
			static let contactsTitle = "Contacts".localized()
			static let deepClean = "Deep Clean".localized()
			static let subscription = "Subscription".localized()
			static let onboarding = "Onboarding".localized()
			static let main = "Main".localized()
			static let videoCompresion = "Video Compression".localized()
			static let location = "Location".localized()
		}
		
		struct MediaContentTitle {
			static let similarPhoto = "Similar Photo".localized()
			static let duplicatePhoto = "Duplicate Photo".localized()
			static let singleScreenShots = "Screenshots".localized()
			static let singleLivePhotos = "Live Photo".localized()
			static let similarLivePhoto = "Similar Live Photo".localized()
			static let similarSelfies = "Similar Selfies".localized()
			static let largeVideo = "Large Video".localized()
			static let duplicatedVideos = "Duplicated Video".localized()
			static let similarVideo = "Similar Video".localized()
			static let singleScreenRecordings = "Screen Recordings".localized()
			static let compression = "Video Compression".localized()
			static let allContacts = "All Contacts".localized()
			static let emptyContacts = "Empty Contacts".localized()
			static let duplicatedContacts = "Duplicated Contacts".localized()
			static let duplicatedPhoneNumbers = "Duplicated Numbers".localized()
			static let duplucatedEmails = "Duplicated Emails".localized()
			static let backup = "Contacts Backup".localized()
		}
		
		struct Subtitles {
			static let categories = "Categories:".localized()
			static let of = "of".localized()
			static let searchHere = "  search contacts here...".localized()
			static let from = "From:".localized()
			static let to = "To:".localized()
			static let best = "best"
			static let new = "new"
			static let allAnalyzed = "All Data Analyzed".localized()
			static let files = "files".localized()
			static let memmory = "memmory".localized()
			static let keepOriginResolution = "keep origin resolution".localized()
			static let originResolution = "origin resolution".localized()
			static let email = "Email".localized()
			static let phone = "Phone Number".localized()
			static let url = "Url".localized()
		}
		
		struct HeaderTitle {
			static let compressionSettings = "Compression Settings".localized()
			static let selectCompressionSettings = "Select Compression Settings".localized()
			static let selectFileFormat = "Select Format of File".localized()
			static let sinceLastClean = "Since the Last Cleaning".localized()
			static let selectLower = "Select Lower Date".localized()
			static let selectUpper = "Select Upper Date".localized()
			static let selectLargeVideo = "Select Large Video Size".localized()
			static let permissionRequest = "Permission Request".localized()
			
			static let resolution = "Resolution".localized()
			static let fps = "FPS"
			static let videoBitrate = "Video Bitrate".localized()
			static let keyframe = "Interval Between Keyframe".localized()
			static let audioBitrate = "Audio Bitrate".localized()
			
			static let videoPreview = "Video Preview".localized()
			static let lowQuality = "Low Quality".localized()
			static let mediumQuality = "Medium Quality".localized()
			static let highQuality = "Hight Quality".localized()
			static let customSettings = "Custom Settings".localized()
			
			static let onlyName = "Missing Contact Data".localized()
			static let onlyPhoneNumber = "Only Phone Number".localized()
			static let onlyEmail = "Only Email".localized()
			static let emptyName = "Missing Name".localized()
			static let wholeEmpty = "Missing All Contact Info".localized()
			
			static let termsSupport = "Terms & Support".localized()
			static let system = "System".localized()
	
			static let links = "Links".localized()
			static let contactName = "Contact Name".localized()
			static let numbers = "Phone Numbers".localized()
			static let mail = "Email".localized()
			
			static let latitude = "latitude".localized()
			static let longitude = "longitude".localized()
			static let altitude = "altitude".localized()
			static let location = "location".localized()
		}
		
		struct Descriptions {
			static let permissionDescription = "These are the permissions the app requires to work properly. Please see description for each permission.".localized()
			static let permissionInfo = "Permissions are necessary for the application to work and perform correctly.".localized()
			static let resolutionDescription = "if set to a lower value, the picture will be more pixelated and the file size will be smaller".localized()
			static let fpsDescription = "a lower framerate means the video will be less smooth and the file size will be significantly smaller".localized()
			static let videoBitrateDescription = "if set to a lower value, it will reduce video quality and considerably decrease file size".localized()
			static let keyframeDescription = "if set to a higher value, video quality and size will decrease, it is recommended to choose higher values if your video has no dynamic scenes".localized()
			static let audioBitrateDescription = "if set to a lower value, the audio quality will deteriorate and the file size will be insignificantly reduced".localized()
			static let shortAudioDescriptionHigh = "high-quality".localized()
			static let shortAudioDescriptionMedium = "medium quality".localized()
			static let shortAudioDescriptionMid = "mid-range quality".localized()
			static let shortAudioDescriptionLow = "low-quality".localized()
		}
		
		struct ProcessingState {
			static let prepareForScanning = "Prepare for scanning".localized()
			static let analyzingWait = "Analyzing, please wait".localized()
			static let compare = "Compare results".localized()
			static let anayzing = "analyzing".localized()
			static let searchingComplete = "Searching complete!".localized()
			static let archiving = "Archiving".localized()
			static let processing = "Processing".localized()
			static let tap = "Tap to scan".localized()
			static let pleaseWait = "Please, wait...".localized()
			
			struct ByGrouping {
				static let similarGroups = "similar groups".localized()
				static let duplicatedGroups = "duplicated groups".localized()
				static let duplicatedCotactsGroups = "duplicated contacts groups".localized()
				///
				static let files = "files".localized()
				static let contacts = "contacts".localized()
				///
				static let selectedPhoto = "selected photos".localized()
				static let selectedVideo = "selected videos".localized()
				static let selectedContacts = "selected contacts".localized()
			}
			
			struct ByEmptyState {
				static let emptySimilarPhoto = "no similiar photos".localized()
				static let emptyDuplicatedPhoto = "no duplicated photos".localized()
				static let emptyScreenShots = "no screen shots".localized()
				static let emptyLivePhoto = "no live photos".localized()
				static let emptySimilarLivePhotos = "no similar live photos".localized()
				static let emptySimilarSelfies = "no similar selfies".localized()
				static let emptyLargeVideos = "no large videos".localized()
				static let noDuplicatedVideo = "no duplicated videos".localized()
				static let noSimilarVideo = "no similar videos".localized()
				static let noScreenRecording = "no screen recordings".localized()
				static let noContacts = "no contacts".localized()
				static let noContactsToClean = "no contacts to clean".localized()
				static let noContent = "no content".localized()
				static let missingNumber = "missing number".localized()
				static let missingName = "missing name".localized()
				static let missingAll = "all data missing".localized()
			}
			
			struct DeepCleanProcessingTitle {
				static let photoClean = "deleting photo (video):".localized()
				static let emptyContactsClean = "removing empty contacts:".localized()
				static let contactsMergeClean = "merge selecting contacts:".localized()
				static let contactsDeleteClean = "deleting selected contacts:".localized()
				static let prepareClen = "prepare cleaning".localized()
			}
			
			struct DeepCleanButtonState {
				static let startDeepClean = "start deep clean".localized()
				static let startAnalyzing = "start analyzing".localized()
				static let stopAnalyzing = "stop analyzing".localized()
				static let startCleaning = "start cleaning".localized()
			}
		}
	
		struct BannerHelpers {
			
			struct Title {
				static let videoTitle = "Compress Videos".localized()
				static let contactTitle = "Sync Contacts".localized()
			}
			
			struct Subtitle {
				static let videoSubtitle = "Optimaze your IPhone data".localized()
				static let contactsSubtitle = "Optimaze your IPhone data".localized()
			}
			
			struct Description {
				static let videoDescription = "Compression Level".localized()
				static let videoDescriptionOne = "50x"
				static let videoDescriptionTwo = "Ultra".localized()
				
				static let contactsDescription = "Save Your Contacts".localized()
				static let contactsDescriptionOne = "With".localized()
				static let contactsDescriptionTwo = "Back-Up".localized()
			}
		}
	}
	
	struct Onboarding {
		
		struct Title {
			static let photo = "Clear Similar Photos".localized()
			static let video = "Optimize Large Video".localized()
			static let contacts = "Merge Same Contacts".localized()
		}
		
		struct Description {
			static let photo = "Autosearch and delete similar photos to obtain more space on iPhone.".localized()
			static let video = "Compress or delete large videos to clear your iPhone data".localized()
			static let contacts = "Organize your Contact Library using merge and clean empty contacts".localized()
		}
	}
	
	struct AlertController {
		struct AlertTitle {
			static var deepCleanProcessing = "Deep Clean processing".localized()
			static var compressionComplete = "Compression Complete!".localized()
			static var mergingContacts = "Merging Contacts".localized()
			static var compressing = "Compressing".localized()
			static var updatingContacts = "Updating Contacts".localized()
			static var selectingContactsWait = "Selecting Contacts, wait".localized()
			static var selectingVideosWait = "Selecting Videos, wait".localized()
			static var selectingPhotosWait = "Selecting Photos, wait".localized()
			static var prepareSearching = "Prepare Searching, wait".localized()
			static var sortByFileSize = "Sort by File Size, wait".localized()
			static var parsingLocation = "Parsing Locations, wait".localized()
			static var searchComplete = "Search complete!".localized()
			static var deletingContact = "Deleting Contacts".localized()
			static var deletingVideo = "Deleting Videos".localized()
			static var deletingPhoto = "Deletting Photos".localized()
			static var deletePhoto = "_deletePhoto".localized()
			static var deleteVideo = "_deleteVideo".localized()
			static var deleteContact = "_deleteContact".localized()
			static var deleteLocation = "Remove Locations?".localized()
			static var mergeContacts = "Merge Contacts".localized()
			static var mergeCompleted = "Merge Completed!".localized()
			static var deleteContactsCompleted = "Delete Completed!".localized()
			static var completeSuccessfully = "Complete Successfully!".localized()
			static var operationIsCancel = "Operation is Canceling!".localized()
			static var stopSearch = "Stop search process?".localized()
			static var notice = "Notice!".localized()
		}
		
		struct AlertMessage {
			static var compresssionComplete = "Video compression is successfully completed! filesize: ".localized()
			static var deletePhoto = "_deletingPhotos".localized()
			static var deleteVideo = "_deletingVideos".localized()
			static var deleteContact = "_deletingContacts".localized()
			static var deleteLocations = "Remove Locations at selected section?".localized()
			static var mergeContacts = "These contacts will be merged. After the merging process is completed, unnecessary contacts will be automatically deleted.".localized()
			static var mergeCompleted = "Merge contacts successfully completed!".localized()
			static var deleteContactsCompleted = "Delete successfully completed!".localized()
			static var deepCleanComplete = "Deep Clean processing complete successfully!".localized()
			static var deepCleanCancel = "Deep Clean Processing is Canceled!".localized()
			static var resetDeepCleanSearch = "This will be reset all searching process!".localized()
			static var stopSearchingProcess = "This will be stop searching process!".localized()
			static var stopDeepCleanDeleteProcess = "This will be stop deleting process and reset all searching data!".localized()
			static var resetResults = "By quiting all search results will be lose!".localized()
		}
	}
	
	struct ErrorsHandler {
		
		struct Title {
			static var emptyResults = "Sorry, no content)".localized()
			static var error = "Error!".localized()
			static var fatalError = "Fatal Error!".localized()
			static var atention = "Atention!".localized()
			static var notice = "Notice!".localized()
			static var noNetwork = "Error! No network connection!".localized()
		}
		
		struct EmptyResultsError {
			static var photoLibrararyIsEmpty = "Photo Library is empty.".localized()
			static var videoLibrararyIsEmpty = "Video Library is empty.".localized()
			static var similarPhotoIsEmpty = "No similar photo.".localized()
			static var duplicatedPhotoIsEmpty = "No duplicated photo.".localized()
			static var screenShotsIsEmpty = "No screenshots.".localized()
			static var similarSelfiesIsEmpty = "No similar selfies.".localized()
			static var livePhotoIsEmpty = "No live photo.".localized()
			static var similarLivePhotoIsEmpty = "No similar live photo.".localized()
			static var photoWithLocationIsEmpty = "No photo with locations data.".localized()
			static var largeVideoIsEmpty = "No large video.".localized()
			static var duplicatedVideoIsEmpty = "No duplucated video.".localized()
			static var similarVideoIsEmpty = "No similar video.".localized()
			static var screenRecordingIsEmpty = "No screen recording.".localized()
			static var contactsIsEmpty = "No Contacts found.".localized()
			static var emptyContactsIsEmpty = "No empty contacts.".localized()
			static var duplicatedNamesIsEmpty = "No duplicated contacts.".localized()
			static var duplicatedNumbersIsEmpty = "No duplicated phone numbers found.".localized()
			static var duplicatedEmailsIsEmpty = "No duplicated email found.".localized()
			static var deepCleanResultsIsEmpty = "Deep Clean search complete with with no similar or duplicated data found.".localized()
		}
		
		struct CompressionError {
			static var cantLoadFile = "Can't load video file.".localized()
			static var compressionFailed = "Video file compression failed.".localized()
			static var resolutionError = "Resolution saved in settings are bigger the origin video file resolution.".localized()
			static var savedError = "Can't save compressed video file.".localized()
			static var noVideoFile = "No video file.".localized()
			static var audioError = "Can't remove audio component from vide file.".localized()
			static var isCanceled = "Compression operation is canceled".localized()
		}
		
		struct DeepCleanError {
			static var completeWithError = "Deep Clean processing complete with error!".localized()
		}
		
		struct DeleteError {
			static var deleteContactsError = "There is an error deleting contact(s).".localized()
			static var deletePhotoError = "There is an error deleting photo(s).".localized()
			static var deleteVideoError = "There is and error deleting video(s).".localized()
		}
		
		struct MergeError {
			static var errorMergeContact = "Error merge contacts.".localized()
			static var mergeContactsError = "Contacts merge with errors!".localized()
		}
		
		struct Errors {
			static var minimumPickerError = "Cannot set a maximum date that is equal or less than the minimum date.".localized()
			static var errorLoadContact = "Error loading contacts!".localized()
			static var errorCreateExpoert = "Can't create export file!".localized()
		}
		
		struct PurchaseError {

				static var defaultPurchseError = "Purchase Error!".localized()
				static var purchaseIsCanceled = "Purchase is canceled!".localized()
				static var refundsCanceled = "Refaund is canceled!".localized()
				static var purchaseIsPending = "Purchase is pending!".localized()
				static var verificationError = "Verification error!".localized()
				static var error = "App Store purchase error!".localized()
				static var productsError = "The products is not available on the store".localized()
				static var networkError = "A network error occurred when communicating with the App Store".localized()
				static var systemError = "Failure due to an unknown, unrecoverable error.".localized()
				static var userCancelled = "The action failed because purchse did not complete some necessary interaction.".localized()
				static var notAvailableInStorefront = "The product is not available in the current storefront.".localized()
				static var unknown = "Error, trying again at a later time will work.".localized()
				static var restorePurchseFailed = "Restore purchase failed".localized()
			}
	}
	
	struct Subscription {
		
		struct Main {
			static var getPremium = "Get Premium".localized()
			static var withPremium = "With Premium".localized()
			static var unlockFeatures = "Unlock All Features".localized()
		}
		
		struct PremiumFeautures {
			static var deepClean = "Deep Clean".localized()
			static var multiselect = "Multiselect Elements".localized()
			static var compression = "Video Compression".localized()
			static var location = "Clean GPS Location".localized()
		}
		
		struct Description {
			static var day = "per day".localized()
			static var week = "per week".localized()
			static var month = "per month".localized()
			static var year = "per year".localized()
		}
		
		struct DescriptionSK {
			static var day = "day".localized()
			static var week = "week".localized()
			static var month = "month".localized()
			static var year = "year".localized()
		}
		
		struct Helper {
			static var termsOfUse = "Terms of Use".localized()
			static var privicy = "Privacy Policy".localized()
		}
		
		struct Premium {
			static var expireSubscription = "Subscription Expire on:".localized()
			static var alreadyPremium = "Already Premium".localized()
			static var currentSubscription = "Current Subscription Status:".localized()
		}
	}
}

//		MARK: - not translated contantValues -
extension Localization {
	
	struct ServiceValues {
		
		static let mbs = "Mbs"
		static let gb = "Gb"
		static let tb = "Tb"
		static let mb = "Mb"
	}
}
