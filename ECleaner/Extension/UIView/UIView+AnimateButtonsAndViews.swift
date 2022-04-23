//
//  UIView+AnimateButtonsAndViews.swift
//  ECleaner
//
//  Created by alexey sorochan on 01.04.2022.
//

import UIKit

extension UIView {
	
	func animateButtonTransform() {
		
		UIView.animate(withDuration: 0.1) {
			self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
		} completion: { _ in
			UIView.animate(withDuration: 0.1) {
				self.transform = CGAffineTransform.identity
			} completion: { _ in }
		}
	}
}

