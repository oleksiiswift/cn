//
//  ContactsManagerOLD.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.12.2021.
//

import Foundation
import PhoneNumberKit
import Contacts

enum AlphabeticalContactsResults {
	case succes(responce: [String: [CNContact]])
	case error(error: Error)
}

class ContactsManager {
	
	static let shared: ContactsManager = {
		let instance = ContactsManager()
		return instance
	}()
	
		/// `private section`
	private var phoneNumberKit = PhoneNumberKit()
	private var progressSearchNotificationManager = ProgressSearchNotificationManager.instance
	
	public let contactsProcessingOperationQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.contacts, maxConcurrentOperationCount: 10, qualityOfService: .background)

		/// `fetching keys`
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
	
		/// `public external status check metods
		/// check status and if restricted returned to settings or ask for permision
	public func checkStatus(completionHandler: @escaping ([String: [CNContact]]) -> ()) {
		
		switch CNContactStore.authorizationStatus(for: .contacts) {
			case .denied, .restricted:
				A.showResrictedAlert(by: .contactsRestricted) {}
			case .notDetermined:
				self.requestAccesss { [unowned self] granted, error in
					self.checkStatus(completionHandler: completionHandler)
				}
			case .authorized:
				self.contactsProcessingStore()
			@unknown default:
				A.showResrictedAlert(by: .contactsRestricted) {}
		}
	}
	
	private var isStoreOpen: Bool {
		
		switch CNContactStore.authorizationStatus(for: .contacts) {
				
			case .denied, .restricted:
				return false
			case .notDetermined:
				self.requestAccesss { granted, error in }
				return false
			case .authorized:
				return true
			@unknown default:
				A.showResrictedAlert(by: .contactsRestricted) {}
		}
		return false
	}
}

//		MARK: - fetching contacts -
extension ContactsManager {
	
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
	
	public func getSortAndGroupContacts(_ contacts: [CNContact]) -> [String : [CNContact]] {
		return Dictionary(grouping: contacts, by: {String(($0.givenName + $0.familyName).uppercased().prefix(1))})
	}
	
		/// fetch all contacts
	public func getAllContacts(_ completionHandler: @escaping ([CNContact]) -> Void) {
		
		guard isStoreOpen else { return }
		
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
	
	public func getPredicateContacts(with identifiers: [String], complationHandler: @escaping ([CNContact]) -> Void) {
		
		let predicate = CNContact.predicateForContacts(withIdentifiers: identifiers)
		var contacts: [CNContact] = []
		
		if isStoreOpen {
			let contactStore: CNContactStore = CNContactStore()
			
			do {
				contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: self.fetchingKeys)
				if !contacts.isEmpty {
					complationHandler(contacts)
				}
			} catch {
				complationHandler([])
			}
		}
	}
	
	
	private func contactsProcessingStore() {
		
		self.getAllContacts { contacts in
			U.UI {
				self.resultProcessing(contacts)
			}
		}
	}
	
	private func resultProcessing(_ contacts: [CNContact]) {
		
		let concurrentOperationContacts = ConcurrentProcessOperation { _ in
			UpdateContentDataBaseMediator.instance.updateContentStoreCount(mediaType: .userContacts, itemsCount: contacts.count, calculatedSpace: 0)
			UpdateContentDataBaseMediator.instance.getAllContacts(contacts)
		}
		concurrentOperationContacts.name = C.key.operation.name.updateContectContacts
		self.contactsProcessingOperationQueuer.addOperation(concurrentOperationContacts)
		
		self.getEmptyContacts(contacts) { contactsGroup in
			UpdateContentDataBaseMediator.instance.getAllEmptyContacts(contactsGroup)
		}
		
		self.getDuplicatedNames(contacts) { contactsGroup in
			UpdateContentDataBaseMediator.instance.getAllDuplicatedContactsGroup(contactsGroup)
		}
		
		self.getDuplicatedPhones(contacts) { contactsGroup in
			UpdateContentDataBaseMediator.instance.getAllDuplicatedNumbersContactsGroup(contactsGroup)
		}
		
		self.getDuplicatedEmails(contacts) { contactsGroup in
			UpdateContentDataBaseMediator.instance.getAllDuplicatedEmailsContactsGroup(contactsGroup)
		}
	}
}

