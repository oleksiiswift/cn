//
//  Constants.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import Foundation
import UIKit

typealias C = Constants
class Constants {
    
    struct gadAdvertisementKey {
        /**
         - parameter GADApplicationIdentifier use in info.plist file
         - parameter gadProductionKey use when app in production
        */
        
        static let GADApplicationIdentifier = ""
        static let gadProductionKey = ""
        
        static let gadTestAppIdentifier = "ca-app-pub-3940256099942544~1458002511"
        static let gadTestKey = "ca-app-pub-3940256099942544/2934735716"
    }
    
    struct key {
        
        struct settings {
            static let isDarkModeOn = "darkModeIsSetOn"
            static let photoLibraryAccessGranted = "photoLibraryAccessGranted"
            static let contactStoreAccessGranted = "contactStoreAccessGranted"
            static let lowerBoundSavedDate = "lowerBoundSavedDate"
            static let upperBoundSavedDate = "upperBoundSavedDate"
            static let lastSmartClean = "lastSmartClean"
			static let largeVideoLowerSize = "largeVideoLowerSize"
            
            static let photoSpace = "photoDiskSpace"
            static let videoSpace = "videoDiskSpace"
            static let allMediaSpace = "wholeAssetsDiskSpace"
        }
        
        struct notification {
            
                /// `phasset disk space update notification name`
            static let photoSpaceNotificationName = "photoSpaceDidChange"
            static let videoSpaceNotificationName = "videoSpaceDidChange"
            static let mediaSpaceNotificationName = "mediaSpaceDidChange"
            static let contactsCountNotificationName = "contactsCountDidChange"
			static let removeStoreObserver = "removeStoreObserver"
			static let addStoreObserver = "addStoreObserver"
            
                /// `deep clean update progress notification name`
            struct deepClean {
                    /// photo
                static let deepCleanSimilarPhotoPhassetScan = "deepCleanSimilarPhotoPhassetScan"
                static let deepCleanDuplicatedPhotoPhassetScan = "deepCleanDuplicatedPhotoPhassetScan"
                static let deepCleanScreenShotsPhotoPhassetScan = "deepCleanScreenShotsPhassetScan"
				static let deepCleanSimilarSelfiesPhotoPhassetScan = "deepCleanSimilarSelfiesPhotoPhassetScan"
                static let deepCleanSimilarLivePhotosPhassetScan = "deepCleanSimilarLivePhotosPhaassetScan"
                static let deepCleanLargeVideoPhassetScan = "deepCleanLargeVideoPhassetScan"
                    /// video
                static let deepCleanDuplicateVideoPhassetScan = "deepCleanDuplicateVideoPhassetScan"
                static let deepCleanSimilarVideoPhassetScan = "deepCleanSimilarVideoPhassetScan"
                static let deepCleanScreenRecordingsPhassetScan = "deepCleanScreenRecordingsPhassetScant"
                    /// contacts
                static let deepCleanEmptyContactsScan = "deepCleanEmptyContactsScan"
                static let deepCleanDuplicatedContactsScan = "deepCleanDuplicatedContactsScan"
                static let deepCleanDuplicatedPhoneNumbersScan = "deepCleanDuplicatedPhoneNumbersScan"
                static let deepCleanDupLicatedMailsScan = "deepCleanDupLicatedEmaailScan"
            }
            
                /// `single Search update progress notification name`
            struct singleSearch {
                    /// contacts
                static let singleSearchAllContactsScan = "singleSearchAllContactsScan"
                static let singleSearchEmptyContactsScan = "singleSearchEmptyContactsScan"
                static let singleSearchDuplicatesNamesContactsScan = "singleSearchDuplicatesNamesContactsScan"
                static let singleSearchDuplicatesNumbersContactsScan = "singleSearchDuplicatesNumbersContactsScan"
                static let singleSearchDupliatesEmailsContactsScan = "singleSearchDupliatesEmailsContactsScan"
					/// photo
				static let singleSearchSimilarPhotoPHAssetScan = "singleSearchSimilarPhotoPhassetScan"
				static let singleDuplicatedPhotoPHAssetScan = "singleDuplicatedPhotoPHAssetScant"
				static let singleSimilarLivePhotoPHAssetScan = "singleSimilarLivePhotoPHAssetScan"
				static let singleScreeenshotsPhotoPHAssetScan = "singleScreeenshotsPhotoPHAssetScan"
				static let singleSimilarSelfiesPHassetScan = "singleSimilarSelfiesPHassetScan"
				static let singleLivePhotoPHAssetScan = "singleLivePhotoPHAssetScan"
				static let singleRecentlyDeletedPHAssetScan = "singleRecentlyDeletedPHAssetScan"
					/// video
				static let singleLargeVideoPHAssetScan = "singleLargeVideoPHAssetScan"
				static let singleDuplicatedVideoPHAssetScan = "singleDuplicatedVideoPHAssetScan"
				static let singleSimilarVideoPHAssetScan = "singleSimilarVideoPHAssetScan"
				static let singleScreenRecordingsVideoPHAssetScan = "singleScreenRecordingsVideoPHAssetScan"
				static let singleRecentlyDeleteVideoPHAssetScan = "singleRecentlyDeleteVideoPHAssetScan"
            }
            
