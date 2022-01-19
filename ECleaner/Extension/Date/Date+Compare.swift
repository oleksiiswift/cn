//
//  Date+Compare.swift
//  ECleaner
//
//  Created by alexey sorochan on 19.01.2022.
//

import Foundation

extension Date {
	
	func isGreaterThanDate(dateToCompare: Date) -> Bool {
			//Declare Variables
		var isGreater = false
		
			//Compare Values
		if self.compare(dateToCompare) == .orderedDescending {
			isGreater = true
		}
		
			//Return Result
		return isGreater
	}
	
	func isLessThanDate(dateToCompare: Date) -> Bool {
			//Declare Variables
		var isLess = false
		
			//Compare Values
		if self.compare(dateToCompare) == .orderedAscending {
			isLess = true
		}
		
			//Return Result
		return isLess
	}
	
	func equalToDate(dateToCompare: Date) -> Bool {
			//Declare Variables
		var isEqualTo = false
		
			//Compare Values
		if self.compare(dateToCompare) == .orderedSame {
			isEqualTo = true
		}
		
			//Return Result
		return isEqualTo
	}
}
