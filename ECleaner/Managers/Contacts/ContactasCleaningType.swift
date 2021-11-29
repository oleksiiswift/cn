//
//  ContactasCleaningType.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.11.2021.
//

import Foundation

enum ContactasCleaningType {
    case onlyName
    case onlyPhone
    case onlyEmail
    case emptyName
    case wholeEmpty
    case none
    
    case duplicatedPhoneNumnber
    case duplicatedContactName
    case duplicatedEmail
    
    var rawValue: String {
        switch self {
            case .onlyName:
                return "only name"
            case .onlyPhone:
                return "only phone"
            case .onlyEmail:
                return "only mail"
            case .emptyName:
                return "incomplete name"
            case .wholeEmpty:
                return "whole Empty phone"
            default:
                return ""
        }
    }
    
    var notificationType: SingleContentSearchNotificationType {
        switch self {
            case .duplicatedPhoneNumnber:
                return .duplicatesNumbers
            case .duplicatedContactName:
                return .duplicatesNames
            case .duplicatedEmail:
                return .duplicatesEmails
            default:
                return .none
        }
    }
    
    var alertEmptyType: AlertType {
        switch self {
            case .duplicatedPhoneNumnber:
                return .duplicatesNumbersIsEmpty
            case .duplicatedContactName:
                return .duplicatesNamesIsEmpty
            case .duplicatedEmail:
                return .duplicatesEmailsIsEmpty
                
            default:
                return .none
        }
    }
    
    var photoMediaType: PhotoMediaType {
        switch self {
            case .duplicatedPhoneNumnber:
                return .duplicatedPhoneNumbers
            case .duplicatedContactName:
                return .duplicatedContacts
            case .duplicatedEmail:
                return .duplicatedEmails
            default:
                return .none
        }
    }
}
