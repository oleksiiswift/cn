//
//  UICollectionView+IndexPath.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.01.2022.
//

import UIKit

extension UICollectionView {
	func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
		let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
		return allLayoutAttributes.filter({ $0.representedElementCategory == .cell }).map { $0.indexPath }
	}
}
