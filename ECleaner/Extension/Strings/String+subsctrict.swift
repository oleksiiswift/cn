//
//  String+subsctrict.swift
//  ECleaner
//
//  Created by alexey sorochan on 04.08.2022.
//

import Foundation

extension String {

	func chopPrefix(_ count: Int = 1) -> String {
		if count >= 0 && count <= self.count {
			let indexStartOfText = self.index(self.startIndex, offsetBy: count)
			return String(self[indexStartOfText...])
		}
		return ""
	}

	func chopSuffix(_ count: Int = 1) -> String {
		if count >= 0 && count <= self.count {
			let indexEndOfText = self.index(self.endIndex, offsetBy: -count)
			return String(self[..<indexEndOfText])
		}
		return ""
	}
}
