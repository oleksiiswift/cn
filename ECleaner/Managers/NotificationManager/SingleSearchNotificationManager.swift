//
//  SingleSearchNotificationManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.11.2021.
//

import Foundation

    
enum SingleContentSearchNotificationType {
    
    ///  `contacts search`
    case allContacts
    case emptyContacts
    case duplicatesNames
    case duplicatesNumbers
    case duplicatesEmails
    
    case none
    
    var dictionaryCountName: String {
        
        switch self {
            case .allContacts:
                return C.key.notificationDictionary.count.allContactsCount
            case .emptyContacts:
                return C.key.notificationDictionary.count.emptyContactsCount
            case .duplicatesNames:
                return C.key.notificationDictionary.count.duplicateNamesContactsCount
            case .duplicatesNumbers:
                return C.key.notificationDictionary.count.duplicateNumbersContactsCount
            case .duplicatesEmails:
                return C.key.notificationDictionary.count.duplicateEmailsContactsCount
            case .none:
                return ""
        }
    }
    
    var dictioanartyIndexName: String {
        switch self {
            case .allContacts:
                return C.key.notificationDictionary.index.allContactsIndex
            case .emptyContacts:
                return C.key.notificationDictionary.index.emptyContactsIndex
            case .duplicatesNames:
                return C.key.notificationDictionary.index.duplicateNamesContactsIndex
            case .duplicatesNumbers:
                return C.key.notificationDictionary.index.duplicateNumbersContactsIndex
            case .duplicatesEmails:
                return C.key.notificationDictionary.index.duplicateEmailContactsIndex
            case .none:
                return ""
        }
    }
    
    var notificationName: Notification.Name {
        
        switch self {
            case .allContacts:
                return .singleSearchAllContactsScan
            case .emptyContacts:
                return .singleSearchEmptyContactsScan
            case .duplicatesNames:
                return .singleSearchDuplicatesNamesContactsScan
            case .duplicatesNumbers:
                return .singleSearchDuplicatesNumbersContactsScan
            case .duplicatesEmails:
                return .singleSearchDupliatesEmailsContactsScan
            case .none:
                return Notification.Name("")
        }
    }
    
    var mediaTypeRawValue: PhotoMediaType {
        
        switch self {
            case .allContacts:
                return .allContacts
            case .emptyContacts:
                return .emptyContacts
            case .duplicatesNames:
                return .duplicatedContacts
            case .duplicatesNumbers:
                return .duplicatedPhoneNumbers
            case .duplicatesEmails:
                return .duplicatedEmails
            case .none:
                return .none
        }
    }
}

class SingleSearchNitificationManager {
    
    class var instance: SingleSearchNitificationManager {
        struct Static {
            static let instance: SingleSearchNitificationManager = SingleSearchNitificationManager()
        }
        return Static.instance
    }
    
    public func sendSingleSearchProgressNotification(notificationtype: SingleContentSearchNotificationType, totalProgressItems: Int, currentProgressItem: Int) {
        
        let userInfo = [notificationtype.dictioanartyIndexName: currentProgressItem,
                        notificationtype.dictionaryCountName: totalProgressItems]
        
        NotificationCenter.default.post(name: notificationtype.notificationName, object: nil, userInfo: userInfo)
    }
}
