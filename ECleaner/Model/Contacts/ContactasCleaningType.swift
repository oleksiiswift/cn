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
    
	case emptyContacts
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
    
	var emptyResultsError: ErrorHandler.EmptyResultsError {
        switch self {
            case .duplicatedPhoneNumnber:
				return .duplicatedNumbersIsEmpty
            case .duplicatedContactName:
				return .duplicatedNamesIsEmpty
            case .duplicatedEmail:
				return .duplicatedEmailsIsEmpty
            default:
				return .contactsIsEmpty
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
