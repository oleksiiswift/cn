//
//  Utils+CoollectionViewDiff.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.08.2022.
//

import Foundation

extension Utils {
	
	struct LayoutManager {
		
		public static func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
			if old.intersects(new) {
				var added = [CGRect]()
				if new.maxY > old.maxY {
					added += [CGRect(x: new.origin.x, y: old.maxY,
									 width: new.width, height: new.maxY - old.maxY)]
				}
				if old.minY > new.minY {
					added += [CGRect(x: new.origin.x, y: new.minY,
									 width: new.width, height: old.minY - new.minY)]
				}
				var removed = [CGRect]()
				if new.maxY < old.maxY {
					removed += [CGRect(x: new.origin.x, y: new.maxY,
									   width: new.width, height: old.maxY - new.maxY)]
				}
				if old.minY < new.minY {
					removed += [CGRect(x: new.origin.x, y: old.minY,
									   width: new.width, height: new.minY - old.minY)]
				}
				return (added, removed)
			} else {
				return ([new], [old])
			}
		}
	}
}
