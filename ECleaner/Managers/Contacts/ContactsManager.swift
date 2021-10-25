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

class ContactsGroup {
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
        
        let sections = self.phoneDuplicatedGroup(phoneDuplicatesContacts)
        debugPrint(sections)
        
        let names = self.namesDuplicated(contacts)
        
        debugPrint(names)
        
        
        let firstTestSection = self.namesDuplicatesGroup(contacts)
    
        let secondTestSection = self.namesDuplicatesGroup(names)
        
        debugPrint(firstTestSection)
        debugPrint(secondTestSection)
    }
    
    
    /// `result` for all contacts
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
    
    /// `sort contacts` by alphabetical results (helper private function)
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
    
    /// `fetch all contacts` for work with all contacts results
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

//  MARK: - in app permisson alert section -
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

//      MARK: - contacts managers - work with contacts

extension ContactsManager {
    
        /// `phoneDuplicates` - find duplicates by existing phone numbers
        /// `phoneDuplicatedGroup` - get section phone duplicated contacts
        /// `namesDuplicated` - find duplicated contacts by name
        /// `namesDuplicatesGroup` - get sections of duplicated contacts by names
        /// `emailDuplicates` - find duplicated contacts by emails
        /// `mailListDuplicatedGroup` -  get sections of duplicated contacts by emails
    
    /// `phone duplicated contacts`
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
    
    /// `phone duplicated group`
    private func phoneDuplicatedGroup(_ contacts: [CNContact]) -> [ContactsGroup] {
        
        var group: [ContactsGroup] = []
        var phoneNumbers: [String] = []
        
        for contact in contacts {
            for phone in contact.phoneNumbers {
                let stringValue = phone.value.stringValue
                if !phoneNumbers.contains(stringValue) {
                    phoneNumbers.append(stringValue)
                    group.append(ContactsGroup(name: stringValue, contacts: []))
                }
            }
        }
        
        for number in phoneNumbers {
            let contacts = contacts.filter({ $0.phoneNumbers.map({ $0.value.stringValue }).contains(number) })
            group.filter({ $0.name == number })[0].contacts.append(contentsOf: contacts)
        }
        return group
    }
    
    
    /// `names duplicated contacts`
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
    
    /// `names duplicated group`
    private func namesDuplicatesGroup(_ contacts: [CNContact]) -> [ContactsGroup] {
        var group: [ContactsGroup] = []
        
        for contact in contacts {
            if group.filter({$0.name == contact.givenName + " " + contact.familyName}).count == 0 {
                group.append(ContactsGroup(name: contact.givenName + " " + contact.familyName, contacts: []))
            }
        }
        
        for contact in contacts {
            group.filter({$0.name == contact.givenName + " " + contact.familyName})[0].contacts.append(contact)
        }
        return group
    }
    
    
    /// `duplicates by email`
    private func emailDuplicates(_ contacts: [CNContact]) -> [CNContact] {
        
        var duplicates: [CNContact] = []
        
        for i in 0...contacts.count - 1 {
            
            let contact = contacts[i]
            
            if duplicates.contains(contact) {
                continue
            }
            
            let emailList: [String] = contact.emailAddresses.map({ $0.value as String})
            let duplicatedContacts: [CNContact] = contacts.filter({ $0 != contact}).filter({
                return $0.emailAddresses.map({ $0.value as String}).contains(emailList)
            })
            
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
    
    /// `email duplicates group`
    private func mailListDuplicatedGroup(_ contacts: [CNContact]) -> [ContactsGroup] {
            
        var group: [ContactsGroup] = []
        var emailList: [String] = []
        
        for contact in contacts {
            for email in contact.emailAddresses {
                if emailList.contains(email.value as String) {
                    emailList.append(email.value as String)
                    group.append(ContactsGroup(name: email.value as String, contacts: []))
                }
            }
        }
        
        for email in emailList {
            let contacts = contacts.filter({$0.emailAddresses.map({ $0.value as String}).contains(email)})
            group.filter({$0.name == email})[0].contacts.append(contentsOf: contacts)
        }
        
        return group
    }
}


