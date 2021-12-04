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

class PhotoManager: NSObject {
	
	static let shared: PhotoManagerOLD = {
		let instance = PhotoManagerOLD()
		return instance
	}()
	
	private var fetchManager = PHAssetFetchManager.shared
	private var progressSearchNotificationManager = ProgressSearchNotificationManager.instance

	public let phassetProcessingOperationQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.phassets, maxConcurrentOperationCount: 10, qualityOfService: .background)
	public let serviceUtilsCalculatedOperationsQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.utils, maxConcurrentOperationCount: 10, qualityOfService: .background)
	
	var assetCollection: PHAssetCollection?
	
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
	
	public func getLargevideoContentOperation(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let largeVideoProcessingOperation = ConcurrentProcessOperation { _ in
			
			self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
				
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
		largeVideoProcessingOperation.name = C.key.operation.name.largeVideo
		return largeVideoProcessingOperation
	}
	
		/// `screen recordings` from gallery
	public func getScreenRecordsVideosOperation(from startDate: String = "01-01-1917 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ screenRecordsAssets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let screenRecordsVideosOperation = ConcurrentProcessOperation { _ in
			
			self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoAssets in
				
				var screenRecords: [PHAsset] = []
			
				if videoAssets.count != 0 {
					
					for videosPosition in 1...videoAssets.count {
						
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
		
		screenRecordsVideosOperation.name = C.key.operation.name.screenRecordingOperation
		return screenRecordsVideosOperation
	}
}

//		MARK: - VIDEO SIMILAR DUPLICATED PROCESSING -
extension PhotoManager {
	
		/// `similar Videos` from gallery
	public func getSimilarVideoAssetsOperation(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false,  completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation
	{
	
	let similarVideoAssetsOperation = ConcurrentProcessOperation { _ in
		
		self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
			
			var assets: [PHAsset] = []
			
			if videoContent.count != 0 {
				
				for videoPosition in 1...videoContent.count {
					let asset = videoContent[videoPosition - 1]
					assets.append(asset)
				}

				let similarVideoPhassetOperation = self.findDuplicatedVideoOperation(assets: assets, strictness: .similar, enableDeepCleanProcessingNotification: enableDeepCleanProcessingNotification, enableSingleProcessingNotification: enableSingleProcessingNotification) { phassetCroup in
					completionHandler(phassetCroup)
				}
				
				self.serviceUtilsCalculatedOperationsQueuer.addOperation(similarVideoPhassetOperation)
				
			} else {
				completionHandler([])
			}
		}
	}
	
	similarVideoAssetsOperation.name = C.key.operation.name.similarVideoProcessingOperation
	return similarVideoAssetsOperation
	
	}
	
		/// `duplicated videos compare algorithm`
	public func getDuplicatedVideoAssetOperation(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
		
		let duplicatedVideoAssetsOperation = ConcurrentProcessOperation { _ in
			
			self.fetchManager.fetchFromGallery(from: startDate,
											   to: endDate,
											   collectiontype: .smartAlbumVideos,
											   by: PHAssetMediaType.video.rawValue) { videoCollection in
				var videos: [OSTuple<NSString, NSData>] = []
				
				
				if videoCollection.count != 0 {
					for index in 1...videoCollection.count {
						
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
								duplicateVideoGroups.append(PhassetGroup(name: "", assets: groupAssets))
							}
						}
					}
					completionHandler(duplicateVideoGroups)
				} else {
					completionHandler([])
				}
			}
		}
		
		duplicatedVideoAssetsOperation.name = C.key.operation.name.duplicateVideoProcessingOperation
		return duplicatedVideoAssetsOperation
	}
	
		/// `similar videos by time stamp`
	public func getSimilarVideosByTimeStampOperation(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
		
		let similarVideosByTimeStampOperation = ConcurrentProcessOperation { _ in
			
			self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
				
				var assets: [PHAsset] = []
				var grouped: [PhassetGroup] = []
				
				if videoContent.count != 0 {
					
					for videoPosition in 1...videoContent.count {
						assets.append(videoContent[videoPosition - 1])
					}
					
					for video in assets {
						var compareAsset: [PHAsset] = []
						debugPrint("->>>>>>>>>>")
						debugPrint(video.localIdentifier)
						
						for check in assets {
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
							grouped.append(PhassetGroup.init(name: "", assets: compareAsset))
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
	public func getSelfiePhotosOperation(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let photoSelfiesOperation = ConcurrentProcessOperation { _ in
			
			self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumSelfPortraits, by: PHAssetMediaType.image.rawValue) { selfiesInLibrary in
				var selfies: [PHAsset] = []
				
				if selfiesInLibrary.count != 0 {
					for selfiePos in 1...selfiesInLibrary.count {
						selfies.append(selfiesInLibrary[selfiePos - 1])
					}
					completionHandler(selfies)
				} else {
					completionHandler([])
				}
			}
		}
		
		photoSelfiesOperation.name = C.key.operation.name.photoSelfiesOperation
		return photoSelfiesOperation
	}
	
		/// `load screenshots` from gallery
	public func getScreenShotsOperation(from startDate: String = "01-01-1917 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let getScreenShotsOperation = ConcurrentProcessOperation { _ in
			
			self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumScreenshots, by: PHAssetMediaType.image.rawValue) { screensShotsLibrary in
				
				var screens: [PHAsset] = []
	
				if screensShotsLibrary.count != 0 {
					
					for screensPos in 1...screensShotsLibrary.count {
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
		
		getScreenShotsOperation.name = C.key.operation.name.screenShotsOperation
		return getScreenShotsOperation
	}
	
			/// `load live photos` from gallery
	public func getLivePhotosOperation(from startDate: String = "01-01-1917 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let livePhotoOperation = ConcurrentProcessOperation { _ in
			
			self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotosLibrary in
				
				var livePhotos: [PHAsset] = []
				if livePhotosLibrary.count != 0 {
					
					for livePhotoPosition in 1...livePhotosLibrary.count {
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
		
		livePhotoOperation.name = C.key.operation.name.livePhotoOperation
		return livePhotoOperation
	}
}

//		MARK: - PHOTO DUPLICATE SIMILAR PROCESSING -
extension PhotoManager {
	
		/// `simmilar photo algoritm`
	public func getSimilarPhotosAssetsOperation(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", fileSizeCheck: Bool = false, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
		
		let similarPhotoProcessingOperation = ConcurrentProcessOperation { _ in
			
			self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photosInGallery in
				
				var group: [PhassetGroup] = []
				var containsAdd: [Int] = []
				var similarPhotos: [(asset: PHAsset, date: Int64, imageSize: Int64)] = []
				
				similarPhotos.reserveCapacity(photosInGallery.count)
				
				
				if photosInGallery.count != 0 {
					
					for index in 1...photosInGallery.count {
						debugPrint("index preocessing duplicate")
						debugPrint("index \(index)")
						
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
							group.append(PhassetGroup(name: "", assets: similar))
						}
					}
					
					completionHandler(group)
				} else {
					completionHandler([])
				}
			}
		}
		similarPhotoProcessingOperation.name = C.key.operation.name.similarPhotoProcessingOperation
		return similarPhotoProcessingOperation
	}
	
		/// `load simmiliar live photo` from gallery
		public func getSimilarLivePhotosOperation(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
			
			let similarLivePhotoProcessingOperation = ConcurrentProcessOperation { _ in
			
				self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotoGallery in
				
					var livePhotos: [OSTuple<NSString, NSData>] = []
					
					if livePhotoGallery.count != 0 {
						for livePosition in 1...livePhotoGallery.count {
							debugPrint("live photo position", livePosition)
							
							if enableSingleProcessingNotification {
								self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .similarLivePhoto,
																											totalProgressItems: livePhotoGallery.count,
																											currentProgressItem: livePosition)
							} else  if enableDeepCleanProcessingNotification {
								self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .similarLivePhoto,
																						 totalProgressItems: livePhotoGallery.count,
																						 currentProgressItem: livePosition)
							}
							
							let image = self.fetchManager.getThumbnail(from: livePhotoGallery[livePosition - 1], size: CGSize(width: 150, height: 150))
							if let data = image.jpegData(compressionQuality: 0.8) {
								let tuple = OSTuple<NSString, NSData>(first: "image\(livePosition)" as NSString, andSecond: data as NSData)
								livePhotos.append(tuple)
							}
						}
						
						let duplicatedTuplesOperation = self.getDuplicatedTuplesOperation(for: livePhotos,
																							 photosInGallery: livePhotoGallery,
																							 isDeepCleanScan: enableDeepCleanProcessingNotification) { similarLivePhotoGroup in
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
	public func getDuplicatedPhotosAsset(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) -> ConcurrentProcessOperation {
		
		let duplicatedPhotoAssetOperation = ConcurrentProcessOperation { _ in
			
			
			self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photoGallery in
				
				var photos: [OSTuple<NSString, NSData>] = []
				
				if photoGallery.count != 0 {
					
					
					for photoPos in 1...photoGallery.count {
						debugPrint("loading duplicate")
						debugPrint("photoposition \(photoPos)")
						
							/// adding notification to handle progress similar photos processing
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .duplicatedPhoto,
																										totalProgressItems: photoGallery.count,
																										currentProgressItem: photoPos)
						} else {
							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .duplicatePhoto,
																							   totalProgressItems: photoGallery.count,
																							   currentProgressItem: photoPos)
						}
						
						let image = self.fetchManager.getThumbnail(from: photoGallery[photoPos - 1], size: CGSize(width: 150, height: 150))
						if let data = image.jpegData(compressionQuality: 0.8) {
							let tuple = OSTuple<NSString, NSData>(first: "image\(photoPos)" as NSString, andSecond: data as NSData)
							photos.append(tuple)
						}
					}
					
					let duplicatedTuplesOperation = self.getDuplicatedTuplesOperation(for: photos, photosInGallery: photoGallery) { duplicatedPhotoAssetsGroup in
						completionHandler(duplicatedPhotoAssetsGroup)
					}
					
					self.serviceUtilsCalculatedOperationsQueuer.addOperation(duplicatedTuplesOperation)
					
				} else {
					completionHandler([])
				}
			}
		}
		duplicatedPhotoAssetOperation.name = C.key.operation.name.duplicatePhotoProcessingOperation
		return duplicatedPhotoAssetOperation
	}
}

//		MARK: - HELPER DUPLICATEDS TYPE SEARCH -
extension PhotoManager {
	
		/// `private duplicated tuples` need for service compare
	private func getDuplicatedTuplesOperation(for photos: [OSTuple<NSString, NSData>], photosInGallery: PHFetchResult<PHAsset>, isDeepCleanScan: Bool = false, completionHandler: @escaping ([PhassetGroup]) -> Void) -> ConcurrentProcessOperation{
		
		let serviceUtilityDuplicatedTuplesOperation = ConcurrentProcessOperation { _ in
			
			var duplicatedPhotosCount: [Int] = []
			var duplicatedGroup: [PhassetGroup] = []
			let duplicatedIDS = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: photos)
			
			
			guard duplicatedIDS.count >= 1 else {
				completionHandler([])
				return
			}
			
			for currentPosition in 1...duplicatedIDS.count {
				let duplicatedTuple = duplicatedIDS[currentPosition - 1]
				var group: [PHAsset] = []
				
				debugPrint("checkDuplicated")
				debugPrint("position \(currentPosition)")
				
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
						duplicatedGroup.append(PhassetGroup(name: "", assets: group))
					}
				}
			}
			
			completionHandler(duplicatedGroup)
		}
		
		serviceUtilityDuplicatedTuplesOperation.name = C.key.operation.name.similarTuplesOperation
		return serviceUtilityDuplicatedTuplesOperation
	}
	
		/// similar close to identical videos algoritm
	public func findDuplicatedVideoOperation(assets: [PHAsset], strictness: Strictness, enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ([PhassetGroup]) -> Void) -> ConcurrentProcessOperation {
		
		let duplicatedVideoOperation = ConcurrentProcessOperation { _ in
			
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
			
			var notificationStarterIndex = 1
			
			for pair in similarImageIdsAsTuples {
				
				if enableSingleProcessingNotification {
					self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .similarVideo,
																								totalProgressItems: similarImageIdsAsTuples.count,
																								currentProgressItem: notificationStarterIndex)
					
					notificationStarterIndex += 1
				} else if enableDeepCleanProcessingNotification {
					self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .similarVideo,
																					   totalProgressItems: similarImageIdsAsTuples.count,
																					   currentProgressItem: notificationStarterIndex)
					notificationStarterIndex += 1
				}
				
				let assetIndex1 = Int(pair.first! as String)!
				let assetIndex2 = Int(pair.second! as String)!
				let asset1 = assets[assetIndex1]
				let asset2 = assets[assetIndex2]
				let groupIndex1 = assetToGroupIndex[asset1]
				let groupIndex2 = assetToGroupIndex[asset2]
				if groupIndex1 == nil && groupIndex2 == nil {
					
					let group = PhassetGroup.init(name: "", assets: [asset1, asset2])
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
				
			}
			completionHandler(phassetGroup)
		}
		duplicatedVideoOperation.name = C.key.operation.name.findDuplicatedVideoOperation
		return duplicatedVideoOperation
	}
}


