//
//  VideoCollectionViewModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 30.07.2022.
//

import Foundation
import Photos

class VideoCollectionViewModel {
	
	public let phassets: [PHAsset]
	
	init(phassets: [PHAsset]) {
		self.phassets = phassets
	}
}

extension VideoCollectionViewModel {
	
	public func numberOfSection() -> Int {
		return 1
	}
	
	public func numberOfRows(at section: Int) -> Int {
		return phassets.count
	}
	
	public func getPhasset(at indexPath: IndexPath) -> PHAsset {
		return phassets[indexPath.row]
	}
}
