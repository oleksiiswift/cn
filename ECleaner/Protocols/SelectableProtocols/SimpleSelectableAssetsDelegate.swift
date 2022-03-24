//
//  SimpleSelectableAssetsDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.03.2022.
//

import Foundation

protocol SimpleSelectableAssetsDelegate: AnyObject {
	func didSelect(assetListsIDs: [String])
}
