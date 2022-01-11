//
//  ContactsGroupModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.12.2021.
//

import Contacts

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
	var groupIdentifier: String
	
	init(name: String, contacts: [CNContact], groupType: ContactasCleaningType, countryIdentifier: ContactsCountryIdentifier) {
		self.countryIdentifier = countryIdentifier
		self.name = name
		self.contacts = contacts
		self.groupType = groupType
		self.groupIdentifier = UUID().uuidString
	}
}