extension PhotoManager {
	
	public func deleteSelectedOperation(assets: [PHAsset], completion: @escaping ((Bool) -> Void)) -> ConcurrentProcessOperation {
		
		let deletePhassetsOperation = ConcurrentProcessOperation {_ in
			
			let assetsSelectedIdentifiers = assets.map({ $0.localIdentifier})
			
			let deletedAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetsSelectedIdentifiers, options: nil)
			
			PHPhotoLibrary.shared().performChanges {
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



















//		MARK: - temporary not in use
extension PhotoManager {
	
	public func getPhotoAssetsCount(from startDate: String, to endDate: String, completion: @escaping (Int) -> Void) {
		
		self.fetchManager.fetchTotalAssetsCount(from: startDate, to: endDate) { totalCount in
			completion(totalCount)
		}
	}
	
	public func getPartitionalMediaAssetsCount(from startDate: String, to endDate: String, completion: @escaping ([AssetsGroupType: Int]) -> Void) {
		
//		var totalProcessingProcess = 0
//
//		var totalPartitinAssetsCount: [AssetsGroupType : Int] = [.photo : 0, // get all photo count
//																 .screenShots : 0, // get all screenshots
//																 .livePhotos : 0, // get all live photosCount
//																 .video : 0, // get all videos
//																 .screenRecordings : 0] // get all screen recordings
//
//		self.fetchManager.fetchPhotoCount(from: startDate, to: endDate) { photoCount in
//			totalPartitinAssetsCount[.photo] = photoCount
//
//			totalProcessingProcess += 1
//			if totalProcessingProcess == 5 {
//				completion(totalPartitinAssetsCount)
//			}
//		}
//
//		self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { result in
//			totalPartitinAssetsCount[.video] = result.count
//
//			totalProcessingProcess += 1
//			if totalProcessingProcess == 5 {
//				completion(totalPartitinAssetsCount)
//			}
//		}
//
//		self.getScreenShots(from: startDate, to: endDate, isDeepCleanScan: false) { assets in
//			totalPartitinAssetsCount[.screenShots] = assets.count
//
//			totalProcessingProcess += 1
//			if totalProcessingProcess == 5 {
//				completion(totalPartitinAssetsCount)
//			}
//		}
//
//		self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { result in
//			totalPartitinAssetsCount[.livePhotos] = result.count
//
//			totalProcessingProcess += 1
//			if totalProcessingProcess == 5 {
//				completion(totalPartitinAssetsCount)
//			}
//		}
//
//		self.getScreenRecordsVideos(from: startDate, to: endDate, isDeepCleanScan: false) { screenRecordsAssets in
//			totalPartitinAssetsCount[.screenRecordings] = screenRecordsAssets.count
//
//			totalProcessingProcess += 1
//			if totalProcessingProcess == 5 {
//				completion(totalPartitinAssetsCount)
//			}
//		}
	}
}
