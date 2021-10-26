//
//  ContactListViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.10.2021.
//

import Foundation
import Contacts

class ContactListViewModel {
    
    public let contacts: [CNContact]
    public var contactsArray: [CNContact] {
        return isSearchEnabled.value ? filteredContacts : contacts
    }
    private var filteredContacts: [CNContact] = []
    public var contactsSections: [String] = []
    private var contactsData: [String: [CNContact]] = [:]
    
    private var searchContact = Dynamic<String>("")
    private var isSearchEnabled = Dynamic<Bool>(false)
    
    private var contactsManager = ContactsManager.shared

    init(contacts: [CNContact]) {
        
        self.contacts = contacts
        reloadSections(self.contacts)
    }
}

// MARK: - contacts data source -
extension ContactListViewModel {
    
    public func numbersOfRows(at section: Int) -> Int {
        return contactsData[self.contactsSections[section]]?.count ?? 0
    }
    
    public func titleOFHeader(at section: Int) -> String? {
        return self.contactsSections[section]
    }
    
    public func getContactOnRow(at indexPath: IndexPath) -> CNContact? {
        let key = self.contactsSections[indexPath.section]
        let contacts = contactsData[key]?.sorted(by: { (a, b) -> Bool in
            let firstContactFullName = a.givenName + a.familyName
            let secondContactFullName = b.givenName + b.familyName
            return firstContactFullName.localizedCaseInsensitiveCompare(secondContactFullName) == .orderedAscending
        })
        return contacts?[indexPath.row]
    }
}

extension ContactListViewModel {
    
    private func reloadSections(_ contacts: [CNContact]) {
        
        self.contactsData = contactsManager.getSortAndGroupContacts(contacts)
        var sortedSections = Array(self.contactsData.keys)
        
        sortedSections = sortedSections.sorted(by: { first, second in
            if first.isEmpty || first == " " {
                return false
            } else if second.isEmpty || second == " " {
                return true
            } else {
                return first.localizedCaseInsensitiveCompare(second) == .orderedAscending
            }
        })
    }
}

extension ContactListViewModel {
    
    public func updateSearchState() {
        
        if !searchContact.value.isEmpty {
            let filteredList = contacts.filter {
                
                $0.givenName.lowercased().contains(searchContact.value.lowercased()) ||
                $0.familyName.lowercased().contains(searchContact.value.lowercased()) ||
                $0.phoneNumbers.contains(where: {$0.value.stringValue.contains(searchContact.value.removeNonNumeric())})
            }
            
            self.filteredContacts = filteredList
            reloadSections(contactsArray)
            isSearchEnabled.value = true
            
        } else {
            reloadSections(self.contacts)
            isSearchEnabled.value = false
        }
    }
}
