//
//  SimpleSelectableAssetsDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.03.2022.
//

import Foundation
import Photos

protocol SimpleSelectableAssetsDelegate: AnyObject {
	func didSelect(selectedIndexPath: [IndexPath], phasstsColledtion: [PHAsset])
}
