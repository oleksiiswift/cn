//
//  SegmentDatePickerType.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.12.2021.
//

import Foundation

enum SegmentDatePickerType: String {
	
	case year = "y"
	case month = "M"
	case date = "d"
	case dateTime = "yMdShm"
	case yearMonth = "yM"
	case monthYear = "My"
	case custom = ""
	
	var description: String {
		return self.rawValue
	}
}



