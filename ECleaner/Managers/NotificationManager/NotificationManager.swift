//
//  NotificationManager.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import Foundation

extension Notification.Name {

        /// `colors asets`
    static let colorDidChange = 			Notification.Name("colorDidChange")
        /// `premium`
    static let premiumDidChange = 			Notification.Name("premiumDidChange")
		/// `permission`
	static let permisionDidChange = 		Notification.Name(C.key.notification.permissionDidChange)
		/// `ìncoming processing recieved`
	static let incomingRemoteActionRecived = Notification.Name(C.key.notification.forceStopProcessing)
	
	static let networkingChanged 		   = Notification.Name(C.key.notification.networking)
	
	static let bannerStatusDidChanged 	   = Notification.Name(C.key.notification.bannerStatus)
    
        /// `disk space`
    static let photoSpaceDidChange =         Notification.Name(C.key.notification.photoSpaceNotificationName)
    static let videoSpaceDidChange =         Notification.Name(C.key.notification.videoSpaceNotificationName)
    static let mediaSpaceDidChange =    	 Notification.Name(C.key.notification.mediaSpaceNotificationName)
    static let contactsCountDidChange =      Notification.Name(C.key.notification.contactsCountNotificationName)
	static let removeContactsStoreObserver = Notification.Name(C.key.notification.removeStoreObserver)
	static let addContactsStoreObserver = 	 Notification.Name(C.key.notification.addStoreObserver)
    
        /// `deep clean progress notification`
    static let deepCleanSimilarPhotoPhassetScan =       Notification.Name(C.key.notification.deepClean.deepCleanSimilarPhotoPhassetScan)
    static let deepCleanDuplicatedPhotoPhassetScan =    Notification.Name(C.key.notification.deepClean.deepCleanDuplicatedPhotoPhassetScan)
    static let deepCleanScreenShotsPhassetScan =        Notification.Name(C.key.notification.deepClean.deepCleanScreenShotsPhotoPhassetScan)
	static let deepCleanSimilarSelfiesPhassetScan =		Notification.Name(C.key.notification.deepClean.deepCleanSimilarSelfiesPhotoPhassetScan)
    static let deepCleanSimilarLivePhotosPhaassetScan = Notification.Name(C.key.notification.deepClean.deepCleanSimilarLivePhotosPhassetScan)
    static let deepCleanLargeVideoPhassetScan =         Notification.Name(C.key.notification.deepClean.deepCleanLargeVideoPhassetScan)
    static let deepCleanDuplicateVideoPhassetScan =     Notification.Name(C.key.notification.deepClean.deepCleanDuplicateVideoPhassetScan)
    static let deepCleanSimilarVideoPhassetScan =       Notification.Name(C.key.notification.deepClean.deepCleanSimilarVideoPhassetScan)
    static let deepCleanScreenRecordingsPhassetScan =   Notification.Name(C.key.notification.deepClean.deepCleanScreenRecordingsPhassetScan)
    static let deepCleanEmptyContactsScan =             Notification.Name(C.key.notification.deepClean.deepCleanEmptyContactsScan)
    static let deepCleanDuplicatedContactsScan =        Notification.Name(C.key.notification.deepClean.deepCleanDuplicatedContactsScan)
    static let deepCleanDuplicatedPhoneNumbersScan =    Notification.Name(C.key.notification.deepClean.deepCleanDuplicatedPhoneNumbersScan)
    static let deepCleanDupLicatedMailsScan =           Notification.Name(C.key.notification.deepClean.deepCleanDupLicatedMailsScan)
	
	static let deepCleanPhotoFilesScan =				Notification.Name(C.key.notification.deepClean.deepCleanPhotoFilesSizeScan)
	static let deepCleanVideoFilesScan = 				Notification.Name(C.key.notification.deepClean.deepCleanVideoFilesSizeScan)
    
