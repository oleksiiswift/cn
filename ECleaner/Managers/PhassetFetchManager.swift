//
//  PhassetFetchManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import Photos
import UIKit

enum SortingDesriptionKey {
    case creationDate
    case modification
    case burstIdentifier
    
    var value: String {
        switch self {
          
            case .creationDate:
                return "creationDate"
            case .modification:
                return "modificationDate"
            case .burstIdentifier:
                return "burstIdentifier"
        }
    }
}



class PHAssetFetchManager {
    
    static let shared = PHAssetFetchManager()
    
    public func fetchAssets(by type: Int) -> PHFetchResult<PHAsset> {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
        fetchOption.predicate = NSPredicate(format: "mediaType == %d", type)
        return PHAsset.fetchAssets(with: fetchOption)
    }
    
    public func fetchAssetsSubtipe(by type: UInt) -> PHFetchResult<PHAsset> {
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
            requestOptions.isSynchronous = true
            
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
}