extension ContactsManager {
	
		/// `` - send notificatons to main screen updating contacts values
		/// - Parameter contacts: recieved all contacts and statint processing
		
	private func getEmptyContacts(_ contacts: [CNContact], completion: @escaping ([ContactsGroup]) -> Void) {
		let operation = self.getEmptyContactsOperation(contacts: contacts, cleanProcessingType: .background) { contactsGroup in
			completion(contactsGroup)
		}
		
		if let operationInQueue = self.contactsProcessingOperationQueuer.operations.first(where: {$0.name == operation.name}) {
			operationInQueue.cancel()
			U.delay(0.1) {
				self.contactsProcessingOperationQueuer.addOperation(operation)
			}
		} else {
			self.contactsProcessingOperationQueuer.addOperation(operation)
		}
	}
	
	private func getDuplicatedNames(_ contacts: [CNContact], completion: @escaping ([ContactsGroup]) -> Void) {
		let operation = self.getDuplicatedContactsNamesOperation(contacts: contacts, cleanProcessingType: .background) { contactsGroup in
			completion(contactsGroup)
		}
		if let operationInQueue = self.contactsProcessingOperationQueuer.operations.first(where: {$0.name == operation.name}) {
			operationInQueue.cancel()
			U.delay(0.1) {
				self.contactsProcessingOperationQueuer.addOperation(operation)
			}
		} else {
			self.contactsProcessingOperationQueuer.addOperation(operation)
		}
	}
	
	private func getDuplicatedPhones(_ contacts: [CNContact], completion: @escaping ([ContactsGroup]) -> Void) {
		let operation = self.getPhoneDuplicatedOperation(contacts: contacts, cleanProcessingType: .background) { contactsGroup in
			completion(contactsGroup)
		}
		if let operationInQueue = self.contactsProcessingOperationQueuer.operations.first(where: {$0.name == operation.name}) {
			operationInQueue.cancel()
			U.delay(0.1) {
				self.contactsProcessingOperationQueuer.addOperation(operation)
			}
		} else {
			self.contactsProcessingOperationQueuer.addOperation(operation)
		}
	}
	
	private func getDuplicatedEmails(_ contacts: [CNContact], completion: @escaping ([ContactsGroup]) -> Void) {
		let operation = self.getEmailDuplicatesOperation(contacts: contacts, cleanProcessingType: .background) { contactsGroup in
			completion(contactsGroup)
		}
		if let operationInQueue = self.contactsProcessingOperationQueuer.operations.first(where: {$0.name == operation.name}) {
			operationInQueue.cancel()
			U.delay(0.1) {
				self.contactsProcessingOperationQueuer.addOperation(operation)
			}
		} else {
			self.contactsProcessingOperationQueuer.addOperation(operation)
		}
	}
}

extension ContactsManager {
	
		///  `` - updating contacts with completions
		/// - Parameters:
		///   - `cleanProcessingType:` optional notification for single screens ui update or deepclean
		///   - `completionHandler:` completion for complete all operation
		///   - `allContacts:` fetching all contacts
		///   - `emptyContacts:` empty contacts
		///   - `duplicatedNames:` duplicated names numbers group
		///   - `duplicatedPhoneNumbers:` duplicated phone numbers group
		///   - `duplicatedEmailGrops:` - duplicated emails groups
	public func getUpdatingContactsAfterContainerDidChange(cleanProcessingType: CleanProcessingPresentType = .background,
														   completionHandler: @escaping () -> Void,
														   allContacts: @escaping ([CNContact]) -> Void,
														   emptyContacts: @escaping ([ContactsGroup]) -> Void,
														   duplicatedNames: @escaping ([ContactsGroup]) -> Void,
														   duplicatedPhoneNumbers: @escaping ([ContactsGroup]) -> Void,
														   duplicatedEmailGrops: @escaping ([ContactsGroup]) -> Void) {
		
		self.getAllContacts { contacts in
			var numbersOfOperations = 4
				/// returned contacts all containers
			allContacts(contacts)
			
			let emptyContactsOperation = self.getEmptyContactsOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup in
				emptyContacts(contactsGroup)
				numbersOfOperations += 1
				if numbersOfOperations == 4 {
					completionHandler()
				}
			}
			
			let duplicatedContactNameOperation = self.getDuplicatedContactsNamesOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup in
				duplicatedNames(contactsGroup)
				numbersOfOperations += 1
				if numbersOfOperations == 4 {
					completionHandler()
				}
			}
			
