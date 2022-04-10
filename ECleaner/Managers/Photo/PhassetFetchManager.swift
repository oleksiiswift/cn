//
//  PhassetFetchManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import Photos
import UIKit
import PhotosUI

typealias SDKey = SortingDesriptionKey
enum SortingDesriptionKey {
    case creationDate
    case modification
    case mediaType
    case burstIdentifier
	case singleMediaType
	case allMediaType
    
    var value: String {
        switch self {
          
            case .creationDate:
                return "creationDate"
            case .modification:
                return "modificationDate"
            case .burstIdentifier:
                return "burstIdentifier"
            case .mediaType:
                return "mediaType"
			case .singleMediaType:
				return "mediaType = %d"
			case .allMediaType:
				return "mediaType = %d || mediaType = %d"
        }
    }
}

//		MARK: - FETCH PHASSET MANAGER - LOAD PHASSETS

class PHAssetFetchManager {
	
	static let shared = PHAssetFetchManager()
	
	private static let lowerDateValue: Date = S.defaultLowerDateValue
	private static let upperDateValue: Date = S.defaultUpperDateValue
	
	
	public func fetchTotalAssetsCountOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, completionHandler: @escaping (Int) -> Void) -> ConcurrentProcessOperation {
		
		let fetchTotalPHAssetsOperation = ConcurrentProcessOperation { _ in
			let fetchOptions = PHFetchOptions()
			fetchOptions.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
			fetchOptions.predicate = NSPredicate(format: SDKey.allMediaType.value,
												 PHAssetMediaType.image.rawValue,
												 PHAssetMediaType.video.rawValue,
												 "\(SDKey.mediaType.value) = %d AND (\(SDKey.creationDate.value) >= %@) AND (\(SDKey.creationDate.value) <= %@)",
												 lowerDate as NSDate,
												 upperDate as NSDate)
			let pholeAssets = PHAsset.fetchAssets(with: fetchOptions)
			
			completionHandler(pholeAssets.count)
		}
		fetchTotalPHAssetsOperation.name = C.key.operation.name.fetchPHAssetCount
		return fetchTotalPHAssetsOperation
	}
	
	public func fetchFromGalleryOperation(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, collectiontype: PHAssetCollectionSubtype, by type: Int, completionHandler: @escaping ((_ result: PHFetchResult<PHAsset>) -> Void)) -> ConcurrentProcessOperation {
		
		let fetchFromGalleryOperation = ConcurrentProcessOperation { _ in
			
			let fetchOptions = PHFetchOptions()
			
			let albumPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: collectiontype, options: fetchOptions)
			
			fetchOptions.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
			fetchOptions.predicate = NSPredicate(
				format: "\(SDKey.mediaType.value) = %d AND (\(SDKey.creationDate.value) >= %@) AND (\(SDKey.creationDate.value) <= %@)",
				type,
				lowerDate as NSDate,
				upperDate as NSDate
			)
			albumPhoto.enumerateObjects({(collection, index, object) in
				completionHandler(PHAsset.fetchAssets(in: collection, options: fetchOptions))
			})
		}
		fetchFromGalleryOperation.name = C.key.operation.name.fetchFromGallery
		return fetchFromGalleryOperation
	}
}

extension PHAssetFetchManager {
	
	
    public func fetchTotalAssetsCount(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, completionHandler: @escaping (Int) -> Void) {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
		fetchOptions.predicate = NSPredicate(format: SDKey.allMediaType.value,
											 PHAssetMediaType.image.rawValue,
											 PHAssetMediaType.video.rawValue,
											 "\(SDKey.mediaType.value) = %d AND (\(SDKey.creationDate.value) >= %@) AND (\(SDKey.creationDate.value) <= %@)",
											 lowerDate as NSDate,
											 upperDate as NSDate)
        
        let pholeAssets = PHAsset.fetchAssets(with: fetchOptions)
        
        completionHandler(pholeAssets.count)
    }
    
    public func fetchFromGallery(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, collectiontype: PHAssetCollectionSubtype, by type: Int, completionHandler: @escaping ((_ result: PHFetchResult<PHAsset>) -> Void)) {
        let fetchOptions = PHFetchOptions()
    
        let albumPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: collectiontype, options: fetchOptions)
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
        fetchOptions.predicate = NSPredicate(
            format: "\(SDKey.mediaType.value) = %d AND (\(SDKey.creationDate.value) >= %@) AND (\(SDKey.creationDate.value) <= %@)",
            type,
			lowerDate as NSDate,
			upperDate as NSDate
        )
        albumPhoto.enumerateObjects({(collection, index, object) in
            completionHandler(PHAsset.fetchAssets(in: collection, options: fetchOptions))
        })
    }
    
    public func fetchPhotoCount(from lowerDate: Date = lowerDateValue, to upperDate: Date = upperDateValue, completionHandler: @escaping ((_ photoCount: Int) -> Void)) {
        fetchFromGallery(from: lowerDate, to: upperDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { libraryResult in
            completionHandler(libraryResult.count)
        }
    }
}

