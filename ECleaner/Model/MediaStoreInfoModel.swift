//
//  MediaStoreInfoModel.swift
//  ECleaner
//
//  Created by alexey sorochan on 30.04.2022.
//

import Foundation

class MediaStoreInfoModel {
	var objects: [MediaContentType : MediaInfoContainerModel]
	
	var totalFilesProcesingCount: Int {
		return calculateTotalProcessingFilesCount()
	}
	
	var totalPhotoLibrarySizeCount: Int64 {
		return calculateTotalFilesSize()
	}
	
	init(objects: [MediaContentType : MediaInfoContainerModel]) {
		self.objects = objects
	}

	private func calculateTotalProcessingFilesCount() -> Int {
		return objects.map({$0.value.processingCurrentIndex}).sum()
	}
	
	private func calculateTotalFilesSize() -> Int64 {
		return objects.map({$0.value.sizeProcessingCount}).sum()
	}
	
	public func resetAllValues() {
		
		for (_, value) in objects {
			value.sizeProcessingCount = 0
			value.processingCurrentIndex = 0
		}
	}
}

class MediaInfoContainerModel {
	
	var contentType: MediaContentType
	
	var processingCurrentIndex: Int = 0
	var sizeProcessingCount: Int64 = 0
	var toralElementsInStore: Int = 0

	var indexPath: IndexPath {
		return contentType.mainScreenIndexPath
	}
	
	init(contentType: MediaContentType) {
		self.contentType = contentType
	}
	
	public func saveTotalSizeProcessing() {
		
		switch self.contentType {
			case .userPhoto:
				S.phassetPhotoFilesSizes = self.sizeProcessingCount
			case .userVideo:
				S.phassetVideoFilesSizes = self.sizeProcessingCount
			default:
				return
		}
	}
}
