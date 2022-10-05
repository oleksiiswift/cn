//
//  Date+CurrentDate.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2021.
//

import Foundation

extension Date {
    
    static func getCurrentDate() -> Double {
        let date = Date()
        return date.timeIntervalSince1970
    }
}

extension Date {
	func startOfMonth() -> Date {
		return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
	}
	
	func endOfMonth() -> Date {
		return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
	}
}

extension Date {
	
	func globalTimeFromUTCConver() -> Date {
		let timezone = TimeZone.current
		let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
		return Date(timeInterval: seconds, since: self)
	}
	
	func localTimeFromUTCConvert() -> Date {
		let timezoneOffset = TimeZone.current.secondsFromGMT()
		let epochDate = self.timeIntervalSince1970
		let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
		return Date(timeIntervalSince1970: timezoneEpochOffset)
	}
}