extension PHAssetFetchManager {
    
//    MARK: fetch asseets 
    private func fetchAssets(by type: Int) -> PHFetchResult<PHAsset> {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
		fetchOption.predicate = NSPredicate(format: SDKey.singleMediaType.value, type)
        return PHAsset.fetchAssets(with: fetchOption)
    }
    
//    MARK: fetch assets by title
    private func fetchAssetsSubtipe(by type: UInt) -> PHFetchResult<PHAsset> {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
        fetchOption.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", type)
        return PHAsset.fetchAssets(with: fetchOption)
    }
    
//    MARK: fetch assets from collection
    public func fetchImagesFromGallery(collection: PHAssetCollection?) -> PHFetchResult<PHAsset> {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
		fetchOption.predicate = NSPredicate(format: SDKey.allMediaType.value, PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        if let collection = collection {
            return PHAsset.fetchAssets(in: collection, options: fetchOption)
        } else {
            return PHAsset.fetchAssets(with: fetchOption)
        }
    }
//	 MARK: fetch videophassets
	public func fetchVideoPHAssets(completionHandler: @escaping (_ videoPHAssets: [PHAsset]) -> Void) {
		var fetchedVideos: [PHAsset] = []
 		let fetchOption = PHFetchOptions()
		fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
		fetchOption.predicate = NSPredicate(format: SDKey.singleMediaType.value, PHAssetMediaType.video.rawValue)
		let result = PHAsset.fetchAssets(with: fetchOption)
		result.enumerateObjects  { phasset, index, stopped in
			fetchedVideos.append(phasset)
		}
		completionHandler(fetchedVideos)
	}
	
	public func fetchImagesDiskUsageFromGallery(with identifiers: [String], completionHandler: @escaping (Int64) -> Void) {
		
		let fetchOptions = PHFetchOptions()
		let results = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: fetchOptions)
		var analyzingPhassets: Int = 0
		var resultsDiskUssage: Int64 = 0
		results.enumerateObjects { phasset, index, stopped in
			let resource = PHAssetResource.assetResources(for: phasset)
			let fileSize = resource.first?.value(forKey: "fileSize") as! Int64
			
			resultsDiskUssage += fileSize
			analyzingPhassets += 1
			
			if analyzingPhassets == results.count {
				completionHandler(resultsDiskUssage)
			}
		}
	}
	
	public func fetchPhassetFromGallery(with identifiers: [String], completionHandler: @escaping ([PHAsset]) -> Void) {
		
		let fetchOptions = PHFetchOptions()
		let results = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: fetchOptions)
		var fetchedPhassets: [PHAsset] = []
		results.enumerateObjects { phasset, index, stopped in
			fetchedPhassets.append(phasset)
		}
		completionHandler(fetchedPhassets)
	}
    
//     MARK: get thumnail from asset
    public func getThumbnail(from asset: PHAsset, size: CGSize) -> UIImage {
        
        var thumbnail = UIImage()
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
		option.isNetworkAccessAllowed = true
		option.deliveryMode = .opportunistic
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, info) -> Void in
            if let image = result {
            thumbnail = image
            }
        })
        return thumbnail
    }
    
//    MARK: - get image from camera roll -
    public func getImage(from asset: PHAsset, complition: @escaping (UIImage) -> Void) {
        
        var image = UIImage()
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: option, resultHandler: {(result, info) -> Void in
            image = result!
            complition(image)
        })
    }
    
