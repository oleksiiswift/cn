//
//  PhotoManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 04.12.2021.
//

import Foundation
import PhotosUI
import Photos
import CocoaImageHashing
import AVKit

enum AssetsGroupType {
	case photo
	case screenShots
	case livePhotos
	case video
	case screenRecordings
}

enum CleaningEnabledNotification {
	case singleProcessing
	case deepCleaningProcessing
}

enum Strictness {
	case similar
	case closeToIdentical
}

	/// `getPhotoLibraryAccess` - use for access photo library alert and open settings
	/// `getPhotoLibrary` - fetch all photo assets in the user photo library and update values
	/// `getDuplicatedPhotosAsset`- finds duplicate photos in user photo library
	/// `getDuplicateVideoAsset` - load duplicated videos
	/// `getSimilarPhotosAsset` load simmilar photos
	/// `getSimilarLivePhotos` - load simmilar live photos
	/// `getScreenShots` `getSelfiePhotos` `getLivePhotos` -  fetch photos by type

		/**
		- parameter isDeepCleanScan in methods used for completion stay in background if `false` completion of methods needs move to main thread
		*/

class PhotoManager {
	
	static let shared: PhotoManager = {
		let instance = PhotoManager()
		return instance
	}()
	
	private var imageManager = PHImageManager()
	private var fetchManager = PHAssetFetchManager.shared
	public var prefetchManager = PHCachingImageManager()
	public lazy var requestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
        options.isSynchronous = false
		options.deliveryMode = .opportunistic
		options.resizeMode = .fast
		options.isNetworkAccessAllowed = true
		return options
	}()
	
	public lazy var requestAVOptions: PHVideoRequestOptions = {
		let options = PHVideoRequestOptions()
		options.isNetworkAccessAllowed = true
		options.deliveryMode = .fastFormat
		return options
	}()
	
	private var progressSearchNotificationManager = ProgressSearchNotificationManager.instance

	public let phassetProcessingOperationQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.phassets,
																			maxConcurrentOperationCount: 10,
																			qualityOfService: .background)
	public let serviceUtilityOperationsQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.utils,
																				  maxConcurrentOperationCount: 5,
																		  qualityOfService: .userInteractive)
    public let prefetchOperationQueue = OperationProcessingQueuer(name: C.key.operation.queue.preetchPHasssetQueue,
																  maxConcurrentOperationCount: 5,
																  qualityOfService: .background)
	
	var assetCollection: PHAssetCollection?
	
	private static let lowerDateValue: Date = S.defaultLowerDateValue
	private static let upperDateValue: Date = S.defaultUpperDateValue

	private var activePHAssetRequests: [String: PHImageRequestID] = [:]
	private var activeAVAssetRequests: [String: PHImageRequestID] = [:]
	
//		    MARK: - authentification -
	private func photoLibraryRequestAuth(completion: @escaping (_ status: Bool) -> Void ) {
		if #available(iOS 14, *) {
			PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
				switch status {
					case .notDetermined:
						debugPrint("notDetermined")
						completion(false)
					case .restricted:
						debugPrint("restricted")
						completion(false)
					case .denied:
						debugPrint("denied")
						completion(false)
					case .authorized:
						debugPrint("authorized")
						completion(true)
					case .limited:
						debugPrint("limited")
						completion(true)
					@unknown default:
						debugPrint("default")
				}
			}
		} else {
			if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
				completion(true)
			} else {
				PHPhotoLibrary.requestAuthorization { status in
					if status == PHAuthorizationStatus.authorized {
						completion(true)
					} else {
						completion(false)
					}
				}
			}
		}
	}
	
	public func checkPhotoLibraryAccess() {
		self.photoLibraryRequestAuth { accessGranted in
			if accessGranted {
				self.getPhotoLibraryContentAndCalculateSpace()
			} else {
				A.showResrictedAlert(by: .photoLibraryRestricted) {}
			}
		}
	}
	
	public func requestPhotoLibraryAccess(_ completion: @escaping () -> Void) {
		self.photoLibraryRequestAuth { accessGranted in
			accessGranted ? completion() : A.showResrictedAlert(by: .photoLibraryRestricted) {}
		}
	}
	
	public func saveVideoAsset(from url: URL, completionHandler: @escaping (_ identifier: String? ,_ isSaved: Bool) -> Void) {
		self.fetchManager.saveAVAsset(with: url) { identifier, completed, error in
			completionHandler(identifier, completed)
		}
	}
}

//	MARK: - INIT PHOTO LIBRARY -
extension PhotoManager {
	
	public func getPhotoLibraryContentAndCalculateSpace() {
		
		let lowerUpperDateOperation = self.fetchManager.getLowerUppedDateFromPhasset()
		let getCalculateTotalAVAssetsCountOperation = self.getCalculateTotalVideoPhassetOperation { totalVideoCount in
			UpdateContentDataBaseMediator.instance.updateContentStoreCount(mediaType: .userVideo, itemsCount: totalVideoCount, calculatedSpace: nil)
		}

		let getCalculateTotalPHAssetsCountOperation = self.getCalculateTotalPhotoPhassetOperation { totalPhotoCount in
			UpdateContentDataBaseMediator.instance.updateContentStoreCount(mediaType: .userPhoto, itemsCount: totalPhotoCount, calculatedSpace: nil)
		}
//			/// `add operation phasset`
		self.prefetchOperationQueue.addOperation(getCalculateTotalPHAssetsCountOperation)
		self.prefetchOperationQueue.addOperation(getCalculateTotalAVAssetsCountOperation)
			/// `calculate all sizes phassets`
		self.startPartitionalSizeCheck()
		self.prefetchOperationQueue.addOperation(lowerUpperDateOperation)
	}
	
	public func startPhotosizeCher() {
		let getPhotoLibraryPHAssetsEstimatedSizeOperation = self.getPhotoLibraryPHAssetsEstimatedSizeOperation { photosEstimatedSize, currentIndex, totalFilesCount in
			ProgressSearchNotificationManager.instance.sendSingleFilesCheckerNotification(notificationtype: .photosSizeCheckerType,
																						  currentIndex: currentIndex,
																						  totalFiles: totalFilesCount)
		} completionHandler: { photosCollectionSize in
			U.delay(3) {
				S.phassetPhotoFilesSizes = photosCollectionSize
				self.getTotalPHAssetSaved()
			}
		}
		self.serviceUtilityOperationsQueuer.addOperation(getPhotoLibraryPHAssetsEstimatedSizeOperation)
	}
	
	public func startVideSizeCher() {
		let getPhotoLibrararyAVAssetsEstimatedSizeOperation = self.getPhotoLibraryAVAssetsEstimatedSizeOperation { videoEsimatedSize, currentIndex, totalFilesCount in
			ProgressSearchNotificationManager.instance.sendSingleFilesCheckerNotification(notificationtype: .videosSizeCheckerType,
																						  currentIndex: currentIndex,
																						  totalFiles: totalFilesCount)
		} completionHandler: { videosCollectionSize in
			U.delay(3) {
				S.phassetVideoFilesSizes = videosCollectionSize
				self.getTotalPHAssetSaved()				
			}
		}
		
		self.serviceUtilityOperationsQueuer.addOperation(getPhotoLibrararyAVAssetsEstimatedSizeOperation)
	}
	
	public func startPartitionalSizeCheck() {
		
		let getPhotoLibraryPHAssetsEstimatedSizeOperation = self.getPhotoLibraryPHAssetsEstimatedSizeOperation { photosEstimatedSize, currentIndex, totalFilesCount in
			ProgressSearchNotificationManager.instance.sendSingleFilesCheckerNotification(notificationtype: .photosSizeCheckerType,
																						  currentIndex: currentIndex,
																						  totalFiles: totalFilesCount)
		} completionHandler: { photosCollectionSize in
			S.phassetPhotoFilesSizes = photosCollectionSize
			self.getTotalPHAssetSaved()
		}
		
		let getPhotoLibrararyAVAssetsEstimatedSizeOperation = self.getPhotoLibraryAVAssetsEstimatedSizeOperation { videoEsimatedSize, currentIndex, totalFilesCount in
			ProgressSearchNotificationManager.instance.sendSingleFilesCheckerNotification(notificationtype: .videosSizeCheckerType,
																						  currentIndex: currentIndex,
																						  totalFiles: totalFilesCount)
		} completionHandler: { videosCollectionSize in
			S.phassetVideoFilesSizes = videosCollectionSize
			self.getTotalPHAssetSaved()
		}

		self.serviceUtilityOperationsQueuer.addOperation(getPhotoLibraryPHAssetsEstimatedSizeOperation)
		self.serviceUtilityOperationsQueuer.addOperation(getPhotoLibrararyAVAssetsEstimatedSizeOperation)
	}
	
