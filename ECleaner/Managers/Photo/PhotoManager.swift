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
	private var deepCleanProgressNotificationManager = DeepCleanNotificationManager.instance
	private var singleSearchNotificationManager = SingleSearchNitificationManager.instance

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
		let calculatedAllDiskSpaceOperation = fetchManager.getCalculatePHAssetSizesSingleOperation { photoSpace, videoSpace, allAssetsSpace in
			S.phassetPhotoFilesSizes = photoSpace
			S.phassetVideoFilesSizes = videoSpace
			S.phassetFilesSize = allAssetsSpace
		}
		
		if !serviceUtilsCalculatedOperationsQueuer.operations.contains(where: {$0.name == calculatedAllDiskSpaceOperation.name}) {
			serviceUtilsCalculatedOperationsQueuer.addOperation(calculatedAllDiskSpaceOperation)
		}
		
		
		
		
	}
}


//	MARK: - VIDEO PROCESSING -
extension PhotoManager {
	
	public func getLargevideoContentOperation(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", enableDeepCleanProcessingNotification: Bool = false, enableSingleProcessingNotification: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let largeVideoProcessingOperation = ConcurrentProcessOperation { _ in
			
			self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
				
				if enableSingleProcessingNotification {
					self.singleSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: .largeVideo, totalProgressItems: 0, currentProgressItem: 1)
				} else if enableDeepCleanProcessingNotification {
					self.deepCleanProgressNotificationManager.sendDeepProgressNotificatin(notificationType: <#T##DeepCleanNotificationType#>, totalProgressItems: <#T##Int#>, currentProgressItem: <#T##Int#>)
				}
				
				
				
				
				var videos: [PHAsset] = []
				
				if videoContent.count != 0 {
			
					for videosPosition in 1...videoContent.count {
						if self.singleSearchNotificationManager.sendSingleSearchProgressNotification(notificationtype: ., totalProgressItems: <#T##Int#>, currentProgressItem: <#T##Int#>)
						
						
						
						if videoContent[videosPosition - 1].imageSize > 55000000 {
							videos.append(videoContent[videosPosition - 1])
						}
						
						if enableSingleProcessingNotification {
							
						}
						
						if isDeepCleanScan {
							self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .largeVideo,
																						 totalProgressItems: videoContent.count,
																						 currentProgressItem: videosPosition)
						}
					}
					
					
					
					
					if !isDeepCleanScan {
						U.UI {
							completionHandler(videos)
						}
					} else {
						completionHandler(videos)
					}
				} else {
					completionHandler([])
				}
			}
			
		}
	}
}

extension PhotoManager {
	

}


