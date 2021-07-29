//
//  Constants.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import Foundation

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
            static let startingSavedDate = "startingSavedDate"
            static let endingSavedDate = "endingSavedDate"
            static let lastSmartClean = "lastSmartClean"
            
            static let photoSpace = "photoDiskSpace"
            static let videoSpace = "videoDiskSpace"
            static let allMediaSpace = "wholeAssetsDiskSpace"
        }
        
        struct notification {
            /// `phasset disk space update notification name`
            static let photoSpaceNotificationName = "photoSpaceDidChange"
            static let videoSpaceNotificationName = "videoSpaceDidChange"
            static let mediaSpaceNotificationName = "mediaSpaceDidChange"
            
            /// `deep clean update progress notification name`
            static let deepCleanSimilarPhotoPhassetScan = "deepCleanSimilarPhotoPhassetScan"
            static let deepCleanDuplicatedPhotoPhassetScan = "deepCleanDuplicatedPhotoPhassetScan"
            static let deepCleanScreenShotsPhotoPhassetScan = "deepCleanScreenShotsPhassetScan"
            static let deepCleanSimilarLivePhotosPhassetScan = "deepCleanSimilarLivePhotosPhaassetScan"
            static let deepCleanLargeVideoPhassetScan = "deepCleanLargeVideoPhassetScan"
            static let deepCleanDuplicateVideoPhassetScan = "deepCleanDuplicateVideoPhassetScan"
            static let deepCleanSimilarVideoPhassetScan = "deepCleanSimilarVideoPhassetScan"
            static let deepCleanScreenRecordingsPhassetScan = "deepCleanScreenRecordingsPhassetScant"
            static let deepCleanAllContactsScan = "deepCleanAllContactsScan"
            static let deepCleanEmptyContactsScan = "deepCleanEmptyContactsScan"
            static let deepCleanDuplicateContacts = "deepCleanDuplicatedContactsScan"
        }
        
//        MARK: - notification dictionary progress identifiers -
        /**
         use for notification info dictionary for update progress of deepCleanNotification
         - parameter `index` use for detect current progrss index
         - parameter `count` use for detect total assets count in progress
         */
    
        struct notificationDictionary {
            
            /// `INDEXES`
            /// photo part
            static let similarPhotoIndex = "deepCleanPhotoPrecessIndex"
            static let duplicatePhotoIndex = "deepCleanDuplicatePhotoProcessingIndex"
            static let screenShotsIndex = "deepCleanscreenShotsIndex"
            static let livePhotosIndex = "deepCleanlivePhotosIndex"
            /// video part
            static let largeVideoIndex = "deepCleanlargeVideoIndex"
            static let duplicateVideoIndex = "deepCleanduplicateVideoIndex"
            static let similarVideoIndex = "deepCleansimilarVideoIndex"
            static let screenRecordingsIndex = "deepCleanscreenRecordingsIndex"
            /// contacts part
            static let allContactsIndex = "deepCleanallContactsIndex"
            static let emptyContactsIndex = "deepCleanemptyContactsIndex"
            static let duplicateContactsIndex = "deepCleanduplicateContactsIndex"
            
            /// `TOTAL COUNT`
            static let similarPhotoCount = "deepCleanSimilarPhotoTotalAsssetsCount"
            static let duplicatePhotoCount = "deepCleanDuplicatePhotoTotalAssetsCount"
            static let screenShotsCount = "deepCleanscreenShotsCount"
            static let livePhotosSimilarCount = "deepCleanlivePhotosCount"
            /// video part
            static let largeVideoCount = "deepCleanlargeVideoCount"
            static let duplicateVideoCount = "deepCleanduplicateVideoCount"
            static let similarVideoCount = "deepCleansimilarVideoCount"
            static let screenRecordingsCount = "deepCleanscreenRecordingsCount"
            /// contacts part
            static let allContactsCount = "deepCleanallContactsCount"
            static let emptyContactsCount = "deepCleanemptyContactsCount"
            static let duplicateContactsCount = "deepCleanduplicateContactsCount"
        }
    }
    
//    MARK: - public identifiers -
    struct identifiers {
        
        struct storyboards {
            static let main = "Main"
            static let media = "MediaContent"
            static let deep = "DeepClean"
        }
        
        struct viewControllers {
            static let advertise = "AdvertisementViewController"
            static let main = "MainViewController"
            static let content = "MediaContentViewController"
            static let datePicker = "DateSelectorViewController"
            static let assetsList = "SimpleAssetsListViewController"
            static let groupedList = "GroupedAssetListViewController"
            
            static let deepClean = "DeepCleaningViewController"
        }
        
        struct cells {
            static let mediaTypeCell = "MediaTypeCollectionViewCell"
            static let contentTypeCell = "ContentTypeTableViewCell"
            static let photoSimpleCell = "PhotoCollectionViewCell"
            static let dropDownCell = "DropDownMenuTableViewCell"
            static let carouselCell = "CarouselCollectionViewCell"
            static let cleanInfoCell = "DeepCleanInfoTableViewCell"
        }
        
        struct views {
            static let groupHeaderView = "GroupedAssetsReusableHeaderView"
            static let groupFooterView = "GroupedAssetsReusableFooterView"
        }
        
        struct xibs {
            /// `cell xibs`
            static let mediaTypeCell = "MediaTypeCollectionViewCell"
            static let contentTypeCell = "ContentTypeTableViewCell"
            static let photoSimpleCell = "PhotoCollectionViewCell"
            static let dropDownCell = "DropDownMenuTableViewCell"
            static let cleanInfoCell = "DeepCleanInfoTableViewCell"
            /// `views`
            static let groupHeader = "GroupedAssetsReusableHeaderView"
            static let groupFooter = "GroupedAssetsReusableFooterView"
            
            static let carouselView = "CarouselItemView"
            
            /// controllers
//            static let photoPreview = "PhotoPreviewViewController"
        }
        
        struct segue {
            static let showDatePicker = "ShowDatePickerSelectorViewControllerSegue"
        }
    }
    
    struct dateFormat {
        static let dmy = "dd-MM-yyy"
        static let dateFormat = "dd MMM, yyyy"
        static let fullDateFormat = "yyyy-MM-dd HH:mm:ss"
        static let expiredDateFormat = "dd\\MM\\yyyy"
        static let fullDmy = "dd-MM-yyyy HH:mm:ss"
    }
    
    struct defaultValues {
        static let dateNow = Date()
    }
}