	public func stopEstimatedSizeProcessingOperations() {
		
		let photoOperationName = C.key.operation.name.phassetsEstimatedSizeOperation
		let videoOperationName = C.key.operation.name.avassetEstimatedSizeOperation
	
		self.serviceUtilityOperationsQueuer.cancelOperation(with: photoOperationName)
		self.serviceUtilityOperationsQueuer.cancelOperation(with: videoOperationName)
		self.cancelAllImageRquests()
	}
	
	private func getTotalPHAssetSaved() {
		
		S.phassetFilesSize = (S.phassetPhotoFilesSizes ?? 0) + (S.phassetVideoFilesSizes ?? 0)
	}
}

//		MARK: - PHOTO VIDEO SIZE OPERATION
extension PhotoManager {
	
	public func getPhotoLibraryPHAssetsEstimatedSizeOperation(estimatedComplitionHandler: @escaping (_ photosEstimatedSize: Int64,_ currentIndex: Int,_ totalFilesCount: Int) -> Void, completionHandler: @escaping (_ photosCollectionSize: Int64) -> Void) -> ConcurrentProcessOperation {
		
		let photolibraryOperation = ConcurrentProcessOperation { operation in
			let timer = ParkBenchTimer()
			var photoLibrararyPhotosSize: Int64 = 0
			var currentProcessingIndex = 0
			
			let options = PHImageRequestOptions()
			options.isSynchronous = true
			options.deliveryMode = .fastFormat
//			options.isNetworkAccessAllowed = true
		
			self.fetchManager.fetchPhotolibraryContent(by: .photo) { result in
				
				if result.count > 0 {
					result.enumerateObjects { object, index, stop in
						autoreleasepool {
							
							if operation.isCancelled {
								stop.pointee = true
								self.cancelAllImageRquests()
								completionHandler(0)
							}
							
//							let requestID = self.imageManager.requestImageDataAndOrientation(for: object, options: options) { data, _, _, _ in
								
								if operation.isCancelled {
									stop.pointee = true
									self.cancelAllImageRquests()
									completionHandler(0)
								} else if !self.serviceUtilityOperationsQueuer.operations.contains(operation) {
									if self.activePHAssetRequests.isEmpty {
										return
									}
								}
								autoreleasepool {
//									if let data = data {
//										let fileSize = Int64(bitPattern: UInt64(data.count))
//										photoLibrararyPhotosSize += fileSize
//										estimatedComplitionHandler(photoLibrararyPhotosSize, index, result.count)
//									} else {
										let fileSize = object.imageSize
									debugPrint(fileSize, index)
										photoLibrararyPhotosSize += fileSize
										estimatedComplitionHandler(photoLibrararyPhotosSize, index, result.count)
//									}
									currentProcessingIndex += 1
									if currentProcessingIndex == result.count {
										debugPrint("time -> \(timer.stop()), totalPhotoSize: \(U.getSpaceFromInt(photoLibrararyPhotosSize))")
										completionHandler(photoLibrararyPhotosSize)
									} else if index == result.count {
										debugPrint("time -> \(timer.stop()), totalPhotoSize: \(U.getSpaceFromInt(photoLibrararyPhotosSize))")
										completionHandler(photoLibrararyPhotosSize)
									}
								}
//							}
							
							if !operation.isCancelled {
//								self.activePHAssetRequests[object.localIdentifier] = requestID
							} else {
								completionHandler(0)
								return
							}
						}
					}
				} else {
					debugPrint("timer: \(timer.stop())")
					completionHandler(0)
				}
			}
		}
		photolibraryOperation.name = C.key.operation.name.phassetsEstimatedSizeOperation
		return photolibraryOperation
	}
	
	public func getPhotoLibraryAVAssetsEstimatedSizeOperation(estimatedComplition: @escaping (_ videoEsimatedSize: Int64,_ currentIndex: Int,_ totalFilesCount: Int) -> Void,
															  completionHandler: @escaping (_ videosCollectionSize: Int64) -> Void) -> ConcurrentProcessOperation {
		let photoLibraryOperation = ConcurrentProcessOperation { operation in
			
			let timer = ParkBenchTimer()
			var photoLibrararyVideosSize: Int64 = 0
			var currentProcessingIndex = 0
			
			let options = PHVideoRequestOptions()
			options.deliveryMode = .highQualityFormat
//			options.isNetworkAccessAllowed = true
			
			self.fetchManager.fetchPhotolibraryContent(by: .video) { result in
				if result.count > 0 {
					
					result.enumerateObjects { object, index, stop in
						
						autoreleasepool {
							
							if operation.isCancelled {
								self.cancelAllImageRquests()
								completionHandler(0)
								stop.pointee = true
							}
							
//							let requestID = self.imageManager.requestAVAsset(forVideo: object, options: options) { avasset, _, _ in
								if operation.isCancelled {
									self.cancelAllImageRquests()
									completionHandler(0)
									stop.pointee = true
								} else if !self.serviceUtilityOperationsQueuer.operations.contains(operation) {
									if self.activeAVAssetRequests.isEmpty {
										return
									}
								}
								
//								if let avasset = avasset as? AVURLAsset {
//									if let data = try? Data(contentsOf: avasset.url, options: .mappedIfSafe) {
//										let fileSize = Int64(bitPattern: UInt64(data.count))
//										photoLibrararyVideosSize += fileSize
//										estimatedComplition(fileSize, index, result.count)
//									} else {
//										debugPrint("size")
//										let filetSize = object.imageSize
//										photoLibrararyVideosSize += filetSize
//										estimatedComplition(photoLibrararyVideosSize, index, result.count)
//									}
//								} else {
									let filetSize = object.imageSize
									debugPrint(filetSize, index)
									photoLibrararyVideosSize += filetSize
									estimatedComplition(photoLibrararyVideosSize, index, result.count)
//								}
								
								currentProcessingIndex += 1
								
								if currentProcessingIndex == result.count {
									debugPrint("timer -> \(timer.stop()), totalVideoSize: \(U.getSpaceFromInt(photoLibrararyVideosSize))")
									completionHandler(photoLibrararyVideosSize)
								} else if index == result.count {
									debugPrint("timer -> \(timer.stop()), totalVideoSize: \(U.getSpaceFromInt(photoLibrararyVideosSize))")
									completionHandler(photoLibrararyVideosSize)
								}
//							}
							
							if !operation.isCancelled {
//								self.activeAVAssetRequests[object.localIdentifier] = requestID
							} else {
								completionHandler(0)
								return
							}
						}
					}
				} else {
					debugPrint("timer \(timer.stop())")
					completionHandler(0)
				}
			}
		}
		photoLibraryOperation.name = C.key.operation.name.avassetEstimatedSizeOperation
		return photoLibraryOperation
	}
	
	private func cancelAllImageRquests() {
		
		for requestID in self.activePHAssetRequests.values {
			imageManager.cancelImageRequest(requestID)
		}
		self.activePHAssetRequests.removeAll()
		
		for requestID in self.activeAVAssetRequests.values {
			imageManager.cancelImageRequest(requestID)
		}
		self.activeAVAssetRequests.removeAll()
	}
	
	private func didCancelPHAssetRequests() {
		for requestID in self.activePHAssetRequests.values {
			imageManager.cancelImageRequest(requestID)
		}
	}
	
	private func didCancelAVAssetRequests() {
		for requestID in self.activeAVAssetRequests.values {
			imageManager.cancelImageRequest(requestID)
		}
	}
	
	private func clearPHAssetRequests() {
		self.activePHAssetRequests.removeAll()
	}
	
	private func clearAVAssetRequests() {
		self.activeAVAssetRequests.removeAll()
	}
	
	public func clearRequestsAfterDeepCleanProcessing() {
		self.clearAVAssetRequests()
		self.clearPHAssetRequests()
	}

	
	
	
	public func getPHAssetFileSizeFromData(_ asset: PHAsset, completionHandler: @escaping (_ fileSize: Int64) -> Void) {
		
		let options = PHImageRequestOptions()
		options.isSynchronous = false
		options.deliveryMode = .highQualityFormat
		options.isNetworkAccessAllowed = true
		
		let requestID = self.imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
			
			if let data = data {
				let fileSize = Int64(bitPattern: UInt64(data.count))
				completionHandler(fileSize)
			} else {
				let fileSize = asset.imageSize
				completionHandler(fileSize)
			}
		}
		DispatchQueue.main.async {
			self.activePHAssetRequests[asset.localIdentifier] = requestID
		}
	}
	
	public func getAVAssetFileSizeFromData(_ asset: PHAsset, completionHandler: @escaping (_ fileSize: Int64) -> Void)  {
		
		let options = PHVideoRequestOptions()
		options.deliveryMode = .highQualityFormat
		options.isNetworkAccessAllowed = true
		
		let requestID = self.imageManager.requestAVAsset(forVideo: asset, options: options) { avasset, _, _ in
			if let avasset = avasset as? AVURLAsset {
				if let data = try? Data(contentsOf: avasset.url, options: .mappedIfSafe) {
					let fileSize = Int64(bitPattern: UInt64(data.count))
					completionHandler(fileSize)
				} else {
					let fileSize = asset.imageSize
					completionHandler(fileSize)
				}
			} else {
				let fileSize = asset.imageSize
				completionHandler(fileSize)
			}
		}
		DispatchQueue.main.async {
			self.activeAVAssetRequests[asset.localIdentifier] = requestID
		}
	}
}