			let duplicatedPhoneNumnberOperation = self.getPhoneDuplicatedOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup in
				duplicatedPhoneNumbers(contactsGroup)
				numbersOfOperations += 1
				if numbersOfOperations == 4 {
					completionHandler()
				}
			}
			
			let duplicatedEmailOperation = self.getEmailDuplicatesOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup in
				duplicatedEmailGrops(contactsGroup)
				numbersOfOperations += 1
				if numbersOfOperations == 4 {
					completionHandler()
				}
			}
			if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == emptyContactsOperation.name}) {
				self.contactsProcessingOperationQueuer.addOperation(emptyContactsOperation)
			}
			
			if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == duplicatedContactNameOperation.name}) {
				self.contactsProcessingOperationQueuer.addOperation(duplicatedContactNameOperation)
			}
			
			if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == duplicatedPhoneNumnberOperation.name}) {
				self.contactsProcessingOperationQueuer.addOperation(duplicatedPhoneNumnberOperation)
			}
			
			if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == duplicatedEmailOperation.name}) {
				self.contactsProcessingOperationQueuer.addOperation(duplicatedEmailOperation)
			}
		}
	}
}


extension ContactsManager {
	
	public func getSingleDuplicatedCleaningContacts(of type: ContactasCleaningType, cleanProcessingType: CleanProcessingPresentType = .singleSearch, completionHandler: @escaping ([ContactsGroup]) -> Void) {
		
		self.getAllContacts { contacts in
			guard !contacts.isEmpty else { completionHandler([]); return }
			
			switch type {
				case .emptyContacts:
					let operation = self.getEmptyContactsOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup in
						completionHandler(contactsGroup)
					}
					if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == operation.name}) {
						self.contactsProcessingOperationQueuer.addOperation(operation)
					} else {
						self.checkActiveOperation(operation)
					}
				case .duplicatedContactName:
					let operation = self.getDuplicatedContactsNamesOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup in
						completionHandler(contactsGroup)
					}
					if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == operation.name}) {
						self.contactsProcessingOperationQueuer.addOperation(operation)
					} else {
						self.checkActiveOperation(operation)
					}
				case .duplicatedPhoneNumnber:
					let operation = self.getPhoneDuplicatedOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup in
						completionHandler(contactsGroup)
					}
					if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == operation.name}) {
						self.contactsProcessingOperationQueuer.addOperation(operation)
					} else {
						self.checkActiveOperation(operation)
					}
				case .duplicatedEmail:
					let operation = self.getEmailDuplicatesOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup in
						completionHandler(contactsGroup)
					}
					if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == operation.name}) {
						self.contactsProcessingOperationQueuer.addOperation(operation)
					} else {
						self.checkActiveOperation(operation)
					}
				default:
					completionHandler([])
			}
		}
	}
	
	private func checkActiveOperation(_ operation: ConcurrentProcessOperation) {
		U.UI {
			P.showIndicator()
		}
		if let contactQueurTaskOperation = self.contactsProcessingOperationQueuer.operations.first(where: {$0.name == operation.name}) {
			contactQueurTaskOperation.cancel()
			U.delay(1) {
				P.hideIndicator()
				self.contactsProcessingOperationQueuer.addOperation(operation)
			}
		} else {
			self.contactsProcessingOperationQueuer.addOperation(operation)
		}
	}
	
	public func getDeepCleanContactsProcessing(completionHandler: @escaping () -> Void,
											   emptyContactsCompletion: @escaping ([ContactsGroup]) -> Void,
											   duplicatedContactsCompletion: @escaping ([ContactsGroup]) -> Void,
											   duplicatedPhoneNumbersCompletion: @escaping ([ContactsGroup]) -> Void,
											   duplicatedEmailsContactsCompletion: @escaping ([ContactsGroup]) -> Void) {
		
		self.getAllContacts { contacts in
						
			var totalProcessingCompleteTasks = 0
			
			guard !contacts.isEmpty else { completionHandler(); return }
			
			let emptyContactsOperation = self.getEmptyContactsOperation(contacts: contacts, cleanProcessingType: .deepCleen) { contactsGroup in
				emptyContactsCompletion(contactsGroup)
				
				totalProcessingCompleteTasks += 1
				if totalProcessingCompleteTasks == 4 {
					completionHandler()
				}
			}
			
			let duplicatedNamesOperation = self.getDuplicatedContactsNamesOperation(contacts: contacts, cleanProcessingType: .deepCleen) { contactsGroup in
				duplicatedContactsCompletion(contactsGroup)
				
				totalProcessingCompleteTasks += 1
				if totalProcessingCompleteTasks == 4 {
					completionHandler()
				}
			}
			
			let duplicatedPhoneNumbersOperation = self.getPhoneDuplicatedOperation(contacts: contacts, cleanProcessingType: .deepCleen) { contactsGroup in
				duplicatedPhoneNumbersCompletion(contactsGroup)
				
				totalProcessingCompleteTasks += 1
				if totalProcessingCompleteTasks == 4 {
					completionHandler()
				}
			}
			
			let duplicatedEmailsOperation = self.getEmailDuplicatesOperation(contacts: contacts, cleanProcessingType: .deepCleen) { contactsGroup in
				duplicatedEmailsContactsCompletion(contactsGroup)
				totalProcessingCompleteTasks += 1
				if totalProcessingCompleteTasks == 4 {
					completionHandler()
				}
			}
						
			self.contactsProcessingOperationQueuer.addOperation(emptyContactsOperation)
			self.contactsProcessingOperationQueuer.addOperation(duplicatedNamesOperation)
			self.contactsProcessingOperationQueuer.addOperation(duplicatedPhoneNumbersOperation)
			self.contactsProcessingOperationQueuer.addOperation(duplicatedEmailsOperation)
			
		}
	}
}

