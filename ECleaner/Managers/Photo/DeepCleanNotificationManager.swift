//
//  DeepCleanNotificationManager.swift
//  ECleaner
//
//  Created by alekseii sorochan on 28.07.2021.
//

import Foundation


enum DeepCleanNotificationType {
    case similarPhoto
    case duplicatePhoto
    case screenshots
    case livePhoto
    
    case largeVideo
    case duplicateVideo
    case similarVideo
    case screenRecordings
    
    case allContacts
    case emptyContacts
    case duplicateContacts
    
    var dictionaryCountName: String {
        switch self {
     
            case .similarPhoto:
                return C.key.notificationDictionary.similarPhotoCount
            case .duplicatePhoto:
                return C.key.notificationDictionary.duplicatePhotoCount
            case .screenshots:
                return C.key.notificationDictionary.screenShotsCount
            case .livePhoto:
                return C.key.notificationDictionary.livePhotosSimilarCount
            case .largeVideo:
                return C.key.notificationDictionary.largeVideoCount
            case .duplicateVideo:
                return C.key.notificationDictionary.duplicatePhotoCount
            case .similarVideo:
                return C.key.notificationDictionary.similarVideoCount
            case .screenRecordings:
                return C.key.notificationDictionary.screenRecordingsCount
            case .allContacts:
                return C.key.notificationDictionary.allContactsCount
            case .emptyContacts:
                return C.key.notificationDictionary.emptyContactsCount
            case .duplicateContacts:
                return C.key.notificationDictionary.duplicateContactsCount
        }
    }
    
    var dictionaryIndexName: String {
        switch self {
        
            case .similarPhoto:
                return C.key.notificationDictionary.similarPhotoIndex
            case .duplicatePhoto:
                return C.key.notificationDictionary.duplicatePhotoIndex
            case .screenshots:
                return C.key.notificationDictionary.screenShotsIndex
            case .livePhoto:
                return C.key.notificationDictionary.livePhotosIndex
            case .largeVideo:
                return C.key.notificationDictionary.largeVideoIndex
            case .duplicateVideo:
                return C.key.notificationDictionary.duplicateVideoIndex
            case .similarVideo:
                return C.key.notificationDictionary.similarVideoIndex
            case .screenRecordings:
                return C.key.notificationDictionary.screenRecordingsIndex
            case .allContacts:
                return C.key.notificationDictionary.allContactsIndex
            case .emptyContacts:
                return C.key.notificationDictionary.emptyContactsIndex
            case .duplicateContacts:
                return C.key.notificationDictionary.duplicateContactsIndex
        }
    }
    
    var notificationName: NSNotification.Name {
        switch self {
            case .similarPhoto:
                return .deepCleanSimilarPhotoPhassetScan
            case .duplicatePhoto:
                return .deepCleanDuplicatedPhotoPhassetScan
            case .screenshots:
                return .deepCleanScreenShotsPhassetScan
            case .livePhoto:
                return .deepCleanSimilarLivePhotosPhaassetScan
            case .largeVideo:
                return .deepCleanLargeVideoPhassetScan
            case .duplicateVideo:
                return .deepCleanDuplicateVideoPhassetScan
            case .similarVideo:
                return .deepCleanSimilarVideoPhassetScan
            case .screenRecordings:
                return .deepCleanScreenRecordingsPhassetScan
            case .allContacts:
                return .deepCleanAllContactsScan
            case .emptyContacts:
                return .deepCleanEmptyContactsScan
            case .duplicateContacts:
                return .deepCleanDuplicatedContactsScan
        }
    }
}

class DeepCleanNotificationManager {
    
    class var instance: DeepCleanNotificationManager {
        struct Static {
            static let instance: DeepCleanNotificationManager = DeepCleanNotificationManager()
        }
        return Static.instance
    }
        
    /// handle notification update according to progress calculate total percentage count
    public func sendDeepProgressNotificatin(notificationType: DeepCleanNotificationType, totalProgressItems: Int, currentProgressItem: Int) {
        
        let infoDictionary = [notificationType.dictionaryIndexName: currentProgressItem,
                              notificationType.dictionaryCountName: totalProgressItems]
        
        NotificationCenter.default.post(name: notificationType.notificationName, object: nil, userInfo: infoDictionary)
    }
}
