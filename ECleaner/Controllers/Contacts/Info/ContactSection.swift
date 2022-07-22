//
//  ContactSection.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.07.2022.
//

import Foundation

struct ContactSection {
	
	let contactModelFields: [ContactModel]
	let headerTitle: String?
	let headerHeight: CGFloat?
	
	init(contactModelFields: [ContactModel], headerTitle: String?, headerHeight: CGFloat?) {
		self.contactModelFields = contactModelFields
		self.headerTitle = headerTitle
		self.headerHeight = headerHeight
	}
}
