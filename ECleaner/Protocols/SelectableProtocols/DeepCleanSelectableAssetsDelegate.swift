//
//  DeepCleanSelectableAssetsDelegate.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.03.2022.
//

import Foundation

protocol DeepCleanSelectableAssetsDelegate: AnyObject {
	 
	 func didSelect(assetsListIds: [String], contentType: PhotoMediaType, updatableGroup: [PhassetGroup], updatableAssets: [PHAsset], updatableContactsGroup: [ContactsGroup])
}
