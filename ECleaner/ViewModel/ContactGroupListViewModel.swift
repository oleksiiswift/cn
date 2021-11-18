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
    private var contactsData: [String: [CNContact]] = [:]
    
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
    
    public func setSectionTitle(for section: Int) -> String {
        return groupSection[section].groupType.rawValue
    }
    
    public func getContactOnRow(at indexPath: IndexPath) -> CNContact? {
        return groupSection[indexPath.section].contacts[indexPath.row]
    }
    
    public func getContacts(at indexPaths: [IndexPath]) -> [CNContact] {
        var cont: [CNContact] = []
        
        indexPaths.forEach { indexPath in
            if let contact = self.getContact(at: indexPath) {
                cont.append(contact)
            }
        }
        return cont
    }
 }

extension ContactGroupListViewModel {

    private func reloadSections(_ contactsGroup: [ContactsGroup]) {}

}
