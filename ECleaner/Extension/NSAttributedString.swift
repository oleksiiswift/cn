//
//  NSAttributedString.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.05.2022.
//

import Foundation


protocol AttributedStringComponent {
	var text: String { get }
	func getAttributes() -> [NSAttributedString.Key: Any]?
}

// MARK: String extensions

extension String: AttributedStringComponent {
	var text: String { self }
	func getAttributes() -> [NSAttributedString.Key: Any]? { return nil }
}

extension String {
	func toAttributed(with attributes: [NSAttributedString.Key: Any]?) -> NSAttributedString {
		.init(string: self, attributes: attributes)
	}
}

// MARK: NSAttributedString extensions

extension NSAttributedString: AttributedStringComponent {
	var text: String { string }

	func getAttributes() -> [Key: Any]? {
		if string.isEmpty { return nil }
		var range = NSRange(location: 0, length: string.count)
		return attributes(at: 0, effectiveRange: &range)
	}
}

extension NSAttributedString {

	convenience init?(from attributedStringComponents: [AttributedStringComponent],
					  defaultAttributes: [NSAttributedString.Key: Any],
					  joinedSeparator: String = " ") {
		switch attributedStringComponents.count {
		case 0: return nil
		default:
			var joinedString = ""
			typealias SttributedStringComponentDescriptor = ([NSAttributedString.Key: Any], NSRange)
			let sttributedStringComponents = attributedStringComponents.enumerated().flatMap { (index, component) -> [SttributedStringComponentDescriptor] in
				var components = [SttributedStringComponentDescriptor]()
				if index != 0 {
					components.append((defaultAttributes,
									   NSRange(location: joinedString.count, length: joinedSeparator.count)))
					joinedString += joinedSeparator
				}
				components.append((component.getAttributes() ?? defaultAttributes,
								   NSRange(location: joinedString.count, length: component.text.count)))
				joinedString += component.text
				return components
			}

			let attributedString = NSMutableAttributedString(string: joinedString)
			sttributedStringComponents.forEach { attributedString.addAttributes($0, range: $1) }
			self.init(attributedString: attributedString)
		}
	}
}
