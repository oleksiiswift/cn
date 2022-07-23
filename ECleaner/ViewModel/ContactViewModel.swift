//
//  ContactViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.07.2022.
//

import Foundation

class ContactViewModel {
	
	public var contactSection: [ContactSection]
	
	init(contactSection: [ContactSection]) {
		self.contactSection = contactSection
	}
	
	public func numberOfSections() -> Int {
		return self.contactSection.count
	}
	
	public func numberOfRows(in section: Int) -> Int {
		return self.contactSection[section].contactModelFields.count
	}
	
	public func getContactModel(at indexPath: IndexPath) -> ContactModel {
		return self.contactSection[indexPath.section].contactModelFields[indexPath.row]
	}
	
	public func getHeaderTitle(in section: Int) -> String? {
		return self.contactSection[section].headerTitle
	}
	
	public func getHeaderHight(in section: Int) -> CGFloat? {
		return self.contactSection[section].headerHeight
	}
	
	public func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
		return self.contactSection[indexPath.section].contactModelFields[indexPath.row].heightForRow
	}
}


