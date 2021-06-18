//
//  PhotoManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import Foundation
import PhotosUI
import Photos


class PhotoManager: NSObject {
    
    private static let shared = PhotoManager()
    
    public override init() {
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    
    
    static var manager: PhotoManager {
        return self.shared
    }
    
    public func getPhotoLibrary() {
        
        photoLibraryRequestAuth { accessGranted in
            if accessGranted {
                debugPrint("try fetch photos")
            } else {
                AlertManager.showOpenSettingsAlert(.allowPhotoLibrary)
            }
        }
    }
    

    
    //extension PHAsset {
    //
    ////    MARK: - get thumbnail image from camera roll -
    //    func getThumbnail(size: CGSize) -> UIImage {
    //        var thumbnail = UIImage()
    //        let manager = PHImageManager.default()
    //        let option = PHImageRequestOptions()
    //        option.isSynchronous = true
    //        manager.requestImage(for: self,
    //                             targetSize: size,
    //                             contentMode: .aspectFill,
    //                             options: option,
    //                             resultHandler: {(result, info)->Void in
    //                                if let image = result {
    //                                    thumbnail = image
    //                                }
    //            thumbnail = result!
    //        })
    //        return thumbnail
    //    }
    
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
//}
  
    

    
//    /extension PHAssetCollection {
    //
    //    func getCoverImageSize(_ size: CGSize) -> UIImage {
    //        var image = UIImage()
    //        let assets = PHAsset.fetchAssets(in: self, options: nil)
    //        let asset = assets.firstObject
    //        if let thumbImage = asset?.getThumbnail(size: size) {
    //            image = thumbImage
    //        }
    //        return image
    //    }
    //
    //    func hasAssets() -> Bool {
    //        let assets = PHAsset.fetchAssets(in: self, options: nil)
    //        return assets.count > 0
    //    }
    //}
    
    
//    MARK: - authentification
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
}

extension PhotoManager: PHPhotoLibraryChangeObserver {
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        U.UI {
            self.getPhotoLibrary()
            PhassetFetchManager().getImage(from: <#T##PHAsset#>, complition: <#T##(UIImage) -> Void#>)
        }
    }
}

//
//func photoLibraryDidChange(_ changeInstance: PHChange) {
//
//    ...
//
//    DispatchQueue.main.sync {
//        let originalCount = fetchResult.count
//        fetchResult = changes.fetchResultAfterChanges
//        if changes.hasIncrementalChanges {
//
//
//        } else {
//            collectionView!.reloadData()
//        }
//
//        ...
//
//    }
//}

//
//extension PHAssetCollection {
//
//    func getCoverImageSize(_ size: CGSize) -> UIImage {
//        var image = UIImage()
//        let assets = PHAsset.fetchAssets(in: self, options: nil)
//        let asset = assets.firstObject
//        if let thumbImage = asset?.getThumbnail(size: size) {
//            image = thumbImage
//        }
//        return image
//    }
//
//    func hasAssets() -> Bool {
//        let assets = PHAsset.fetchAssets(in: self, options: nil)
//        return assets.count > 0
//    }
//}

//
//extension PHAsset {
//
////    MARK: - get thumbnail image from camera roll -
//    func getThumbnail(size: CGSize) -> UIImage {
//        var thumbnail = UIImage()
//        let manager = PHImageManager.default()
//        let option = PHImageRequestOptions()
//        option.isSynchronous = true
//        manager.requestImage(for: self,
//                             targetSize: size,
//                             contentMode: .aspectFill,
//                             options: option,
//                             resultHandler: {(result, info)->Void in
//                                if let image = result {
//                                    thumbnail = image
//                                }
//            thumbnail = result!
//        })
//        return thumbnail
//    }
//
////    MARK: - get image from camera roll -
//    func getImage(complition: @escaping (UIImage) -> Void) {
//        var image = UIImage()
//        let manager = PHImageManager.default()
//        let option = PHImageRequestOptions()
//
//        manager.requestImage(for: self,
//                             targetSize: PHImageManagerMaximumSize,
//                             contentMode: .default,
//                             options: option,
//                             resultHandler: {(result, info)->Void in
//            image = result!
//            complition(image)
//        })
//    }
//
////    MARK: - get image from asset
//    func getImageFromPHAsset() -> UIImage {
//        var image = UIImage()
//        let manager = PHImageManager.default()
//        let requestOptions = PHImageRequestOptions()
//        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
//        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
//        requestOptions.isSynchronous = true
//
//        if self.mediaType == PHAssetMediaType.image {
//            manager.requestImage(for: self,
//                                 targetSize: PHImageManagerMaximumSize,
//                                 contentMode: .default,
//                                 options: requestOptions) { (pickerImage, info) in
//                if let pckrImage = pickerImage {
//                    image = pckrImage
//                }
//            }
//        }
//        return image
//    }
//}


////
////  PHAsset+ImportData.swift
////  Photo Safe
////
////  Created by alexey sorochan on 19.08.2020.
////  Copyright © 2020 iMac_3. All rights reserved.
////
//
//import Photos
//
//extension PHAsset {
//
////    MARK: - import image as Data -
//    func getImageDataFromAsset(complition: @escaping (_ data: Data?) -> Void) {
//           let manager = PHImageManager.default()
//           let requestOptions = PHImageRequestOptions()
//           requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
//           requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
//           requestOptions.isSynchronous = true
//           manager.requestImageData(for: self, options: requestOptions) { (data, string, orientation, info) in
//               if let imageData = data {
//                   complition(imageData as Data)
//               } else {
//                   complition(nil)
//               }
//           }
//       }
//
////    MARK: - import video as AVAsset -
//    func getVideoDataFromAsset(complition: @escaping (_ asset: AVAsset?) -> Void) {
//        let manager = PHImageManager.default()
//        let requestOptions = PHVideoRequestOptions()
//        requestOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.highQualityFormat
//
//        manager.requestAVAsset(forVideo: self, options: requestOptions) { (asset, audioMix, info) in
//            if let videoAsset = asset {
//                complition(videoAsset as AVAsset)
//            } else {
//                complition(nil)
//            }
//        }
//    }
//}
////
//extension PHAsset {
//
////    MARK: - select deselct media picker key -
//    struct RuntimeKey {
//        static var isSelectedKey = UnsafeRawPointer.init(bitPattern: "isSelectedKey".hashValue)!
//    }
//
//    var isSelectedItem: Bool? {
//        set {
//            objc_setAssociatedObject(self, PHAsset.RuntimeKey.isSelectedKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, PHAsset.RuntimeKey.isSelectedKey) as? Bool
//        }
//    }
//}
//
//
//extension PHAssetCollection {
//
//    var mediaCount: Int {
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
//        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
//        return result.count
//    }
//}