//	MARK: - VIDEO PROCESSING -
extension PhotoManager {
	
	public func getLargevideoContentOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ((_ assets: [PHAsset],_ isCancelled: Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let largeVideoProcessingOperation = ConcurrentProcessOperation { operation in
			
			let deleyInterval: Double = cleanProcessingType == .background ? 0 : 1
			let sleepInterval: UInt32 = cleanProcessingType == .background ? 0 : 1
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
				
				var videos: [PHAsset] = []
				
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .largeVideo, singleCleanType: .largeVideo, status: .prepare, totalItems: 0, currentIndex: 0)
				sleep(sleepInterval)
				
				if videoContent.count != 0 {
					for videosPosition in 1...videoContent.count {
						
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .largeVideo, singleCleanType: .largeVideo)
							completionHandler([], operation.isCancelled)
							return
						}
						
						let fileSize = videoContent[videosPosition - 1].imageSize
					
						if fileSize > SettingsManager.largeVideoLowerSize {
							videos.append(videoContent[videosPosition - 1])
						}
						
						if cleanProcessingType == .deepCleen {
							self.sendFileSizeNotification(type: .videoFilesSize, totalFiles: videoContent.count, currentIndex: videosPosition, fileSize: fileSize)
						}
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .largeVideo, singleCleanType: .largeVideo, status: .progress, totalItems: videoContent.count, currentIndex: videosPosition)
					}
					self.sendNotification(processing: cleanProcessingType, deepCleanType: .largeVideo, singleCleanType: .largeVideo, status: .result, totalItems: videoContent.count, currentIndex: videoContent.count)
					U.delay(deleyInterval) {
						completionHandler(videos, operation.isCancelled)
					}
				} else {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .largeVideo, singleCleanType: .largeVideo)
					U.delay(deleyInterval) {
						completionHandler([], operation.isCancelled)
					}
				}
			}
		}
		largeVideoProcessingOperation.name = CommonOperationSearchType.largeVideoContentOperation.rawValue
		return largeVideoProcessingOperation
	}
	
		/// `screen recordings` from gallery
	public func getScreenRecordsVideosOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ((_ screenRecordsAssets: [PHAsset],_ isCancelled: Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let screenRecordsVideosOperation = ConcurrentProcessOperation { operation in
			
			let deleyInterval: Double = cleanProcessingType == .background ? 0 : 1
			let sleepInterval: UInt32 = cleanProcessingType == .background ? 0 : 1
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoAssets in
				
				var screenRecords: [PHAsset] = []
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .screenRecordings, singleCleanType: .screenRecordings, status: .prepare, totalItems: 0, currentIndex: 0)
				sleep(sleepInterval)
				if videoAssets.count != 0 {
					
					for videosPosition in 1...videoAssets.count {
						
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .screenRecordings, singleCleanType: .screenRecordings)
							completionHandler([], operation.isCancelled)
							return
						}
					
						let asset = videoAssets[videosPosition - 1]
						
						if let assetResource = PHAssetResource.assetResources(for: asset).first {
							if assetResource.originalFilename.contains("RPReplay") {
								screenRecords.append(asset)
							}
						}
						
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .screenRecordings, singleCleanType: .screenRecordings, status: .progress, totalItems: videoAssets.count, currentIndex: videosPosition)
					}
					U.delay(deleyInterval) {
						completionHandler(screenRecords, operation.isCancelled)
					}
				} else {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .screenRecordings, singleCleanType: .screenRecordings)
					U.delay(deleyInterval) {
						completionHandler([], operation.isCancelled)
					}
				}
			}
		}
		screenRecordsVideosOperation.name = CommonOperationSearchType.screenRecordingsVideoOperation.rawValue
		return screenRecordsVideosOperation
	}
}

//		MARK: - VIDEO SIMILAR DUPLICATED PROCESSING -
extension PhotoManager {
	
