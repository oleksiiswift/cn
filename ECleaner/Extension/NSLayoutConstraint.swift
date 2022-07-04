//
//  NSLayoutConstraint.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.07.2022.
//

import Foundation

extension NSLayoutConstraint {
	/**
	 Change multiplier constraint

	 - parameter multiplier: CGFloat
	 - returns: NSLayoutConstraint
	*/
	func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {

		NSLayoutConstraint.deactivate([self])

		let newConstraint = NSLayoutConstraint(
			item: firstItem as Any,
			attribute: firstAttribute,
			relatedBy: relation,
			toItem: secondItem,
			attribute: secondAttribute,
			multiplier: multiplier,
			constant: constant)

		newConstraint.priority = priority
		newConstraint.shouldBeArchived = self.shouldBeArchived
		newConstraint.identifier = self.identifier

		NSLayoutConstraint.activate([newConstraint])
		return newConstraint
	}
}
