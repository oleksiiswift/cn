//
//  ContactsManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 25.10.2021.
//

import ContactsUI
import UIKit
import PhoneNumberKit

enum AlphabeticalContactsResults {
    case succes(responce: [String: [CNContact]])
    case error(error: Error)
}


class ContactsCountryIdentifier {
    var region: String
    var countryCode: String
    
    init(region: String, countryCode: String) {
        self.region = region
        self.countryCode = countryCode
    }
}

class ContactsGroup {
    let countryIdentifier: ContactsCountryIdentifier
    let name: String
    var contacts: [CNContact]
    var groupType: ContactasCleaningType
    
    init(name: String, contacts: [CNContact], groupType: ContactasCleaningType, countryIdentifier: ContactsCountryIdentifier) {
        self.countryIdentifier = countryIdentifier
        self.name = name
        self.contacts = contacts
        self.groupType = groupType
    }
}

class ContactsManager {
    
    static let shared: ContactsManager = {
        let instance = ContactsManager()
        return instance
    }()
    
    private var phoneNumberKit = PhoneNumberKit()
    private var fileManager = FileManager.default
    private var notificationManager = SingleSearchNitificationManager.instance
    
    private var deleteContactsTaskContinue: Bool = true
    private var mergeContactsTaskContinue: Bool = true
    private var searchContactsTaskContinue: Bool = true

    private let contactsDuplicatesOperationQueue = OperationPhotoProcessingQueuer(name: "Contacts Duplicates Queuer", maxConcurrentOperationCount: 10, qualityOfService: .utility)
    public let operationConcurrentQueue = OperationPhotoProcessingQueuer(name: "firstCheckRunContacts", maxConcurrentOperationCount: 4, qualityOfService: .utility)
    
    private let fetchingKeys: [CNKeyDescriptor] = [
        CNContactVCardSerialization.descriptorForRequiredKeys(),
        CNContactThumbnailImageDataKey as CNKeyDescriptor,
        CNContactImageDataAvailableKey as CNKeyDescriptor,
        CNContactImageDataKey as CNKeyDescriptor
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

//  MARK: - public external methods -
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
    
    private func isStoreOpen() -> Bool {
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
                
            case .denied, .restricted:
                return false
            case .notDetermined:
                self.requestAccesss { granted, error in }
                return false
            case .authorized:
                return true
            @unknown default:
                self.showRestrictedAlert()
        }
        return false
    }
    
        /// fetch all contacts
    public func getAllContacts(_ completionHandler: @escaping ([CNContact]) -> Void) {
        
        guard isStoreOpen() else { return }
        
        U.BG {
            self.fetchContacts(keys: self.fetchingKeys) { result in
                switch result {
                    case .success(let contacts):
                        completionHandler(contacts)
                        break
                    case .failure:
                        completionHandler([])
                        break
                }
            }
        }
    }
    
    public func getDuplicatedContacts(of type: ContactasCleaningType, completionHandler: @escaping ([ContactsGroup]) -> Void) {
        
        self.getAllContacts { contacts in
            
            guard !contacts.isEmpty else { completionHandler([]); return }
            
            U.BG {
                switch type {
                    case .duplicatedPhoneNumnber:
                        let burn = ConcurrentPhotoProcessOperation { _ in
                            self.phoneDuplicatesGroup(contacts) { contactsGroup in
                                completionHandler(contactsGroup)
                            }
                        }
                        self.contactsDuplicatesOperationQueue.addOperation(burn)
                    case .duplicatedContactName:
                        let burn = ConcurrentPhotoProcessOperation { _ in
                            self.namesDuplicated(contacts) { duplicatedContacts in
                                self.namesDuplicatesGroup(duplicatedContacts) { contactsGroup in
                                    completionHandler(contactsGroup)
                                }
                            }
                        }
                        self.contactsDuplicatesOperationQueue.addOperation(burn)
                    case .duplicatedEmail:
                        let burn = ConcurrentPhotoProcessOperation { _ in
                            self.emailDuplicatesGroup(contacts) { contactsGroup in
                                completionHandler(contactsGroup)
                            }
                        }
                        self.contactsDuplicatesOperationQueue.addOperation(burn)
                    default:
                        completionHandler([])
                }
            }
        }
    }
    
    public func getEmptyContacts(_ completionHandler: @escaping ([ContactsGroup]) -> Void) {
        self.getAllContacts { contacts in
            self.groupingMissingIncompleteContacts(contacts) { groupingIncompleteContacts in
                completionHandler(groupingIncompleteContacts)
            }
        }
    }
    
    public func deleteAllContacts() {
        self.getAllContacts { contacts in
            self.deleteContacts(contacts) { suxxess, deletedCount in
                debugPrint("deleting is \(suxxess)")
                debugPrint("deleted \(deletedCount) contacts")
            }
        }
    }
}


//      MARK: fetch user contacts
extension ContactsManager {
    
    private func contactsProcessingStore() {
        
        self.getAllContacts { contacts in
            U.UI {
                self.resultProcessing(contacts)
            }
        }
    }
    
