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
}