extension ContactsManager {
	
		/// ``getEmptyContactsOperation`` - find duplicated contacts by name
		/// ``getDuplicatedContactsNamesOperation`` - get sections of duplicated contacts by names
		/// ``getPhoneDuplicatedOperation`` find duplicated contacts by phone numbers
		/// ``getEmailDuplicatesOperation`` - find duplicated contacts by emails  -  get sections of duplicated contacts by emails
		/// ``getEmailDuplicatesOperation`` - check for empty fields
	
		/// `check empty filds` - check if some fileds is emty
	private func getEmptyContactsOperation(contacts: [CNContact], cleanProcessingType: CleanProcessingPresentType, _ completionHandler: @escaping ([ContactsGroup]) -> Void) -> ConcurrentProcessOperation {
		
		let emptyContactsOperation = ConcurrentProcessOperation { operation in
			
			let deleyInterval: Double = cleanProcessingType == .background ? 0 : 1
			let sleepInterval: UInt32 = cleanProcessingType == .background ? 0 : 1
			
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .emptyContacts, singleCleanType: .emptyContacts, status: .prepare, totalItems: 0, currentIndex: 0)
			sleep(sleepInterval)
			
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
			
				/// `whole empty` group
			let wholeEmptyContacts = emptyNameContacts.filter({$0.phoneNumbers.count == 0 && $0.emailAddresses.count == 0})
			let wholeEmptyContactsName = ContactasCleaningType.wholeEmpty.rawValue
			let wholeEmptyGroup = ContactsGroup(name: wholeEmptyContactsName, contacts: wholeEmptyContacts, groupType: .wholeEmpty, countryIdentifier: emptyIdentifier)
			
			wholeEmptyContacts.count != 0 ? contactsGroup.append(wholeEmptyGroup) : ()
			
			if operation.isCancelled {
				self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .emptyContacts, singleCleanType: .emptyContacts)
				completionHandler([])
				return
			}
			
