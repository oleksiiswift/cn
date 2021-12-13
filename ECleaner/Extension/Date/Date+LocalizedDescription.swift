//
//  Date+LocalizedDescription.swift
//  ECleaner
//
//  Created by alexey sorochan on 13.12.2021.
//

import Foundation

extension Date {
	
	func stringMonth() -> String {
		
			let df = DateFormatter()
			df.setLocalizedDateFormatFromTemplate("MMM")
			return df.string(from: self)
	}
}