//    MARK: - get image from asset
    public func getImage(from asset: PHAsset) -> UIImage {
        
            var image = UIImage()
            let manager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
        
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            requestOptions.isSynchronous = false
            
        if asset.mediaType == PHAssetMediaType.image {
            manager.requestImage(for: asset,
                targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOptions) { (fetchedImage, info) in
                if let fetchImage = fetchedImage {
                    image = fetchImage
                }
            }
        }
        return image
    }
    
    public func assetSizeFromData(asset: PHAsset, completion: @escaping ((_ result: Int64) -> Void)) {
        var fileSize: Int64 = 0
        let requestOptions = PHImageRequestOptions.init()
        requestOptions.isSynchronous = false
        
        let imageManager = PHImageManager.default()
        
        imageManager.requestImageDataAndOrientation(for: asset, options: requestOptions) { imageData, _, _, _ in
            if imageData != nil {
                fileSize = Int64(imageData!.count)
                debugPrint(fileSize)
                completion(fileSize)
            }
        }
        completion(fileSize)
    }
        
    func statisticPictureAssetsAllSize(items: PHFetchResult<AnyObject>) -> Int64 {
             var fileAllSizeB: Int64 = 0
             let requestOptions = PHImageRequestOptions.init()
             requestOptions.isSynchronous = true
        
                 items.enumerateObjects({ (object, index, isStop) in
                     let imageManager = PHImageManager.default()
                    imageManager.requestImageDataAndOrientation(for: object as! PHAsset, options: requestOptions) { imageData, dataUTI, orientation, info in
                        if imageData != nil {
                            fileAllSizeB += Int64(imageData!.count)
                        }
                    }
                 })
        return fileAllSizeB
    }
}
            
//		MARK: - files count check, space calculated operation -
extension PHAssetFetchManager {
	
		/// `all assets size` - calculated all asset at one
	public func getCalculatedAllPHAssetSizeOperation(result: PHFetchResult<PHAsset>, completionHandler: @escaping (Int64) -> Void) -> ConcurrentProcessOperation {
		
		let calculatedAllPHAssetOperation = ConcurrentProcessOperation(operationName: C.key.operation.name.phassetAllSizes) { operation in
			var phassetCalculetedSize: Int64 = 0
			let requestOptions = PHImageRequestOptions.init()
			requestOptions.isSynchronous = false
			var currentProcessingIndex: Int = 0
			result.enumerateObjects({ (object, index, stopped) in
				let manager = PHImageManager.default()
				manager.requestImageDataAndOrientation(for: object, options: requestOptions) { imageData, _, _, _ in
					currentProcessingIndex += 1
					if imageData != nil {
						phassetCalculetedSize += object.imageSize
						debugPrint(String("\(currentProcessingIndex) -> \(phassetCalculetedSize)"))
					}
				}
			})
			completionHandler(phassetCalculetedSize)
		}
		return calculatedAllPHAssetOperation
	}
	
