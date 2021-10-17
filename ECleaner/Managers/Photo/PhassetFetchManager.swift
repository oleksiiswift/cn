//
//  PhassetFetchManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import Photos
import UIKit

typealias SDKey = SortingDesriptionKey
enum SortingDesriptionKey {
    case creationDate
    case modification
    case mediaType
    case burstIdentifier
    
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
        }
    }
}

class PHAssetFetchManager {
    
    static let shared = PHAssetFetchManager()

    public func fetchTotalAssetsCount(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", completionHandler: @escaping (Int) -> Void) {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue, "\(SDKey.mediaType.value) = %d AND (\(SDKey.creationDate.value) >= %@) AND (\(SDKey.creationDate.value) <= %@)",
                                                         startDate.NSDateConverter(format: C.dateFormat.fullDmy),
                                                         endDate.NSDateConverter(format: C.dateFormat.fullDmy))
        
        let pholeAssets = PHAsset.fetchAssets(with: fetchOptions)
        
        completionHandler(pholeAssets.count)
    }
    
    public func fetchFromGallery(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", collectiontype: PHAssetCollectionSubtype, by type: Int, completionHandler: @escaping ((_ result: PHFetchResult<PHAsset>) -> Void)) {
        let fetchOptions = PHFetchOptions()
    
        let albumPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: collectiontype, options: fetchOptions)
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
        fetchOptions.predicate = NSPredicate(
            format: "\(SDKey.mediaType.value) = %d AND (\(SDKey.creationDate.value) >= %@) AND (\(SDKey.creationDate.value) <= %@)",
            type,
            startDate.NSDateConverter(format: C.dateFormat.fullDmy),
            endDate.NSDateConverter(format: C.dateFormat.fullDmy)
        )
        albumPhoto.enumerateObjects({(collection, index, object) in
            completionHandler(PHAsset.fetchAssets(in: collection, options: fetchOptions))
        })
    }
    
    public func fetchPhotoCount(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", completionHandler: @escaping ((_ photoCount: Int) -> Void)) {
        fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { libraryResult in
            completionHandler(libraryResult.count)
        }
    }
}

extension PHAssetFetchManager {
    
//    MARK: fetch asseets 
    private func fetchAssets(by type: Int) -> PHFetchResult<PHAsset> {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
        fetchOption.predicate = NSPredicate(format: "mediaType == %d", type)
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
        fetchOption.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        if let collection = collection {
            return PHAsset.fetchAssets(in: collection, options: fetchOption)
        } else {
            return PHAsset.fetchAssets(with: fetchOption)
        }
    }
    
//     MARK: get thumnail from asset
    public func getThumbnail(from asset: PHAsset, size: CGSize) -> UIImage {
        
        var thumbnail = UIImage()
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        
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
    
//    MARK: - all assets size -
    public func calculateAllAssetsSize(result: PHFetchResult<PHAsset>) -> Int64 {
        var allSize: Int64 = 0

        let requestOptions = PHImageRequestOptions.init()
        
        requestOptions.isSynchronous = false
        
        var numbers = 0
        result.enumerateObjects({ (object, index, stopped) in
            let manager = PHImageManager.default()
            manager.requestImageDataAndOrientation(for: object, options: requestOptions) { imageData, _, _, _ in
                numbers += 1
                
                if imageData != nil {
                    allSize += object.imageSize
                    debugPrint(String("\(numbers) -> \(allSize)"))
//                         Int64(imageData!.count)
                }
            }
        })
        return allSize
    }
    
    public func gitAllCalculatedPhassetsSize(_ completionHandler: @escaping (_ photoSpace: Int64,_ videoSpace: Int64,_ allAssetsSpace: Int64) -> Void) {
        var allSpaceSize: Int64 = 0
        var photoPhassetSpace: Int64 = 0
        var videoPhassetSpace: Int64 = 0
            
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
        fetchOption.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        
        let assets = PHAsset.fetchAssets(with: fetchOption)
        
        assets.enumerateObjects { object, index, stopped in
            debugPrint("calculated space at index: ", index)
            if object.mediaType == .image {
                allSpaceSize += object.imageSize
                photoPhassetSpace += object.imageSize
            } else if object.mediaType == .video {
                allSpaceSize += object.imageSize
                videoPhassetSpace += object.imageSize
            }
        }
        completionHandler(photoPhassetSpace, videoPhassetSpace, allSpaceSize)
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
            
//  MARK: recentle deleted assets fetch methods
extension PHAssetFetchManager {
 
    public func recentlyDeletedAlbumFetch(completionHandler: @escaping (([PHAsset]) -> Void)) {

        fetchRecentlyDeletedCollection { collection in
            guard let albumCollection = collection else {
                completionHandler([])
                return
            }

            let result = PHAsset.fetchAssets(in: albumCollection, options: nil)
            var assets = [PHAsset]()

            if result.count == 0 {
                U.UI {
                    completionHandler([])
                }
                return
            }

            for assetPosition in 1...result.count {
                assets.append(result[assetPosition - 1])
            }
            
            U.UI {
                completionHandler(assets)
            }
            completionHandler(assets)
        }
    }
    
    public func recentlyDeletedSortedAlbumFetch(completionHandler: @escaping ((_ photosAssets: [PHAsset],_ videoAssets: [PHAsset]) -> Void)) {
        
        fetchRecentlyDeletedCollection { collection in
            
            guard let recentlyDeletedCollection = collection else { return completionHandler([], [])}
            
            var photoAssets: [PHAsset] = []
            var videoAssets: [PHAsset] = []
            
            let photoFetchOptions = PHFetchOptions()
            let videoFetchOptions = PHFetchOptions()
            
            photoFetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            videoFetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            
            let photoResult = PHAsset.fetchAssets(in: recentlyDeletedCollection, options: photoFetchOptions)
            let videoResult = PHAsset.fetchAssets(in: recentlyDeletedCollection, options: videoFetchOptions)
            
            if photoResult.count == 0 && videoResult.count == 0 {
                U.UI {
                    completionHandler([], [])
                }
                return
            }
            
            for photoAssetPosition in 1...photoResult.count {
                photoAssets.append(photoResult[photoAssetPosition - 1])
            }
            
            for videoAssetPosion in 1...videoResult.count {
                videoAssets.append(videoResult[videoAssetPosion - 1])
            }
            
            U.UI {
                completionHandler(photoAssets, videoAssets)
            }
        }
    }
    
    private func fetchRecentlyDeletedCollection(completionHandler: @escaping ((PHAssetCollection?) -> Void)) {
        
        let result = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        for i in 0..<result.count {
            let album = result[i]
            
            if album.localizedTitle == "Recently Deleted" {
                 completionHandler(album)
            }
        }
    }
}

extension PHAsset {
    
    var imageSize: Int64 {
        
        let resources = PHAssetResource.assetResources(for: self)
        var fileDiskSpace: Int64 = 0
        
        if let resource = resources.first {
            if let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {
                fileDiskSpace = Int64(bitPattern: UInt64(unsignedInt64))
            }
        }
        return fileDiskSpace
    }
}
