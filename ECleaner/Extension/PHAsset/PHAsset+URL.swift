//
//  PHAsset+URL.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.03.2022.
//

import Foundation
import Photos

extension PHAsset {
	
	func getPhassetURL(completionHandler: @escaping ((_ responseURL: URL?) -> Void)) {
		
		switch self.mediaType {
			case .image:
				let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
				options.canHandleAdjustmentData = { (photoAdjustmentData: PHAdjustmentData) -> Bool in
					return true
				}
				
				self.requestContentEditingInput(with: options) { contentEditingInput, info in
					completionHandler(contentEditingInput?.fullSizeImageURL as URL?)
				}
			case .video:
				let options: PHVideoRequestOptions = PHVideoRequestOptions()
				options.version = .original
				PHImageManager.default().requestAVAsset(forVideo: self, options: options) { asset, audioMix, info in
					if let urlAsset = asset as? AVURLAsset {
						let assetURL: URL = urlAsset.url as URL
						completionHandler(assetURL)
					} else {
						completionHandler(nil)
					}
				}
			default:
				completionHandler(nil)
		}
	}
}
