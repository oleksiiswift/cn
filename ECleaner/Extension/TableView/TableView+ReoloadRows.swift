//
//  TableView+ReoloadRows.swift
//  ECleaner
//
//  Created by alexey sorochan on 19.04.2022.
//

import Foundation

extension UITableView {
	
	func reloadRowWithoutAnimation(at indexPath: IndexPath) {
		UIView.performWithoutAnimation {
			self.reloadRows(at: [indexPath], with: .none)
		}
	}
}
