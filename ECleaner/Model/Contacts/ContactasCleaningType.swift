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
				return C.key.contacts.groupSorting.name
            case .onlyPhone:
				return C.key.contacts.groupSorting.phone
            case .onlyEmail:
				return C.key.contacts.groupSorting.mail
            case .emptyName:
				return C.key.contacts.groupSorting.emptyName
            case .wholeEmpty:
				return C.key.contacts.groupSorting.empty
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