            /// `contacts notification`
            static let mergeContactsSelectionDidChange = "mergeContactsSelectionDidChange"
            static let selectedContactsDidChange = "selectedContactsDidChange"
        }
		
		struct dispatch {
			static let mergeContacts = "mergeContactsLabel"
			static let deleteContacts = "deletingContactsLabel"
			static let selectedPhassetsQueue = "selectedPhassetsQueue"
		}
		
		struct operation {
			
			struct queue {
				static let contacts = "contactsCleanSearchOperationQueuer"
				static let phassets = "phassetsCleanSearchOperationQueuer"
				static let deepClean = "deepCleanSearchOperationQueuer"
				static let cleaningProcess = "cleaningProcessOprationQueuer"
				static let utils = "utilsBackgroudSpaceCalculated"
                static let preetchPHasssetQueue = "prefetchPhassetsImagesOperationQueuer"
			}
			
			struct name {
				
					/// `contacts`
				static let updateContectContacts = "updateBaseContactsOperation"
				static let mergeContacts = "mergeContactsOperation"
				static let deleteContacts = "deleteContactsOperation"
				
				static let emptyContacts = "emptyContactsOperation"
				static let duplicatedContacts = "duplicatedContactsOperation"
				static let phoneDuplicated = "phoneDuplicatedOperation"
				static let emailDuplicated = "emailDuplicatedOperation"
				
					/// `system phassets`
				static let phassetSingleSizes = "getCalculatePHAssetSizesSingleOperation"
				static let phassetAllSizes = "getCalculatedAllPHAssetSizeOperation"
				static let fetchPHAssetCount = "fetchTotalPHAssetsOperation"
				static let fetchFromGallery = "fetchFromGalleryOperation"
				
				static let similarPhotoProcessingOperation = "similarPhotoProcessingOperation"
				static let duplicatePhotoProcessingOperation = "duplicatePhotoProcessingOperation"
				static let screenShotsOperation = "screenShotsOperation"
				static let livePhotoOperation = "livePhotoOperation"
				static let similarSelfiesOperation = "similarSelfiesOperation"
				static let similarLivePhotoProcessingOperation = "similarLivePhotoProcessingOperation"
				
				static let recentlyDeletedAlbums = "recentlyDeletedAlbumFetchOperation"
				static let recentlyDeletedSortedAlbums = "recentlyDeletedSortedAlbumsFetchOperation"
				static let deletePhassetsOperation = "deletePhassetsOperation"
				static let recoverPhassetsOperation = "recoverPhassetsOperation"

				static let videoCountOperation = "calculateTotalVideoProcessingOperation"
				static let photoCouuntOperation = "calculateTotlaPhotoProcessingOperation"
				static let screenRecordingOperation = "screenRecordsVideosOperation"
								
				static let largeVideo = "largeVideoOperation"
				static let similarVideoProcessingOperation = "similarVideoProcessingOperation"
				static let duplicateVideoProcessingOperation = "duplicateVideoProcessingOperation"
			
				static let similarTuplesOperation = "serviceUtilitySimilarTuplesOperation"
				static let duplicatedTuplesOperation = "serviceUtilityDuplicatedTuplesOperation"
				static let findDuplicatedVideoOperation = "findDuplicatedVideoOperation"
				static let getSimilarVideosByTimeStampOperation = "getSimilarVideosByTimeStampOperation"
				
					/// `deep clean`
				static let deepCleanProcessingCleaningOperation = "deepCleanProcessingCleaningOperation"
                    /// `prefetch phassets`
                static let prefetchPHAssetsOperation = "prefetchPHassetsOperation"
			}
		}
        
//        MARK: - notification dictionary progress identifiers -
        /**
         use for notification info dictionary for update progress of deepCleanNotification
         - parameter `index` use for detect current progrss index
         - parameter `count` use for detect total assets count in progress
         */
    
        struct notificationDictionary {
            
