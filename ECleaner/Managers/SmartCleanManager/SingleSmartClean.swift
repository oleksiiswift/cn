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
	
	public let smarCleanOperationQueue = OperationProcessingQueuer(name: C.key.operation.queue.smartClean, maxConcurrentOperationCount: 4, qualityOfService: .background)
	
	public func startSmartCleanFetch(_ scanOptions: [PhotoMediaType], lowerBoundDate: Date, upperBoundDate: Date,
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
									 completionHandler: @escaping (_ isCanceled: Bool) -> Void) {
		
		var totalResultsCount = 0
		var operationQueueHandler: [ConcurrentProcessOperation] = []
		
//        MARK: - similar photoassets -
		let getSimilarPhotosAssetsOperation = photoManager.getSimilarPhotosAssetsOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { similarGroup, isCancelled in
			similarPhoto(similarGroup)
			totalResultsCount += 1
			if totalResultsCount == scanOptions.count {
				completionHandler(isCancelled)
			}
		}
		
		operationQueueHandler.append(getSimilarPhotosAssetsOperation)
		
//        MARK: - duplicated photo assets -
		let duplicatedPhotoAssetOperation = photoManager.getDuplicatedPhotosAsset(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { duplicateGroup, isCancelled in
			duplicatedPhoto(duplicateGroup)
			totalResultsCount += 1
			if totalResultsCount == scanOptions.count {
				completionHandler(isCancelled)
			}
		}
		
		operationQueueHandler.append(duplicatedPhotoAssetOperation)
		
//		MARK: - screen shots photo assets =
		let screenShotosPhotoAssetOperation = photoManager.getScreenShotsOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { assets, isCancelled in
			screenShots(assets)
			totalResultsCount += 1
			if totalResultsCount == scanOptions.count {
				completionHandler(isCancelled)
			}
		}
		
		operationQueueHandler.append(screenShotosPhotoAssetOperation)
		
//		MARK: - simmiar selfie photo assets group -
		let similarSelfiesPhotoAssetOperation = photoManager.getSimilarSelfiePhotosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { similartSelfiesGroup, isCancelled in
			similarSelfie(similartSelfiesGroup)
			totalResultsCount += 1
			if totalResultsCount == scanOptions.count {
				completionHandler(isCancelled)
			}
		}
		
		operationQueueHandler.append(similarSelfiesPhotoAssetOperation)
		
//		MARK: - livephoto assets -
		let livePhotoAssetsOperation = photoManager.getLivePhotosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { assets, isCancelled in
			livePhotos(assets)
			totalResultsCount += 1
			if totalResultsCount == scanOptions.count {
				completionHandler(isCancelled)
			}
		}
		
		operationQueueHandler.append(livePhotoAssetsOperation)
		
//		MARK: - large video -
		let largeVideoAssetsOperation = photoManager.getLargevideoContentOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { assets, isCancelled in
			largeVideo(assets)
			totalResultsCount += 1
			if totalResultsCount == scanOptions.count {
				completionHandler(isCancelled)
			}
		}
		
		operationQueueHandler.append(largeVideoAssetsOperation)
		
//        MARK: - duplicated video assets -
		let getDuplicatedVideoAssetOperation = photoManager.getDuplicatedVideoAssetOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { duplicatedVideoAsset, isCancelled in
			duplicatedVideo(duplicatedVideoAsset)
			totalResultsCount += 1
			if totalResultsCount == scanOptions.count {
				completionHandler(isCancelled)
			}
		}
		
		operationQueueHandler.append(getDuplicatedVideoAssetOperation)
		
//        MARK: - similar videos assets -
		let getSimilarVideoAssetsOperation = photoManager.getSimilarVideoAssetsOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { similiarVideoAsset, isCancelled in
			similarVideo(similiarVideoAsset)
			totalResultsCount += 1
			if totalResultsCount == scanOptions.count {
				completionHandler(isCancelled)
			}
		}
		
		operationQueueHandler.append(getSimilarVideoAssetsOperation)
		
//        MARK: - screen recordings assets -
		let getScreenRecordsVideosOperation = photoManager.getScreenRecordsVideosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { screenRecordsAssets, isCancelled in
			screenRecordings(screenRecordsAssets)
			totalResultsCount += 1
			if totalResultsCount == scanOptions.count {
				completionHandler(isCancelled)
			}
		}
		
		operationQueueHandler.append(getScreenRecordsVideosOperation)
		
		for option in scanOptions {
			if let operation = operationQueueHandler.first(where: {$0.name == option.cleanOperationName}) {
				smarCleanOperationQueue.addOperation(operation)
			}
		}
	}
	
	public func setCanceProcessingSmartCleaning() {
		smarCleanOperationQueue.cancelAll()
	}
}
