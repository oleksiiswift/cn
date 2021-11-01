//
//  ContactGroupListViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.11.2021.
//

import Foundation
import Contacts

class ContactGroupListViewModel {
    
    public let groupSection: [ContactsGroup]
    
    private var contactsManager = ContactsManager.shared
    
    init(contactsGroup: [ContactsGroup]) {
        
        self.groupSection = contactsGroup
    }
}


extension ContactGroupListViewModel {
    
    public func numbersOfSections() -> Int {
        return groupSection.count
    }
    
    public func numbersOfRows(at section: Int) -> Int {
        return groupSection[section].contacts.count
    }
    
    public func getContact(at indexPath: IndexPath) -> CNContact? {
        
        return groupSection[indexPath.section].contacts[indexPath.row]
    }
}

extension ContactGroupListViewModel {
    
    
}
