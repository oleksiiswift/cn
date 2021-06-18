//
//  PhassetFetchManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import Photos
import UIKit

class PhassetFetchManager {
    
    static let shared = PhassetFetchManager()
    
    
//    private var resultPhotos: PHFetchResult<PHAsset>!
//    private func fetchImagesFromGallery(collection: PHAssetCollection?) {
//        U.UI {
//            let fetchOption = PHFetchOptions()
//            fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//            fetchOption.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
//            if let collection = collection {
//                self.resultPhotos = PHAsset.fetchAssets(in: collection, options: fetchOption)
//            } else {
//                self.resultPhotos = PHAsset.fetchAssets(with: fetchOption)
//                self.collectionTitleTextLabel.text = L.cellTitles.allMedia
//            }
//            self.collectionView.reloadData()
//        }
//    }
//
//
    
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