        ///  `single search scan progress notification`
	static let singleSearchSimilarPhotoScan = 				Notification.Name(C.key.notification.singleSearch.singleSearchSimilarPhotoPHAssetScan)
	static let singleSearchDuplicatedPhotoScan = 			Notification.Name(C.key.notification.singleSearch.singleDuplicatedPhotoPHAssetScan)
	static let singleSearchSimilarLivePhotoScan =			Notification.Name(C.key.notification.singleSearch.singleLivePhotoPHAssetScan)
	static let singleSearchScreenShotsPhotoScan = 			Notification.Name(C.key.notification.singleSearch.singleScreeenshotsPhotoPHAssetScan)
	static let singleSearchSimilarSelfiePhotoScan = 		Notification.Name(C.key.notification.singleSearch.singleSimilarSelfiesPHassetScan)
	static let singleSearchLivePhotoScan = 					Notification.Name(C.key.notification.singleSearch.singleLivePhotoPHAssetScan)
	static let singleSearchRecentlyDeletedPhotoScan = 		Notification.Name(C.key.notification.singleSearch.singleRecentlyDeletedPHAssetScan)
	static let singleSearchLargeVideoScan = 				Notification.Name(C.key.notification.singleSearch.singleLargeVideoPHAssetScan)
	static let singleSearchDuplicatedVideoScan = 			Notification.Name(C.key.notification.singleSearch.singleDuplicatedVideoPHAssetScan)
	static let singleSearchSimilarVideoScan = 				Notification.Name(C.key.notification.singleSearch.singleSimilarVideoPHAssetScan)
	static let singleSearchScreenRecordingVideoScan = 		Notification.Name(C.key.notification.singleSearch.singleScreenRecordingsVideoPHAssetScan)
	static let singleSearchRecentlyDeletedVideoScan = 		Notification.Name(C.key.notification.singleSearch.singleRecentlyDeleteVideoPHAssetScan)
    static let singleSearchAllContactsScan =                Notification.Name(C.key.notification.singleSearch.singleSearchAllContactsScan)
    static let singleSearchEmptyContactsScan =              Notification.Name(C.key.notification.singleSearch.singleSearchEmptyContactsScan)
    static let singleSearchDuplicatesNamesContactsScan =    Notification.Name(C.key.notification.singleSearch.singleSearchDuplicatesNamesContactsScan)
    static let singleSearchDuplicatesNumbersContactsScan =  Notification.Name(C.key.notification.singleSearch.singleSearchDuplicatesNumbersContactsScan)
    static let singleSearchDupliatesEmailsContactsScan =    Notification.Name(C.key.notification.singleSearch.singleSearchDupliatesEmailsContactsScan)
	
	static let singleOperationPhotoFilesSizeScan = 			Notification.Name(C.key.notification.singleSearch.singleOperationPhotoFilesSizeScan)
	static let singleOperationVideoFilesSizeScan = 			Notification.Name(C.key.notification.singleSearch.singleOperationVideoFilesSizeScan)
    
        /// `contacts`
    static let mergeContactsSelectionDidChange =    Notification.Name(C.key.notification.mergeContactsSelectionDidChange)
    static let selectedContactsCountDidChange =     Notification.Name(C.key.notification.selectedContactsDidChange)
    static let scrollViewDidScroll =                Notification.Name("scrollViewDidScroll")
    static let scrollViewDidBegingDragging =        Notification.Name("scrollViewDidBeginDragging")
    static let searchBarDidCancel =                 Notification.Name("searchBarDidCancel")
    static let searchBarShouldResign =              Notification.Name("searchBarShouldResign")
	static let searchBarClearButtonClicked = 		Notification.Name("searchBarClearButtonClicked")
    
        /// `progress alert notification`
    static let progressDeleteContactsAlertDidChangeProgress =   Notification.Name("progressDeleteContactsAlertDidChangeProgress")
    static let progressMergeContactsAlertDidChangeProgress =    Notification.Name("progressMergeContactsAlertDidChangeProgress")
	static let progressDeepCleanDidChangeProgress = 			Notification.Name("progressDeepCleanDidChangeProgress")
	
	static let avPlayerDidPlayEndTime = NSNotification.Name.AVPlayerItemDidPlayToEndTime
	
	static let compressionVideoDidStart = NSNotification.Name(C.key.notification.compressionDidStart)
	
	static let shortCutsItemsNavigationItemsNotification = NSNotification.Name("shortCutsItemsNavigationItemsNotification")
	
	static let didCancelPromtRequest = Notification.Name.init("iRateUserDidRequestReminderToRateApp")
}

