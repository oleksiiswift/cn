//
//  SegmentDatePickerDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.12.2021.
//

import Foundation

protocol SegmentDatePickerDelegate {
	
	func datePicker(_ segmentDatePicker: SegmentDatePicker, didSelect row: Int, in component: Int)
}
