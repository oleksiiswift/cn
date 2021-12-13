//
//  PHAssetGroupModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.12.2021.
//

import Foundation
import Photos

class PhassetGroup {
	var name: String
	var assets: [PHAsset]
	
	init(name: String, assets: [PHAsset]) {
		self.name = name
		self.assets = assets
	}
}
