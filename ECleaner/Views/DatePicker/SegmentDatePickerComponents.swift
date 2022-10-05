//
//  SegmentDatePickerComponents.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.12.2021.
//

import Foundation

enum SegmentDatePickerComponents: Character {
	
	case invalid = "i"
	case year = "y"
	case month = "M"
	case day = "d"
	case hour = "h"
	case minute = "m"
	case space = "S"
}

enum DateComponent: Int {
	case month
	case year
}
