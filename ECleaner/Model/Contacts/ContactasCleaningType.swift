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
	
	case telegram
    
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
	
	var name: String {
		switch self {
			case .onlyName:
				return Localization.Main.HeaderTitle.onlyName
			case .onlyPhone:
				return Localization.Main.HeaderTitle.onlyPhoneNumber
			case .onlyEmail:
				return Localization.Main.HeaderTitle.onlyEmail
			case .emptyName:
				return Localization.Main.HeaderTitle.emptyName
			case .wholeEmpty:
				return Localization.Main.HeaderTitle.wholeEmpty
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
