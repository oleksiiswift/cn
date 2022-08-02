//
//  AVUrlAsset.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.04.2022.
//

import AVFoundation

extension AVURLAsset {
	var fileSize: Int? {
		let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
		let resourceValues = try? url.resourceValues(forKeys: keys)

		return resourceValues?.fileSize ?? resourceValues?.totalFileSize
	}
}
