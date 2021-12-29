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
	
	private var fetchManager = PHAssetFetchManager.shared
	private var progressSearchNotificationManager = ProgressSearchNotificationManager.instance

	public let phassetProcessingOperationQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.phassets, maxConcurrentOperationCount: 10, qualityOfService: .background)
	public let serviceUtilsCalculatedOperationsQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.utils, maxConcurrentOperationCount: 10, qualityOfService: .background)
	
	var assetCollection: PHAssetCollection?
	
	private static let lowerDateValue: Date = S.defaultLowerDateValue
	private static let upperDateValue: Date = S.defaultUpperDateValue
	
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
}

//	MARK: - INIT PHOTO LIBRARY -
extension PhotoManager {
	
	public func getPhotoLibraryContentAndCalculateSpace() {
		
			/// `calculate all sizes phassets`
		let calculatedAllDiskSpaceOperation = self.fetchManager.getCalculatePHAssetSizesSingleOperation { photoSpace, videoSpace, allAssetsSpace in
			S.phassetPhotoFilesSizes = photoSpace
			S.phassetVideoFilesSizes = videoSpace
			S.phassetFilesSize = allAssetsSpace
		}
	
			/// `calculate and ger large videos from photo library`
		let getLargeVideosOperation = self.getLargevideoContentOperation { assets in
			UpdateContentDataBaseMediator.instance.getLargeVideosAssets(assets)
		}
		
		let getRecentlyDeletedPhassetOperation = self.fetchManager.recentlyDeletdSortedAlbumsFetchOperation { photosAssets, videoAssets in
			UpdateContentDataBaseMediator.instance.getRecentlyDeletedPhotosAssets(photosAssets)
			UpdateContentDataBaseMediator.instance.getRecentlyDeletedVideosAssets(videoAssets)
		}
		
		let getCalculateTotalVideoPhassetOperation = self.getCalculateTotalVideoPhassetOperation { totalVideoCount in
			UpdateContentDataBaseMediator.instance.updateContentStoreCount(mediaType: .userVideo, itemsCount: totalVideoCount, calculatedSpace: nil)
		}
		
		let getCalculatedTotalPhotoPhassetOperation = self.getCalculateTotalPhotoPhassetOperation { totalPhotoCount in
			UpdateContentDataBaseMediator.instance.updateContentStoreCount(mediaType: .userPhoto, itemsCount: totalPhotoCount, calculatedSpace: nil)
		}
		
		let getScreenRecordingsOperation = self.getScreenRecordsVideosOperation { screenRecordsAssets in
			UpdateContentDataBaseMediator.instance.getScreenRecordsVideosAssets(screenRecordsAssets)
			
		}
		
		let getScreenShorsOperation = self.getScreenShotsOperation { assets in
			UpdateContentDataBaseMediator.instance.getScreenshots(assets)
		}
		
		let getLivePhotoOperation = self.getLivePhotosOperation { assets in
			UpdateContentDataBaseMediator.instance.getLivePhotosAssets(assets)
		}
		
		let getSelfiesPhotoOperation = self.getSelfiePhotosOperation { assets in
			UpdateContentDataBaseMediator.instance.getFrontCameraAssets(assets)
		}
		
			/// `add operation phasset`
		if !serviceUtilsCalculatedOperationsQueuer.operations.contains(where: {$0.name == calculatedAllDiskSpaceOperation.name}) {
			serviceUtilsCalculatedOperationsQueuer.addOperation(calculatedAllDiskSpaceOperation)
		}
		
		if !serviceUtilsCalculatedOperationsQueuer.operations.contains(where: {$0.name == getLargeVideosOperation.name}) {
			serviceUtilsCalculatedOperationsQueuer.addOperation(getLargeVideosOperation)
		}
		
		if !serviceUtilsCalculatedOperationsQueuer.operations.contains(where: {$0.name == getRecentlyDeletedPhassetOperation.name}) {
			serviceUtilsCalculatedOperationsQueuer.addOperation(getRecentlyDeletedPhassetOperation)
		}
		
		if !serviceUtilsCalculatedOperationsQueuer.operations.contains(where: {$0.name == getCalculateTotalVideoPhassetOperation.name}) {
			serviceUtilsCalculatedOperationsQueuer.addOperation(getCalculateTotalVideoPhassetOperation)
		}
		
		if !serviceUtilsCalculatedOperationsQueuer.operations.contains(where: {$0.name == getCalculatedTotalPhotoPhassetOperation.name}) {
			serviceUtilsCalculatedOperationsQueuer.addOperation(getCalculatedTotalPhotoPhassetOperation)
		}
		
		if !serviceUtilsCalculatedOperationsQueuer.operations.contains(where: {$0.name == getScreenRecordingsOperation.name}) {
			serviceUtilsCalculatedOperationsQueuer.addOperation(getScreenRecordingsOperation)
		}
		
		if !serviceUtilsCalculatedOperationsQueuer.operations.contains(where: {$0.name == getScreenShorsOperation.name}) {
			serviceUtilsCalculatedOperationsQueuer.addOperation(getScreenShorsOperation)
		}
		
		if !serviceUtilsCalculatedOperationsQueuer.operations.contains(where: {$0.name == getLivePhotoOperation.name}) {
			serviceUtilsCalculatedOperationsQueuer.addOperation(getLivePhotoOperation)
		}
		
		if !serviceUtilsCalculatedOperationsQueuer.operations.contains(where: {$0.name == getSelfiesPhotoOperation.name}) {
			serviceUtilsCalculatedOperationsQueuer.addOperation(getSelfiesPhotoOperation)
		}
	}
}


