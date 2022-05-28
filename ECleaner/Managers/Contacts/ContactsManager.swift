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
	
	public let contactsProcessingOperationQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.contacts, maxConcurrentOperationCount: 10, qualityOfService: .userInteractive)

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
		
		guard SettingsManager.permissions.permisssionDidShow else { return }
		 guard ContactsPermissions().authorized else { return }
		
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
		
		guard ContactsPermissions().authorized else { return }
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
	
	
	public func contactsProcessingStore() {
		
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
		
		self.getEmptyContacts(contacts) { contactsGroup, _ in
			UpdateContentDataBaseMediator.instance.getAllEmptyContacts(contactsGroup)
		}
		
		self.getDuplicatedNames(contacts) { contactsGroup, _ in
			UpdateContentDataBaseMediator.instance.getAllDuplicatedContactsGroup(contactsGroup)
		}
		
		self.getDuplicatedPhones(contacts) { contactsGroup, _ in
			UpdateContentDataBaseMediator.instance.getAllDuplicatedNumbersContactsGroup(contactsGroup)
		}
		
		self.getDuplicatedEmails(contacts) { contactsGroup, _ in
			UpdateContentDataBaseMediator.instance.getAllDuplicatedEmailsContactsGroup(contactsGroup)
		}
	}
}

extension ContactsManager {
	
		/// `` - send notificatons to main screen updating contacts values
		/// - Parameter contacts: recieved all contacts and statint processing
		
