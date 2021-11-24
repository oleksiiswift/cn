//
//  NotificationManager.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.06.2021.
//

import Foundation

extension Notification.Name {

        /// `colors asets`
    static let colorDidChange = Notification.Name("colorDidChange")
        /// `premium`
    static let premiumDidChange = Notification.Name("premiumDidChange")
    
        /// `disk space`
    static let photoSpaceDidChange = Notification.Name("photoSpaceDidChange")
    static let videoSpaceDidChange = Notification.Name("videoSpaceDidChange")
    static let mediaSpaceDidChange = Notification.Name("mediaSpaceDidChange")
    
        /// `deep clean progress notification`
    static let deepCleanSimilarPhotoPhassetScan = Notification.Name(C.key.notification.deepClean.deepCleanSimilarPhotoPhassetScan)
    static let deepCleanDuplicatedPhotoPhassetScan = Notification.Name(C.key.notification.deepClean.deepCleanDuplicatedPhotoPhassetScan)
    static let deepCleanScreenShotsPhassetScan = Notification.Name(C.key.notification.deepClean.deepCleanScreenShotsPhotoPhassetScan)
    static let deepCleanSimilarLivePhotosPhaassetScan = Notification.Name(C.key.notification.deepClean.deepCleanSimilarLivePhotosPhassetScan)
    static let deepCleanLargeVideoPhassetScan = Notification.Name(C.key.notification.deepClean.deepCleanLargeVideoPhassetScan)
    static let deepCleanDuplicateVideoPhassetScan = Notification.Name(C.key.notification.deepClean.deepCleanDuplicateVideoPhassetScan)
    static let deepCleanSimilarVideoPhassetScan = Notification.Name(C.key.notification.deepClean.deepCleanSimilarVideoPhassetScan)
    static let deepCleanScreenRecordingsPhassetScan = Notification.Name(C.key.notification.deepClean.deepCleanScreenRecordingsPhassetScan)
    static let deepCleanAllContactsScan = Notification.Name(C.key.notification.deepClean.deepCleanAllContactsScan)
    static let deepCleanEmptyContactsScan = Notification.Name(C.key.notification.deepClean.deepCleanEmptyContactsScan)
    static let deepCleanDuplicatedContactsScan = Notification.Name(C.key.notification.deepClean.deepCleanDuplicateContacts)
    
        ///  `single search scan progress notification`
    static let singleSearchAllContactsScan = Notification.Name(C.key.notification.singleSearch.singleSearchAllContactsScan)
    static let singleSearchEmptyContactsScan = Notification.Name(C.key.notification.singleSearch.singleSearchEmptyContactsScan)
    static let singleSearchDuplicatesNamesContactsScan = Notification.Name(C.key.notification.singleSearch.singleSearchDuplicatesNamesContactsScan)
    static let singleSearchDuplicatesNumbersContactsScan = Notification.Name(C.key.notification.singleSearch.singleSearchDuplicatesNumbersContactsScan)
    static let singleSearchDupliatesEmailsContactsScan = Notification.Name(C.key.notification.singleSearch.singleSearchDupliatesEmailsContactsScan)
    
        /// `contacts`
    static let mergeContactsSelectionDidChange = Notification.Name(C.key.notification.mergeContactsSelectionDidChange)
    static let selectedContactsCountDidChange = Notification.Name(C.key.notification.selectedContactsDidChange)
    static let scrollViewDidScroll = Notification.Name("scrollViewDidScroll")
    static let scrollViewDidBegingDragging = Notification.Name("scrollViewDidBeginDragging")
    static let searchBarDidCancel = Notification.Name("searchBarDidCancel")
    
        /// `progress alert notification`
    static let progressDeleteContactsAlertDidChangeProgress = Notification.Name("progressDeleteContactsAlertDidChangeProgress")
    static let progressMergeContactsAlertDidChangeProgress = Notification.Name("progressMergeContactsAlertDidChangeProgress")
}
