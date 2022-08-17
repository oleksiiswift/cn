//
//  Localize+Count.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.06.2022.
//

import Foundation

extension String {
	func localizedWith(count: Int) -> String {
		return String.localizedStringWithFormat(NSLocalizedString(self, comment: ""), count)
	}
}
