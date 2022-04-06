//
//  SingleSmartClean.swift
//  ECleaner
//
//  Created by alexey sorochan on 06.04.2022.
//

import UIKit
import Photos

class SmartCleanManager {
	
	private var photoManager = PhotoManager.shared
	private var fetchManager = PHAssetFetchManager.shared
	private var progressNotificationManager = ProgressSearchNotificationManager.instance
	
	
	let wholeCleanOperationQueuer = OperationProcessingQueuer(name: C.key.operation.queue.smartClean, maxConcurrentOperationCount: 3, qualityOfService: .background)
	
	let smarCleanOperationQueue = OperationProcessingQueuer(name: C.key.operation.queue.smartClean, maxConcurrentOperationCount: 3, qualityOfService: .background)
	
	public func startSmartCleanFetch(_ optionMediaType: [PhotoMediaType], lowerBoundDate: Date, upperBoundDate: Date,
									 handler: @escaping ([PhotoMediaType]) -> Void,
									 similarPhoto: @escaping ([PhassetGroup]) -> Void,
									 duplicatedPhoto: @escaping ([PhassetGroup]) -> Void,
									 screenShots: @escaping ([PHAsset]) -> Void,
									 similarSelfie: @escaping ([PhassetGroup]) -> Void,
									 livePhotos: @escaping ([PHAsset]) -> Void,
									 largeVideo: @escaping ([PHAsset]) -> Void,
									 duplicatedVideo: @escaping ([PhassetGroup]) -> Void,
									 similarVideo: @escaping ([PhassetGroup]) -> Void,
									 screenRecordings: @escaping ([PHAsset]) -> Void,
									 completionHandler: @escaping () -> Void) {
		
		var totalResultsCount = 0
		var operationQueueHandler: [ConcurrentProcessOperation] = []
		
//        MARK: - similar photoassets -
		let getSimilarPhotosAssetsOperation = photoManager.getSimilarPhotosAssetsOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { similarGroup in
			similarPhoto(similarGroup)
			totalResultsCount += 1
			if totalResultsCount == optionMediaType.count {
				completionHandler()
			}
		}
		getSimilarPhotosAssetsOperation.name = C.key.operation.name.similarPhotoProcessingOperation
		operationQueueHandler.append(getSimilarPhotosAssetsOperation)
		
//        MARK: - duplicated photo assets -
		let duplicatedPhotoAssetOperation = photoManager.getDuplicatedPhotosAsset(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { duplicateGroup in
			duplicatedPhoto(duplicateGroup)
			totalResultsCount += 1
			if totalResultsCount == optionMediaType.count {
				completionHandler()
			}
		}
		duplicatedPhotoAssetOperation.name = C.key.operation.name.duplicatePhotoProcessingOperation
		operationQueueHandler.append(duplicatedPhotoAssetOperation)
		
		
//		MARK: - screen shots photo assets =
		let screenShotosPhotoAssetOperation = photoManager.getScreenShotsOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { assets in
			screenShots(assets)
			totalResultsCount += 1
			if totalResultsCount == optionMediaType.count {
				completionHandler()
			}
		}
		screenShotosPhotoAssetOperation.name = C.key.operation.name.screenShotsOperation
		operationQueueHandler.append(screenShotosPhotoAssetOperation)
		
//		MARK: - simmiar selfie photo assets group -
		let similarSelfiesPhotoAssetOperation = photoManager.getSimilarSelfiePhotosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { similartSelfiesGroup in
			similarSelfie(similartSelfiesGroup)
			totalResultsCount += 1
			if totalResultsCount == optionMediaType.count {
				completionHandler()
			}
		}
		similarSelfiesPhotoAssetOperation.name = C.key.operation.name.similarSelfiesOperation
		operationQueueHandler.append(similarSelfiesPhotoAssetOperation)
		
//		MARK: - livephoto assets -
		let livePhotoAssetsOperation = photoManager.getLivePhotosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { assets in
			livePhotos(assets)
			totalResultsCount += 1
			if totalResultsCount == optionMediaType.count {
				completionHandler()
			}
		}
		livePhotoAssetsOperation.name = C.key.operation.name.livePhotoOperation
		operationQueueHandler.append(livePhotoAssetsOperation)
		
//		MARK: - large video -
		let largeVideoAssetsOperation = photoManager.getLargevideoContentOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { assets in
			largeVideo(assets)
			totalResultsCount += 1
			if totalResultsCount == optionMediaType.count {
				completionHandler()
			}
		}
		largeVideoAssetsOperation.name = C.key.operation.name.largeVideo
		operationQueueHandler.append(largeVideoAssetsOperation)
		
//        MARK: - duplicated video assets -
		let getDuplicatedVideoAssetOperation = photoManager.getDuplicatedVideoAssetOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { duplicatedVideoAsset in
			duplicatedVideo(duplicatedVideoAsset)
			totalResultsCount += 1
			if totalResultsCount == optionMediaType.count {
				completionHandler()
			}
		}
		getDuplicatedVideoAssetOperation.name = C.key.operation.name.duplicateVideoProcessingOperation
		operationQueueHandler.append(getDuplicatedVideoAssetOperation)
		
//        MARK: - similar videos assets -
		let getSimilarVideoAssetsOperation = photoManager.getSimilarVideoAssetsOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { similiarVideoAsset in
			similarVideo(similiarVideoAsset)
			totalResultsCount += 1
			if totalResultsCount == optionMediaType.count {
				completionHandler()
			}
		}
		getSimilarVideoAssetsOperation.name = C.key.operation.name.similarVideoProcessingOperation
		operationQueueHandler.append(getSimilarVideoAssetsOperation)
		
//        MARK: - screen recordings assets -
		let getScreenRecordsVideosOperation = photoManager.getScreenRecordsVideosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { screenRecordsAssets in
			screenRecordings(screenRecordsAssets)
			totalResultsCount += 1
			if totalResultsCount == optionMediaType.count {
				completionHandler()
			}
		}
		getScreenRecordsVideosOperation.name = C.key.operation.name.screenRecordingOperation
		operationQueueHandler.append(getScreenRecordsVideosOperation)
		
		
		for type in optionMediaType {
			if let operation = operationQueueHandler.first(where: {$0.name == type.cleanOperationName}) {
				smarCleanOperationQueue.addOperation(operation)
			}
		}
	}
	
	public func setCanceProcessingSmartCleaning() {
		smarCleanOperationQueue.cancelAll()
	}
}
