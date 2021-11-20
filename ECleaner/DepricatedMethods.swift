//
//  DepricatedMethods.swift
//  ECleaner
//
//  Created by alexey sorochan on 20.11.2021.
//

import Foundation
import Contacts


extension ContactsManager {
    
        /// processing is to long -> depricated
    private func namesDuplicatedDepricated(_ contacts: [CNContact], completionHandler: @escaping ([CNContact]) -> Void) {
        
        var duplicates: [CNContact] = []
        
        for i in 0...contacts.count - 1 {
            debugPrint("name duplicate index: \(i)")
            if duplicates.contains(contacts[i]) {
                continue
            }
            let contact = contacts[i]
            let duplicatedContacts: [CNContact] = contacts.filter({ $0 != contacts[i]}).filter({$0.givenName.removeWhitespace() + $0.familyName.removeWhitespace() == contact.givenName.removeWhitespace() + contact.familyName.removeWhitespace()}) //.filter({$0.familyName == contact.familyName})
            
            duplicatedContacts.forEach({
                
                let name = $0.givenName.removeWhitespace() + $0.familyName.removeWhitespace() + $0.middleName.removeWhitespace()
                
                guard !name.isEmpty else { return }
                
                debugPrint("each")
                if !duplicates.contains(contact) {
                    debugPrint(contact)
                    duplicates.append(contact)
                }
                
                if !duplicates.contains($0) {
                    debugPrint($0)
                    duplicates.append($0)
                }
            })
        }
        completionHandler(duplicates)
    }
    
        /// `names duplicated group`
    private func namesDuplicatesGroupDepricated(_ contacts: [CNContact], completionHandler: @escaping ([ContactsGroup]) -> Void) {
        var group: [ContactsGroup] = []
        
        for contact in contacts {
            debugPrint("names group index: \(String(describing: contacts.firstIndex(of: contact)))")
            if group.filter({$0.name.removeWhitespace() == contact.givenName.removeWhitespace() + contact.familyName.removeWhitespace()}).count == 0 {
                let itentifier = self.getRegionIdentifier(from: contact)
                group.append(ContactsGroup(name: contact.givenName.removeWhitespace() + contact.familyName.removeWhitespace(), contacts: [], groupType: .duplicatedContactName, countryIdentifier: itentifier))
            }
        }
        
        for contact in contacts {
            debugPrint("extra filer index: \(String(describing: contacts.firstIndex(of: contact)))")
            group.filter({$0.name.removeWhitespace() == contact.givenName.removeWhitespace() + contact.familyName.removeWhitespace()})[0].contacts.append(contact)
        }
        
        group.forEach({ $0.contacts = self.esctimateBestContactIn($0.contacts )})
        
        completionHandler(group)
    }
}
