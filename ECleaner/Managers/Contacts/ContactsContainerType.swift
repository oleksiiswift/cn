//
//  ContactsContainerType.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.11.2021.
//

import Foundation

enum ContactsContainerType {
    case none
    case card
    case adressBook
    case contacts
    
    var rawValue: String? {
        switch self {
            case .none:
                return nil
            case .card:
                return C.contacts.contactsContainer.card
            case .adressBook:
                return C.contacts.contactsContainer.addressBook
            case .contacts:
                return C.contacts.contactsContainer.contancts
        }
    }
}
