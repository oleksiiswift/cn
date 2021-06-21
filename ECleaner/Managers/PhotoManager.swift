//
//  PhotoManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import Foundation
import PhotosUI
import Photos
import CocoaImageHashing

class PhassetGroup {
    var name: String
    var assets: [PHAsset]
    
    init(name: String, assets: [PHAsset]) {
        self.name = name
        self.assets = assets
    }
}

class PhotoManager: NSObject {
    
    private static let shared = PhotoManager()
    
    static var manager: PhotoManager {
        return self.shared
    }
    
    private var fetchManager = PHAssetFetchManager.shared
    
    public override init() {
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }

    public func getPhotoLibrary() {
        
        photoLibraryRequestAuth { accessGranted in
            if accessGranted {
                
                self.loadSelfiePhotos { selfie in
                    debugPrint("selfie count \(selfie.count)")
                }
                
                
                self.loadScreenShots { screens in
                    debugPrint("screen shots \(screens.count)")
                }
                
                self.loadSimmilarLivePhotos { groups in
                    debugPrint("simmilar live Phooto groups")
                    
                    debugPrint(groups.count)
                    
                    for i in groups {
                        debugPrint("detect")
                        debugPrint(i.assets.count)
                    }
                }
                
                self.loadSimmilarPhotos { groups in
                    debugPrint("simmilar group")
                    debugPrint(groups.count)
                    
                    for i in groups {
                        debugPrint("simmilar photos")
                        debugPrint(i.assets.count)
                    }
                }
                
            } else {
                AlertManager.showOpenSettingsAlert(.allowPhotoLibrary)
            }
        }
    }
    
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
    
    public func loadSimmilarPhotos(from dataFrom: String = "01-01-1970", to dateTo: String = "01-01-2666", completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) {
        
        fetchManager.fetchFromGallery(from: dataFrom, to: dateTo, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photoGallery in
            U.BG {
                var photos: [OSTuple<NSString, NSData>] = []
                
                if photoGallery.count == 0 {
                    U.UI {
                        completionHandler([])
                    }
                }
                
                for photoPos in 1...photoGallery.count {
                    debugPrint("loading")
                    debugPrint("photoposition \(photoPos)")
                    let image = self.fetchManager.getThumbnail(from: photoGallery[photoPos - 1], size: CGSize(width: 150, height: 150))
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        let tuple = OSTuple<NSString, NSData>(first: "image\(photoPos)" as NSString, andSecond: data as NSData)
                        photos.append(tuple)
                    }
                }
                self.getSimmilarTuples(for: photos, photosInGallery: photoGallery) { simmilarPhotos in
                    completionHandler(simmilarPhotos)
                }
            }
        }
    }
    
    public func loadSimmilarLivePhotos(from dataFrom: String = "01-01-1970", to dateTo: String = "01-01-2666", completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) {
        
        fetchManager.fetchFromGallery(from: dataFrom, to: dateTo, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotoGallery in
            U.BG {
                var livePhotos: [OSTuple<NSString, NSData>] = []
                
                if livePhotoGallery.count != 0 {
                    
                    for livePosition in 1...livePhotoGallery.count {
                        let image = self.fetchManager.getThumbnail(from: livePhotoGallery[livePosition - 1], size: CGSize(width: 150, height: 150))
                        if let data = image.jpegData(compressionQuality: 0.8) {
                            let tuple = OSTuple<NSString, NSData>(first: "image\(livePosition)" as NSString, andSecond: data as NSData)
                            livePhotos.append(tuple)
                        }
                    }
                    
                    self.getSimmilarTuples(for: livePhotos, photosInGallery: livePhotoGallery) { simmilarLifePhotos in
                        completionHandler(simmilarLifePhotos)
                    }
                } else {
                    U.UI {
                        completionHandler([])
                    }
                }
            }
        }
    }
    
    private func getSimmilarTuples(for photos: [OSTuple<NSString, NSData>], photosInGallery: PHFetchResult<PHAsset>, completionHandler: @escaping ([PhassetGroup]) -> Void){
        
        var simmilarPhotosCount: [Int] = []
        var simmilarGroup: [PhassetGroup] = []
        let simmilarIDS = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: photos)
        
        U.UI {
            guard simmilarIDS.count >= 1 else { completionHandler([])
                debugPrint("zero simmilar IDS")
                return
            }
            
            for currentPosition in 1...simmilarIDS.count {
                let simmilarTuple = simmilarIDS[currentPosition - 1]
                var group: [PHAsset] = []
                
                debugPrint("checkSimmilar")
                debugPrint("position \(currentPosition)")
                
                
                if let first = simmilarTuple.first as String?, let second = simmilarTuple.second as String? {
                    let firstInteger = first.replacingStringAndConvertToIntegerForImage() - 1
                    let secondInteger = second.replacingStringAndConvertToIntegerForImage() - 1
                    debugPrint(first)
                    debugPrint(second)
                    
                    if abs(secondInteger - firstInteger) >= 10 { continue }
                    if !simmilarPhotosCount.contains(firstInteger) {
                        simmilarPhotosCount.append(firstInteger)
                        group.append(photosInGallery[firstInteger])
                    }
                    
                    if !simmilarPhotosCount.contains(secondInteger) {
                        simmilarPhotosCount.append(secondInteger)
                        group.append(photosInGallery[secondInteger])
                    }
                    
                    simmilarIDS.filter({
                                        $0.first != nil && $0.second != nil}).filter({
                                                                                        $0.first == simmilarTuple.first ||
                                                                                            $0.second == simmilarTuple.second ||
                                                                                            $0.second == simmilarTuple.second ||
                                                                                            $0.second == simmilarTuple.first}).forEach ({ tuple in
                                                                                                if let first = tuple.first as String?, let second = tuple.second as String? {
                                                                                                    let firstInt = first.replacingStringAndConvertToIntegerForImage() - 1
                                                                                                    let socondInt = second.replacingStringAndConvertToIntegerForImage() - 1
                                                                                                    
                                                                                                    if abs(secondInteger - firstInteger) >= 10 {
                                                                                                        return
                                                                                                    }
                                                                                                    
                                                                                                    debugPrint(first)
                                                                                                    debugPrint(second)
                                                                                                    
                                                                                                    if !simmilarPhotosCount.contains(firstInt) {
                                                                                                        simmilarPhotosCount.append(firstInt)
                                                                                                        group.append(photosInGallery[firstInt])
                                                                                                    }
                                                                                                    
                                                                                                    if !simmilarPhotosCount.contains(socondInt) {
                                                                                                        simmilarPhotosCount.append(socondInt)
                                                                                                        group.append(photosInGallery[socondInt])
                                                                                                    }
                                                                                                } else {
                                                                                                    return
                                                                                                }
                                                                                                
                                                                                            })
                    if group.count >= 2 {
                        simmilarGroup.append(PhassetGroup(name: "", assets: group))
                    }
                }
            }
            completionHandler(simmilarGroup)
        }
    }
    
    
    
    
    public func loadSelfiePhotos(_ completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
        
        fetchManager.fetchFromGallery(collectiontype: .smartAlbumSelfPortraits, by: PHAssetMediaType.image.rawValue) { selfiesInLibrary in
            
            U.BG {
                var selfies: [PHAsset] = []
                if selfiesInLibrary.count == 0 {
                    U.UI {
                        completionHandler([])
                    }
                    return
                }
                
                for selfiePos in 1...selfiesInLibrary.count {
                    selfies.append(selfiesInLibrary[selfiePos - 1])
                }
                
                U.UI {
                    completionHandler(selfies)
                }
            }
        }
    }
    
    public func loadScreenShots(from dataFrom: String = "01-01-1970", to dateTo: String = "01-01-2666", completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
        
        fetchManager.fetchFromGallery(from: dataFrom, to: dateTo, collectiontype: .smartAlbumScreenshots, by: PHAssetMediaType.image.rawValue) { screensShotsLibrary in
            U.BG {
                var screens: [PHAsset] = []
                
                if screensShotsLibrary.count == 0 {
                    U.UI {
                        completionHandler([])
                    }
                    return
                }
                
                for screensPos in 1...screensShotsLibrary.count {
                    screens.append(screensShotsLibrary[screensPos - 1])
                }
                
                U.UI {
                    completionHandler(screens)
                }
            }
        }
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
    
    private func loadTestingAssets() {
      
        let photoCollection = self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { collection in
            debugPrint("photo collection count")
            debugPrint(collection.count)
        }
        
        let selfiesCollection = self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumSelfPortraits, by: PHAssetMediaType.image.rawValue) { selfies in
            debugPrint("some selfies count")
            debugPrint(selfies.count)
        }
        
        let livePhotoCollection = self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhoto in
            debugPrint("some live count")
            debugPrint(livePhoto.count)
        }
        
        let screenShotsCollection = self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumScreenshots, by: PHAssetMediaType.image.rawValue) { screenShots in
            debugPrint("some screens count")
            debugPrint(screenShots.count)
        }
        
        
        let gifsCollection = self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumAnimated, by: PHAssetMediaType.image.rawValue) { gifs in
            debugPrint("some gifs count")
            debugPrint(gifs.count)
        }
        
        let videoCollection = self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { video in
            debugPrint("some video count")
            debugPrint(video.count)
        }
        
        
        
        
        