			sleep(sleepInterval)
			for i in 0...contacts.count - 1 {
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .emptyContacts, singleCleanType: .emptyContacts, status: .progress, totalItems: contacts.count, currentIndex: i)
			}
			
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .emptyContacts, singleCleanType: .emptyContacts, status: .result, totalItems: contacts.count, currentIndex: contacts.count)
			U.delay(deleyInterval) {
				completionHandler(contactsGroup)
			}
		}
		emptyContactsOperation.name = COT.emptyContactOperation.rawValue
		return emptyContactsOperation
	}
	
	
		/// `names duplicated contacts group`
	private func getDuplicatedContactsNamesOperation(contacts: [CNContact], cleanProcessingType: CleanProcessingPresentType, _ completionHandler: @escaping ([ContactsGroup]) -> Void) -> ConcurrentProcessOperation {
	
		let duplicatedContactsOperation = ConcurrentProcessOperation { operation in
			
			let deleyInterval: Double = cleanProcessingType == .background ? 0 : 1
			
			var group: [ContactsGroup] = []
			var currentProcessingIndex: Int = 0
			
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicateContacts, singleCleanType: .duplicatesNames, status: .prepare, totalItems: 0, currentIndex: 0)
			
			var contactsDictionary = Dictionary(grouping: contacts, by: {String($0.familyName.removeWhitespace() + $0.givenName.removeWhitespace())})
			contactsDictionary.removeValue(forKey: "")
			let filterDictionary = contactsDictionary.filter({$0.value.count > 1})
			
			if !filterDictionary.isEmpty {
				
				for (contactName, similarContacts) in filterDictionary {
										
					if operation.isCancelled {
						self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicateContacts, singleCleanType: .duplicatesNames)
						completionHandler([])
						return
					}
					
					currentProcessingIndex += 1
					
					self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicateContacts, singleCleanType: .duplicatesNames, status: .progress, totalItems: filterDictionary.count, currentIndex: currentProcessingIndex)
					
					sleep(UInt32(0.1))
					let phoneNumbers = similarContacts.map({$0.phoneNumbers}).reduce([], +)
					let stringNumbers = phoneNumbers.map({$0.value.stringValue})
					let itentifier = self.checkRegionIdentifier(from: stringNumbers)
					
					group.append(ContactsGroup(name: contactName, contacts: similarContacts, groupType: .duplicatedContactName, countryIdentifier: itentifier))
				}
				group.forEach({ $0.contacts = self.esctimateBestContactIn($0.contacts )})
			} else {
				self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicateContacts, singleCleanType: .duplicatesNames)
			}
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicateContacts, singleCleanType: .duplicatesNames, status: .result, totalItems: filterDictionary.count, currentIndex: filterDictionary.count)
			U.delay(deleyInterval) {
				completionHandler(group)
			}
		}
		duplicatedContactsOperation.name = COT.duplicatedNameOperation.rawValue
		return duplicatedContactsOperation
	}
	
		/// `phone numbers duplicated group`
	private func getPhoneDuplicatedOperation(contacts: [CNContact], cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ([ContactsGroup]) -> Void) -> ConcurrentProcessOperation {
		
		let phoneDuplicatedOperation = ConcurrentProcessOperation { operation in
			
			let deleyInterval: Double = cleanProcessingType == .background ? 0 : 1
			
			let contactsStore = CNContactStore()
			let phoneNumbers = Array(Set(contacts.map({$0.phoneNumbers.map({$0.value})}).reduce([], +)))
			
			var duplicatedContacts: [ContactsGroup] = []
			
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicatedPhoneNumbers, singleCleanType: .duplicatesNumbers, status: .prepare, totalItems: 0, currentIndex: 0)
			
			if !phoneNumbers.isEmpty {
				
				for i in 0...phoneNumbers.count - 1 {
					
					if operation.isCancelled {
						self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicatedPhoneNumbers, singleCleanType: .duplicatesNumbers)
						completionHandler([])
						return
					}
					
					let phoneNunber = phoneNumbers[i]
					let fetchPredicate = CNContact.predicateForContacts(matching: phoneNunber)
					do {
						let containerResults = try contactsStore.unifiedContacts(matching: fetchPredicate, keysToFetch: self.fetchingKeys)
						
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicatedPhoneNumbers, singleCleanType: .duplicatesNumbers, status: .progress, totalItems: phoneNumbers.count, currentIndex: i)
						
						if containerResults.count > 1 {
							let identifier = ContactsCountryIdentifier(region: "", countryCode: "")
							duplicatedContacts.append(ContactsGroup(name: phoneNunber.stringValue, contacts: containerResults, groupType: .duplicatedPhoneNumnber, countryIdentifier: identifier))
						}
					} catch {
						debugPrint(error.localizedDescription)
					}
				}
			} else {
				self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicatedPhoneNumbers, singleCleanType: .duplicatesNumbers)
			}
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicatedPhoneNumbers, singleCleanType: .duplicatesNumbers, status: .result, totalItems: phoneNumbers.count, currentIndex: phoneNumbers.count)
			U.delay(deleyInterval) {
				completionHandler(duplicatedContacts)
			}
		}
		phoneDuplicatedOperation.name = COT.duplicatedPhoneNumbersOperation.rawValue
		return phoneDuplicatedOperation
	}
	
		/// `duplicated email list group`
	private func getEmailDuplicatesOperation(contacts: [CNContact], cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ([ContactsGroup]) -> Void) -> ConcurrentProcessOperation {
		
		let emailDuplicatedOperation = ConcurrentProcessOperation { operation in
			
			let deleyInterval: Double = cleanProcessingType == .background ? 0 : 1
			
			let contactsStore = CNContactStore()
			let emailsList = Array(Set(contacts.map({$0.emailAddresses.map({$0.value as String})}).reduce([], +)))
			var duplicatedContacts: [ContactsGroup] = []
			
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicatedEmails, singleCleanType: .duplicatesEmails, status: .prepare, totalItems: 0, currentIndex: 0)
			
			if !emailsList.isEmpty {
				
				for i in 0...emailsList.count - 1 {
				
					if operation.isCancelled {
						self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicatedEmails, singleCleanType: .duplicatesEmails)
						completionHandler([])
						return
					}
					
					let email = emailsList[i]
					do {
						let fetchPredicate = CNContact.predicateForContacts(matchingEmailAddress: email)
						
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicatedEmails, singleCleanType: .duplicatesEmails, status: .progress, totalItems: emailsList.count, currentIndex: i)
			
						let containerResult = try contactsStore.unifiedContacts(matching: fetchPredicate, keysToFetch: self.fetchingKeys)
						if containerResult.count > 1 {
							let identifier = ContactsCountryIdentifier(region: "", countryCode: "")
							duplicatedContacts.append(ContactsGroup(name: email, contacts: containerResult, groupType: .duplicatedEmail, countryIdentifier: identifier))
						}
					} catch {
						debugPrint(error.localizedDescription)
					}
				}
			} else {
				self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicatedEmails, singleCleanType: .duplicatesEmails)
			}
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicatedEmails, singleCleanType: .duplicatesEmails, status: .result, totalItems: emailsList.count, currentIndex: emailsList.count)
			U.delay(deleyInterval) {
				completionHandler(duplicatedContacts)
			}
		}
		emailDuplicatedOperation.name = COT.duplicatedEmailsOperation.rawValue
		return emailDuplicatedOperation
	}

	private func smartMergeGroups(_ groups: [ContactsGroup], completionHandler: @escaping ([String], [CNContact]) -> Void) {
		
		var deletingContacts: [CNContact] = []
		var leftContacts: [String] = []
		var index = 0
		for group in groups {
			self.contactsMerge(in: group) { mutableID, contacts in
				deletingContacts.append(contentsOf: contacts)
				leftContacts.append(mutableID)
				index += 1
				if index == groups.count {
					completionHandler(leftContacts, deletingContacts)
				}
			}
		}
	}
}