                /// `INDEXES`
            struct index {
                    /// photo part
                static let similarPhotoIndex = "deepCleanPhotoPrecessIndex"
                static let duplicatePhotoIndex = "deepCleanDuplicatePhotoProcessingIndex"
                static let screenShotsIndex = "deepCleanscreenShotsProcessingIndex"
                static let livePhotosIndex = "deepCleanlivePhotosProcessingIndex"
				static let similarSelfiePhotoIndex = "similarSelfiePhotoProcessingIndex"
				static let recentlyDeletedPhotoIndex = "recentlyDeletedPhotoProcessingIndex"
                    /// video part
                static let largeVideoIndex = "deepCleanlargeVideoProcessingIndex"
                static let duplicateVideoIndex = "deepCleanduplicateVideoProcessingIndex"
                static let similarVideoIndex = "deepCleansimilarVideoProcessingIndex"
                static let screenRecordingsIndex = "deepCleanscreenRecordingsProcessingIndex"
				static let recentrlyDeletedVideoIndex = "recentrlyDeletedVideoProcessingIndex"
                    /// contacts part
                static let allContactsIndex = "deepCleanallContactsProcessingIndex"
                static let emptyContactsIndex = "deepCleanemptyContactsProcessingIndex"
                static let duplicateNamesContactsIndex = "duplicateNamesContactsProcessingIndex"
                static let duplicateNumbersContactsIndex = "duplicateNumbersContactsProcessingIndex"
                static let duplicateEmailContactsIndex = "duplicateEmailContactsProcessingIndex"
            }
            
                /// `TOTAL COUNT`
            struct count {
                    
                static let similarPhotoCount = "deepCleanSimilarPhotoTotalAsssetsCount"
                static let duplicatePhotoCount = "deepCleanDuplicatePhotoTotalAssetsCount"
                static let screenShotsCount = "deepCleanscreenShotsCount"
                static let livePhotosSimilarCount = "deepCleanlivePhotosCount"
				static let similarSelfiePhotosCount = "similarSelfiePhotosCount"
				static let recentlyDeletedPhotoCount = "recentlyDeletedPhotoCount"
                    /// video part
                static let largeVideoCount = "deepCleanlargeVideoCount"
                static let duplicateVideoCount = "deepCleanduplicateVideoCount"
                static let similarVideoCount = "deepCleansimilarVideoCount"
                static let screenRecordingsCount = "deepCleanscreenRecordingsCount"
				static let recentlyDeletedVideoCount = "recentlyDeletedVideoCount"
                    /// contacts part
                static let allContactsCount = "deepCleanallContactsCount"
                static let emptyContactsCount = "deepCleanemptyContactsCount"
                static let duplicateNamesContactsCount = "duplicateNamesContactsCount"
                static let duplicateNumbersContactsCount = "duplicateNumbersContactsCount"
                static let duplicateEmailsContactsCount = "duplicateEmailsContactsCount"
            }
				/// `STATE`
			struct state {
				static let similarPhotoState = "deepCleanPhotoPrecessState"
				static let duplicatePhotoState = "deepCleanDuplicatePhotoProcessingState"
				static let screenShotsState = "deepCleanscreenShotsProcessingState"
				static let livePhotosState = "deepCleanlivePhotosProcessingState"
				static let similarLivePhototState = "deepCleanSimiliarLivePhotoState"
				static let similarSelfieState = "similarSelfiePhotoProcessingState"
				static let recentlyDeletedPhotoState = "recentlyDeletedPhotoProcessingState"
					/// video part
				static let largeVideoState = "deepCleanlargeVideoProcessingState"
				static let duplicateVideoState = "deepCleanduplicateVideoProcessingState"
				static let similarVideoState = "deepCleansimilarVideoProcessingState"
				static let screenRecordingsState = "deepCleanscreenRecordingsProcessingState"
				static let recentrlyDeletedVideoState = "recentrlyDeletedVideoProcessingState"
					/// contacts part
				static let allContactsState = "deepCleanallContactsProcessingState"
				static let emptyContactsState = "deepCleanemptyContactsProcessingState"
				static let duplicateNamesContactsState = "duplicateNamesContactsProcessingState"
				static let duplicateNumbersContactsState = "duplicateNumbersContactsProcessingState"
				static let duplicateEmailContactsState = "duplicateEmailContactsProcessingState"
			}
			
            
            struct scroll {
                    /// contact scroll delegate scriklkub
                static let scrollViewInset = "scrollViewInset"
                static let scrollViewOffset = "scrollViewOffset"
            }
                
            struct progressAlert {
                static let progrssAlertValue = "progressAlertValue"
                static let progressAlertFilesCount = "progressAlertFilesCount"
				
				static let deepCleanProgressValue = "deepCleanProgressValue"
				static let deepCleanProcessingChangedTitle = "deepCleanProcessingChangedTitle"
            }
        }
    }
    
//    MARK: - public identifiers -
    struct identifiers {
        
        struct navigation {
            static let main = "StartingNavigationBar"
            static let navigationBar = "NavigationBar"
        }
        