    private func resultProcessing(_ contacts: [CNContact]) {
        
        let concurrentOperationContacts = ConcurrentPhotoProcessOperation { _ in
            UpdateContentDataBaseMediator.instance.updateContacts(contacts.count)
            UpdateContentDataBaseMediator.instance.getAllContacts(contacts)
        }
        
        let concurrentOperationEmptyContacts = ConcurrentPhotoProcessOperation { _ in
            self.getEmptyContacts(contacts)
        }
        
        let concurrentOperationNamesContacts = ConcurrentPhotoProcessOperation { _ in
            self.getDuplicatedNames(contacts)
        }
        
        let concurrentOperationPhonesContacts = ConcurrentPhotoProcessOperation { _ in
            self.getDuplicatedPhones(contacts)
        }
        
        let concurrentOperationEmailsContacts = ConcurrentPhotoProcessOperation { _ in
            self.getDuplicatedEmails(contacts)
        }
    
        operationConcurrentQueue.addOperation(concurrentOperationContacts)
        operationConcurrentQueue.addOperation(concurrentOperationEmptyContacts)
        operationConcurrentQueue.addOperation(concurrentOperationNamesContacts)
        operationConcurrentQueue.addOperation(concurrentOperationPhonesContacts)
        operationConcurrentQueue.addOperation(concurrentOperationEmailsContacts)
    }
    
    public func getSortAndGroupContacts(_ contacts: [CNContact]) -> [String : [CNContact]] {
        return Dictionary(grouping: contacts, by: {String(($0.givenName + $0.familyName).uppercased().prefix(1))})
    }
    
        /// `all containers`
    private func getContactsContainers() -> [CNContainer] {
        
        let contactStore = CNContactStore()
        var contactsContainers: [CNContainer] = []
        
        do {
            contactsContainers = try contactStore.containers(matching: nil)
        } catch {
            self.checkStatus { _ in }
        }
        return contactsContainers
    }
    
