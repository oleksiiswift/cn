//
//  ContactsManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.10.2021.
//

import ContactsUI
import UIKit

enum AlphabeticalContactsResults {
    case succes(responce: [String: [CNContact]])
    case error(error: Error)
}

class CNContactSection {
    let name: String
    var contacts: [CNContact]
    
    init(name: String, contacts: [CNContact]) {
        self.name = name
        self.contacts = contacts
    }
}


class ContactsManager {
    
    static let shared: ContactsManager = {
        let instance = ContactsManager()
        return instance
    }()
    
    private let fetchingKeys: [CNKeyDescriptor] = [
        CNContactVCardSerialization.descriptorForRequiredKeys(),
        CNContactThumbnailImageDataKey as CNKeyDescriptor
    ]
    
    
//    MARK: - contacts store auth status -
    
    /// auth for contacts data
    private func checkContactStoreAuthStatus(completion: @escaping(_ grantAccess: Bool) -> Void) {
        
        completion(CNContactStore.authorizationStatus(for: .contacts) == .authorized)
    }
    
    /// request access for user contacts
    private func requestAccesss(_ requestGranted: @escaping(Bool, Error?) -> ()) {
        
        CNContactStore().requestAccess(for: .contacts) { grandted, error in
            requestGranted(grandted, error)
        }
    }
}

extension ContactsManager {
    
    /// check status and if restricted returned to settings or ask for permision
    public func checkStatus(completionHandler: @escaping ([String: [CNContact]]) -> ()) {
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
                
            case .denied, .restricted:
                self.showRestrictedAlert()

            case .notDetermined:
                self.requestAccesss { [unowned self] granted, error in
                    self.checkStatus(completionHandler: completionHandler)
                }
            case .authorized:
                self.contactsProcessingStore()
            @unknown default:
                self.showRestrictedAlert()
        }
    }
}


//      MARK: fetch user contacts
extension ContactsManager {
    
    private func contactsProcessingStore() {
        
        U.UI {
            self.startingProcessFetchingContactsSections { contacts in
                
            }
            
            self.fetchContacts { result in
                switch result {
                case .success(let contacts):
                        
//                        TODO: remove from this lateter and add to processing
                        self.resultProcessing(contacts)
                    break
                case .failure:
                    break
                }
            }
        }
    }
    
    
    private func resultProcessing(_ contacts: [CNContact]) {
        #warning("WorkInProgress")
        
        let phoneDuplicatesContacts = self.phoneDuplicates(contacts)
        debugPrint(phoneDuplicates)
        
        let sections = self.phoneDuplicatedSections(phoneDuplicatesContacts)
        debugPrint(sections)
        
        let names = self.namesDuplicated(contacts)
        
        debugPrint(names)
        
        
        let firstTestSection = self.namesDuplicatesSections(contacts)
    
        let secondTestSection = self.namesDuplicatesSections(names)
        
        debugPrint(firstTestSection)
        debugPrint(secondTestSection)
    }
    
    private func startingProcessFetchingContactsSections(completionHandler: @escaping([String: [CNContact]]) -> Void) {
        
        self.fetchSortedContacts { result in
            switch result {
                case .succes(let responce):
                    completionHandler(responce)
                case .error(let error):
                    debugPrint(error)
            }
        }
    }

    private func fetchSortedContacts(completionHandler: @escaping (AlphabeticalContactsResults) -> ()) {
    
        var orderedContacts: [String: [CNContact]] = [String: [CNContact]]()
        let contactStore: CNContactStore = CNContactStore()
        let fetchRequest: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: self.fetchingKeys)
        
        CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
        fetchRequest.mutableObjects = false
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .givenName
    