	public func getLowerUppedDateFromPhasset() -> ConcurrentProcessOperation {
		let dateCalculatedOperation = ConcurrentProcessOperation { _ in
			
			U.GLB(qos: .background, {

				var lowerDateValue: Date {
					return S.lowerBoundSavedDate
				}
				
				var upperDateValue: Date {
					return S.upperBoundSavedDate
				}
				
				let fetchOption = PHFetchOptions()
				fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
				fetchOption.predicate = NSPredicate(format: SDKey.allMediaType.value, PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
				let assets = PHAsset.fetchAssets(with: fetchOption)

				assets.enumerateObjects { object, index, stopped in
					
					if let date = object.creationDate {
						if date.isLessThanDate(dateToCompare: lowerDateValue) {
							S.lowerBoundSavedDate = date
						}
						
						if date.isGreaterThanDate(dateToCompare: upperDateValue) {
							S.upperBoundSavedDate = date
						}
					}
				}
			})
			
		}
		return dateCalculatedOperation
	}
	
		/// `all assets file size, and in one loop get photo video`
	public func getCalculatePHAssetSizesSingleOperation(_ completionHandler: @escaping (_ photoSpace: Int64,_ videoSpace: Int64,_ allAssetsSpace: Int64) -> Void) -> ConcurrentProcessOperation {
		
		let calculatedAllPhassetSpaceOperation = ConcurrentProcessOperation { _ in
			U.GLB(qos: .background, {
				
				var photoLibraryPHAssetCalculatedSpace: Int64 = 0
				var photoPhassetSpace: Int64 = 0
				var videoPhassetSpace: Int64 = 0
				let fetchOption = PHFetchOptions()
				fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
				fetchOption.predicate = NSPredicate(format: SDKey.allMediaType.value, PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
				let assets = PHAsset.fetchAssets(with: fetchOption)
//				var media: [PHAsset] = []
				assets.enumerateObjects { object, index, stopped in
//					debugPrint("calculated space at index: ", index)
//					media.append(object)
					if object.mediaType == .image {
						photoLibraryPHAssetCalculatedSpace += object.imageSize
						photoPhassetSpace += object.imageSize
					} else if object.mediaType == .video {
						photoLibraryPHAssetCalculatedSpace += object.imageSize
						videoPhassetSpace += object.imageSize
					}
				}
				
//				photoPhassetSpace = media.filter({$0.mediaType == .image}).map({$0.imageSize}).sum()
//				videoPhassetSpace = media.filter({$0.mediaType == .video}).map({$0.imageSize}).sum()

//				photoLibraryPHAssetCalculatedSpace = photoPhassetSpace + videoPhassetSpace
				completionHandler(photoPhassetSpace, videoPhassetSpace, photoLibraryPHAssetCalculatedSpace)
			})
		}
		calculatedAllPhassetSpaceOperation.name = C.key.operation.name.phassetSingleSizes
		return calculatedAllPhassetSpaceOperation
	}
}

//		MARK: - RECENTLY DELETED PHASSETS CHECK -
		/// recentle deleted assets fetch methods
extension PHAssetFetchManager {
	
	public func recentlyDeletedAlbumFetchOperation(completionHandler: @escaping (([PHAsset]) -> Void)) -> ConcurrentProcessOperation {
	
		let recentlyDeletedAlbumFetch = ConcurrentProcessOperation { _ in
			self.fetchRecentlyDeletedCollection { collection in
				guard let albumCollection = collection else {
					completionHandler([])
					return
				}

				let result = PHAsset.fetchAssets(in: albumCollection, options: nil)
				var assets = [PHAsset]()

				if result.count != 0 {
					for assetPosition in 1...result.count {
						assets.append(result[assetPosition - 1])
					}
					completionHandler(assets)
					
				} else {
					completionHandler([])
				}
			}
		}
		recentlyDeletedAlbumFetch.name = C.key.operation.name.recentlyDeletedAlbums
		return recentlyDeletedAlbumFetch
	}
	
	public func recentlyDeletdSortedAlbumsFetchOperation(completionHandler: @escaping ((_ photosAssets: [PHAsset],_ videoAssets: [PHAsset]) -> Void)) -> ConcurrentProcessOperation {
		
		let recentlyDeletedAlbumsSortFetch = ConcurrentProcessOperation { operation in
			
			self.fetchRecentlyDeletedCollection { collection in
				
				guard let recentlyDeletedCollection = collection else { return completionHandler([], [])}
				
				var photoAssets: [PHAsset] = []
				var videoAssets: [PHAsset] = []
				
				let photoFetchOptions = PHFetchOptions()
				let videoFetchOptions = PHFetchOptions()
				
				photoFetchOptions.predicate = NSPredicate(format: SDKey.singleMediaType.value, PHAssetMediaType.image.rawValue)
				videoFetchOptions.predicate = NSPredicate(format: SDKey.singleMediaType.value, PHAssetMediaType.video.rawValue)
				
				let photoResult = PHAsset.fetchAssets(in: recentlyDeletedCollection, options: photoFetchOptions)
				let videoResult = PHAsset.fetchAssets(in: recentlyDeletedCollection, options: videoFetchOptions)
				
				if photoResult.count != 0 && videoResult.count != 0 {
			
					for photoAssetPosition in 1...photoResult.count {
						if operation.isCancelled {
							completionHandler([], [])
							return
						}
						photoAssets.append(photoResult[photoAssetPosition - 1])
					}
					
					for videoAssetPosion in 1...videoResult.count {
						if operation.isCancelled {
							completionHandler([], [])
							return
						}
						videoAssets.append(videoResult[videoAssetPosion - 1])
					}
					completionHandler(photoAssets, videoAssets)
				} else if photoResult.count != 0 && videoResult.count == 0 {
					for photoAssetPosition in 1...photoResult.count {
						if operation.isCancelled {
							completionHandler([], [])
							return
						}
						photoAssets.append(photoResult[photoAssetPosition - 1])
					}
					
					completionHandler(photoAssets, [])
				} else if photoAssets.count == 0 && videoResult.count != 0 {
					for videoAssetPosion in 1...videoResult.count {
						if operation.isCancelled {
							completionHandler([], [])
							return
						}
						videoAssets.append(videoResult[videoAssetPosion - 1])
					}
					completionHandler([], videoAssets)
				} else {
					completionHandler([], [])
				}
			}
		}
		recentlyDeletedAlbumsSortFetch.name = CommonOperationSearchType.recentlyDeletedOperation.rawValue
		return recentlyDeletedAlbumsSortFetch
	}
	
	public func fetchRecentlyDeletedCollection(completionHandler: @escaping ((PHAssetCollection?) -> Void)) {
		
		let result = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
		
		for i in 0..<result.count {
			let album = result[i]
			
			if album.localizedTitle == "Recently Deleted" {
				 completionHandler(album)
			}
		}
	}
}

//		MARK: - UTILS -
extension PHAssetFetchManager {
	
}