        /// `result` for all contacts
    private func startingProcessFetchingContactsSections(completionHandler: @escaping ([String: [CNContact]]) -> Void) {
        
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
            debugPrint(error.localizedDescription)
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
        /// `groupingMissingIncompleteContacts` - checj for empty fields

        /// `phone duplicated contacts` `phone duplicated group`
    private func phoneDuplicatesGroup(_ contacts: [CNContact], enableSingleNotification: Bool = true, enableDeepCleanNotification: Bool = false, completionHandler: @escaping ([ContactsGroup]) -> Void) {
        
        let contactsStore = CNContactStore()
        let phoneNumbers = Array(Set(contacts.map({$0.phoneNumbers.map({$0.value})}).reduce([], +)))
        
        var duplicatedContacts: [ContactsGroup] = []
        
        for i in 0...phoneNumbers.count - 1 {
            
            guard searchContactsTaskContinue else {
                completionHandler([])
                return
            }
            
            let phoneNunber = phoneNumbers[i]
            let fetchPredicate = CNContact.predicateForContacts(matching: phoneNunber)
            do {
                let containerResults = try contactsStore.unifiedContacts(matching: fetchPredicate, keysToFetch: self.fetchingKeys)
                
                if enableSingleNotification {
                    self.notificationManager.sendSingleSearchProgressNotification(notificationtype: .duplicatesNumbers, totalProgressItems: phoneNumbers.count, currentProgressItem: i)
                }
                
                if enableSingleNotification {
//                    TODO: deep clean notification
                }
                
                if containerResults.count > 1 {
//                    let identifier = self.checkRegionIdentifier(from: [phoneNunber.stringValue])
                    let identifier = ContactsCountryIdentifier(region: "", countryCode: "")
                    duplicatedContacts.append(ContactsGroup(name: phoneNunber.stringValue, contacts: containerResults, groupType: .duplicatedPhoneNumnber, countryIdentifier: identifier))
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        completionHandler(duplicatedContacts)
    }
    
        /// `names duplicated contacts`
    private func namesDuplicated(_ contacts: [CNContact], completionHandler: @escaping ([String : [CNContact]]) -> Void) {
        
        self.notificationManager.sendSingleSearchProgressNotification(notificationtype: .duplicatesNames, totalProgressItems: Int(0.01), currentProgressItem: contacts.count)
        
        var contactsDictionary = Dictionary(grouping: contacts, by: {String($0.familyName.removeWhitespace() + $0.givenName.removeWhitespace())})
        contactsDictionary.removeValue(forKey: "")
        let filterDictionary = contactsDictionary.filter({$0.value.count > 1})
        completionHandler(filterDictionary)
    }
    
    private func namesDuplicatesGroup(_ contacts: [String : [CNContact]], enableSingleNotification: Bool = true, enableDeepCleanNotification: Bool = false, completionHandler: @escaping ([ContactsGroup]) -> Void) {
        
        var group: [ContactsGroup] = []
        var currentProcessingIndex: Int = 0
        
        for (contactName, similarContacts) in contacts {
            
            guard searchContactsTaskContinue else {
                completionHandler([])
                return
            }
            
            currentProcessingIndex += 1
            
            if enableSingleNotification {
                self.notificationManager.sendSingleSearchProgressNotification(notificationtype: .duplicatesNames, totalProgressItems: contacts.count, currentProgressItem: currentProcessingIndex)
            }
            
            if enableDeepCleanNotification {
//                TODO: add deep clean notification
            }
            
            
            sleep(UInt32(0.1))
            let phoneNumbers = similarContacts.map({$0.phoneNumbers}).reduce([], +)
            let stringNumbers = phoneNumbers.map({$0.value.stringValue})
            let itentifier = self.checkRegionIdentifier(from: stringNumbers)

            group.append(ContactsGroup(name: contactName, contacts: similarContacts, groupType: .duplicatedContactName, countryIdentifier: itentifier))
        }
        group.forEach({ $0.contacts = self.esctimateBestContactIn($0.contacts )})
        completionHandler(group)
    }
    
        /// `duplicates by email` /// `email duplicates group`
    private func emailDuplicatesGroup(_ contacts: [CNContact], enableSingleNotification: Bool = true, enableDeepCleanNotification: Bool = false, completionHandler: @escaping ([ContactsGroup]) -> Void) {
        
        let contactsStore = CNContactStore()
        let emailsList = Array(Set(contacts.map({$0.emailAddresses.map({$0.value as String})}).reduce([], +)))
        var duplicatedContacts: [ContactsGroup] = []
        
        for i in 0...emailsList.count - 1 {
            
            guard searchContactsTaskContinue else {
                completionHandler([])
                return
            }
            
            let email = emailsList[i]
            do {
                let fetchPredicate = CNContact.predicateForContacts(matchingEmailAddress: email)
                
                if enableSingleNotification {
                    self.notificationManager.sendSingleSearchProgressNotification(notificationtype: .duplicatesEmails, totalProgressItems: emailsList.count, currentProgressItem: i)
                }
                if enableDeepCleanNotification {
//                    TODO: add depp clean notification
                }
                
                let containerResult = try contactsStore.unifiedContacts(matching: fetchPredicate, keysToFetch: self.fetchingKeys)
                if containerResult.count > 1 {
                    let identifier = ContactsCountryIdentifier(region: "", countryCode: "")
                    duplicatedContacts.append(ContactsGroup(name: email, contacts: containerResult, groupType: .duplicatedEmail, countryIdentifier: identifier))
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        completionHandler(duplicatedContacts)
    }

        /// `check empty filds` - check if some fileds is emty
    private func groupingMissingIncompleteContacts(_ contacts: [CNContact], completionHandler: @escaping ([ContactsGroup]) -> Void) {
        
        var contactsGroup: [ContactsGroup] = []
        let emptyIdentifier = ContactsCountryIdentifier(region: "", countryCode: "")
        
            /// `only name` group
        let onlyNameContacts = contacts.filter({ $0.phoneNumbers.count == 0 && $0.emailAddresses.count == 0})
        let onlyNameGroupName = ContactasCleaningType.onlyName.rawValue
        let onlyNameGroup = ContactsGroup(name: onlyNameGroupName, contacts: onlyNameContacts, groupType: .onlyName, countryIdentifier: emptyIdentifier)
        
        onlyNameContacts.count != 0 ? contactsGroup.append(onlyNameGroup) : ()
        
            /// `incomplete name` group
        let emptyNameContacts = contacts.filter({$0.givenName.isEmpty || $0.givenName.isWhitespace}).filter({$0.familyName.isEmpty || $0.familyName.isWhitespace}).filter({$0.middleName.isEmpty || $0.middleName.isWhitespace})
        let emptyNameGroupName = ContactasCleaningType.emptyName.rawValue
        let incompleteNameContacts = emptyNameContacts.filter({$0.phoneNumbers.count != 0 && $0.emailAddresses.count != 0} )
        
        let emptyNameGroup = ContactsGroup(name: emptyNameGroupName, contacts: incompleteNameContacts, groupType: .emptyName, countryIdentifier: emptyIdentifier)
        
        emptyNameContacts.count != 0 ? contactsGroup.append(emptyNameGroup) : ()
        
            /// `only mail` group
        let onlyEmailsContacts = emptyNameContacts.filter({$0.phoneNumbers.count == 0 && $0.emailAddresses.count != 0})
        let onlyEmailGroupName = ContactasCleaningType.onlyEmail.rawValue
        let onlyEmailGroup = ContactsGroup(name: onlyEmailGroupName, contacts: onlyEmailsContacts, groupType: .onlyEmail, countryIdentifier: emptyIdentifier)
        
        onlyEmailsContacts.count != 0 ? contactsGroup.append(onlyEmailGroup) : ()
        
            /// `only phone number` group
        let onlyPhoneNumbersContacts = emptyNameContacts.filter({$0.phoneNumbers.count != 0 && $0.emailAddresses.count == 0})
        let onlyPhoneNumbersGroupName = ContactasCleaningType.onlyPhone.rawValue
        let onlyPhoneNumbersGroup = ContactsGroup(name: onlyPhoneNumbersGroupName, contacts: onlyPhoneNumbersContacts, groupType: .onlyPhone, countryIdentifier: emptyIdentifier)
        
        onlyPhoneNumbersContacts.count != 0 ? contactsGroup.append(onlyPhoneNumbersGroup) : ()
        
        let wholeEmptyContacts = emptyNameContacts.filter({$0.phoneNumbers.count == 0 && $0.emailAddresses.count == 0})
        let wholeEmptyContactsName = ContactasCleaningType.wholeEmpty.rawValue
        let wholeEmptyGroup = ContactsGroup(name: wholeEmptyContactsName, contacts: wholeEmptyContacts, groupType: .wholeEmpty, countryIdentifier: emptyIdentifier)
        
        wholeEmptyContacts.count != 0 ? contactsGroup.append(wholeEmptyGroup) : ()
        
        completionHandler(contactsGroup)
    }
    
    public func getDuplicatedAllContacts(_ contacts: [CNContact], completion: @escaping ([ContactasCleaningType : [ContactsGroup]]) -> Void) {
        
        var totalProcessingOperation = 0
        var allGroupsDuplicated: [ContactasCleaningType : [ContactsGroup]] = [:]
        
        let phoneDuplicatesFindOperation = ConcurrentPhotoProcessOperation { _ in
            
            self.phoneDuplicatesGroup(contacts) { contactsGroup in
                totalProcessingOperation += 1
                allGroupsDuplicated[.duplicatedPhoneNumnber] = contactsGroup
                if totalProcessingOperation == 3 {
                    completion(allGroupsDuplicated)
                }
            }
        }
        
        let nameDuplicatedFindOperation = ConcurrentPhotoProcessOperation { _ in
            
            self.namesDuplicated(contacts) { duplicatedContacts in
                
                self.namesDuplicatesGroup(duplicatedContacts) { contactsGroup in
                    totalProcessingOperation += 1
                    allGroupsDuplicated[.duplicatedContactName] = contactsGroup
                    if totalProcessingOperation == 3 {
                        completion(allGroupsDuplicated)
                    }
                }
            }
        }
        
        let emailDuplicatedFindOperation = ConcurrentPhotoProcessOperation { _ in
            
            self.emailDuplicatesGroup(contacts) { contactsGroup in
                
                totalProcessingOperation += 1
                allGroupsDuplicated[.duplicatedEmail] = contactsGroup
                if totalProcessingOperation == 3 {
                    completion(allGroupsDuplicated)
                }
            }
        }
        
        contactsDuplicatesOperationQueue.addOperation(nameDuplicatedFindOperation)
        contactsDuplicatesOperationQueue.addOperation(phoneDuplicatesFindOperation)
        contactsDuplicatesOperationQueue.addOperation(emailDuplicatedFindOperation)
    }
}

extension ContactsManager  {

    private func smartNamesDuplicated(_ contacts: [CNContact], completionHandler: @escaping ([CNContact]) -> Void) {
        
        var duplicates: [CNContact] = []
        
        for i in 0...contacts.count - 1 {
            debugPrint("name duplicate index: \(i)")
            if duplicates.contains(contacts[i]) {
                continue
            }
            let contact = contacts[i]
            let duplicatedContacts: [CNContact] = contacts.filter({ $0 != contacts[i]}).filter({$0.givenName.removeWhitespace() + $0.familyName.removeWhitespace() == contact.givenName.removeWhitespace() + contact.familyName.removeWhitespace()}) //.filter({$0.familyName == contact.familyName})
            
            duplicatedContacts.forEach({
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
    private func smartNamesDuplicatesGroup(_ contacts: [CNContact], completionHandler: @escaping ([ContactsGroup]) -> Void) {
        var group: [ContactsGroup] = []
        
        for contact in contacts {
            debugPrint("names group index: \(String(describing: contacts.firstIndex(of: contact)))")
            if group.filter({$0.name.removeWhitespace().lowercased() == contact.givenName.removeWhitespace().lowercased() + contact.familyName.removeWhitespace().lowercased()}).count == 0 {
                let countryIdentifier = self.getRegionIdentifier(from: contact)
                group.append(ContactsGroup(name: contact.givenName.removeWhitespace().lowercased() + contact.familyName.removeWhitespace().lowercased(), contacts: [], groupType: .duplicatedContactName, countryIdentifier: countryIdentifier))
            }
        }
        
        for contact in contacts {
            debugPrint("extra filer index: \(String(describing: contacts.firstIndex(of: contact)))")
            group.filter({$0.name.removeWhitespace().lowercased() == contact.givenName.removeWhitespace().lowercased() + contact.familyName.removeWhitespace().lowercased()})[0].contacts.append(contact)
        }
    
        group.forEach({ $0.contacts = self.esctimateBestContactIn($0.contacts )})
    
        completionHandler(group)
    }
    
    public func mergeContacts(in group: [ContactsGroup], merged indexes: [Int], completionHandler: @escaping (Bool, [Int]) -> Void) {
        
        var errorsCount: Int = 0
        var deleteSelectionIndexCount: Int = 0
        var indexesForUpdate: [Int] = []
        U.GLB(qos: .background) {
            
            for index in indexes {
                
                guard self.mergeContactsTaskContinue else {
                    completionHandler(true, indexesForUpdate)
                    return
                }
                
                self.smartMergeContacts(in: group[index]) { deleteContacts in
                    self.deleteContacts(deleteContacts) { suxxess, deleteCount in
                        if suxxess {
                            deleteSelectionIndexCount += 1
                            indexesForUpdate.append(index)
                        } else {
                            let errors = deleteContacts.count - deleteCount
                            errorsCount += errors
                        }
                        
                        let calculetedProgress: CGFloat = CGFloat(100 * deleteSelectionIndexCount / indexes.count) / 100
                        let totalProcessing: String = "\(deleteSelectionIndexCount) / \(indexes.count)"
                        
                        let userInfo: [String : Any] = [C.key.notificationDictionary.progressAlert.progrssAlertValue: calculetedProgress,
                                                        C.key.notificationDictionary.progressAlert.progressAlertFilesCount: totalProcessing]
                        
                        U.notificationCenter.post(name: .progressMergeContactsAlertDidChangeProgress, object: nil, userInfo: userInfo)
                        sleep(UInt32(0.1))
                        
                        if indexes.count == deleteSelectionIndexCount {
                            completionHandler(true, indexesForUpdate)
                        }
                    }
                }
            }
        }
    }

    public func smartMergeContacts(in group: ContactsGroup, deletingContactsCompletion: @escaping ([CNContact]) -> Void) {
        
        var contactsDuplicates: [CNContact] = group.contacts
        
        var futureBestContact = CNMutableContact()
        var bestGroupValue: Int = 0
        
        /// `main user names data`
        var givenName: [String] = []
        var familyName: [String] = []
        var middleName: [String] = []
        var organizationName: [String] = []
        /// `optional user data`
        var jobTitle: [String] = []
        var departmentName: [String] = []
        
        /// `ìmage data`
        var thumbnailsImageData: [Data] = []
        var imagesData: [Data] = []
        
        /// `user phone numbers and social`
        var phoneNumbers: [CNLabeledValue<CNPhoneNumber>] = []
        var emailAddresses: [CNLabeledValue<NSString>] = []
        var postalAddresses: [CNLabeledValue<CNPostalAddress>] = []
        var urlAddresses: [CNLabeledValue<NSString>] = []
        var contactRelations: [CNLabeledValue<CNContactRelation>] = []
        var socialProfiles: [CNLabeledValue<CNSocialProfile>] = []
        var instantMessageAddresses: [CNLabeledValue<CNInstantMessageAddress>] = []
        
        /// `grouping contacts`
        for contact in contactsDuplicates {
            
            if contact.fieldStatus() > bestGroupValue {
                bestGroupValue = contact.fieldStatus()
                futureBestContact = contact.mutableCopy() as! CNMutableContact
            }
            
            givenName.append(contact.givenName)
            familyName.append(contact.familyName)
            middleName.append(contact.middleName)
            
            jobTitle.append(contact.jobTitle)
            departmentName.append(contact.departmentName)
            
            organizationName.append(contact.organizationName)
            contact.phoneNumbers.forEach { phoneNumbers.append($0) }
            contact.emailAddresses.forEach { emailAddresses.append($0) }
            contact.postalAddresses.forEach { postalAddresses.append($0) }
            contact.urlAddresses.forEach { urlAddresses.append($0) }
            contact.contactRelations.forEach { contactRelations.append($0)}
            contact.socialProfiles.forEach { socialProfiles.append($0)}
            contact.instantMessageAddresses.forEach {instantMessageAddresses.append($0) }
            
            if contact.imageDataAvailable {
                if let data = contact.thumbnailImageData {
                    thumbnailsImageData.append(data)
                }
                
                if let imageData = contact.imageData {
                    imagesData.append(imageData)
                }
            }
        }
        
        if let mutableContact = futureBestContact.mutableCopy() as? CNMutableContact {
            
            mutableContact.givenName = givenName.bestElement ?? ""
            mutableContact.familyName = familyName.bestElement ?? ""
            mutableContact.middleName = middleName.bestElement ?? ""
            mutableContact.organizationName = organizationName.bestElement ?? ""
            
            mutableContact.jobTitle = jobTitle.bestElement ?? ""
            mutableContact.departmentName = departmentName.bestElement ?? ""
            
            phoneNumbers.forEach { mutableContact.phoneNumbers.append($0) }
            emailAddresses.forEach { mutableContact.emailAddresses.append($0) }
            postalAddresses.forEach { mutableContact.postalAddresses.append($0) }
            urlAddresses.forEach { mutableContact.urlAddresses.append($0) }
            contactRelations.forEach { mutableContact.contactRelations.append($0) }
            socialProfiles.forEach { mutableContact.socialProfiles.append($0) }
            instantMessageAddresses.forEach { mutableContact.instantMessageAddresses.append($0) }
            
            if !imagesData.isEmpty {
                if let imageData = self.checkImages(from: imagesData) {
                    mutableContact.imageData = imageData
                }
            }
            
            self.update(contact: mutableContact) { result in
                contactsDuplicates = contactsDuplicates.filter({ $0.identifier != mutableContact.identifier })
                deletingContactsCompletion(contactsDuplicates)
            }
        }
    }
    
    public func esctimateBestContactIn(_ group: [CNContact]) -> [CNContact] {
        
        var refactorContactGroup = group
        var bestContact: CNContact?
        var bestValue: Int = 0
        var longestNumber: Int = 0
        for contact in group {
            if contact.fieldStatus() > bestValue {
                bestValue = contact.fieldStatus()
                bestContact = contact
            } else if contact.fieldStatus() == bestValue {
                let sum = contact.phoneNumbers.map({$0.value.stringValue.count}).sum()
                if sum > longestNumber {
                    longestNumber = sum
                    bestContact = contact
                }
            }
        }
        
        if let contact = bestContact {
            debugPrint("refacor group")
            refactorContactGroup.bringToFront(item: contact)
            return refactorContactGroup
        }
        return group
    }
    
    /// simlple rebase contacts for groups and selectd one more fill contact
    public func rebaseContacts(_ contactsGroup: [ContactsGroup], completionHelpers: @escaping () -> Void) {
            
        let groupNumbers = contactsGroup.count
        var numbersOfIteration = 0
        for group in contactsGroup {
            self.simpleCombine(group.contacts) { success in
                numbersOfIteration += 1
                debugPrint("combine -> \(success)")
                if numbersOfIteration == groupNumbers {
                    completionHelpers()
                }
            }
        }
    }
    
    /// merge contactrs only select where best fields
    public func simpleCombine(_ contacts: [CNContact], _ handler: @escaping ((_ success: Bool) -> Void)){
        var bestContact: CNContact?
        var bestValue: Int = 0
        for contact in contacts {
            if contact.fieldStatus() > bestValue {
                bestValue = contact.fieldStatus()
                bestContact = contact
            }
        }
        
        let deletedContacts = contacts.filter({ $0 != bestContact! })
        self.deleteContacts(deletedContacts) { _, _ in }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            handler(true)
        })
    }
    
    public func checkForBestContact(_ contacts: [CNContact]) -> [CNContact] {
        
        var refablishContacts: [CNContact] = contacts
        var bestValue: Int = 0
        
        for contact in refablishContacts {
            debugPrint("refactor contact group")
            if contact.fieldStatus() > bestValue {
                bestValue = contact.fieldStatus()
                refablishContacts.bringToFront(item: contact)
            }
        }
        return refablishContacts
    }
    
    private func checkImages(from imageDatas: [Data]) -> Data? {
        
        var bestImageData: Data?
        
        if let data = imageDatas.first {
            bestImageData = data
        }
        
        for representData in imageDatas {
            if bestImageData != representData {
                if let rhsData = bestImageData {
                    let lhsData = representData
                    if lhsData.count > rhsData.count {
                        bestImageData = lhsData
                    }
                }
            }
        }
        
        return bestImageData
    }
}

extension ContactsManager {
    
    public func deleteContacts(_ contacts: [CNContact],_ completionHandler: @escaping ((Bool, Int) -> Void)) {
        
        U.BG {
            var deletedContactsCount = 0
            
            for contact in contacts {
                
                guard self.deleteContactsTaskContinue else {
                    completionHandler(false, deletedContactsCount)
                    return
                }
                
                self.deleteContact(contact) { success in
                    if success {
                        deletedContactsCount += 1
                        
                        let calculateprogress: CGFloat = CGFloat(100 * deletedContactsCount / contacts.count) / 100
                        
                        let userInfo: [String: Any] = [C.key.notificationDictionary.progressAlert.progrssAlertValue: calculateprogress,
                                                       C.key.notificationDictionary.progressAlert.progressAlertFilesCount: "\(deletedContactsCount) / \(contacts.count)"]
                        
                        U.notificationCenter.post(name: .progressDeleteContactsAlertDidChangeProgress, object: nil, userInfo: userInfo)
                        debugPrint(deletedContactsCount)
                    }
                }
            }
            
            if contacts.count == deletedContactsCount {
                completionHandler(true, deletedContactsCount)
            } else {
                completionHandler(false,deletedContactsCount)
            }
        }
    }

    public func deleteContact(_ contact: CNContact, _ handler: @escaping ((_ success: Bool) -> Void)) {
        
        delete(contact: contact.mutableCopy() as! CNMutableContact, completionHandler: { (result) in
            switch result{
                case .success(let bool):
                    handler(bool)
                    break
                case .failure:
                    handler(false)
                    break
            }
        })
    }

    private func delete(contact mutContact: CNMutableContact, completionHandler: @escaping (_ result: Result<Bool, Error>) -> Void) {
        let store = CNContactStore()
        let request = CNSaveRequest()
        
        request.delete(mutContact)
        
        do {
            try store.execute(request)
            completionHandler(.success(true))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    private func update(contact mutContact: CNMutableContact, completionHandler: @escaping (_ result: Result<Bool, Error>) -> Void) {
        let store = CNContactStore()
        let request = CNSaveRequest()
        
        request.update(mutContact)
        do {
            try store.execute(request)
            completionHandler(.success(true))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    private func create(contact mutContact: CNMutableContact, completionHandler: @escaping (_ result: Result<Bool, Error>) -> Void) {
        let store = CNContactStore()
        let request = CNSaveRequest()
        request.add(mutContact, toContainerWithIdentifier: nil)
        do {
            try store.execute(request)
            completionHandler(.success(true))
        } catch {
            completionHandler(.failure(error))
        }
    }
}

extension ContactsManager {
    
    private func getAppropriateName(for container: CNContainer?) -> String? {
        
        switch container?.name {
            case ContactsContainerType.card.rawValue, ContactsContainerType.none.rawValue:
                return C.contacts.contactsContainer.iCloud
            case ContactsContainerType.adressBook.rawValue:
                return C.contacts.contactsContainer.google
            case ContactsContainerType.contacts.rawValue:
                return C.contacts.contactsContainer.yahoo
            default:
                return C.contacts.contactsContainer.facebook
        }
    }
          
    public func getIcloudContacts() -> [CNContact] {
        
        let contactStore = CNContactStore()
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        for container in allContainers {
            let containerName = getAppropriateName(for: container)
            
            if containerName == C.contacts.contactsContainer.iCloud {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                do {
                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: self.fetchingKeys)
                    return containerResults
                } catch {
                    print("Error fetching results for container")
                }
            }
        }
        return []
    }
}


//      MARK: - phone number parsing -
extension ContactsManager {
    
    public func getRegionIdentifier(from contact: CNContact) -> ContactsCountryIdentifier {
        
        let contactPhoneNumbers: [String] = contact.phoneNumbers.map({$0.value.stringValue})
        
        if !contactPhoneNumbers.isEmpty {
            let phoneNumbers = phoneNumberKit.parse(contactPhoneNumbers)
            let phoneCountryCode = self.getCommonIdentificators(from: phoneNumbers.map({String($0.countryCode)}))
            let regionID = self.getCommonIdentificators(from: phoneNumbers.map({$0.regionID}).compactMap({$0}))
            return ContactsCountryIdentifier(region: regionID, countryCode: phoneCountryCode)
        } else {
            return ContactsCountryIdentifier(region: "", countryCode: "")
        }
    }
    
    
    public func checkRegionIdentifier(from contactPhoneNumbers: [String]) -> ContactsCountryIdentifier {
    
        if !contactPhoneNumbers.isEmpty {
            let phoneNumbers = phoneNumberKit.parse(contactPhoneNumbers)
            let phoneCountryCode = self.getCommonIdentificators(from: phoneNumbers.map({String($0.countryCode)}))
            let regionID = self.getCommonIdentificators(from: phoneNumbers.map({$0.regionID}).compactMap({$0}))
            return ContactsCountryIdentifier(region: regionID, countryCode: phoneCountryCode)
        } else {
            return ContactsCountryIdentifier(region: "", countryCode: "")
        }
    }
    
    private func getCommonIdentificators(from stingIndentifiers: [String]) -> String {
        let identificatorDictionary = Dictionary(grouping: stingIndentifiers, by: {$0})
        let sortedIdentificators = identificatorDictionary.mapValues({$0.count})
        return sortedIdentificators.sorted(by: {$0.value > $1.value}).first?.key ?? ""
    }
}


//      MARK: - exportContacts contacts -
extension ContactsManager {
    
    /// export `[CNContacts] TO VCF`
    public func vcfContactsExportAll(_ completion: @escaping (_ fileURL: URL?) -> Void) {
        
        getAllContacts { contacts in
            self.exporContactsAsVCF(contacts) { fileURL in
                completion(fileURL)
            }
        }
    }
    
    public func vcfContactsExport(contacts: [CNContact],_ completion: @escaping (_ fileURL: URL?) -> Void) {
        self.exporContactsAsVCF(contacts) { fileURL in
            completion(fileURL)
        }
    }
    
    /// export `[CNContacts] TO CSV`
    public func csvContactsExportAll(_ completion: @escaping (_ fileURL: URL?) -> Void) {
        
        getAllContacts { contacts in
            self.csvContactsExportAll { fileURL in
                completion(fileURL)
            }
        }
    }
    
    public func csvContactsExport(contacts: [CNContact],_ completion: @escaping (_ fileURL: URL?) -> Void) {
        self.exportContactsAsCSV(contacts) { fileURL in
            completion(fileURL)
        }
    }
    
    /// `Convert [CNContacts] TO VCF`
    private func exporContactsAsVCF(_ contacts: [CNContact], completionHandler: @escaping (_ fileURL: URL?) -> Void) {
        
        do {
            var data = Data()
            try data = CNContactVCardSerialization.dataWithImage(contacts: contacts)
            do {
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent("someName").appendingPathExtension("vcf")
                if self.fileManager.fileExists(atPath: fileURL.absoluteString) {
                    try self.fileManager.removeItem(at: fileURL)
                }
                try data.write(to: fileURL)
                completionHandler(fileURL)
            } catch {
                completionHandler(nil)
                debugPrint(error.localizedDescription)
            }
        } catch {
            completionHandler(nil)
            debugPrint(error.localizedDescription)
        }
    }
    
    /// `Convert CSV TO [CNContact]`
    private func exportContactsAsCSV(_ contacts: [CNContact], completionHandler: @escaping (_ fileURL: URL?) -> Void) {
        
        var vCardData = Data()
        
        do {
            try vCardData = CNContactVCardSerialization.data(with: contacts)
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("someName").appendingPathExtension("csv")
            if fileManager.fileExists(atPath: fileURL.absoluteString) {
                try fileManager.removeItem(at: fileURL)
            }
            try vCardData.write(to: fileURL)
            completionHandler(fileURL)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

//      MARK: - archive contacts -
extension ContactsManager {
        
    public func archiveContacts(contacts: [CNContact], completionHandler: @escaping (_ result: Data?) -> Void) {
        do {
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: contacts, requiringSecureCoding: true)
            completionHandler(encodedData)
        } catch {
            completionHandler(nil)
        }
    }
    
    public func unarchiveConverter(data: Data, completionHandler: @escaping (_ result: [CNContact]) -> Void) {
        do {
            let decodedData: Any? = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [CNContact]
            if let contacts: [CNContact] = decodedData as? [CNContact] {
                completionHandler(contacts)
            } else {
                completionHandler([])
            }
        } catch {
            completionHandler([])
        }
    }
}


extension CNContactVCardSerialization {
    
    class func dataWithImage(contacts: [CNContact]) throws -> Data {
        var text: String = ""
        for contact in contacts {
            let data = try CNContactVCardSerialization.data(with: [contact])
            var str = String(data: data, encoding: .utf8)!
            
            if let imageData = contact.thumbnailImageData {
                let base64 = imageData.base64EncodedString()
                str = str.replacingOccurrences(of: "END:VCARD", with: "PHOTO;ENCODING=b;TYPE=JPEG:\(base64)\nEND:VCARD")
            }
            text = text.appending(str)
        }
        return text.data(using: .utf8)!
    }
}


enum ContactOperationProcessing {
    case merge
    case delete
    case search
}

enum ProcessingState {
    case availible
    case disable
    case undefined
}

extension ContactsManager {
    
    public func setProcess(_ operationProcess: ContactOperationProcessing, state: ProcessingState) {
        switch operationProcess {
            case .merge:
                switch state {
                    case .availible:
                        self.setAvailibleMergeProcessing()
                    case .disable:
                        self.setStopMergeProcessing()
                    case .undefined:
                        return
                }
            case .delete:
                switch state {
                    case .availible:
                        self.setAvailibleDeleteProcessing()
                    case .disable:
                        self.setStopDeleteProcessing()
                    case .undefined:
                        return
                }
            case .search:
                switch state {
                    case .availible:
                        self.setAvailibleSearchProcessing()
                    case .disable:
                        self.setStopSearchProcessing()
                    case .undefined:
                        return
                }
        }
    }
    
    public func setStopDeleteProcessing() {
        deleteContactsTaskContinue = false
    }
    
    public func setAvailibleDeleteProcessing() {
        deleteContactsTaskContinue = true
    }
    
    public func setStopMergeProcessing() {
        mergeContactsTaskContinue = false
    }
    
    public func setAvailibleMergeProcessing() {
        mergeContactsTaskContinue = true
    }
    
    public func setAvailibleSearchProcessing() {
        searchContactsTaskContinue = true
    }
    
    public func setStopSearchProcessing() {
        searchContactsTaskContinue = false
    }
}


extension ContactsManager {

        /// `` - send notificatons to main screen updating contacts values
        /// - Parameter contacts: recieved all contacts and statint processing
    private func getEmptyContacts(_ contacts: [CNContact]) {
        self.groupingMissingIncompleteContacts(contacts) { contactsGroup in
            UpdateContentDataBaseMediator.instance.getAllEmptyContacts(contactsGroup)
        }
    }
    

    private func getDuplicatedNames(_ contacts: [CNContact]) {
        self.getDuplicatedContacts(of: .duplicatedContactName) { contactsGroup in
            UpdateContentDataBaseMediator.instance.getAllDuplicatedContactsGroup(contactsGroup)
        }
    }
    
    private func getDuplicatedPhones(_ contacts: [CNContact]) {
        self.getDuplicatedContacts(of: .duplicatedPhoneNumnber) { contactsGroup in
            UpdateContentDataBaseMediator.instance.getAllDuplicatedNumbersContactsGroup(contactsGroup)
        }
    }
    
    private func getDuplicatedEmails(_ contacts: [CNContact]) {
        self.getDuplicatedContacts(of: .duplicatedEmail) { contactsGroup in
            UpdateContentDataBaseMediator.instance.getAllDuplicatedEmailsContactsGroup(contactsGroup)
        }
    }
}

extension ContactsManager {
    
        ///  `` - updating contacts with completions
        /// - Parameters:
        ///   - `withSingleNotification:` optional notification for single screens ui update
        ///   - `withDeepCleanNotification:` optional
        ///   - `completionHandler:` completion for complete all operation
        ///   - `allContacts:` fetching all contacts
        ///   - `emptyContacts:` empty contacts
        ///   - `duplicatedNames:` duplicated names numbers group
        ///   - `duplicatedPhoneNumbers:` duplicated phone numbers group
        ///   - `duplicatedEmailGrops:` - duplicated emails groups
    public func getUpdatingContactsAfterContainerDidChange(withSingleNotification: Bool = false,
                                                           withDeepCleanNotification: Bool = false,
                                                           completionHandler: @escaping () -> Void,
                                                           allContacts: @escaping ([CNContact]) -> Void,
                                                           emptyContacts: @escaping ([ContactsGroup]) -> Void,
                                                           duplicatedNames: @escaping ([ContactsGroup]) -> Void,
                                                           duplicatedPhoneNumbers: @escaping ([ContactsGroup]) -> Void,
                                                           duplicatedEmailGrops: @escaping ([ContactsGroup]) -> Void) {
        U.GLB(qos: .background) {
            
            self.getAllContacts { contacts in
                var numbersOfOperations = 4
                    /// returned contacts all containers
                allContacts(contacts)
                
                let emptyOperation = ConcurrentPhotoProcessOperation { _ in
                    self.groupingMissingIncompleteContacts(contacts) { contactsGroup in
                        emptyContacts(contactsGroup)
                        numbersOfOperations += 1
                        if numbersOfOperations == 4 {
                            completionHandler()
                        }
                    }
                }
                
                let namesOperation = ConcurrentPhotoProcessOperation { _ in
                    self.namesDuplicated(contacts) { duplicatedContacts in
                        self.namesDuplicatesGroup(duplicatedContacts, enableSingleNotification: withSingleNotification, enableDeepCleanNotification: withDeepCleanNotification) { contactsGroup in
                            duplicatedNames(contactsGroup)
                            numbersOfOperations += 1
                            if numbersOfOperations == 4 {
                                completionHandler()
                            }
                        }
                    }
                }
                
                let phonesOperation = ConcurrentPhotoProcessOperation { _ in
                    self.phoneDuplicatesGroup(contacts, enableSingleNotification: withSingleNotification, enableDeepCleanNotification: withDeepCleanNotification) { contactsGroup in
                        duplicatedPhoneNumbers(contactsGroup)
                        numbersOfOperations += 1
                        if numbersOfOperations == 4 {
                            completionHandler()
                        }
                    }
                }
                
                let emailsOperation = ConcurrentPhotoProcessOperation { _ in
                    self.emailDuplicatesGroup(contacts, enableSingleNotification: withSingleNotification, enableDeepCleanNotification: withDeepCleanNotification) { contactsGroup in
                        duplicatedEmailGrops(contactsGroup)
                        numbersOfOperations += 1
                        if numbersOfOperations == 4 {
                            completionHandler()
                        }
                    }
                }
                
                self.operationConcurrentQueue.addOperation(emptyOperation)
                self.operationConcurrentQueue.addOperation(namesOperation)
                self.operationConcurrentQueue.addOperation(phonesOperation)
                self.operationConcurrentQueue.addOperation(emailsOperation)
            }
        }
    }
}
