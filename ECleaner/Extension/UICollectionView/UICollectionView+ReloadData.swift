//
//  UICollectionView+ReloadData.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.03.2022.
//

import UIKit

extension UICollectionView {
	
	func reloadDataWitoutAnimation() {
		
		UIView.performWithoutAnimation {
			reloadData()
		}
	}
	
	func reloadDataWithotAnimation(in section: IndexSet) {
		
		UIView.performWithoutAnimation {
			reloadSections(section)
		}
	}
	
	func smoothReloadData(completionHandler: (() -> Void)? = nil) {
		
		UIView.transition(with: self, duration: 0.35, options: .transitionCrossDissolve) {
			self.reloadData()
		} completion: { _ in
			completionHandler?()
		}
	}
}
