//
//  UILabel+HeightSize.swift
//  ECleaner
//
//  Created by alexey sorochan on 23.04.2022.
//

import Foundation

extension UILabel {
	
	func calculateTextHeight () -> CGFloat {
		
		let attributedText = NSAttributedString(string: self.text!, attributes: [NSAttributedString.Key.font: self.font as UIFont])
		let rect = attributedText.boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
		return ceil(rect.size.height)
	}
}

extension UILabel {
	var maxNumberOfLines: Int {
		let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
		let text = (self.text ?? "") as NSString
		let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font as UIFont], context: nil).height
		let lineHeight = font.lineHeight
		return Int(ceil(textHeight / lineHeight))
	}
}
