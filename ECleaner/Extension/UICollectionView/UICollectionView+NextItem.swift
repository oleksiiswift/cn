//
//  UICollectionView+NextItem.swift
//  ECleaner
//
//  Created by alexey sorochan on 07.02.2022.
//

import UIKit

extension UICollectionView {
	func scrollToNextItem() {
		let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
		self.moveToFrame(contentOffset: contentOffset)
	}

	func scrollToPreviousItem() {
		let contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
		self.moveToFrame(contentOffset: contentOffset)
	}

	func moveToFrame(contentOffset : CGFloat) {
		self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
	}
}
