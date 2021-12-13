//
//  UILabel+Margin.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.12.2021.
//

import UIKit


extension UILabel {
	
	func setMargins(margin: CGFloat = 10) {
		if let textString = self.text {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.firstLineHeadIndent = margin
			paragraphStyle.headIndent = margin
			paragraphStyle.tailIndent = -margin
			let attributedString = NSMutableAttributedString(string: textString)
			attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
			attributedText = attributedString
		}
	}
	
	func leftMargin(margin: CGFloat = 10) {
		if let textString = self.text {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.firstLineHeadIndent = margin
			paragraphStyle.headIndent = margin
			paragraphStyle.alignment = .left
			let attributedString = NSMutableAttributedString(string: textString)
			attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
			attributedText = attributedString
		}
	}
	
	func rightMargin(margin: CGFloat = 10) {
		if let textString = self.text {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.tailIndent = -margin
			paragraphStyle.alignment = .right
			let attributedString = NSMutableAttributedString(string: textString)
			attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
			attributedText = attributedString
		}
	}
}
