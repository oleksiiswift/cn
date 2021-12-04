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
				
				if enableSingleProcessingNotification {
					self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .largeVideo, totalProgressItems: 0, currentProgressItem: 1)
				} else if enableDeepCleanProcessingNotification {
					self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .largeVideo, totalProgressItems: 0, currentProgressItem: 1)
				}
				
				var videos: [PHAsset] = []
				
				if videoContent.count != 0 {
			
					for videosPosition in 1...videoContent.count {
						
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .largeVideo, totalProgressItems: videoContent.count, currentProgressItem: videosPosition)
						} else if enableDeepCleanProcessingNotification {
							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .largeVideo, totalProgressItems: videoContent.count, currentProgressItem: videosPosition)
						}
						
						if videoContent[videosPosition - 1].imageSize > 55000000 {
							videos.append(videoContent[videosPosition - 1])
						}
					}
					
					if enableSingleProcessingNotification {
						self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .largeVideo, totalProgressItems: videoContent.count, currentProgressItem: videoContent.count - 1
						)
					} else if enableDeepCleanProcessingNotification {
						self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .largeVideo, totalProgressItems: videoContent.count, currentProgressItem: videoContent.count - 1)
					}
					
					completionHandler(videos)
				} else {
					
					if enableSingleProcessingNotification {
						self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .largeVideo, totalProgressItems: 1, currentProgressItem: 1)
					} else if enableDeepCleanProcessingNotification {
						self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .largeVideo, totalProgressItems: 1, currentProgressItem: 1)
					}
					
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
				
				if enableSingleProcessingNotification {
					self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .screenRecordings, totalProgressItems: 0, currentProgressItem: 1)
				} else if enableDeepCleanProcessingNotification {
					self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .screenRecordings, totalProgressItems: 0, currentProgressItem: 1)
				}
				
				
				if videoAssets.count != 0 {
					
					for videosPosition in 1...videoAssets.count {
						
						let asset = videoAssets[videosPosition - 1]
						
						if let assetResource = PHAssetResource.assetResources(for: asset).first {
							if assetResource.originalFilename.contains("RPReplay") {
								screenRecords.append(asset)
							}
						}
						
						if enableSingleProcessingNotification {
							self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .screenRecordings, totalProgressItems: videoAssets.count, currentProgressItem: videosPosition)
						} else if enableDeepCleanProcessingNotification {
							self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .screenRecordings, totalProgressItems: videoAssets.count, currentProgressItem: videosPosition)
						}
					}
					completionHandler(screenRecords)
				} else {
					
					if enableSingleProcessingNotification {
						self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .screenRecordings, totalProgressItems: 1, currentProgressItem: 1)
					} else if enableDeepCleanProcessingNotification {
						self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .screenRecordings, totalProgressItems: 1, currentProgressItem: 1)
					}
					completionHandler([])
				}
			}
		}
		
		screenRecordsVideosOperation.name = C.key.operation.name.screenRecordingOperation
		return screenRecordsVideosOperation
		
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
				if enableSingleProcessingNotification {
					self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .screenShots, totalProgressItems: 0, currentProgressItem: 1)
				} else if enableDeepCleanProcessingNotification {
					self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .screenshots, totalProgressItems: 0, currentProgressItem: 1)
				}
				
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
					
					if enableSingleProcessingNotification {
						self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .screenShots, totalProgressItems: 1, currentProgressItem: 1)
					} else if enableDeepCleanProcessingNotification {
						self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .screenshots, totalProgressItems: 1, currentProgressItem: 1)
					}
					
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
				
				if enableSingleProcessingNotification {
					self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .livePhoto, totalProgressItems: 0, currentProgressItem: 1)
				} else if enableDeepCleanProcessingNotification {
//					self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .similarLivePhoto, totalProgressItems: 0, currentProgressItem: 1)
				}
				
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
					
					if enableSingleProcessingNotification {
						self.progressSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .screenShots, totalProgressItems: 1, currentProgressItem: 1)
					} else if enableDeepCleanProcessingNotification {
						self.progressSearchNotificationManager.sendDeepProgressNotificatin(notificationType: .screenshots, totalProgressItems: 1, currentProgressItem: 1)
					}
					
					completionHandler([])
				}
			}
		}
		
		livePhotoOperation.name = C.key.operation.name.livePhotoOperation
		return livePhotoOperation
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