	private func getEmptyContacts(_ contacts: [CNContact], completion: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void) {
		let operation = self.getEmptyContactsOperation(contacts: contacts, cleanProcessingType: .background) { contactsGroup, isCancelled in
			completion(contactsGroup, isCancelled)
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
	
	private func getDuplicatedNames(_ contacts: [CNContact], completion: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void) {
		let operation = self.getDuplicatedContactsNamesOperation(contacts: contacts, cleanProcessingType: .background) { contactsGroup, isCancelled in
			completion(contactsGroup, isCancelled)
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
	
	private func getDuplicatedPhones(_ contacts: [CNContact], completion: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void) {
		let operation = self.getPhoneDuplicatedOperation(contacts: contacts, cleanProcessingType: .background) { contactsGroup, isCancelled in
			completion(contactsGroup, isCancelled)
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
	
	private func getDuplicatedEmails(_ contacts: [CNContact], completion: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void) {
		let operation = self.getEmailDuplicatesOperation(contacts: contacts, cleanProcessingType: .background) { contactsGroup, isCancelled in
			completion(contactsGroup, isCancelled)
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
														   completionHandler: @escaping (_ isCancelled: Bool) -> Void,
														   allContacts: @escaping ([CNContact]) -> Void,
														   emptyContacts: @escaping ([ContactsGroup]) -> Void,
														   duplicatedNames: @escaping ([ContactsGroup]) -> Void,
														   duplicatedPhoneNumbers: @escaping ([ContactsGroup]) -> Void,
														   duplicatedEmailGrops: @escaping ([ContactsGroup]) -> Void) {
		
		self.getAllContacts { contacts in
			var numbersOfOperations = 4
				/// returned contacts all containers
			allContacts(contacts)
			
			let emptyContactsOperation = self.getEmptyContactsOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup, isCancelled in
				emptyContacts(contactsGroup)
				numbersOfOperations += 1
				if numbersOfOperations == 4 {
					completionHandler(isCancelled)
				}
			}
			
			let duplicatedContactNameOperation = self.getDuplicatedContactsNamesOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup, isCancelled in
				duplicatedNames(contactsGroup)
				numbersOfOperations += 1
				if numbersOfOperations == 4 {
					completionHandler(isCancelled)
				}
			}
			
			let duplicatedPhoneNumnberOperation = self.getPhoneDuplicatedOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup, isCancelled in
				duplicatedPhoneNumbers(contactsGroup)
				numbersOfOperations += 1
				if numbersOfOperations == 4 {
					completionHandler(isCancelled)
				}
			}
			
			let duplicatedEmailOperation = self.getEmailDuplicatesOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup, isCancelled in
				duplicatedEmailGrops(contactsGroup)
				numbersOfOperations += 1
				if numbersOfOperations == 4 {
					completionHandler(isCancelled)
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
	
	public func getSingleDuplicatedCleaningContacts(of type: ContactasCleaningType, cleanProcessingType: CleanProcessingPresentType = .singleSearch, completionHandler: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void) {
		
		self.getAllContacts { contacts in

			guard !contacts.isEmpty else {
				completionHandler([], false)
				return
			}
			
			switch type {
				case .emptyContacts:
					let operation = self.getEmptyContactsOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup, isCancelled in
						completionHandler(contactsGroup, isCancelled)
					}
					if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == operation.name}) {
						self.contactsProcessingOperationQueuer.addOperation(operation)
					} else {
						self.checkActiveOperation(operation)
					}
				case .duplicatedContactName:
					let operation = self.getDuplicatedContactsNamesOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup, isCancelled in
						completionHandler(contactsGroup, isCancelled)
					}
					if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == operation.name}) {
						self.contactsProcessingOperationQueuer.addOperation(operation)
					} else {
						self.checkActiveOperation(operation)
					}
				case .duplicatedPhoneNumnber:
					let operation = self.getPhoneDuplicatedOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup, isCancelled in
						completionHandler(contactsGroup, isCancelled)
					}
					if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == operation.name}) {
						self.contactsProcessingOperationQueuer.addOperation(operation)
					} else {
						self.checkActiveOperation(operation)
					}
				case .duplicatedEmail:
					let operation = self.getEmailDuplicatesOperation(contacts: contacts, cleanProcessingType: cleanProcessingType) { contactsGroup, isCancelled in
						completionHandler(contactsGroup, isCancelled)
					}
					if !self.contactsProcessingOperationQueuer.operations.contains(where: {$0.name == operation.name}) {
						self.contactsProcessingOperationQueuer.addOperation(operation)
					} else {
						self.checkActiveOperation(operation)
					}
				default:
					completionHandler([], false)
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
	
	public func getDeepCleanContactsProcessing(completionHandler: @escaping (_ contactStoreIsEmpty: Bool,_ isCancelled: Bool) -> Void,
											   emptyContactsCompletion: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void,
											   duplicatedContactsCompletion: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void,
											   duplicatedPhoneNumbersCompletion: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void,
											   duplicatedEmailsContactsCompletion: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void) {
		
		self.getAllContacts { contacts in
						
			var totalProcessingCompleteTasks = 0
			
			guard !contacts.isEmpty else { completionHandler(true, false); return }
			
			var processingOperationQueue: [ConcurrentProcessOperation] = []
			
			let emptyContactsOperation = self.getEmptyContactsOperation(contacts: contacts, cleanProcessingType: .deepCleen) { contactsGroup, isCancelled in
				emptyContactsCompletion(contactsGroup, isCancelled)
				
				totalProcessingCompleteTasks += 1
				if totalProcessingCompleteTasks == 4 {
					completionHandler(contacts.isEmpty, isCancelled)
				}
			}
			processingOperationQueue.append(emptyContactsOperation)
		
			let duplicatedNamesOperation = self.getDuplicatedContactsNamesOperation(contacts: contacts, cleanProcessingType: .deepCleen) { contactsGroup, isCancelled in
				duplicatedContactsCompletion(contactsGroup, isCancelled)
				
				totalProcessingCompleteTasks += 1
				if totalProcessingCompleteTasks == 4 {
					completionHandler(contacts.isEmpty, isCancelled)
				}
			}
			processingOperationQueue.append(duplicatedNamesOperation)
			
			let duplicatedPhoneNumbersOperation = self.getPhoneDuplicatedOperation(contacts: contacts, cleanProcessingType: .deepCleen) { contactsGroup, isCancelled in
				duplicatedPhoneNumbersCompletion(contactsGroup, isCancelled)
				
				totalProcessingCompleteTasks += 1
				if totalProcessingCompleteTasks == 4 {
					completionHandler(contacts.isEmpty, isCancelled)
				}
			}
			processingOperationQueue.append(duplicatedPhoneNumbersOperation)
			
			let duplicatedEmailsOperation = self.getEmailDuplicatesOperation(contacts: contacts, cleanProcessingType: .deepCleen) { contactsGroup, isCancelled in
				duplicatedEmailsContactsCompletion(contactsGroup, isCancelled)
				totalProcessingCompleteTasks += 1
				if totalProcessingCompleteTasks == 4 {
					completionHandler(contacts.isEmpty, isCancelled)
				}
			}
			processingOperationQueue.append(duplicatedEmailsOperation)

			processingOperationQueue.forEach { operation in
				self.contactsProcessingOperationQueuer.addOperation(operation)
			}
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
	private func getEmptyContactsOperation(contacts: [CNContact], cleanProcessingType: CleanProcessingPresentType, _ completionHandler: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void) -> ConcurrentProcessOperation {
		
		let emptyContactsOperation = ConcurrentProcessOperation { operation in
			
			guard contacts.count != 0 else {
				completionHandler([], operation.isCancelled)
				return
			}
			
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
				completionHandler([], operation.isCancelled)
				return
			}
			
			sleep(sleepInterval)
			for i in 0...contacts.count - 1 {
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .emptyContacts, singleCleanType: .emptyContacts, status: .progress, totalItems: contacts.count, currentIndex: i)
			}
			
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .emptyContacts, singleCleanType: .emptyContacts, status: .result, totalItems: contacts.count, currentIndex: contacts.count)
			U.delay(deleyInterval) {
				completionHandler(contactsGroup, operation.isCancelled)
			}
		}
		emptyContactsOperation.name = COT.emptyContactOperation.rawValue
		return emptyContactsOperation
	}
	
	
		/// `names duplicated contacts group`
	private func getDuplicatedContactsNamesOperation(contacts: [CNContact], cleanProcessingType: CleanProcessingPresentType, _ completionHandler: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void) -> ConcurrentProcessOperation {
	
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
						completionHandler([], operation.isCancelled)
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
				completionHandler(group, operation.isCancelled)
			}
		}
		duplicatedContactsOperation.name = COT.duplicatedNameOperation.rawValue
		return duplicatedContactsOperation
	}
	
		/// `phone numbers duplicated group`
	private func getPhoneDuplicatedOperation(contacts: [CNContact], cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void) -> ConcurrentProcessOperation {
		
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
						completionHandler([], operation.isCancelled)
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
				completionHandler(duplicatedContacts, operation.isCancelled)
			}
		}
		phoneDuplicatedOperation.name = COT.duplicatedPhoneNumbersOperation.rawValue
		return phoneDuplicatedOperation
	}
	
		/// `duplicated email list group`
	private func getEmailDuplicatesOperation(contacts: [CNContact], cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping (_ contactsGroup: [ContactsGroup],_ isCancelled: Bool) -> Void) -> ConcurrentProcessOperation {
		
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
						completionHandler([], operation.isCancelled)
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
				completionHandler(duplicatedContacts, operation.isCancelled)
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
	
	public func mergeAsyncContacts(in groups: [ContactsGroup], merged indexes: [Int],_ currentProgressConpletionHandler: @escaping(_ progressType: ProgressAlertType,_ currentIndex: Int,_ totalIndexes: Int) -> Void, completionHandler: @escaping(_ suxees: Bool,_ mergedContactsIndexes: [Int]) -> Void) {
		
		let mergrgeContactsOperation = ConcurrentProcessOperation { operation in
			
			let dispatchGroup = DispatchGroup()
			let dispatchQueue = DispatchQueue(label: C.key.dispatch.mergeContactsQueue)
			let dispatchSemaphore = DispatchSemaphore(value: 0)
			
			var finalProcessingIndexeForUpdating: [Int] = []
			var currentMergeProcessingIndex = 0
			var totalErrorsCount = 0
			
			for index in indexes {
				dispatchGroup.enter()
				let mergedGroup = groups[index]
				
				if operation.isCancelled {
					completionHandler(false, finalProcessingIndexeForUpdating)
					return
				}
				
				self.contactsMerge(in: mergedGroup) { mutableContactID, removableContacts in
					self.deleteAsyncContacts(removableContacts) { currentDeletingContactIndex in
						debugPrint(currentDeletingContactIndex)
					} completionHandler: { errorsCount in
						if errorsCount != 0 {
							totalErrorsCount += errorsCount
						} else {
							finalProcessingIndexeForUpdating.append(index)
							currentMergeProcessingIndex += 1
							currentProgressConpletionHandler(.mergeContacts, currentMergeProcessingIndex, indexes.count)
						}
					}
					dispatchSemaphore.signal()
					dispatchGroup.leave()
				}
				dispatchGroup.wait()
			}
			
			dispatchGroup.notify(queue: dispatchQueue) {
				completionHandler(true, finalProcessingIndexeForUpdating)
			}
		}
		mergrgeContactsOperation.name = C.key.operation.name.mergeContacts
		contactsProcessingOperationQueuer.addOperation(mergrgeContactsOperation)
	}
	
	public func mergeContactsDoNotInUSe(in groups: [ContactsGroup], merged indexes: [Int], currentCompletionIndex: @escaping(_ progressType: ProgressAlertType,_ currentIndex: Int,_ totalIndexes: Int) -> Void, completionHandler: @escaping(_ suxxes: Bool,_ mergedIndexes: [Int]) -> Void) {
		
		let mergeContactsOperation = ConcurrentProcessOperation { operation in
			
			var deletingContacts: [CNContact] = []
			var indexesForUpdate: [Int] = []
			
			let dispatchGroup = DispatchGroup()
			let dispatchQuoue = DispatchQueue(label: C.key.dispatch.mergeContactsQueue)
			let dispatchSemaphore = DispatchSemaphore(value: 0)
			
			var currentMergeProcessingIndex = 0
			
			dispatchQuoue.async {
				for index in indexes {
					dispatchGroup.enter()
					self.contactsMerge(in: groups[index]) { mutableContactID, removebleContacts in
						if operation.isCancelled {
							completionHandler(false, indexesForUpdate)
							return
						}
						
						currentMergeProcessingIndex += 1
						deletingContacts.append(contentsOf: removebleContacts)
						indexesForUpdate.append(index)
						currentCompletionIndex(.mergeContacts, currentMergeProcessingIndex, indexes.count)
						dispatchSemaphore.signal()
						dispatchGroup.leave()
					}
					dispatchSemaphore.wait()
				}
			}
			
			dispatchGroup.notify(queue: dispatchQuoue) {
				U.delay(0.3) {
					let contacts = Array(Set(deletingContacts))
					currentCompletionIndex(.deleteContacts, 0, contacts.count)
					U.delay(0.3) {
						self.deleteAsyncContacts(contacts) { currentDeletingContactIndex in
							currentCompletionIndex(.deleteContacts, currentDeletingContactIndex, contacts.count)
						} completionHandler: { errorsCount in
							completionHandler(errorsCount == 0, indexesForUpdate)
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
				U.BG {
					self.update(contact: mutableContact) { result in
						let removableContacts = contactsDuplicates.filter({ $0.identifier != mutableContact.identifier })
						deletingContactsCompletion(mutableContact.identifier, removableContacts)
					}
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
		self.deleteAsyncContacts(deletedContacts) { currentDeletingContactIndex in
			debugPrint(currentDeletingContactIndex)
		} completionHandler: { errorsCount in
			debugPrint(errorsCount)
		}

		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
			handler(true)
		})
	}
	
	public func checkForBestContact(_ contacts: [CNContact]) -> [CNContact] {
		
		var refablishContacts: [CNContact] = contacts
		var bestValue: Int = 0
		
		for contact in refablishContacts {
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

//      MARK: - DELETE CONTACTS METHODS -

extension ContactsManager {
	
	public func deleteAsyncContacts(_ contacts: [CNContact], _ indexingHandler: @escaping(_ currentDeletingContactIndex: Int) -> Void, completionHandler: @escaping(_ errorsCount: Int) -> Void) {
		
		let deleteContactsOperation = BlockOperation()
		
		deleteContactsOperation.addExecutionBlock {
			
			var errorsCount = 0
			let dispatchGroup = DispatchGroup()
			let dispatchQueue = DispatchQueue(label: C.key.dispatch.deleteContactsQueue)
			let dispatchSemaphore = DispatchSemaphore(value: 0)
			var currentDeletingContatsIndex = 0
			
			for contact in contacts {
				dispatchGroup.enter()
				self.deleteContact(contact) { success in
					
					if deleteContactsOperation.isCancelled {
						completionHandler(errorsCount)
						return
					}
					
					currentDeletingContatsIndex += 1
					if !success {
						errorsCount += 1
					}
					indexingHandler(currentDeletingContatsIndex)
					dispatchSemaphore.signal()
					dispatchGroup.leave()
				}
				dispatchSemaphore.wait()
			}
			
			dispatchGroup.notify(queue: dispatchQueue) {
				completionHandler(errorsCount)
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
			var cont = 0
			for contact in contacts {
				self.deleteContact(contact) { success in
					cont += 1
					debugPrint("deleting is \(success)")
					debugPrint("deleted \(cont) contacts")
				}
			}
		}
	}
}

//		MARK: - CREATE - UPDATE -
extension ContactsManager {
	
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
		contactsProcessingOperationQueuer.cancelOperation(with: C.key.operation.name.deleteContacts)
	}
	
	private func setStopMergeProcessing() {
		contactsProcessingOperationQueuer.cancelOperation(with: C.key.operation.name.mergeContacts)
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
