//
//  GroupSelectableAssetsDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.03.2022.
//

import Foundation

protocol GroupSelectableAssetsDelegate: AnyObject {
	func didSelect(assetListsIDs: [String])
}
