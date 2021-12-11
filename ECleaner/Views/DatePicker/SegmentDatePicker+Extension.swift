//
//  SegmentDatePicker+Extension.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.12.2021.
//

import Foundation
import UIKit

extension Date {
	
	func getHour() -> Int {
		return Calendar.current.component(.hour, from: self)
	}
	
	func getMinute() -> Int {
		return Calendar.current.component(.minute, from: self)
	}
	
	func getDay() -> Int {
		return Calendar.current.component(.day, from: self)
	}
	
	func getMonth() -> Int {
		return Calendar.current.component(.month, from: self)
	}
	
	func getYear() -> Int {
		return Calendar.current.component(.year, from: self)
	}
}