//	MARK: - VIDEO PROCESSING -
extension PhotoManager {
	
	public func getLargevideoContentOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let largeVideoProcessingOperation = ConcurrentProcessOperation { _ in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
				
				var videos: [PHAsset] = []
				
				if videoContent.count != 0 {
			
					for videosPosition in 1...videoContent.count {
						
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .largeVideo,
																										totalProgressItems: videoContent.count,
																										currentProgressItem: videosPosition)
						} else if enableDeepCleanProcessingNotification {
							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .largeVideo,
																							   totalProgressItems: videoContent.count,
																							   currentProgressItem: videosPosition)
						}
						
						if videoContent[videosPosition - 1].imageSize > 55000000 {
							videos.append(videoContent[videosPosition - 1])
						}
					}
					completionHandler(videos)
				} else {
					completionHandler([])
				}
			}
		}
		largeVideoProcessingOperation.name = CommonOperationSearchType.largeVideoContentOperation.rawValue
		return largeVideoProcessingOperation
	}
	
		/// `screen recordings` from gallery
	public func getScreenRecordsVideosOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ screenRecordsAssets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let screenRecordsVideosOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoAssets in
				
				var screenRecords: [PHAsset] = []
			
				if videoAssets.count != 0 {
					
					for videosPosition in 1...videoAssets.count {
						
						if operation.isCancelled {
							completionHandler([])
							return
						}
					
						let asset = videoAssets[videosPosition - 1]
						
						if let assetResource = PHAssetResource.assetResources(for: asset).first {
							if assetResource.originalFilename.contains("RPReplay") {
								screenRecords.append(asset)
							}
						}
						
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .screenRecordings,
																										totalProgressItems: videoAssets.count,
																										currentProgressItem: videosPosition)
						} else if enableDeepCleanProcessingNotification {
							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .screenRecordings,
																							   totalProgressItems: videoAssets.count,
																							   currentProgressItem: videosPosition)
						}
					}
					completionHandler(screenRecords)
				} else {
					completionHandler([])
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
	public func getSimilarVideoAssetsOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false,  completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation
	{
	
	let similarVideoAssetsOperation = ConcurrentProcessOperation { operation in
		
		self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
			
			var assets: [PHAsset] = []
			
			if videoContent.count != 0 {
				
				for videoPosition in 1...videoContent.count {
					let asset = videoContent[videoPosition - 1]
					assets.append(asset)
				}
				
				let similarVideoPhassetOperation = self.findDuplicatedVideoOperation(assets: assets, strictness: .similar, enableDeepCleanProcessingNotification: enableDeepCleanProcessingNotification, enableSingleProcessingNotification: enableSingleProcessingNotification, operation: operation) { phassetCroup in
					completionHandler(phassetCroup)
				}
				
				self.serviceUtilsCalculatedOperationsQueuer.addOperation(similarVideoPhassetOperation)
				
			} else {
				completionHandler([])
			}
		}
	}
	similarVideoAssetsOperation.name = CommonOperationSearchType.similarVideoAssetsOperation.rawValue
	return similarVideoAssetsOperation
	}
	
		/// `duplicated videos compare algorithm`
	public func getDuplicatedVideoAssetOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
		
		let duplicatedVideoAssetsOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate,
											   to: upperDate,
											   collectiontype: .smartAlbumVideos,
											   by: PHAssetMediaType.video.rawValue) { videoCollection in
				var videos: [OSTuple<NSString, NSData>] = []
				
				
				if videoCollection.count != 0 {
					for index in 1...videoCollection.count {
						
						if operation.isCancelled {
							completionHandler([])
							return
						}
						
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .duplicatedVideo,
																										totalProgressItems: videoCollection.count,
																										currentProgressItem: index)
						} else if enableDeepCleanProcessingNotification {
							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .duplicateVideo,
																							   totalProgressItems: videoCollection.count,
																							   currentProgressItem: index)
						}
						
						let image = self.fetchManager.getThumbnail(from: videoCollection[index - 1], size: CGSize(width: 150, height: 150))
						if let data = image.jpegData(compressionQuality: 0.8) {
							let imageTuple = OSTuple<NSString, NSData>(first: "image\(index)" as NSString, andSecond: data as NSData)
							videos.append(imageTuple)
						} else {
								//                            return
						}
					}
					
					let duplicateVideoIDasTuples = OSImageHashing.sharedInstance().similarImages(withProvider: .pHash, forImages: videos)
					var duplicateVideoNumbers: [Int] = []
					var duplicateVideoGroups: [PhassetGroup] = []
					
					guard duplicateVideoIDasTuples.count >= 1 else {
						completionHandler([])
						return
					}
					
					for index in 1...duplicateVideoIDasTuples.count {
						
						if operation.isCancelled {
							completionHandler([])
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
									completionHandler([])
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
						}
					}
					completionHandler(duplicateVideoGroups)
				} else {
					completionHandler([])
				}
			}
		}
		duplicatedVideoAssetsOperation.name = CommonOperationSearchType.duplicatedVideoAssetOperation.rawValue
		return duplicatedVideoAssetsOperation
	}
	
		/// `similar videos by time stamp`
	public func getSimilarVideosByTimeStampOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
		
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
	public func getSelfiePhotosOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let photoSelfiesOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumSelfPortraits, by: PHAssetMediaType.image.rawValue) { selfiesInLibrary in
				var selfies: [PHAsset] = []
				
				if selfiesInLibrary.count != 0 {
					for selfiePos in 1...selfiesInLibrary.count {
						
						if operation.isCancelled {
							completionHandler([])
							return
						}
						
						selfies.append(selfiesInLibrary[selfiePos - 1])
					}
					completionHandler(selfies)
				} else {
					completionHandler([])
				}
			}
		}
		photoSelfiesOperation.name = CommonOperationSearchType.singleSelfieAssetsOperation.rawValue
		return photoSelfiesOperation
	}
	
		/// `load screenshots` from gallery
	public func getScreenShotsOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let getScreenShotsOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumScreenshots, by: PHAssetMediaType.image.rawValue) { screensShotsLibrary in
				
				var screens: [PHAsset] = []
	
				if screensShotsLibrary.count != 0 {
					
					for screensPos in 1...screensShotsLibrary.count {
						
						if operation.isCancelled {
							completionHandler([])
							return
						}
						
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .screenShots, totalProgressItems: screensShotsLibrary.count, currentProgressItem: screensPos)
						} else if enableDeepCleanProcessingNotification {
							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .screenshots, totalProgressItems: screensShotsLibrary.count, currentProgressItem: screensPos)
						}
						screens.append(screensShotsLibrary[screensPos - 1])
					}
					completionHandler(screens)
				} else {
					completionHandler([])
				}
			}
		}
		getScreenShotsOperation.name = CommonOperationSearchType.screenShotsAssetsOperation.rawValue
		return getScreenShotsOperation
	}
	
			/// `load live photos` from gallery
	public func getLivePhotosOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let livePhotoOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotosLibrary in
				
				var livePhotos: [PHAsset] = []
				if livePhotosLibrary.count != 0 {
					
					for livePhotoPosition in 1...livePhotosLibrary.count {
						
						if operation.isCancelled {
							completionHandler([])
							return
						}
						
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .livePhoto, totalProgressItems: livePhotosLibrary.count, currentProgressItem: livePhotoPosition)
						} else if enableDeepCleanProcessingNotification {
//							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: ., totalProgressItems: livePhotosLibrary.count, currentProgressItem: livePhotoPosition)
						}
						livePhotos.append(livePhotosLibrary[livePhotoPosition - 1])
					}
					completionHandler(livePhotos)
				} else {
					completionHandler([])
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
	public func getSimilarPhotosAssetsOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, fileSizeCheck: Bool = false, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
		
		let similarPhotoProcessingOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photosInGallery in
				
				var group: [PhassetGroup] = []
				var containsAdd: [Int] = []
				var similarPhotos: [(asset: PHAsset, date: Int64, imageSize: Int64)] = []
				
				similarPhotos.reserveCapacity(photosInGallery.count)
				
				
				if photosInGallery.count != 0 {
					
					for index in 1...photosInGallery.count {
						debugPrint("index preocessing duplicate")
						debugPrint("index \(index)")
							
						if operation.isCancelled {
							completionHandler([])
							return
						}
					
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .similarPhoto,
																										totalProgressItems: photosInGallery.count,
																										currentProgressItem: index)
						} else if enableDeepCleanProcessingNotification {
							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .similarPhoto,
																							   totalProgressItems: photosInGallery.count,
																							   currentProgressItem: index)
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
							completionHandler([])
							return
						}
						
						debugPrint("similar index precessing: ", index)
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
							debugPrint("apend new group")
							let date = similar.first?.creationDate
							group.append(PhassetGroup(name: "", assets: similar, creationDate: date))
						}
					}
					
					completionHandler(group)
				} else {
					completionHandler([])
				}
			}
		}
		similarPhotoProcessingOperation.name = CommonOperationSearchType.similarPhotoAssetsOperaton.rawValue
		return similarPhotoProcessingOperation
	}
	
		/// `load simmiliar live photo` from gallery
	public func getSimilarLivePhotosOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
		
		let similarLivePhotoProcessingOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotoGallery in
				
				var livePhotos: [OSTuple<NSString, NSData>] = []
				
				if livePhotoGallery.count != 0 {
					for livePosition in 1...livePhotoGallery.count {
						
						if operation.isCancelled {
							completionHandler([])
							return
						}
					
						debugPrint("live photo position", livePosition)
						
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .similarLivePhoto,
																										totalProgressItems: livePhotoGallery.count,
																										currentProgressItem: livePosition / 2)
						} else  if enableDeepCleanProcessingNotification {
							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .similarLivePhoto,
																							   totalProgressItems: livePhotoGallery.count,
																							   currentProgressItem: livePosition / 2)
						}
						
						let image = self.fetchManager.getThumbnail(from: livePhotoGallery[livePosition - 1], size: CGSize(width: 150, height: 150))
						if let data = image.jpegData(compressionQuality: 0.8) {
							let tuple = OSTuple<NSString, NSData>(first: "image\(livePosition)" as NSString, andSecond: data as NSData)
							livePhotos.append(tuple)
						}
					}
					
					let duplicatedTuplesOperation = self.getDuplicatedTuplesOperation(for: livePhotos, photosInGallery: livePhotoGallery, deepCleanTyep: .similarLivePhoto, singleCleanType: .similarLivePhoto, enableDeepCleanProcessingNotification: enableDeepCleanProcessingNotification, enableSingleProcessingNotification: enableSingleProcessingNotification) { similarLivePhotoGroup in
						completionHandler(similarLivePhotoGroup)
					}
		
					self.serviceUtilsCalculatedOperationsQueuer.addOperation(duplicatedTuplesOperation)
					
				} else {
					completionHandler([])
				}
			}
		}
		similarLivePhotoProcessingOperation.name = C.key.operation.name.similarLivePhotoProcessingOperation
		return similarLivePhotoProcessingOperation
	}
	
		// `duplicate photo algorithm`
	public func getDuplicatedPhotosAsset(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
		
		let duplicatedPhotoAssetOperation = ConcurrentProcessOperation { operation in
			
			
			self.fetchManager.fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photoGallery in
				
				var photos: [OSTuple<NSString, NSData>] = []
				
				if photoGallery.count != 0 {
					
					
					for photoPos in 1...photoGallery.count {
						debugPrint("loading duplicate")
						debugPrint("photoposition \(photoPos)")
						
						if operation.isCancelled {
							completionHandler([])
							return
						}
						
							/// adding notification to handle progress similar photos processing
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .duplicatedPhoto,
																										totalProgressItems: photoGallery.count,
																										currentProgressItem: photoPos / 2)
						} else {
							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .duplicatePhoto,
																							   totalProgressItems: photoGallery.count,
																							   currentProgressItem: photoPos / 2)
						}
						
						let image = self.fetchManager.getThumbnail(from: photoGallery[photoPos - 1], size: CGSize(width: 150, height: 150))
						if let data = image.jpegData(compressionQuality: 0.8) {
							let tuple = OSTuple<NSString, NSData>(first: "image\(photoPos)" as NSString, andSecond: data as NSData)
							photos.append(tuple)
						}
					}
					
					let duplicatedTuplesOperation = self.getDuplicatedTuplesOperation(for: photos, photosInGallery: photoGallery, deepCleanTyep: .duplicatePhoto, singleCleanType: .duplicatedPhoto,  enableDeepCleanProcessingNotification: enableDeepCleanProcessingNotification, enableSingleProcessingNotification: enableSingleProcessingNotification) { duplicatedPhotoAssetsGroup in
						completionHandler(duplicatedPhotoAssetsGroup)
					}
					
					self.serviceUtilsCalculatedOperationsQueuer.addOperation(duplicatedTuplesOperation)
					
				} else {
					completionHandler([])
				}
			}
		}
		duplicatedPhotoAssetOperation.name = CommonOperationSearchType.duplicatedPhotoAssetsOperation.rawValue
		return duplicatedPhotoAssetOperation
	}
}