		/// `similar Videos` from gallery
	public func getSimilarVideoAssetsOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, cleanProcessingType: CleanProcessingPresentType,  completionHandler: @escaping ((_ videoAssets: [PhassetGroup],_ isCancelled: Bool) -> Void)) -> ConcurrentProcessOperation
	{
	
	let similarVideoAssetsOperation = ConcurrentProcessOperation { operation in
		
		self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
			
			var assets: [PHAsset] = []
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarVideo, singleCleanType: .similarVideo, status: .prepare, totalItems: 0, currentIndex: 0)
			sleep(1)
			
			if videoContent.count != 0 {
				
				for videoPosition in 1...videoContent.count {
					if operation.isCancelled {
						self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarVideo, singleCleanType: .similarVideo)
						completionHandler([], operation.isCancelled)
						return
					}
					let asset = videoContent[videoPosition - 1]
					assets.append(asset)
					self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarVideo, singleCleanType: .similarVideo, status: .analyzing, totalItems: 0, currentIndex: 0)
				}
				let similarVideoPhassetOperation = self.findDuplicatedVideoOperation(assets: assets, strictness: .similar, cleanProcessingType: cleanProcessingType, operation: operation) { phassetCroup, isCancelled in
					U.delay(1) {
						completionHandler(phassetCroup, isCancelled)
					}
				}
				
				self.phassetProcessingOperationQueuer.addOperation(similarVideoPhassetOperation)
				
			} else {
				self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarVideo, singleCleanType: .similarVideo)
				U.delay(1) {
					completionHandler([], operation.isCancelled)
				}
			}
		}
	}
	similarVideoAssetsOperation.name = CommonOperationSearchType.similarVideoAssetsOperation.rawValue
	return similarVideoAssetsOperation
	}
	
		/// `duplicated videos compare algorithm`
	public func getDuplicatedVideoAssetOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ((_ videoAssets: [PhassetGroup],_ isCancelled: Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let duplicatedVideoAssetsOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate,
											   to: upperDate,
											   collectiontype: .smartAlbumVideos,
											   by: PHAssetMediaType.video.rawValue) { videoCollection in
				var videos: [OSTuple<NSString, NSData>] = []
				
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicateVideo, singleCleanType: .duplicatedVideo, status: .prepare, totalItems: 0, currentIndex: 0)
				sleep(1)
				
				if videoCollection.count != 0 {
					for index in 1...videoCollection.count {
						
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicateVideo, singleCleanType: .duplicatedVideo)
							completionHandler([], operation.isCancelled)
							self.didCancelAVAssetRequests()
							return
						}
						

						let image = self.fetchManager.getThumbnail(from: videoCollection[index - 1], size: CGSize(width: 150, height: 150))
						if let data = image.jpegData(compressionQuality: 0.8) {
							let imageTuple = OSTuple<NSString, NSData>(first: "image\(index)" as NSString, andSecond: data as NSData)
							videos.append(imageTuple)
						}
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicateVideo, singleCleanType: .duplicatedVideo, status: .progress, totalItems: videoCollection.count, currentIndex: index)
					}
					
					self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicateVideo, singleCleanType: .duplicatedVideo, status: .compare, totalItems: 0, currentIndex: 0)
					let duplicateVideoIDasTuples = OSImageHashing.sharedInstance().similarImages(withProvider: .pHash, forImages: videos)
					var duplicateVideoNumbers: [Int] = []
					var duplicateVideoGroups: [PhassetGroup] = []
					
					guard duplicateVideoIDasTuples.count >= 1 else {
						self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicateVideo, singleCleanType: .duplicatedVideo)
						completionHandler([], operation.isCancelled)
						return
					}
					
					for index in 1...duplicateVideoIDasTuples.count {
						
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicateVideo, singleCleanType: .duplicatedVideo)
							completionHandler([], operation.isCancelled)
							self.didCancelAVAssetRequests()
							return
						}
						
						let tuple = duplicateVideoIDasTuples[index - 1]
						var groupAssets: [PHAsset] = []
						if let first = tuple.first as String?, let second = tuple.second as String? {
							let firstInteger = first.replacingStringAndConvertToIntegerForImage() - 1
							let secondInteger = second.replacingStringAndConvertToIntegerForImage() - 1
							
							if abs(secondInteger - firstInteger) >= 10 { continue }
							if !duplicateVideoNumbers.contains(firstInteger) {
								duplicateVideoNumbers.append(firstInteger)
								groupAssets.append(videoCollection[firstInteger])
							}
							
							if !duplicateVideoNumbers.contains(secondInteger) {
								duplicateVideoNumbers.append(secondInteger)
								groupAssets.append(videoCollection[secondInteger])
							}
							
							duplicateVideoIDasTuples.filter({$0.first != nil && $0.second != nil}).filter({ $0.first == tuple.first || $0.first == tuple.second || $0.second == tuple.second || $0.second == tuple.first }).forEach({ tuple in
								
								if operation.isCancelled {
									self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicateVideo, singleCleanType: .duplicatedVideo)
									completionHandler([], operation.isCancelled)
									self.didCancelAVAssetRequests()
									return
								}
								
								if let firstTuple = tuple.first as String?, let secondTuple = tuple.second as String? {
									let firstTupleInteger = firstTuple.replacingStringAndConvertToIntegerForImage() - 1
									let secondTupleInteger = secondTuple.replacingStringAndConvertToIntegerForImage() - 1
									
									if abs(secondTupleInteger - firstTupleInteger) >= 10 {
										return
									}
									
									if !duplicateVideoNumbers.contains(firstTupleInteger) {
										duplicateVideoNumbers.append(firstTupleInteger)
										groupAssets.append(videoCollection[firstTupleInteger])
									}
									
									if !duplicateVideoNumbers.contains(secondTupleInteger) {
										duplicateVideoNumbers.append(secondTupleInteger)
										groupAssets.append(videoCollection[secondInteger])
									}
								}
							})
							
							if groupAssets.count >= 2 {
								duplicateVideoGroups.append(PhassetGroup(name: "", assets: groupAssets, creationDate: groupAssets.first?.creationDate))
							}
							
							self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicateVideo, singleCleanType: .duplicatedVideo, status: .compare, totalItems: duplicateVideoIDasTuples.count, currentIndex: duplicateVideoIDasTuples.count)
						}
					}
					self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicateVideo, singleCleanType: .duplicatedVideo, status: .result, totalItems: duplicateVideoIDasTuples.count, currentIndex: duplicateVideoIDasTuples.count)
					U.delay(1) {
						completionHandler(duplicateVideoGroups, operation.isCancelled)
					}
				} else {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicateVideo, singleCleanType: .duplicatedVideo)
					U.delay(1) {
						completionHandler([], operation.isCancelled)
					}
				}
			}
		}
		duplicatedVideoAssetsOperation.name = CommonOperationSearchType.duplicatedVideoAssetOperation.rawValue
		return duplicatedVideoAssetsOperation
	}
	
		/// `similar videos by time stamp`
	public func getSimilarVideosByTimeStampOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
		
		let similarVideosByTimeStampOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
				
				var assets: [PHAsset] = []
				var grouped: [PhassetGroup] = []
				
				if videoContent.count != 0 {
					
					for videoPosition in 1...videoContent.count {
						assets.append(videoContent[videoPosition - 1])
					}
					
					for video in assets {
						
						if operation.isCancelled {
							completionHandler([])
							return
						}
						
						var compareAsset: [PHAsset] = []
						debugPrint("->>>>>>>>>>")
						debugPrint(video.localIdentifier)
						
						for check in assets {
							
							if operation.isCancelled {
								completionHandler([])
								return
							}
						
							debugPrint("........")
							debugPrint(check.localIdentifier)
							if video.localIdentifier != check.localIdentifier {
								if video.duration == check.duration && video.creationDate == check.creationDate {
									compareAsset.append(video)
									compareAsset.append(check)
								} else {
									
								}
							}
						}
						if compareAsset.count != 0 {
							grouped.append(PhassetGroup.init(name: "", assets: compareAsset, creationDate: compareAsset.first?.creationDate))
						}
					}
					completionHandler(grouped.isEmpty ? [] : grouped)
				} else {
					completionHandler([])
				}
			}
		}
		similarVideosByTimeStampOperation.name = C.key.operation.name.getSimilarVideosByTimeStampOperation
		return similarVideosByTimeStampOperation
	}
}


//		MARK: - PHOTO PROCESSING -
extension PhotoManager {
	
		/// `load selfies` from gallery
	
	public func getSimilarSelfiePhotosOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ((_ similartSelfiesGroup: [PhassetGroup],_ isCanceled: Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let similarSelfiesProcessingOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumSelfPortraits, by: PHAssetMediaType.image.rawValue) { photosInGallery in
				
				var group: [PhassetGroup] = []
				var containsAdd: [Int] = []
				var similarPhotos: [(asset: PHAsset, date: Int64, imageSize: Int64)] = []
				
				similarPhotos.reserveCapacity(photosInGallery.count)
				
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarSelfiePhotos, singleCleanType: .similarSelfiesPhoto, status: .prepare, totalItems: 0, currentIndex: 0)
				sleep(1)
				
				if photosInGallery.count != 0 {
					
					for index in 1...photosInGallery.count {
							
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarSelfiePhotos, singleCleanType: .similarSelfiesPhoto)
							completionHandler([], operation.isCancelled)
							return
						}
						
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarSelfiePhotos, singleCleanType: .similarSelfiesPhoto, status: .analyzing, totalItems: 0, currentIndex: 0)
						similarPhotos.append((asset: photosInGallery[index - 1],
											  date: Int64(photosInGallery[index - 1].creationDate!.timeIntervalSince1970),
											  imageSize: photosInGallery[index - 1].imageSize))
					}
					
					similarPhotos.sort { similarPhotoNumberOne, similarPhotoNumberTwo in
						return similarPhotoNumberOne.date > similarPhotoNumberTwo.date
					}
					
					for index in 0...similarPhotos.count - 1 {
						
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarSelfiePhotos, singleCleanType: .similarSelfiesPhoto)
							completionHandler([], operation.isCancelled)
							return
						}
						
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarSelfiePhotos, singleCleanType: .similarSelfiesPhoto, status: .progress, totalItems: similarPhotos.count, currentIndex: index)
						var similarIndex = index + 1
						if containsAdd.contains(index) { continue }
						var similar: [PHAsset] = []
						
						if (similarIndex < similarPhotos.count && abs(similarPhotos[index].date - similarPhotos[similarIndex].date) <= 10) {
							similar.append(similarPhotos[index].asset)
							containsAdd.append(index)
							repeat {
								if containsAdd.contains(similarIndex) {
									continue
								}
								similar.append(similarPhotos[similarIndex].asset)
								containsAdd.append(similarIndex)
								similarIndex += 1
							} while similarIndex < similarPhotos.count && abs(similarPhotos[index].date - similarPhotos[similarIndex].date) <= 10
						}
						if similar.count != 0 {
							let date = similar.first?.creationDate
							group.append(PhassetGroup(name: "", assets: similar, creationDate: date))
						}
					}
					self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarSelfiePhotos, singleCleanType: .similarSelfiesPhoto, status: .result, totalItems: similarPhotos.count, currentIndex: similarPhotos.count)
					U.delay(1) {
						completionHandler(group, operation.isCancelled)
					}
				} else {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarSelfiePhotos, singleCleanType: .similarSelfiesPhoto)
					U.delay(1) {
						completionHandler([], operation.isCancelled)
					}
				}
			}
		}
		similarSelfiesProcessingOperation.name = CommonOperationSearchType.similarSelfiesAssetsOperation.rawValue
		return similarSelfiesProcessingOperation
	}
		
		/// `load screenshots` from gallery
	public func getScreenShotsOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ((_ assets: [PHAsset],_ isCancelled: Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let getScreenShotsOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumScreenshots, by: PHAssetMediaType.image.rawValue) { screensShotsLibrary in
				
				let deleyInterval: Double = cleanProcessingType == .background ? 0 : 1
				let sleepInterval: UInt32 = cleanProcessingType == .background ? 0 : 1
				
				var screens: [PHAsset] = []
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .screenshots, singleCleanType: .screenShots, status: .prepare, totalItems: 0, currentIndex: 0)
				
				sleep(sleepInterval)
				
				if screensShotsLibrary.count != 0 {
					
					for screensPos in 1...screensShotsLibrary.count {
						
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .screenshots, singleCleanType: .screenShots)
							completionHandler([], operation.isCancelled)
							return
						}
						
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .screenshots, singleCleanType: .screenShots, status: .progress, totalItems: screensShotsLibrary.count, currentIndex: screensPos)
						screens.append(screensShotsLibrary[screensPos - 1])
					}
					self.sendNotification(processing: cleanProcessingType, deepCleanType: .screenshots, singleCleanType: .screenShots, status: .result, totalItems: screensShotsLibrary.count, currentIndex: screensShotsLibrary.count)
					U.delay(deleyInterval) {
						completionHandler(screens, operation.isCancelled)
					}
				} else {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .screenshots, singleCleanType: .screenShots)
					U.delay(deleyInterval) {
						completionHandler([], operation.isCancelled)
					}
				}
			}
		}
		getScreenShotsOperation.name = CommonOperationSearchType.screenShotsAssetsOperation.rawValue
		return getScreenShotsOperation
	}
	
			/// `load live photos` from gallery
	public func getLivePhotosOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ((_ assets: [PHAsset],_ isCancelled: Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let livePhotoOperation = ConcurrentProcessOperation { operation in

			let deleyInterval: Double = cleanProcessingType == .background ? 0 : 1
			let sleepInterval: UInt32 = cleanProcessingType == .background ? 0 : 1
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotosLibrary in
				
				var livePhotos: [PHAsset] = []
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .none, singleCleanType: .livePhoto, status: .prepare, totalItems: 0, currentIndex: 0)
				sleep(sleepInterval)
				
				if livePhotosLibrary.count != 0 {
					
					
					for livePhotoPosition in 1...livePhotosLibrary.count {
						
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .none, singleCleanType: .livePhoto)
							completionHandler([], operation.isCancelled)
							return
						}
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .none, singleCleanType: .livePhoto, status: .progress, totalItems: livePhotosLibrary.count, currentIndex: livePhotoPosition)
						livePhotos.append(livePhotosLibrary[livePhotoPosition - 1])
					}
					self.sendNotification(processing: cleanProcessingType, deepCleanType: .none, singleCleanType: .livePhoto, status: .result, totalItems: livePhotosLibrary.count, currentIndex: livePhotosLibrary.count)
					U.delay(deleyInterval) {
						completionHandler(livePhotos, operation.isCancelled)
					}
				} else {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .none, singleCleanType: .livePhoto)
					U.delay(deleyInterval) {
						completionHandler([], operation.isCancelled)
					}
				}
			}
		}
		livePhotoOperation.name = CommonOperationSearchType.livePhotoAssetsOperation.rawValue
		return livePhotoOperation
	}
}

