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
    
    public func fetchFromGallery(from startDate: String = "01-01-1970", to endDate: String = "01-01-2666", collectiontype: PHAssetCollectionSubtype, by type: Int, completionHandler: @escaping ((_ result: PHFetchResult<PHAsset>) -> Void)) {
        let fetchOptions = PHFetchOptions()
    
        let albumPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: collectiontype, options: fetchOptions)
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
        fetchOptions.predicate = NSPredicate(
            format: "\(SDKey.mediaType.value) = %d AND (\(SDKey.creationDate.value) >= %@) AND (\(SDKey.creationDate.value) <= %@)",
            type,
            startDate.NSDateConverter(format: C.dateFormat.dmy),
            endDate.NSDateConverter(format: C.dateFormat.dmy)
        )
        albumPhoto.enumerateObjects({(collection, index, object) in
            completionHandler(PHAsset.fetchAssets(in: collection, options: fetchOptions))
        })
    }
    
    public func fetchPhotoCount(from startDate: String = "01-01-1970", to endDate: String = "01-01-2666", completionHandler: @escaping ((_ photoCount: Int) -> Void)) {
        fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { libraryResult in
            completionHandler(libraryResult.count)
        }
    }
}

extension PHAssetFetchManager {
    
    
    private func fetchAssets(by type: Int) -> PHFetchResult<PHAsset> {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
        fetchOption.predicate = NSPredicate(format: "mediaType == %d", type)
        return PHAsset.fetchAssets(with: fetchOption)
    }
    
    private func fetchAssetsSubtipe(by type: UInt) -> PHFetchResult<PHAsset> {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
        fetchOption.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", type)
        return PHAsset.fetchAssets(with: fetchOption)
    }
    
    
    public func someFetch() {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
//        fetchOption.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        let stre = "People".localized()
        fetchOption.predicate = NSPredicate(format: "title = %@", stre, PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
//        "title = %@", "People"
        
    
        let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumSyncedFaces, options: nil)

          albumsPhoto.enumerateObjects({(collection, index, object) in
              let photoInAlbum = PHAsset.fetchAssets(in: collection, options: nil)
                  print(photoInAlbum.count)
                  print(collection.localizedTitle)

          })
        
    }
    
    
    
//    MARK: fetch assets from collection
    private func fetchImagesFromGallery(collection: PHAssetCollection?) -> PHFetchResult<PHAsset> {
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
        
        option.isSynchronous = false
        
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            if let image = result {
            thumbnail = image
            }
            thumbnail = result!
        })
        return thumbnail
    }
    
//    MARK: - get image from camera roll -
    public func getImage(from asset: PHAsset, complition: @escaping (UIImage) -> Void) {
        
        var image = UIImage()
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: option, resultHandler: {(result, info)->Void in
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
    
    
    
    //    func statisticPictureAssetsAllSize(items: PHFetchResult) -> Int64 {
    //         var fileAllSizeB: Int64 = 0
    //         let requestOptions = PHImageRequestOptions.init()
    //         requestOptions.isSynchronous = true
    //             items.fetchResult?.enumerateObjects({ (object, index, isStop) in
    //                 let imageManager = PHImageManager.default()
    //                 imageManager.requestImageData(for: object as! PHAsset, options: requestOptions, resultHandler: { (imageData, dataUTI, orientation, info) in
    //                     if imageData != nil {
    //                                                  fileAllSizeB += Int64(imageData!.count); // image size, unit B
    //                     }
    //                 })
    //             })
    //         }
    //
    //         return fileAllSizeB
    //}

    
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