        struct storyboards {
            static let main = "Main"
            static let media = "MediaContent"
            static let deep = "DeepClean"
			static let preview = "MediaPreview"
            static let contacts = "Contacts"
            static let contactsGroup = "ContactsGroup"
            static let exportContacts = "ExportContact"
			static let settings = "Settings"
        }
        
        struct viewControllers {
            static let advertise = "AdvertisementViewController"
            static let main = "MainViewController"
            static let content = "MediaContentViewController"
            static let datePicker = "DateSelectorViewController"
            static let assetsList = "SimpleAssetsListViewController"
            static let groupedList = "GroupedAssetListViewController"
			static let media = "MediaViewController"
			static let preview = "PreviewViewController"
            static let contacts = "ContactsViewController"
            static let deepClean = "DeepCleaningViewController"
            static let contactsGroup = "ContactsGroupViewController"
            static let expordContacts = "ExportContactsViewController"
			static let settings = "SettingsViewController"
			
        }
        
        struct cells {
            static let mediaTypeCell = "MediaTypeCollectionViewCell"
            static let contentTypeCell = "ContentTypeTableViewCell"
            static let photoSimpleCell = "PhotoCollectionViewCell"
			static let photoPreviewCell = "PhotoPreviewCollectionViewCell"
            static let dropDownCell = "DropDownMenuTableViewCell"
            static let carouselCell = "CarouselCollectionViewCell"
            static let cleanInfoCell = "DeepCleanInfoTableViewCell"
            static let contactCell = "ContactTableViewCell"
            static let groupContactCell = "GroupContactTableViewCell"
			static let helperBannerCell = "HelperBannerTableViewCell"
        }
        
        struct views {
            static let groupHeaderView = "GroupedAssetsReusableHeaderView"
            static let groupFooterView = "GroupedAssetsReusableFooterView"
            static let contactGroupHeader = "GroupedContactsHeaderView"
            static let bottomButtonBarView = "BottomButtonBarView"
            static let bottomDoubleButtonBarView = "BottomDoubleButtonBarView"
            static let searchBar = "SearchBarView"
        }
        
        struct xibs {
            /// `cell xibs`
            static let mediaTypeCell = "MediaTypeCollectionViewCell"
            static let contentTypeCell = "ContentTypeTableViewCell"
            static let photoSimpleCell = "PhotoCollectionViewCell"
			static let photoPreviewCell = "PhotoPreviewCollectionViewCell"
            static let dropDownCell = "DropDownMenuTableViewCell"
            static let cleanInfoCell = "DeepCleanInfoTableViewCell"
            static let contactCell = "ContactTableViewCell"
            static let groupContactCell = "GroupContactTableViewCell"
			static let bannerCell = "HelperBannerTableViewCell"
            /// `views`
            static let groupHeader = "GroupedAssetsReusableHeaderView"
            static let groupFooter = "GroupedAssetsReusableFooterView"
            static let contactGroupHeader = "GroupedContactsHeaderView"
            static let bottomButtonBarView = "BottomButtonBarView"
            static let bottomDoubleButtonBarView = "BottomDoubleButtonBarView"
            static let searchBar = "SearchBarView"
            
            static let carouselView = "CarouselItemView"
            static let datePickerContainer = "DateSelectebleView"
            
            /// `navigation`
            static let startingNavigationBar = "StartingNavigationBar"
            static let navigationBar = "NavigationBar"
            
            /// controllers
//            static let photoPreview = "PhotoPreviewViewControllerOLDVers"
        }
        
        struct segue {
			static let showLowerDatePicker = "ShowDatePickerLowerDateSelectorViewController"
			static let showUpperDatePicker = "ShowDatePickerUpperDateSelectorViewController"
            static let showExportContacts = "ShowExportContactsViewControllerSegue"
			static let showSizeSelector = "ShowVideoSizeSelectorSegue"
        }
    }
	
	struct uiElementsNames {
		struct layers {
			static let progressLayer = "progress"
		}
	}
    
    struct dateFormat {
        static let dmy = "dd-MM-yyy"
        static let dateFormat = "dd MMM, yyyy"
        static let fullDateFormat = "yyyy-MM-dd HH:mm:ss"
        static let expiredDateFormat = "dd\\MM\\yyyy"
        static let fullDmy = "dd-MM-yyyy HH:mm:ss"
		static let monthDateYear = "MMM d, yyyy"
    }
    
    struct defaultValues {
        static let dateNow = Date()
    }
    
    struct contacts {
        
        struct contactsContainer{
            static let card = "Card"
            static let iCloud = "iCloud"
            static let addressBook = "Address Book"
            static let google = "Google"
            static let contancts = "Contacts"
            static let yahoo = "Yahoo"
            static let facebook = "Facebook"
        }
    }
}