//		MARK: - PHOTO DUPLICATE SIMILAR PROCESSING -
extension PhotoManager {
	
		/// `simmilar photo algoritm`
	public func getSimilarPhotosAssetsOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, fileSizeCheck: Bool = false, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ((_ assets: [PhassetGroup],_ isCancelled: Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let similarPhotoProcessingOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photosInGallery in
				
				var group: [PhassetGroup] = []
				var containsAdd: [Int] = []
				var similarPhotos: [(asset: PHAsset, date: Int64, imageSize: Int64)] = []
				
				similarPhotos.reserveCapacity(photosInGallery.count)
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarPhoto, singleCleanType: .similarPhoto, status: .prepare, totalItems: 0, currentIndex: 0)
				sleep(1)
				
				if photosInGallery.count != 0 {
					
					for index in 1...photosInGallery.count {
							
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarPhoto, singleCleanType: .similarPhoto)
							completionHandler([], operation.isCancelled)
							self.didCancelPHAssetRequests()
							return
						}

						self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarPhoto, singleCleanType: .similarPhoto, status: .analyzing, totalItems: 0, currentIndex: 0)
						
						if cleanProcessingType == .deepCleen {
							let op = ConcurrentProcessOperation { filesCheckerOperation in
								let fileSize = photosInGallery[index - 1].imageSize
//								self.getPHAssetFileSizeFromData(photosInGallery[index - 1]) { fileSize in
									self.sendFileSizeNotification(type: .photoFilesSize, totalFiles: photosInGallery.count, currentIndex: index, fileSize: fileSize)
//								}
							}
							self.serviceUtilityOperationsQueuer.addOperation(op)
						}
						
						similarPhotos.append((asset: photosInGallery[index - 1],
											  date: Int64(photosInGallery[index - 1].creationDate!.timeIntervalSince1970),
											  imageSize: fileSizeCheck ? photosInGallery[index - 1].imageSize : 0))
					}
					
					similarPhotos.sort { similarPhotoNumberOne, similarPhotoNumberTwo in
						return similarPhotoNumberOne.date > similarPhotoNumberTwo.date
					}
					
					for index in 0...similarPhotos.count - 1 {
						
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarPhoto, singleCleanType: .similarPhoto)
							completionHandler([], operation.isCancelled)
							self.didCancelPHAssetRequests()
							return
						}
						
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarPhoto, singleCleanType: .similarPhoto, status: .progress, totalItems: similarPhotos.count, currentIndex: index)
						
						var similarIndex = index + 1
						if containsAdd.contains(index) { continue }
						var similar: [PHAsset] = []
						
						if (similarIndex < similarPhotos.count && abs(similarPhotos[index].date - similarPhotos[similarIndex].date) <= 10) {
							similar.append(similarPhotos[index].asset)
							containsAdd.append(index)
							repeat {
								if containsAdd.contains(similarIndex) {
									continue
								}
								similar.append(similarPhotos[similarIndex].asset)
								containsAdd.append(similarIndex)
								similarIndex += 1
							} while similarIndex < similarPhotos.count && abs(similarPhotos[index].date - similarPhotos[similarIndex].date) <= 10
						}
						if similar.count != 0 {
							let date = similar.first?.creationDate
							group.append(PhassetGroup(name: "", assets: similar, creationDate: date))
						}
					}
					self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarPhoto, singleCleanType: .similarPhoto, status: .result, totalItems: similarPhotos.count, currentIndex: similarPhotos.count)
					U.delay(1) {
						completionHandler(group, operation.isCancelled)
					}
				} else {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarPhoto, singleCleanType: .similarPhoto)
					U.delay(1) {
						completionHandler([], operation.isCancelled)
					}
				}
			}
		}
		similarPhotoProcessingOperation.name = CommonOperationSearchType.similarPhotoAssetsOperaton.rawValue
		return similarPhotoProcessingOperation
	}
	
		/// `load simmiliar live photo` from gallery
	public func getSimilarLivePhotosOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ((_ assets: [PhassetGroup],_ isCancelled: Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let similarLivePhotoProcessingOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotoGallery in
				
				var livePhotos: [OSTuple<NSString, NSData>] = []
				
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarLivePhoto, singleCleanType: .similarLivePhoto, status: .prepare, totalItems: 0, currentIndex: 0)
				sleep(1)
				
				if livePhotoGallery.count != 0 {
					for livePosition in 1...livePhotoGallery.count {
						
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarLivePhoto, singleCleanType: .similarLivePhoto)
							completionHandler([], operation.isCancelled)
							return
						}
						
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarLivePhoto, singleCleanType: .similarLivePhoto, status: .compare, totalItems: 0, currentIndex: 0)
						
						let image = self.fetchManager.getThumbnail(from: livePhotoGallery[livePosition - 1], size: CGSize(width: 150, height: 150))
						if let data = image.jpegData(compressionQuality: 0.8) {
							let tuple = OSTuple<NSString, NSData>(first: "image\(livePosition)" as NSString, andSecond: data as NSData)
							livePhotos.append(tuple)
						}
					}
					
					let duplicatedTuplesOperation = self.getDuplicatedTuplesOperation(for: livePhotos, photosInGallery: livePhotoGallery, deepCleanType: .similarLivePhoto, singleCleanType: .similarLivePhoto, cleanProcessingType: cleanProcessingType) { similarLivePhotoGroup, isCancelled in
						U.delay(1) {
							completionHandler(similarLivePhotoGroup, isCancelled)
						}
					}
					
					self.phassetProcessingOperationQueuer.addOperation(duplicatedTuplesOperation)
					
				} else {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarLivePhoto, singleCleanType: .similarLivePhoto)
					U.delay(1) {
						completionHandler([], operation.isCancelled)
					}
				}
			}
		}
		similarLivePhotoProcessingOperation.name = C.key.operation.name.similarLivePhotoProcessingOperation
		return similarLivePhotoProcessingOperation
	}
	
		// `duplicate photo algorithm`
	public func getDuplicatedPhotosAsset(strictness: Strictness = .closeToIdentical, from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ((_ assets: [PhassetGroup],_ isCancelled: Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let duplicatedPhotoAssetOperation = ConcurrentProcessOperation { operation in
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photoGallery in
				
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicatePhoto, singleCleanType: .duplicatedPhoto, status: .prepare, totalItems: 0, currentIndex: 0)
				sleep(1)
				
				if photoGallery.count != 0 {
				
					var assets: [PHAsset] = []
					photoGallery.enumerateObjects { phasset, index, stop in
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicatePhoto, singleCleanType: .duplicatedPhoto)
							completionHandler([], operation.isCancelled)
							return
						}
						assets.append(phasset)
					}
					
						/// adding notification to handle progress similar photos processing
					self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicatePhoto, singleCleanType: .duplicatedPhoto, status: .analyzing, totalItems: 0, currentIndex: 0)
										
					var rawTuples: [OSTuple<NSString, NSData>] = []

					for (index, asset) in assets.enumerated() {
						let imageData = asset.thumbnailSync?.pngData()
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicatePhoto, singleCleanType: .duplicatedPhoto)
							completionHandler([], operation.isCancelled)
							return
						}
						self.sendNotification(processing: cleanProcessingType, deepCleanType: .duplicatePhoto, singleCleanType: .duplicatedPhoto, status: .progress, totalItems: assets.count, currentIndex: index)
						rawTuples.append(OSTuple<NSString, NSData>.init(first: "\(index)" as NSString, andSecond: imageData as NSData?))
					}
					
					let photoTuples = rawTuples.filter({ $0.second != nil })
					
					let duplicatedTuplesOperation = self.getTuplesOperation(for: photoTuples,
																			   photosInGallery: assets,
																			   deepCleanType: .duplicatePhoto,
																			   sinlgeCleanType: .duplicatedPhoto,
																			   cleanProcessingType: cleanProcessingType,
																			   strictness: strictness) { duplicatedPhotoAssetsGroups, isCancelled in
						U.delay(1) {
							completionHandler(duplicatedPhotoAssetsGroups, isCancelled)
						}
					}
					duplicatedTuplesOperation.name = CommonOperationSearchType.utitlityDuplicatedPhotoTuplesOperation.rawValue
					self.phassetProcessingOperationQueuer.addOperation(duplicatedTuplesOperation)
				} else {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .duplicatePhoto, singleCleanType: .duplicatedPhoto)
					U.delay(1) {
						completionHandler([], operation.isCancelled)
					}
				}
			}
		}
		duplicatedPhotoAssetOperation.name = CommonOperationSearchType.duplicatedPhotoAssetsOperation.rawValue
		return duplicatedPhotoAssetOperation
	}
	
	private func getRowTuple(from phasset: [PHAsset], operatiom: ConcurrentProcessOperation, completionHandler: @escaping (_ tuples: [OSTuple<NSString, NSData>]) -> Void) {
		
	}
}