//		MARK: - MERGE CONTACTS -
extension ContactsManager {
	
	public func mergeContacts(in group: [ContactsGroup], merged indexes: [Int], completionHandler: @escaping (Bool, [Int]) -> Void) {
		
		let mergeContactsOperation = ConcurrentProcessOperation { operation in
			
			var errorsCount: Int = 0
			var deleteSelectionIndexCount: Int = 0
			var indexesForUpdate: [Int] = []
			var fullCircleIndexesCount = 0
			
			for index in indexes {
	
				if operation.isCancelled {
					completionHandler(true, indexesForUpdate)
					return
				}
				
				
				self.contactsMerge(in: group[index]) { _, deleteContacts in
					self.deleteContacts(deleteContacts) { suxxess, deleteCount in
						if suxxess {
							deleteSelectionIndexCount += 1
							indexesForUpdate.append(index)
						} else {
							let errors = deleteContacts.count - deleteCount
							errorsCount += errors
						}
						
						fullCircleIndexesCount += 1
						
						let calculetedProgress: CGFloat = CGFloat(100 * deleteSelectionIndexCount / indexes.count) / 100
						let totalProcessing: String = "\(deleteSelectionIndexCount) / \(indexes.count)"
						
						let userInfo: [String : Any] = [C.key.notificationDictionary.progressAlert.progrssAlertValue: calculetedProgress,
														C.key.notificationDictionary.progressAlert.progressAlertFilesCount: totalProcessing]
						
						U.notificationCenter.post(name: .progressMergeContactsAlertDidChangeProgress, object: nil, userInfo: userInfo)
						sleep(UInt32(0.1))
						
						if indexes.count == deleteSelectionIndexCount {
							completionHandler(true, indexesForUpdate)
						} else if indexes.count == fullCircleIndexesCount {
							completionHandler(false, indexesForUpdate)
						}
					}
				}
			}
		}
		mergeContactsOperation.name = C.key.operation.name.mergeContacts
		contactsProcessingOperationQueuer.addOperation(mergeContactsOperation)
	}
	
