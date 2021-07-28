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
    static let deepCleanSimilarPhotoPhassetScan = Notification.Name("deepCleanSimilarPhotoPhassetScant")
    static let deepCleanDuplicatedPhotoPhassetScan = Notification.Name("deepCleanDuplicatedPhotoPhassetScan")
    static let deepCleanScreenShotsPhassetScan = Notification.Name("deepCleanScreenShotsPhassetScan")
    static let deepCleanSimilarLivePhotosPhaassetScan = Notification.Name("deepCleanSimilarLivePhotosPhaassetScan")
    static let deepCleanLargeVideoPhassetScan = Notification.Name("deepCleanLargeVideoPhassetScan")
    static let deepCleanDuplicateVideoPhassetScan = Notification.Name("deepCleanDuplicateVideoPhassetScan")
    static let deepCleanSimilarVideoPhassetScan = Notification.Name("deepCleanSimilarVideoPhassetScan")
    static let deepCleanScreenRecordingsPhassetScan = Notification.Name("deepCleanScreenRecordingsPhassetScant")
    static let deepCleanAllContactsScan = Notification.Name("deepCleanAllContactsScan")
    static let deepCleanEmptyContactsScan = Notification.Name("deepCleanEmptyContactsScan")
    static let deepCleanDuplicatedContactsScan = Notification.Name("deepCleanDuplicatedContactsScan")
}