//		MARK: - HELPER DUPLICATEDS TYPE SEARCH -
extension PhotoManager {
	
	private func getTuplesOperation(for photoTuples: [OSTuple<NSString, NSData>],
									photosInGallery: [PHAsset],
									deepCleanType: DeepCleanNotificationType,
									sinlgeCleanType: SingleContentSearchNotificationType,
									cleanProcessingType: CleanProcessingPresentType,
									strictness: Strictness,
									completionHandler: @escaping ([PhassetGroup], Bool) -> Void) -> ConcurrentProcessOperation {
		
		let serviceUtilityDuplicatedTuplesOperation = ConcurrentProcessOperation { operation in
			
			let providerID = OSImageHashingProviderIdForHashingQuality(.high)
			let provider = OSImageHashingProviderFromImageHashingProviderId(providerID)
			let defaultHashDistanceTreshHold = provider.hashDistanceSimilarityThreshold()
			var hashDistanseTrashold: Int64 {
				switch strictness {
					case .similar:
						return defaultHashDistanceTreshHold
					case .closeToIdentical:
						return 1
				}
			}
			
			var dupliatedGroups: [PhassetGroup] = []
			var duplicateGroups = [[PHAsset]]()
			var groupIndexesPhassets: [PHAsset: Int] = [:]
			
			self.sendNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: sinlgeCleanType, status: .compare, totalItems: photosInGallery.count, currentIndex: photosInGallery.count)
			
			if operation.isCancelled {
				self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: sinlgeCleanType)
				completionHandler([], operation.isCancelled)
				return
			}
			
