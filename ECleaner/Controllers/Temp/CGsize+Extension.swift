//
//  CGsize+Extension.swift
//  ECleaner
//
//  Created by alexey sorochan on 15.02.2022.
//

import UIKit

extension CGSize {
	var aspectRatio: CGFloat {
		return width / height
	}
}


public extension Optional {
	/**
	 *  Require this optional to contain a non-nil value
	 *
	 *  This method will either return the value that this optional contains, or trigger
	 *  a `preconditionFailure` with an error message containing debug information.
	 *
	 *  - parameter hint: Optionally pass a hint that will get included in any error
	 *                    message generated in case nil was found.
	 *
	 *  - return: The value this optional contains.
	 */
	func require(hint hintExpression: @autoclosure () -> String? = nil,
				 file: StaticString = #file,
				 line: UInt = #line) -> Wrapped {
		guard let unwrapped = self else {
			var message = "Required value was nil in \(file), at line \(line)"

			if let hint = hintExpression() {
				message.append(". Debugging hint: \(hint)")
			}

			#if !os(Linux)
			let exception = NSException(
				name: .invalidArgumentException,
				reason: message,
				userInfo: nil
			)

			exception.raise()
			#endif

			preconditionFailure(message)
		}

		return unwrapped
	}
}
