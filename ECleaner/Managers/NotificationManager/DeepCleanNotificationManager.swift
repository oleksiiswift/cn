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
    case similarLivePhoto
    
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
                return C.key.notificationDictionary.count.similarPhotoCount
            case .duplicatePhoto:
                return C.key.notificationDictionary.count.duplicatePhotoCount
            case .screenshots:
                return C.key.notificationDictionary.count.screenShotsCount
            case .similarLivePhoto:
                return C.key.notificationDictionary.count.livePhotosSimilarCount
            case .largeVideo:
                return C.key.notificationDictionary.count.largeVideoCount
            case .duplicateVideo:
                return C.key.notificationDictionary.count.duplicateVideoCount
            case .similarVideo:
                return C.key.notificationDictionary.count.similarVideoCount
            case .screenRecordings:
                return C.key.notificationDictionary.count.screenRecordingsCount
            case .allContacts:
                return C.key.notificationDictionary.count.allContactsCount
            case .emptyContacts:
                return C.key.notificationDictionary.count.emptyContactsCount
            case .duplicateContacts:
                return C.key.notificationDictionary.count.duplicateNamesContactsCount
        }
    }
    
    var dictionaryIndexName: String {
        
        switch self {
        
            case .similarPhoto:
                return C.key.notificationDictionary.index.similarPhotoIndex
            case .duplicatePhoto:
                return C.key.notificationDictionary.index.duplicatePhotoIndex
            case .screenshots:
                return C.key.notificationDictionary.index.screenShotsIndex
            case .similarLivePhoto:
                return C.key.notificationDictionary.index.livePhotosIndex
            case .largeVideo:
                return C.key.notificationDictionary.index.largeVideoIndex
            case .duplicateVideo:
                return C.key.notificationDictionary.index.duplicateVideoIndex
            case .similarVideo:
                return C.key.notificationDictionary.index.similarVideoIndex
            case .screenRecordings:
                return C.key.notificationDictionary.index.screenRecordingsIndex
            case .allContacts:
                return C.key.notificationDictionary.index.allContactsIndex
            case .emptyContacts:
                return C.key.notificationDictionary.index.emptyContactsIndex
            case .duplicateContacts:
                return C.key.notificationDictionary.index.duplicateNamesContactsIndex
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
            case .similarLivePhoto:
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
    
    var mediaTypeRawValue: PhotoMediaType {
        switch self {
            case .similarPhoto:
                return .similarPhotos
            case .duplicatePhoto:
                return .duplicatedPhotos
            case .screenshots:
                return .singleScreenShots
            case .similarLivePhoto:
                return .similarLivePhotos
            case .largeVideo:
                return .singleLargeVideos
            case .duplicateVideo:
                return .duplicatedVideos
            case .similarVideo:
                return .similarVideos
            case .screenRecordings:
                return .singleScreenRecordings
            case .allContacts:
                return .allContacts
            case .emptyContacts:
                return .emptyContacts
            case .duplicateContacts:
                return .duplicatedContacts
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