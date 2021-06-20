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
    
    public var photos: [PHAsset] = []
    
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
                
                let collection = PHAssetFetchManager.shared.fetchImagesFromGallery(collection: nil)
                debugPrint("all")
                debugPrint(collection.count)
                
                let imageCollection = PHAssetFetchManager.shared.fetchAssets(by: PHAssetMediaType.image.rawValue)
                debugPrint("images")
                debugPrint(imageCollection.count)
                
                let videoCollection = PHAssetFetchManager.shared.fetchAssets(by: PHAssetMediaType.video.rawValue)
                debugPrint("video")
                debugPrint(videoCollection.count)
                
                let livePhotosCollection = PHAssetFetchManager.shared.fetchAssetsSubtipe(by: PHAssetMediaSubtype.photoLive.rawValue)
                debugPrint("live photo cout")
                debugPrint(livePhotosCollection.count)
                
                let screenShots = PHAssetFetchManager.shared.fetchAssetsSubtipe(by: PHAssetMediaSubtype.photoScreenshot.rawValue)
                debugPrint("screenshots")
                debugPrint(screenShots.count)
                
                let videoStreamed = PHAssetFetchManager.shared.fetchAssetsSubtipe(by: PHAssetMediaSubtype.videoStreamed.rawValue)
                debugPrint("videoStreamed")
                debugPrint(videoStreamed.count)
                
                let videoTimelapse = PHAssetFetchManager.shared.fetchAssetsSubtipe(by: PHAssetMediaSubtype.videoTimelapse.rawValue)
                debugPrint("videoTimelapse")
                debugPrint(videoTimelapse.count)
                
         
                
                imageCollection.enumerateObjects({(object: AnyObject!, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                    if let fetchObject = object as? PHAsset {
                        self.photos.append(fetchObject)
                    }
                })
                
                var simmilar: [[PHAsset]] = []
                
                for n in self.photos {
                    for z in self.photos {
                        var p: [PHAsset] = []
                        if z != n {
                            if z.creationDate == n.creationDate {
                                debugPrint(z.creationDate)
                                p.append(n)
                                p.append(z)
                            }
                        }
                        if !p.isEmpty {
                            simmilar.append(p)
                        }
                    }
                }
                
                
                debugPrint(simmilar.count)
                
                
                for s in simmilar {
                    debugPrint("simmirial for date objects")
                    for someSimm in s {
                        debugPrint(someSimm.burstIdentifier)
                        debugPrint(someSimm.localIdentifier)
                        debugPrint(someSimm.location)
                    }
                }
                
                
                debugPrint("end")
                
                
                
//                for p in self.photos {
//                    let ass = self.photos.filter {
//
//                        $0.creationDate == p.creationDate
//                    }
//
//                    if !ass.isEmpty {
//                        simmilar.append(ass)
//                    }
//                }
//
//
//                for s in simmilar {
//                    debugPrint(s.count)
//                }
                
//                let z = self.photos.getDuplicates()
//
//
//                for i in z {
//                    debugPrint(i.creationDate)
//                }
                
//
//                for s in self.photos {
//                    let g = s.getSimilarTimeStampAssets(in: imageCollection, comparing: s, interval: 40)
//
//                    if !g.isEmpty {
//                        simmilar.append(g)
//                    }
//                }
//
//                debugPrint(simmilar.count)
//                for h in simmilar {
//
//                    debugPrint(h.count)
//
//                    for p in h {
//                        debugPrint(p.burstIdentifier)
//                        debugPrint(p.creationDate)
//                        debugPrint(p.localIdentifier)
//                    }
//                }
                
                

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

extension PHAsset {
    
    public func getSimilarTimeStampAssets(in assetFetchResult: PHFetchResult<PHAsset>, comparing asset: PHAsset, interval: Double ) -> [PHAsset] {
           
           var suffix: [PHAsset] = []
           var prefix: [PHAsset] = []
           var assets: [PHAsset] = []
           
           let index = assetFetchResult.index(of: asset)
           
           for i in 0..<assetFetchResult.count {
               let asset = assetFetchResult[i]
               assets.append(asset)
           }
           
           prefix = Array(assets.prefix(upTo: index))
           suffix = Array(assets.suffix(from: index))
           
           let alternateSuffix = getAlternatesIn(suffix: suffix, compare: asset, interval: interval)
           let alternatePrefix = getAlternatesIn(prefix: prefix, compare: asset, interval: interval)
           
           ///Alternate results?
           return self.mergeFunction(alternateSuffix, alternatePrefix)
       }
       
       /// This needs to live in other place, like an array extension
       private func mergeFunction<T>(_ one: [T], _ two: [T]) -> [T] {
           let commonLength = min(one.count, two.count)
           return zip(one, two).flatMap { [$0, $1] }
               + one.suffix(from: commonLength)
               + two.suffix(from: commonLength)
       }
    
    private func getAlternatesIn(prefix: [PHAsset], compare asset: PHAsset, interval: Double) -> [PHAsset] {
            
            let staticAssetCreationTime = asset.creationDate?.timeIntervalSince1970
            var startingTime: TimeInterval = asset.creationDate!.timeIntervalSince1970
            print("startingTime date - original from asset \(asset.creationDate!)")
            
            let _ = prefix.reversed().map {
                print("prefix date asset \(String(describing: $0.creationDate))")
            }
            
            var filteredAssets: [PHAsset] = []
            
            for localAsset in prefix.reversed() {
                if startingTime - localAsset.creationDate!.timeIntervalSince1970 < interval {
                    filteredAssets.append(localAsset)
                    print("added From prefix - \(localAsset.creationDate!)")
                } else {
                    print("not added From prefix - \(localAsset.creationDate!)")
                }
                startingTime = localAsset.creationDate!.timeIntervalSince1970
                let minPeriodInterval = staticAssetCreationTime! - startingTime
                if minPeriodInterval > 40 { //40 seconds window?
                    print("startingTime is \(localAsset.creationDate!) staticAssetCreationTime is \(String(describing: asset.creationDate)) rest is  \(minPeriodInterval)")
                    break
                }
            }
            return filteredAssets
        }
    
    private func getAlternatesIn(suffix: [PHAsset], compare asset: PHAsset, interval: Double) -> [PHAsset] {
         
         let staticAssetCreationTime = asset.creationDate?.timeIntervalSince1970
         var startingTime: TimeInterval = asset.creationDate!.timeIntervalSince1970
         print("startingTime date - original from asset \(asset.creationDate!)")
         
         let _ = suffix.map {
             print("sufix date asset \(String(describing: $0.creationDate))")
         }
         var filteredAssets: [PHAsset] = []
         for asset in suffix {
             if asset.creationDate!.timeIntervalSince1970 - startingTime < interval {
                 filteredAssets.append(asset)
                 print("added From sufix -\(asset.creationDate!)")
             } else {
                 print("not added From sufix - \(asset.creationDate!)")
             }
             startingTime = asset.creationDate!.timeIntervalSince1970
             let minPeriodInterval = startingTime - staticAssetCreationTime!
             if  minPeriodInterval > 40 { // 40 seconds window?
                 print("startingTime is \(startingTime) staticAssetCreationTime is \(staticAssetCreationTime!) rest is  \(startingTime - staticAssetCreationTime!)")
                 break
             }
         }
         return filteredAssets
     }
    
    func getAlternatePhotos() -> [PHAsset] {
          
          /// get the collection of the asset to avoid fetching all photos in the library
        let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsContaining(self, with: .smartAlbum, options: nil)
          
          let options = PHFetchOptions()
          options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
          guard let collection =  collectionFetchResult.firstObject else { return [] }
          print("Collection Localized title \(String(describing: collection.localizedTitle))")
          let assetsFetchResult = PHAsset.fetchAssets(in: collection, options: options)
          let filteredPhotos = getSimilarTimeStampAssets(in: assetsFetchResult, comparing: self, interval: 100)
          return filteredPhotos
      }
      
}

extension PhotoManager: PHPhotoLibraryChangeObserver {
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        U.UI {
            self.getPhotoLibrary()
        }
    }
}

extension PhotoManager {
    

  
     
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
