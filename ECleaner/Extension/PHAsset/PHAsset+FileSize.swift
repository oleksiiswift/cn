//
//  PHAsset+FileSize.swift
//  ECleaner
//
//  Created by alexey sorochan on 04.12.2021.
//

import Photos


extension PHAsset {
	
	var imageSize: Int64 {
		
		let resources = PHAssetResource.assetResources(for: self)
		var fileDiskSpace: Int64 = 0
		
		if let resource = resources.first {
			if let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {
				fileDiskSpace = Int64(bitPattern: UInt64(unsignedInt64))
			}
		}
		return fileDiskSpace
	}
}