//		MARK: - HELPER DUPLICATEDS TYPE SEARCH -
extension PhotoManager {
	
		/// `private duplicated tuples` need for service compare
	private func getDuplicatedTuplesOperation(for photos: [OSTuple<NSString, NSData>], photosInGallery: PHFetchResult<PHAsset>, deepCleanTyep: DeepCleanNotificationType, singleCleanType: SingleContentSearchNotificationType, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ([PhassetGroup]) -> Void) -> ConcurrentProcessOperation{
		
		let serviceUtilityDuplicatedTuplesOperation = ConcurrentProcessOperation { operation in
			
			var duplicatedPhotosCount: [Int] = []
			var duplicatedGroup: [PhassetGroup] = []
			let duplicatedIDS = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: photos)
			
			
			guard duplicatedIDS.count >= 1 else {
				completionHandler([])
				return
			}
			
			for currentPosition in 1...duplicatedIDS.count {
				
				if operation.isCancelled {
					completionHandler([])
					return
				}
				
				let duplicatedTuple = duplicatedIDS[currentPosition - 1]
				var group: [PHAsset] = []
				
				debugPrint("checkDuplicated")
				debugPrint("position \(currentPosition)")
				
				if enableSingleProcessingNotification {
					self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: singleCleanType,
																								totalProgressItems: duplicatedIDS.count,
																								currentProgressItem: currentPosition)
				} else if enableDeepCleanProcessingNotification {
					self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: deepCleanTyep,
																					   totalProgressItems: duplicatedIDS.count,
																					   currentProgressItem: currentPosition)
				}
				
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
							completionHandler([])
							return
						}
					
						if let first = tuple.first as String?, let second = tuple.second as String? {
							let firstInt = first.replacingStringAndConvertToIntegerForImage() - 1
							let socondInt = second.replacingStringAndConvertToIntegerForImage() - 1
							
							if abs(secondInteger - firstInteger) >= 10 {
								return
							}
							
							debugPrint(first)
							debugPrint(second)
							
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
			completionHandler(duplicatedGroup)
		}
		serviceUtilityDuplicatedTuplesOperation.name = CommonOperationSearchType.utitlityDuplicatedPhotoTuplesOperation.rawValue
		return serviceUtilityDuplicatedTuplesOperation
	}
	
		/// similar close to identical videos algoritm
	public func findDuplicatedVideoOperation(assets: [PHAsset], strictness: Strictness, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, operation: ConcurrentProcessOperation, completionHandler: @escaping ([PhassetGroup]) -> Void) -> ConcurrentProcessOperation {
		
		let duplicatedVideoOperation = ConcurrentProcessOperation { operation in
			
			var phassetGroup: [PhassetGroup] = []
			
			let rawTuples: [OSTuple<NSString, NSData>] = assets.enumerated().map { (index, asset) -> OSTuple<NSString, NSData> in
				let imageData = asset.thumbnailSync?.pngData()
				return OSTuple<NSString, NSData>.init(first: "\(index)" as NSString, andSecond: imageData as NSData?)
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
			
			let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(withProvider: providerId, withHashDistanceThreshold: hashDistanceTreshold, forImages: toCheckTuples)
			
			var assetToGroupIndex = [PHAsset: Int]()
			
			var notificationStarterIndex = 0
			
			for pair in similarImageIdsAsTuples {
				
				if operation.isCancelled {
					completionHandler([])
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
				
				if enableSingleProcessingNotification {
					notificationStarterIndex += 1
					self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .similarVideo,
																								totalProgressItems: similarImageIdsAsTuples.count,
																								currentProgressItem: notificationStarterIndex)
					
				} else if enableDeepCleanProcessingNotification {
					notificationStarterIndex += 1
					self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .similarVideo,
																					   totalProgressItems: similarImageIdsAsTuples.count,
																					   currentProgressItem: notificationStarterIndex)
				}
			}
			completionHandler(phassetGroup)
		}
		duplicatedVideoOperation.name = C.key.operation.name.findDuplicatedVideoOperation
		return duplicatedVideoOperation
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
	
	public func recoverSelectedOperation(assets: [PHAsset], completion: @escaping ((Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let recoverPhassetsOperation = ConcurrentProcessOperation { operation in
			
			self.fetchManager.fetchRecentlyDeletedCollection { recentlyDeletedCollection in
				PHPhotoLibrary.shared().performChanges {
					if let recentlyDeletedAlbum = recentlyDeletedCollection {
						let assetsIdentifiers = assets.map({$0.localIdentifier})
						
						
//						PHPhotoLibrary.shared().performChanges({
								guard let request = PHAssetCollectionChangeRequest(for: recentlyDeletedAlbum) else {
									return
								}
//								request.removeAssets([asset] as NSArray)
//						request.removeAssets([assets] as NSArray)
						
//						let albumPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumRecentlyAdded, options: nil)
//
//						albumPhoto.enumerateObjects { collection, index, object in
//							let result = PHAsset.fetchAssets(in: collection, options: nil)
//
//
//
//							var a = PHAsset.fetchAssets(in: collection, options: nil)
//
//							var z: [PHAsset] = []
//							a.enumerateObjects { asset, index, object in
//								z.append(asset)
//							}
//
//							let id = z.map({$0.localIdentifier})
//
//
//
//							let s = PHAsset.fetchAssets(withLocalIdentifiers: id, options: nil)
//
//							let albumChangeR = PHAssetCollectionChangeRequest(for: collection, assets: s)
//
//							s.enumerateObjects { assets, index, object in
//								debugPrint(assets.localIdentifier)
//							}
//						}
						
//						let recent = PHAsset.fetchAssets(in: recentlyDeletedAlbum, options: .none)
						
					
						
						
						
//						fetchOptions.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
//						fetchOptions.predicate = NSPredicate(
//							format: "\(SDKey.mediaType.value) = %d AND (\(SDKey.creationDate.value) >= %@) AND (\(SDKey.creationDate.value) <= %@)",
//							type,
//							lowerDate as NSDate,
//							upperDate as NSDate
//						)
//						albumPhoto.enumerateObjects({(collection, index, object) in
//							completionHandler(PHAsset.fetchAssets(in: collection, options: fetchOptions))
//
						
//						let options = PHFetchOptions()
						
						
						
						
						
//						let results = PHAsset.fetchAssets(withLocalIdentifiers: assetsIdentifiers, options: options)
//						debugPrint(results.count)
//						results.enumerateObjects { asset, index, object in
//							debugPrint(asset.localIdentifier)
//						}
//
//
//
						
//						NSPredicate(format: "localIdentifier = %@", assetsIdentifiers)
						
						
//						let albumChangeRequest = PHAssetCollectionChangeRequest(for: recentlyDeletedAlbum, assets: recent)
//					
						let fastEnumeration = NSArray(array: assets)
//						albumChangeRequest?.removeAssets(fastEnumeration)
//						
//						request.removeAssets(fastEnumeration)
				
//						PHPhotoLibrary.shared()
						
//
//						let assetIdentifiers = assetsToDeleteFromDevice.map({ $0.localIdentifier })
//						let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
					
						
						
			
					}
				} completionHandler: { suxxess, error in
					completion(false)
				}
			}
			
			
			
//			var albumPlaceholder: PHObjectPlaceholder?
//			   PHPhotoLibrary.shared().performChanges({
//				   // Request creating an album with parameter name
//				   let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
//				   // Get a placeholder for the new album
//				   albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
//			   }, completionHandler: { success, error in
//				   if success {
//					   guard let placeholder = albumPlaceholder else {
//						   fatalError("Album placeholder is nil")
//					   }
//
//					   let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
//					   guard let album: PHAssetCollection = fetchResult.firstObject else {
//						   // FetchResult has no PHAssetCollection
//						   return
//					   }
//
//					   // Saved successfully!
//					   print(album.assetCollectionType)
//				   }
//				   else if let e = error {
//					   // Save album failed with error
//				   }
//

//
//
			
//			PHPhotoLibrary.shared().performChanges({
//				   let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//				   let placeholder = assetRequest.placeholderForCreatedAsset
//				   guard let _placeholder = placeholder else { completion(nil); return }
//
//				   let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
//				   albumChangeRequest?.addAssets([_placeholder] as NSFastEnumeration)
//			   }) { success, error in
//				   completion(nil)
//			   }
			
			
		}
		
		recoverPhassetsOperation.name = C.key.operation.name.recoverPhassetsOperation
		return recoverPhassetsOperation
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
		
		let screenShotCountOperation = getScreenShotsOperation(from: startDate, to: endDate) { screenShots in
			totalPartitinAssetsCount[.screenShots] = screenShots.count
			totalProcessingProcess += 1
			if totalProcessingProcess == 5 {
				completion(totalPartitinAssetsCount)
			}
		}

		let livePhotoCountOperation = getLivePhotosOperation(from: startDate, to: endDate) { livePhotos in
			totalPartitinAssetsCount[.livePhotos] = livePhotos.count
			totalProcessingProcess += 1
			if totalProcessingProcess == 5 {
				completion(totalPartitinAssetsCount)
			}
		}
		
		let screenRecordingsVideosOperation = getScreenShotsOperation(from: startDate, to: endDate) { screenRecordsAssets in
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