	public func contactsMerge(in group: ContactsGroup, deletingContactsCompletion: @escaping (String, [CNContact]) -> Void) {
		
		let contactsIDS: [String] = group.contacts.map({$0.identifier})
		
		self.getPredicateContacts(with: contactsIDS) { contactsDuplicates in
			
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
					let removableContacts = contactsDuplicates.filter({ $0.identifier != mutableContact.identifier })
					deletingContactsCompletion(mutableContact.identifier, removableContacts)
				}
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

//		MARK: - HELPER METHODS -
extension ContactsManager {
	
	///  `phone number parsing`
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

//      MARK: - DELETE, CREATE, UPDATE CONTACTS METHODS -

extension ContactsManager {
	
	public func deleteContacts(_ contacts: [CNContact],_ completionHandler: @escaping ((Bool, Int) -> Void)) {
		
		let deleteContactsOperation = ConcurrentProcessOperation { operation in
			
			var deletedOperationCount = 0
			var deletedContactsCount = 0
			var errorsCount = 0
			
			
			for contact in contacts {
	
				if operation.isCancelled {
					completionHandler(false, errorsCount)
					return
				}
				
				self.deleteContact(contact) { success in
						
					deletedOperationCount += 1
					
					if success {
						deletedContactsCount += 1
						
						let calculateprogress: CGFloat = CGFloat(100 * deletedContactsCount / contacts.count) / 100
						
						let userInfo: [String: Any] = [C.key.notificationDictionary.progressAlert.progrssAlertValue: calculateprogress,
													   C.key.notificationDictionary.progressAlert.progressAlertFilesCount: "\(deletedContactsCount) / \(contacts.count)"]
						
						U.notificationCenter.post(name: .progressDeleteContactsAlertDidChangeProgress, object: nil, userInfo: userInfo)
						debugPrint(deletedOperationCount)
					} else {
						errorsCount += 1
					}
					
					if contacts.count == deletedContactsCount {
						completionHandler(true, deletedContactsCount)
					} else {
						completionHandler(false,deletedContactsCount)
					}
				}
			}
			
		
		}
		deleteContactsOperation.name = C.key.operation.name.deleteContacts
		contactsProcessingOperationQueuer.addOperation(deleteContactsOperation)
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
	
	public func deleteAllContatsFromStore() {
		self.getAllContacts { contacts in
			self.deleteContacts(contacts) { suxxess, deletedCount in
				debugPrint("deleting is \(suxxess)")
				debugPrint("deleted \(deletedCount) contacts")
			}
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
	
	private func setStopDeleteProcessing() {
		contactsProcessingOperationQueuer.cancelAll()
	}
	
	private func setStopMergeProcessing() {
		contactsProcessingOperationQueuer.cancelAll()
	}
	
	private func setStopSearchProcessing() {
		contactsProcessingOperationQueuer.cancelAll()
	}
	
	private func setAvailibleSearchProcessing() {}
	private func setAvailibleMergeProcessing() {}
	private func setAvailibleDeleteProcessing() {}
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

extension ContactsManager {
	
	private func sendNotification(processing: CleanProcessingPresentType, deepCleanType: DeepCleanNotificationType = .none, singleCleanType: SingleContentSearchNotificationType = .none, status: ProcessingProgressOperationState, totalItems: Int, currentIndex: Int) {
		
		switch processing {
			case .deepCleen:
				self.progressSearchNotificationManager.sendDeepProgressNotification(notificationType: deepCleanType, status: status, totalProgressItems: totalItems, currentProgressItem: currentIndex)
			case .singleSearch:
				self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: singleCleanType, status: status, totalProgressItems: totalItems, currentProgressItem: currentIndex)
			case .background:
				return
		}
	}
	
	private func sendEmptyNotification(processing: CleanProcessingPresentType, deepCleanType: DeepCleanNotificationType = .none, singleCleanType: SingleContentSearchNotificationType = .none) {
		switch processing {
			case .deepCleen:
				self.sendEmptyDeepCleanNotification(of: deepCleanType)
			case .singleSearch:
				self.sendEmptySingleCleanNotification(of: singleCleanType)
			case .background:
				return
		}
	}
	
	private func sendEmptyDeepCleanNotification(of type: DeepCleanNotificationType) {
		U.delay(1) {
			self.progressSearchNotificationManager.sendDeepProgressNotification(notificationType: type, status: .empty, totalProgressItems: 0, currentProgressItem: 0)
		}
	}
	
	private func sendEmptySingleCleanNotification(of type: SingleContentSearchNotificationType) {
		U.delay(1) {
			self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: type, status: .empty, totalProgressItems: 0, currentProgressItem: 0)
		}
	}
	
	private func sendUtilityDeepCleanNotification(of type: DeepCleanNotificationType, state: ProcessingProgressOperationState) {
		self.progressSearchNotificationManager.sendDeepProgressNotification(notificationType: type, status: state, totalProgressItems: 0, currentProgressItem: 0)
	}
	
	private func sendUtilitySingleCleanNotification(of type: SingleContentSearchNotificationType, state: ProcessingProgressOperationState) {
		self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: type, status: state, totalProgressItems: 0, currentProgressItem: 0)
	}
}
