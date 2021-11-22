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
    static let deepCleanSimilarPhotoPhassetScan = Notification.Name(C.key.notification.deepCleanSimilarPhotoPhassetScan)
    static let deepCleanDuplicatedPhotoPhassetScan = Notification.Name(C.key.notification.deepCleanDuplicatedPhotoPhassetScan)
    static let deepCleanScreenShotsPhassetScan = Notification.Name(C.key.notification.deepCleanScreenShotsPhotoPhassetScan)
    static let deepCleanSimilarLivePhotosPhaassetScan = Notification.Name(C.key.notification.deepCleanSimilarLivePhotosPhassetScan)
    static let deepCleanLargeVideoPhassetScan = Notification.Name(C.key.notification.deepCleanLargeVideoPhassetScan)
    static let deepCleanDuplicateVideoPhassetScan = Notification.Name(C.key.notification.deepCleanDuplicateVideoPhassetScan)
    static let deepCleanSimilarVideoPhassetScan = Notification.Name(C.key.notification.deepCleanSimilarVideoPhassetScan)
    static let deepCleanScreenRecordingsPhassetScan = Notification.Name(C.key.notification.deepCleanScreenRecordingsPhassetScan)
    static let deepCleanAllContactsScan = Notification.Name(C.key.notification.deepCleanAllContactsScan)
    static let deepCleanEmptyContactsScan = Notification.Name(C.key.notification.deepCleanEmptyContactsScan)
    static let deepCleanDuplicatedContactsScan = Notification.Name(C.key.notification.deepCleanDuplicateContacts)
    
    /// `contacts`
    static let mergeContactsSelectionDidChange = Notification.Name(C.key.notification.mergeContactsSelectionDidChange)
    static let selectedContactsCountDidChange = Notification.Name(C.key.notification.selectedContactsDidChange)
    static let scrollViewDidScroll = Notification.Name("scrollViewDidScroll")
    static let searchBarDidCancel = Notification.Name("searchBarDidCancel")
    
    /// `progress alert notification`
    static let progressAlertDidChangeProgress = Notification.Name("progoressCalculationDidChange")
}