//                let collection = PHAssetFetchManager.shared.fetchImagesFromGallery(collection: nil)
//                debugPrint("all")
//                debugPrint(collection.count)
//
//                let imageCollection = PHAssetFetchManager.shared.fetchAssets(by: PHAssetMediaType.image.rawValue)
//                debugPrint("images")
//                debugPrint(imageCollection.count)
//
//                let videoCollection = PHAssetFetchManager.shared.fetchAssets(by: PHAssetMediaType.video.rawValue)
//                debugPrint("video")
//                debugPrint(videoCollection.count)
//
//                let livePhotosCollection = PHAssetFetchManager.shared.fetchAssetsSubtipe(by: PHAssetMediaSubtype.photoLive.rawValue)
//                debugPrint("live photo cout")
//                debugPrint(livePhotosCollection.count)
//
//                let screenShots = PHAssetFetchManager.shared.fetchAssetsSubtipe(by: PHAssetMediaSubtype.photoScreenshot.rawValue)
//                debugPrint("screenshots")
//                debugPrint(screenShots.count)
//
//                let videoStreamed = PHAssetFetchManager.shared.fetchAssetsSubtipe(by: PHAssetMediaSubtype.videoStreamed.rawValue)
//                debugPrint("videoStreamed")
//                debugPrint(videoStreamed.count)
//
//                let videoTimelapse = PHAssetFetchManager.shared.fetchAssetsSubtipe(by: PHAssetMediaSubtype.videoTimelapse.rawValue)
//                debugPrint("videoTimelapse")
//                debugPrint(videoTimelapse.count)
        
 
        
//                imageCollection.enumerateObjects({(object: AnyObject!, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
//                    if let fetchObject = object as? PHAsset {
//                        self.photos.append(fetchObject)
//                    }
//                })
        
    }
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



    
extension String{
    
    func replacingStringAndConvertToIntegerForImage() -> Int {
        if let integer = Int(self.replacingOccurrences(of: "image", with: "")) {
            return integer
        } else {
            return 0
        }
    }
}