        do {
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: { contact, _ in
                var key: String = "#"
                let first = contact.givenName.count > 1 ? contact.givenName[0..<1] : "?"
                
                if first.containsAlphabets {
                    key = first.uppercased()
                }
                
                var contacts = [CNContact]()
                
                if let segregated = orderedContacts[key] {
                   contacts = segregated
                }
                
                contacts.append(contact)
                orderedContacts[key] = contacts
                
            })
        } catch {
            completionHandler(.error(error: error))
        }
        completionHandler(.succes(responce: orderedContacts))
    }
    
    
    private func fetchContacts(keys: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()], completionHandler: @escaping (_ result: Result<[CNContact], Error>) -> Void) {
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        do {
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: {
                contact, _ in
                contacts.append(contact)
            })
            completionHandler(.success(contacts))
        } catch {
            completionHandler(.failure(error))
        }
    }
}

extension ContactsManager {
    
    private func showRestrictedAlert() {
        
//  TODO: add alert manager
        
        let alert = UIAlertController(title: "permisision denied", message: "\(U.appName) does not have access to contacts. Please, allow the application to access to your contacts.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "settings", style: .destructive) { _ in
            self.openSettings()
        }
        
        let continueRestrinctAction = UIAlertAction(title: "ok", style: .cancel) { _ in
            debugPrint("do nothing")
        }
        
        alert.addAction(continueRestrinctAction)
        alert.addAction(settingsAction)
        
        if let topController = getTheMostTopController() {
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
    private func openSettings() {
        U.openSettings()
    }
}

extension ContactsManager {
    
    private func phoneDuplicates(_ contacts: [CNContact]) -> [CNContact] {
        var duplicates: [CNContact] = []
        
        let filteredContacts = contacts.filter({ $0.phoneNumbers.count != 0})
        
        for i in 0...filteredContacts.count - 1 {
            if duplicates.contains(contacts[i]) {
                continue
            }
            
            let phones: [String] = filteredContacts[i].phoneNumbers.map({$0.value.stringValue})
            let duplicatedContacts: [CNContact] = filteredContacts.filter({$0 != filteredContacts[i]}).filter({
                return $0.phoneNumbers.map({ $0.value.stringValue}).contains(phones)
            })
            
            duplicatedContacts.forEach({
                if !duplicates.contains(filteredContacts[i]){
                    duplicates.append(filteredContacts[i])
                }
                if !duplicates.contains($0){
                    duplicates.append($0)
                }
            })
        }
        return duplicates
    }
    
    private func phoneDuplicatedSections(_ contacts: [CNContact]) -> [CNContactSection] {
        
        var sections: [CNContactSection] = []
        var phoneNumbers: [String] = []
        
        for contact in contacts {
            for phone in contact.phoneNumbers {
                let stringValue = phone.value.stringValue
                if !phoneNumbers.contains(stringValue) {
                    phoneNumbers.append(stringValue)
                    sections.append(CNContactSection(name: stringValue, contacts: []))
                }
            }
        }
        
        for number in phoneNumbers {
            let contacts = contacts.filter({ $0.phoneNumbers.map({ $0.value.stringValue }).contains(number) })
            sections.filter({ $0.name == number })[0].contacts.append(contentsOf: contacts)
        }
        return sections
    }
    
    
    private func namesDuplicated(_ contacts: [CNContact]) -> [CNContact] {
        
        var duplicates: [CNContact] = []
        
        for i in 0...contacts.count - 1 {
            if duplicates.contains(contacts[i]) {
                continue
            }
            let contact = contacts[i]
            let duplicatedContacts: [CNContact] = contacts.filter({ $0 != contacts[i]}).filter({$0.givenName == contact.givenName}).filter({$0.familyName == contact.familyName})
            
            duplicatedContacts.forEach({
                if !duplicates.contains(contact) {
                    duplicates.append(contact)
                }
                
                if !duplicates.contains($0) {
                    duplicates.append($0)
                }
            })
        }
        return duplicates
    }
    
    private func namesDuplicatesSections(_ contacts: [CNContact]) -> [CNContactSection] {
        var sections: [CNContactSection] = []
        
        for contact in contacts {
            if sections.filter({$0.name == contact.givenName + " " + contact.familyName}).count == 0 {
                sections.append(CNContactSection(name: contact.givenName + " " + contact.familyName, contacts: []))
            }
        }
        
        for contact in contacts {
            sections.filter({$0.name == contact.givenName + " " + contact.familyName})[0].contacts.append(contact)
        }
        return sections
    }
}