			let duplicatedPhotosIDsAsTuples = OSImageHashing.sharedInstance().similarImages(withProvider: providerID,
																							withHashDistanceThreshold: hashDistanseTrashold,
																							forImages: photoTuples)
			if operation.isCancelled {
				self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: sinlgeCleanType)
				completionHandler([], operation.isCancelled)
				return
			}
			
			guard duplicatedPhotosIDsAsTuples.count >= 1 else {
				self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: sinlgeCleanType)
				completionHandler([], operation.isCancelled)
				return
			}
			
			var index = 0
			
			for pair in duplicatedPhotosIDsAsTuples {
				if operation.isCancelled {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: sinlgeCleanType)
					completionHandler([], operation.isCancelled)
					return
				}
				let assetIndex1 = Int(pair.first! as String)!
				let assetIndex2 = Int(pair.second! as String)!
				let asset1 = photosInGallery[assetIndex1]
				let asset2 = photosInGallery[assetIndex2]
				let groupIndex1 = groupIndexesPhassets[asset1]
				let groupIndex2 = groupIndexesPhassets[asset2]
				
				self.sendNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: sinlgeCleanType, status: .progress, totalItems: photosInGallery.count, currentIndex: photosInGallery.count)
			
				index += 1
				if groupIndex1 == nil && groupIndex2 == nil {
						// new group
					duplicateGroups.append([asset1, asset2])
					let groupIndex = duplicateGroups.count - 1
					groupIndexesPhassets[asset1] = groupIndex
					groupIndexesPhassets[asset2] = groupIndex
				} else if groupIndex1 == nil && groupIndex2 != nil {
						// add 1 to 2's group
					duplicateGroups[groupIndex2!].append(asset1)
					groupIndexesPhassets[asset1] = groupIndex2!
				} else if groupIndex1 != nil && groupIndex2 == nil {
						// add 2 to 1's group
					duplicateGroups[groupIndex1!].append(asset2)
					groupIndexesPhassets[asset2] = groupIndex1!
				}
			}
			
			for group in duplicateGroups {
				
				if operation.isCancelled {
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: sinlgeCleanType)
					completionHandler([], operation.isCancelled)
					return
				}
				
				if group.count >= 2 {
					dupliatedGroups.append(PhassetGroup(name: "", assets: group, creationDate: group.first?.creationDate))
				}
			}
			self.sendNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: sinlgeCleanType, status: .result, totalItems: duplicatedPhotosIDsAsTuples.count, currentIndex: index)
			completionHandler(dupliatedGroups, operation.isCancelled)
		}
		
		serviceUtilityDuplicatedTuplesOperation.name = CommonOperationSearchType.utitlityDuplicatedPhotoTuplesOperation.rawValue
		return serviceUtilityDuplicatedTuplesOperation
	}
	
	
		/// `private duplicated tuples` need for service compare (not working properly as duplicate))
	private func getDuplicatedTuplesOperation(for photos: [OSTuple<NSString, NSData>], photosInGallery: PHFetchResult<PHAsset>, deepCleanType: DeepCleanNotificationType, singleCleanType: SingleContentSearchNotificationType, cleanProcessingType: CleanProcessingPresentType, completionHandler: @escaping ([PhassetGroup],_ isCancelled: Bool) -> Void) -> ConcurrentProcessOperation{
		
		let serviceUtilityDuplicatedTuplesOperation = ConcurrentProcessOperation { operation in
			
			var duplicatedPhotosCount: [Int] = []
			var duplicatedGroup: [PhassetGroup] = []
			
			self.sendNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: singleCleanType, status: .analyzing, totalItems: 0, currentIndex: 0)
            let duplicatedIDS = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: photos)
            
			guard duplicatedIDS.count >= 1 else {
				self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarLivePhoto, singleCleanType: .similarLivePhoto)
				completionHandler([], operation.isCancelled)
				return
			}
			
            for (currentPosition, tupleValue) in duplicatedIDS.enumerated() {
				
				if operation.isCancelled {
					completionHandler([], operation.isCancelled)
					return
				}
	
				let duplicatedTuple = tupleValue
				var group: [PHAsset] = []
				
				self.sendNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: singleCleanType, status: .progress, totalItems: duplicatedIDS.count, currentIndex: currentPosition)
								
				if let first = duplicatedTuple.first as String?, let second = duplicatedTuple.second as String? {
					let firstInteger = first.replacingStringAndConvertToIntegerForImage() - 1
					let secondInteger = second.replacingStringAndConvertToIntegerForImage() - 1
					debugPrint(first)
					debugPrint(second)
					
					if abs(secondInteger - firstInteger) >= 10 { continue }
					if !duplicatedPhotosCount.contains(firstInteger) {
						duplicatedPhotosCount.append(firstInteger)
						group.append(photosInGallery[firstInteger])
					}
					
					if !duplicatedPhotosCount.contains(secondInteger) {
						duplicatedPhotosCount.append(secondInteger)
						group.append(photosInGallery[secondInteger])
					}
					
					duplicatedIDS.filter({ $0.first != nil && $0.second != nil}).filter({ $0.first == duplicatedTuple.first || $0.second == duplicatedTuple.second || $0.second == duplicatedTuple.second || $0.second == duplicatedTuple.first}).forEach ({ tuple in
						
						if operation.isCancelled {
							self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: singleCleanType)
							completionHandler([], operation.isCancelled)
							return
						}
					
						if let first = tuple.first as String?, let second = tuple.second as String? {
							let firstInt = first.replacingStringAndConvertToIntegerForImage() - 1
							let socondInt = second.replacingStringAndConvertToIntegerForImage() - 1
							
							if abs(secondInteger - firstInteger) >= 10 {
								return
							}
							
							if !duplicatedPhotosCount.contains(firstInt) {
								duplicatedPhotosCount.append(firstInt)
								group.append(photosInGallery[firstInt])
							}
							
							if !duplicatedPhotosCount.contains(socondInt) {
								duplicatedPhotosCount.append(socondInt)
								group.append(photosInGallery[socondInt])
							}
						} else {
							return
						}
					})
					if group.count >= 2 {
						duplicatedGroup.append(PhassetGroup(name: "", assets: group, creationDate: group.first?.creationDate))
					}
				}
			}
			self.sendNotification(processing: cleanProcessingType, deepCleanType: deepCleanType, singleCleanType: singleCleanType, status: .result, totalItems: duplicatedIDS.count, currentIndex: duplicatedIDS.count)
			completionHandler(duplicatedGroup, operation.isCancelled)
		}
		serviceUtilityDuplicatedTuplesOperation.name = CommonOperationSearchType.utitlityDuplicatedPhotoTuplesOperation.rawValue
		return serviceUtilityDuplicatedTuplesOperation
	}
	
		/// similar close to identical videos algoritm
	public func findDuplicatedVideoOperation(assets: [PHAsset], strictness: Strictness, cleanProcessingType: CleanProcessingPresentType, operation: ConcurrentProcessOperation, completionHandler: @escaping ([PhassetGroup],_ isCancelled: Bool) -> Void) -> ConcurrentProcessOperation {
		
		let duplicatedVideoOperation = ConcurrentProcessOperation { operation in
			
			var phassetGroup: [PhassetGroup] = []
		
			var rawTuples: [OSTuple<NSString, NSData>] = []
			
			for (index, asset) in assets.enumerated() {
				
				let imageData = asset.thumbnailSync?.pngData()
				
				if operation.isCancelled {
					completionHandler([], operation.isCancelled)
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarVideo, singleCleanType: .similarVideo)
					return
				}
				
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarVideo, singleCleanType: .similarVideo, status: .progress, totalItems: assets.count, currentIndex: index)
				rawTuples.append(OSTuple<NSString, NSData>.init(first: "\(index)" as NSString, andSecond: imageData as NSData?))
			}
			
			let toCheckTuples = rawTuples.filter({ $0.second != nil })
			
			let providerId = OSImageHashingProviderIdForHashingQuality(.medium)
			let provider = OSImageHashingProviderFromImageHashingProviderId(providerId);
			let defaultHashDistanceTreshold = provider.hashDistanceSimilarityThreshold()
			let hashDistanceTreshold: Int64
			
			switch strictness {
				case .similar:
					hashDistanceTreshold = defaultHashDistanceTreshold
				case .closeToIdentical:
					hashDistanceTreshold = 1
			}
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarVideo, singleCleanType: .similarVideo, status: .compare, totalItems: assets.count, currentIndex: assets.count)
			let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(withProvider: providerId, withHashDistanceThreshold: hashDistanceTreshold, forImages: toCheckTuples)
			
			var assetToGroupIndex = [PHAsset: Int]()
					
			for (_, pair) in similarImageIdsAsTuples.enumerated() {
				
				if operation.isCancelled {
					completionHandler([], operation.isCancelled)
					self.sendEmptyNotification(processing: cleanProcessingType, deepCleanType: .similarVideo, singleCleanType: .similarVideo)
					return
				}

				let assetIndex1 = Int(pair.first! as String)!
				let assetIndex2 = Int(pair.second! as String)!
				let asset1 = assets[assetIndex1]
				let asset2 = assets[assetIndex2]
				let groupIndex1 = assetToGroupIndex[asset1]
				let groupIndex2 = assetToGroupIndex[asset2]
				if groupIndex1 == nil && groupIndex2 == nil {
					
					let group = PhassetGroup.init(name: "", assets: [asset1, asset2], creationDate: asset1.creationDate)
					phassetGroup.append(group)
					let groupIndex = phassetGroup.count - 1
					assetToGroupIndex[asset1] = groupIndex
					assetToGroupIndex[asset2] = groupIndex
				} else if groupIndex1 == nil && groupIndex2 != nil {
					phassetGroup[groupIndex2!].assets.append(asset1)
					assetToGroupIndex[asset1] = groupIndex2!
				} else if groupIndex1 != nil && groupIndex2 == nil {
					phassetGroup[groupIndex1!].assets.append(asset2)
					assetToGroupIndex[asset2] = groupIndex1!
				}
				
				self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarVideo, singleCleanType: .similarVideo, status: .compare, totalItems: similarImageIdsAsTuples.count, currentIndex: similarImageIdsAsTuples.count)
			}
			completionHandler(phassetGroup, operation.isCancelled)
			self.sendNotification(processing: cleanProcessingType, deepCleanType: .similarVideo, singleCleanType: .similarVideo, status: .result, totalItems: similarImageIdsAsTuples.count, currentIndex: similarImageIdsAsTuples.count)
		}
		duplicatedVideoOperation.name = C.key.operation.name.findDuplicatedVideoOperation
		return duplicatedVideoOperation
	}
}

extension PhotoManager {
	
	public func getVideoCollection(completionHandler: @escaping (_ phassets: [PHAsset]) -> Void) {
		
		self.fetchManager.fetchVideoPHAssets { videoPHAssets in
			completionHandler(videoPHAssets)
		}
	}
}

	/// `notification sections`
extension PhotoManager {
	
	private func sendNotification(processing: CleanProcessingPresentType, deepCleanType: DeepCleanNotificationType = .none, singleCleanType: SingleContentSearchNotificationType = .none, status: ProcessingProgressOperationState, totalItems: Int, currentIndex: Int) {
		
		switch processing {
			case .deepCleen:
				self.progressSearchNotificationManager.sendDeepProgressNotification(notificationType: deepCleanType, status: status, totalProgressItems: totalItems, currentProgressItem: currentIndex)
			case .singleSearch:
				self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: singleCleanType, status: status, totalProgressItems: totalItems, currentProgressItem: currentIndex)
			case .background:
				return
		}
	}
	
	private func sendFileSizeNotification(type: DeepCleanNotificationType, totalFiles: Int, currentIndex: Int, fileSize: Int64) {
		switch type {
			case .photoFilesSize:
				self.progressSearchNotificationManager.sentSizeFilesCheckerNotification(notificationtype: .photoFilesSize, value: fileSize, currentIndex: currentIndex, totlelFiles: totalFiles)
			case .videoFilesSize:
				self.progressSearchNotificationManager.sentSizeFilesCheckerNotification(notificationtype: .videoFilesSize, value: fileSize, currentIndex: currentIndex, totlelFiles: totalFiles)
			default:
				return
		}
	}
	
	private func sendEmptyNotification(processing: CleanProcessingPresentType, deepCleanType: DeepCleanNotificationType = .none, singleCleanType: SingleContentSearchNotificationType = .none) {
		switch processing {
			case .deepCleen:
				self.sendEmptyDeepCleanNotification(of: deepCleanType)
			case .singleSearch:
				self.sendEmptySingleCleanNotification(of: singleCleanType)
			case .background:
				return
		}
	}
	
	private func sendEmptyDeepCleanNotification(of type: DeepCleanNotificationType) {
		U.delay(1) {
			self.progressSearchNotificationManager.sendDeepProgressNotification(notificationType: type, status: .empty, totalProgressItems: 0, currentProgressItem: 0)
		}
	}
	
	private func sendEmptySingleCleanNotification(of type: SingleContentSearchNotificationType) {
		U.delay(1) {
			self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: type, status: .empty, totalProgressItems: 0, currentProgressItem: 0)
		}
	}
	
	private func sendUtilityDeepCleanNotification(of type: DeepCleanNotificationType, state: ProcessingProgressOperationState) {
		self.progressSearchNotificationManager.sendDeepProgressNotification(notificationType: type, status: state, totalProgressItems: 0, currentProgressItem: 0)
	}
	
	private func sendUtilitySingleCleanNotification(of type: SingleContentSearchNotificationType, state: ProcessingProgressOperationState) {
		self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: type, status: state, totalProgressItems: 0, currentProgressItem: 0)
	}
}

