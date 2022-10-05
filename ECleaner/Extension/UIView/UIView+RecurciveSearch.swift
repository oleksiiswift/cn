//
//  UIView+RecurciveSearch.swift
//  ECleaner
//
//  Created by alexey sorochan on 11.12.2021.
//

import UIKit

extension UIView {
	
	func findViews<T: UIView>(subclassOf: T.Type) -> [T] {
		return recursiveSubviews.compactMap { $0 as? T }
	}
	
	var recursiveSubviews: [UIView] {
		return subviews + subviews.flatMap { $0.recursiveSubviews }
	}
}
