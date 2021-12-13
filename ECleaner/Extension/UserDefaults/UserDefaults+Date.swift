//
//  UserDefaults+Date.swift
//  ECleaner
//
//  Created by alexey sorochan on 13.12.2021.
//

import Foundation

extension UserDefaults {
	
	func set(date: Date?, forKey key: String) {
		self.set(date, forKey: key)
	}
	
	func getDate(forKey key: String) -> Date? {
		return self.value(forKey: key) as? Date
	}
}