extension PhotoManager {
	
	public func deleteSelectedOperation(assets: [PHAsset], completion: @escaping ((Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let deletePhassetsOperation = ConcurrentProcessOperation { operation in
			let assetsSelectedIdentifiers = assets.map({ $0.localIdentifier})
			
			let deletedAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetsSelectedIdentifiers, options: nil)
			
			PHPhotoLibrary.shared().performChanges {
				if operation.isCancelled {
					return
				}
				PHAssetChangeRequest.deleteAssets(deletedAssets)
			} completionHandler: { success, error in
					completion(success)
			}
		}
		
		deletePhassetsOperation.name = C.key.operation.name.deletePhassetsOperation
		return deletePhassetsOperation
	}
}


//		MARK: - HELPER PROCESSING -
extension PhotoManager {
	
	public func getCalculateTotalVideoPhassetOperation(_ completionHandler: @escaping (Int) -> Void) -> ConcurrentProcessOperation {
		
		let calculateTotalVideoProcessingOperation = ConcurrentProcessOperation { _ in
			self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { result in
				completionHandler(result.count)
			}
		}
		calculateTotalVideoProcessingOperation.name = C.key.operation.name.videoCountOperation
		return calculateTotalVideoProcessingOperation
	}
	
	public func getCalculateTotalPhotoPhassetOperation(_ completionHandler: @escaping (Int) -> Void) -> ConcurrentProcessOperation {
		
		let calculateTotalPhotoProcessingOperation = ConcurrentProcessOperation { _ in
			self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { result in
				completionHandler(result.count)
			}
		}
		calculateTotalPhotoProcessingOperation.name = C.key.operation.name.photoCouuntOperation
		return calculateTotalPhotoProcessingOperation
	}
}

extension PhotoManager {
	
	public func getPhotoAssetsCount(from startDate: Date, to endDate: Date, completion: @escaping (Int) -> Void) {
		
		self.fetchManager.fetchTotalAssetsCount(from: startDate, to: endDate) { totalCount in
			completion(totalCount)
		}
	}
	
	public func getPartitionalMediaAssetsCount(from startDate: Date, to endDate: Date, completion: @escaping ([AssetsGroupType: Int]) -> Void) {
		
		var totalProcessingProcess = 0

		var totalPartitinAssetsCount: [AssetsGroupType : Int] = [.photo : 0, // get all photo count
																 .screenShots : 0, // get all screenshots
																 .livePhotos : 0, // get all live photosCount
																 .video : 0, // get all videos
																 .screenRecordings : 0] // get all screen recordings
		
		let photoCountOperation = fetchManager.fetchTotalAssetsCountOperation(from: startDate, to: endDate) { photoCount in
			totalPartitinAssetsCount[.photo] = photoCount
			totalProcessingProcess += 1
			if totalProcessingProcess == 5 {
				completion(totalPartitinAssetsCount)
			}
		}
		
		let videoCountOperationm = fetchManager.fetchFromGalleryOperation(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { video in
			totalPartitinAssetsCount[.video] = video.count
			totalProcessingProcess += 1
			if totalProcessingProcess == 5 {
				completion(totalPartitinAssetsCount)
			}
		}
		
		let screenShotCountOperation = getScreenShotsOperation(from: startDate, to: endDate, cleanProcessingType: .background) { screenShots, _ in
			totalPartitinAssetsCount[.screenShots] = screenShots.count
			totalProcessingProcess += 1
			if totalProcessingProcess == 5 {
				completion(totalPartitinAssetsCount)
			}
		}

		let livePhotoCountOperation = getLivePhotosOperation(from: startDate, to: endDate, cleanProcessingType: .background) { livePhotos, _ in
			totalPartitinAssetsCount[.livePhotos] = livePhotos.count
			totalProcessingProcess += 1
			if totalProcessingProcess == 5 {
				completion(totalPartitinAssetsCount)
			}
		}
		
		let screenRecordingsVideosOperation = getScreenShotsOperation(from: startDate, to: endDate, cleanProcessingType: .background) { screenRecordsAssets, _ in
			totalPartitinAssetsCount[.screenRecordings] = screenRecordsAssets.count
			totalProcessingProcess += 1
			if totalProcessingProcess == 5 {
				completion(totalPartitinAssetsCount)
			}
		}
		
		phassetProcessingOperationQueuer.addOperation(photoCountOperation)
		phassetProcessingOperationQueuer.addOperation(videoCountOperationm)
		phassetProcessingOperationQueuer.addOperation(screenShotCountOperation)
		phassetProcessingOperationQueuer.addOperation(livePhotoCountOperation)
		phassetProcessingOperationQueuer.addOperation(screenRecordingsVideosOperation)
	}
}

extension PhotoManager {
	
	public func getAssetsUsedMemmoty(by ids: [String], completionHandler: @escaping (Int64) -> Void) -> ConcurrentProcessOperation {
		
		let getAssetsByIdOperation = ConcurrentProcessOperation { operation in
		
			self.fetchManager.fetchImagesDiskUsageFromGallery(with: ids) { calculatedResult in
				completionHandler(calculatedResult)
			}
		}
		return getAssetsByIdOperation
	}
}

//  MARK: -fetch prefetch operations-
extension PhotoManager {
    
    public func prefetchsForPHAssets(_ assets: [PHAsset]) {

            let phassetOperation = ConcurrentProcessOperation { operation in
				self.prefetchManager.allowsCachingHighQualityImages = true
                self.prefetchManager.startCachingImages(for: assets, targetSize: self.prefetchPhotoTargetSize(), contentMode: .aspectFit, options: self.requestOptions)
            }
            prefetchOperationQueue.addOperation(phassetOperation)
    }
    
    public func cancelFetchForPHAseets(_ assets: [PHAsset]) {
        self.prefetchManager.stopCachingImages(for: assets, targetSize: self.prefetchPhotoTargetSize(), contentMode: .aspectFit, options: self.requestOptions)
    }
    
	public func requestChacheImageForPhasset(_ asset: PHAsset, completion: @escaping (_ image: UIImage?,_ id: String) -> Void) {
        let targetSize = self.prefetchPhotoTargetSize()
	
        if asset.representsBurst {
			prefetchManager.requestImageDataAndOrientation(for: asset, options: self.requestOptions) { data, _, _, _ in
                let image = data.flatMap { UIImage(data: $0) }
				completion(image, asset.localIdentifier)
            }
        }
        else {
			prefetchManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: self.requestOptions) { image, _ in
					completion(image, asset.localIdentifier)
            }
        }
    }
	
	
	public func loadChacheImageForPhasset(_ asset: PHAsset) -> UIImage? {
		var resultImage: UIImage?
		
		prefetchManager.requestImage(for: asset, targetSize: self.prefetchPhotoTargetSize(), contentMode: .aspectFill, options: self.requestOptions) { image, _ in
			resultImage = image
		}
		return resultImage
	}
    
        /// 'get size for asset'
    public func prefetchPhotoTargetSize() -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: 400 * scale, height: 400 * scale)
    }
    
    public func sizeForAsset(_ asset: PHAsset, scale: CGFloat = 1) -> CGSize {
        
        let assetPropotion = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        let imageHeight: CGFloat = 400
        let imageWidth = floor(assetPropotion * imageHeight)
        
        return CGSize(width: imageWidth * scale, height: imageHeight * scale)
    }
}

extension PhotoManager {
	
	public func getPhassetShareUrl(_ asset: PHAsset, completionHandler: @escaping (_ sharedURL: URL?,_ name: String?) -> Void) {

		let fileManager = ECFileManager()
		let options = PHVideoRequestOptions()
		options.isNetworkAccessAllowed = true
		options.deliveryMode = .highQualityFormat
		
		let resource = PHAssetResource.assetResources(for: asset).first!
		let name = resource.originalFilename

		self.imageManager.requestAVAsset(forVideo: asset, options: options) { avasset, mix, info in
			if let avasset = avasset as? AVURLAsset{
				fileManager.copyFileTemoDdirectory(from: avasset.url, with: name) { url in
					if let url = url {
						if fileManager.isFileExiest(at: url) {
							completionHandler(url, name)
						} else {
							completionHandler(nil, nil)
						}
					} else {
						completionHandler(nil, nil)
					}
				}
			} else {
				completionHandler(nil, nil)
			}
		}
	}
}
