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
import AVKit

class PhassetGroup {
    var name: String
    var assets: [PHAsset]
    
    init(name: String, assets: [PHAsset]) {
        self.name = name
        self.assets = assets
    }
}

/// `getPhotoLibraryAccess` - use for access photo library alert and open settings
/// `getPhotoLibrary` - fetch all photo assets in the user photo library and update values
/// `getDuplicatedPhotosAsset`- finds duplicate photos in user photo library
/// `getDuplicateVideoAsset` - load duplicated videos
/// `getSimilarPhotosAsset` load simmilar photos
/// `getSimilarLivePhotos` - load simmilar live photos
/// `getScreenShots` `getSelfiePhotos` `getLivePhotos` -  fetch photos by type

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
    
    public func getPhotoLibraryAccess() {
        
        photoLibraryRequestAuth { accessGranted in
            if accessGranted {
                S.isLibraryAccessGranted = true
                self.getPhotoLibrary()
            } else {
                S.isLibraryAccessGranted = false
                
                AlertManager.showOpenSettingsAlert(.allowPhotoLibrary)
            }
        }
    }
    
    private func getPhotoLibrary() {
        
        let operationQueue: OperationQueue = {
            
            let operation = OperationQueue()
            operation.qualityOfService = .background
            operation.maxConcurrentOperationCount = 10
            
            return operation
        }()
        
        operationQueue.addOperation {
            debugPrint("start video count")
            self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { assets in
                U.UI {
                    debugPrint("done with video count")
                    UpdateContentDataBaseMediator.instance.updateVideos(assets.count, calculatedSpace: 0)
                }
            }
        }
        operationQueue.addOperation {
            debugPrint("start photo count")
            self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { assets in
                U.UI {
                    debugPrint("done with gallery count")
                    UpdateContentDataBaseMediator.instance.updatePhotos(assets.count, calculatedSpace: 0)
                }
            }
        }
        
        operationQueue.addOperation {
            debugPrint("start screen records")
            self.getScreenRecordsVideos { assets in
                debugPrint("done with screenrecords")
                UpdateContentDataBaseMediator.instance.getScreenRecordsVideosAssets(assets)
            }
        }
        
        operationQueue.addOperation {
            
            debugPrint("start get screenshots")
            self.getScreenShots { assets in
                debugPrint("done with screenshots")
                UpdateContentDataBaseMediator.instance.getScreenshots(assets)
            }
        }
        
        operationQueue.addOperation {
            debugPrint("start live photos")
            self.getLivePhotos { assets in
                debugPrint("done with livephoto")
                UpdateContentDataBaseMediator.instance.getLivePhotosAssets(assets)
            }
        }
        
        operationQueue.addOperation {
            debugPrint("start selfie")
            self.getSelfiePhotos { assets in
                debugPrint("done with selfies")
                UpdateContentDataBaseMediator.instance.getFrontCameraAssets(assets)
            }
        }
        
        operationQueue.addOperation {
            debugPrint("start large")
            self.getLargevideoContent { assets in
                debugPrint("done with large videos")
                UpdateContentDataBaseMediator.instance.getLargeVideosAssets(assets)
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
    
    public func calculateSpace(completionHandler: @escaping (_ spaceIn: Int64) -> Void) {
        var fileSize: Int64 = 0

        U.BG {
            self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { result in
                fileSize += self.fetchManager.calculateAllAssetsSize(result: result)
            }

            self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { result in
                fileSize += self.fetchManager.calculateAllAssetsSize(result: result)
            }

            U.UI {
                completionHandler(fileSize)
            }
        }
    }
}

//      MARK: - photo part -
extension PhotoManager {
    
    /// `simmilar photo algoritm`
    public func getSimilarPhotosAssets(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", fileSizeCheck: Bool = false, completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) {
        
        P.showIndicator()
        
        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photosInGallery in
            
            var group: [PhassetGroup] = []
            var containsAdd: [Int] = []
            var similarPhotos: [(asset: PHAsset, date: Int64, imageSize: Int64)] = []
            
            similarPhotos.reserveCapacity(photosInGallery.count)
            
            U.BG {
                if photosInGallery.count != 0 {
                    
                    photosInGallery.enumerateObjects { asset, index, stop in
                        debugPrint("index preocessing duplicate")
                        debugPrint("index \(index)")
                        similarPhotos.append((asset: asset, date: Int64(asset.creationDate!.timeIntervalSince1970), imageSize: fileSizeCheck ? asset.imageSize : 0))
                    }
                    
                    similarPhotos.sort { similarPhotoNumberOne, similarPhotoNumberTwo in
                        return similarPhotoNumberOne.date > similarPhotoNumberTwo.date
                    }
                    
                    for index in 0...similarPhotos.count - 1 {
                        var similarIndex = index + 1
                        if containsAdd.contains(index) { continue }
                        var similar: [PHAsset] = []
                        
                        if (similarIndex < similarPhotos.count && abs(similarPhotos[index].date - similarPhotos[similarIndex].date) <= 10) {
                            similar.append(similarPhotos[index].asset)
                            containsAdd.append(index)
                            repeat {
                                if containsAdd.contains(similarIndex) {
                                    continue
                                }
                                similar.append(similarPhotos[similarIndex].asset)
                                containsAdd.append(similarIndex)
                                similarIndex += 1
                            } while similarIndex < similarPhotos.count && abs(similarPhotos[index].date - similarPhotos[similarIndex].date) <= 10
                        }
                        if similar.count != 0 {
                            debugPrint("apend new group")
                            group.append(PhassetGroup(name: "", assets: similar))
                        }
                    }
                    P.hideIndicator()
                    U.UI {
                        completionHandler(group)
                    }
                } else {
                    P.hideIndicator()
                    U.UI {
                        completionHandler([])
                    }
                }
            }
        }
    }
    
    /// `duplicate photo algorithm`
    public func getDuplicatedPhotosAsset(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) {
        
        P.showIndicator()
        
        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photoGallery in
            U.BG {
                var photos: [OSTuple<NSString, NSData>] = []
                
                if photoGallery.count != 0 {
     
                    photoGallery.enumerateObjects { asset, index, stop in
                        debugPrint("loading duplicate")
                        debugPrint("photoposition \(index)")
                        let image = self.fetchManager.getThumbnail(from: asset, size: CGSize(width: 150, height: 150))
                        if let data = image.jpegData(compressionQuality: 0.8) {
                            let tuple = OSTuple<NSString, NSData>(first: "image\(index)" as NSString, andSecond: data as NSData)
                            photos.append(tuple)
                        }
                    }
                    
                    self.getDuplicatedTuples(for: photos, photosInGallery: photoGallery) { duplicatedPhotoAssetsGroup in
                        P.hideIndicator()
                        completionHandler(duplicatedPhotoAssetsGroup)
                    }
                } else {
                    U.UI {
                        P.hideIndicator()
                        completionHandler([])
                    }
                }
            }
        }
    }
    
    /// `load simmiliar live photo` from gallery
    public func getSimilarLivePhotos(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) {
        
        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotoGallery in
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
                    
                    self.getDuplicatedTuples(for: livePhotos, photosInGallery: livePhotoGallery) { similarLivePhotoGroup in
                        completionHandler(similarLivePhotoGroup)
                    }
                } else {
                    U.UI {
                        completionHandler([])
                    }
                }
            }
        }
    }
    
    /// `private duplicated tuples` need for service compare
    private func getDuplicatedTuples(for photos: [OSTuple<NSString, NSData>], photosInGallery: PHFetchResult<PHAsset>, completionHandler: @escaping ([PhassetGroup]) -> Void){
        
        var duplicatedPhotosCount: [Int] = []
        var duplicatedGroup: [PhassetGroup] = []
        let duplicatedIDS = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: photos)
        
        U.UI {
            guard duplicatedIDS.count >= 1 else {
                completionHandler([])
                return
            }
            
            for currentPosition in 1...duplicatedIDS.count {
                let duplicatedTuple = duplicatedIDS[currentPosition - 1]
                var group: [PHAsset] = []
                
                debugPrint("checkDuplicated")
                debugPrint("position \(currentPosition)")
                
                if let first = duplicatedTuple.first as String?, let second = duplicatedTuple.second as String? {
                    let firstInteger = first.replacingStringAndConvertToIntegerForImage() - 1
                    let secondInteger = second.replacingStringAndConvertToIntegerForImage() - 1
                    debugPrint(first)
                    debugPrint(second)
                    
                    if abs(secondInteger - firstInteger) >= 10 { continue }
                    if !duplicatedPhotosCount.contains(firstInteger) {
                        duplicatedPhotosCount.append(firstInteger)
                        group.append(photosInGallery[firstInteger])
                    }
                    
                    if !duplicatedPhotosCount.contains(secondInteger) {
                        duplicatedPhotosCount.append(secondInteger)
                        group.append(photosInGallery[secondInteger])
                    }
                    
                    duplicatedIDS.filter({ $0.first != nil && $0.second != nil}).filter({ $0.first == duplicatedTuple.first || $0.second == duplicatedTuple.second || $0.second == duplicatedTuple.second || $0.second == duplicatedTuple.first}).forEach ({ tuple in
                        if let first = tuple.first as String?, let second = tuple.second as String? {
                            let firstInt = first.replacingStringAndConvertToIntegerForImage() - 1
                            let socondInt = second.replacingStringAndConvertToIntegerForImage() - 1
                            
                            if abs(secondInteger - firstInteger) >= 10 {
                                return
                            }
                            
                            debugPrint(first)
                            debugPrint(second)
                            
                            if !duplicatedPhotosCount.contains(firstInt) {
                                duplicatedPhotosCount.append(firstInt)
                                group.append(photosInGallery[firstInt])
                            }
                            
                            if !duplicatedPhotosCount.contains(socondInt) {
                                duplicatedPhotosCount.append(socondInt)
                                group.append(photosInGallery[socondInt])
                            }
                        } else {
                            return
                        }
                    })
                    if group.count >= 2 {
                        duplicatedGroup.append(PhassetGroup(name: "", assets: group))
                    }
                }
            }
            completionHandler(duplicatedGroup)
        }
    }
    
    /// `load selfies` from gallery
    public func getSelfiePhotos(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
        
        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumSelfPortraits, by: PHAssetMediaType.image.rawValue) { selfiesInLibrary in
            
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
    
    /// `load live photos` from gallery
    public func getLivePhotos(_ completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
        
        fetchManager.fetchFromGallery(collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotosLibrary in
            
            U.BG {
                var livePhotos: [PHAsset] = []
                if livePhotosLibrary.count == 0 {
                    U.UI {
                        completionHandler([])
                    }
                    return
                }
                
                for livePhoto in 1...livePhotosLibrary.count {
                    livePhotos.append(livePhotosLibrary[livePhoto - 1])
                }
                
                U.UI {
                    completionHandler(livePhotos)
                }
            }
        }
    }
    
    /// `load screenshots` from gallery
    public func getScreenShots(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
        
        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumScreenshots, by: PHAssetMediaType.image.rawValue) { screensShotsLibrary in
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

//  MARK: - video part -
extension PhotoManager {
    
    /// `fetch large videos` from gallery
    public func getLargevideoContent(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
        
        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
            U.BG {
                var videos: [PHAsset] = []
                
                if videoContent.count == 0 {
                    U.UI {
                        completionHandler([])
                    }
                    return
                }
                
                for videosPosition in 1...videoContent.count {
                    if videoContent[videosPosition - 1].imageSize > 15000000 { //550000000 
                        videos.append(videoContent[videosPosition - 1])
                    }
                }
                U.UI {
                    completionHandler(videos)
                }
            }
        }
    }
    
    /// `duplicated Videos` from gallery
    public func getDuplicatesVideos(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) {
//        MARK: TODO adding 
        completionHandler([])
    }
    
    /// `screen recordings` from gallery
    public func getScreenRecordsVideos(from startDate: String = "01-01-1917 00:00:00", to endDate: String = "01-01-2666 00:00:00", completionHandler: @escaping ((_ screenRecordsAssets: [PHAsset]) -> Void)) {
        
        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoAssets in
            U.BG {
                var screenRecords: [PHAsset] = []
                
                if videoAssets.count == 0 {
                    U.UI {
                        completionHandler([])
                    }
                    return
                }
                                
                for videosPosition in 1...videoAssets.count {
                    let asset = videoAssets[videosPosition - 1]
                    if let assetResource = PHAssetResource.assetResources(for: asset).first {
                        if assetResource.originalFilename.contains("RPReplay") {
                            screenRecords.append(asset)
                        }
                    }
                }
                U.UI {
                    completionHandler(screenRecords)
                }
            }
        }
    }

    /// `duplicated videos compare algorithm`
    public func getDuplicatedVideoAsset(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) {
        
        fetchManager.fetchFromGallery(from: startDate,
                                      to: endDate,
                                      collectiontype: .smartAlbumVideos,
                                      by: PHAssetMediaType.video.rawValue) { videoCollection in
            var videos: [OSTuple<NSString, NSData>] = []
            
            U.BG {
                if videoCollection.count != 0 {
                    for index in 1...videoCollection.count {
                        let image = self.fetchManager.getThumbnail(from: videoCollection[index - 1], size: CGSize(width: 150, height: 150))
                        if let data = image.jpegData(compressionQuality: 0.8) {
                            let imageTuple = OSTuple<NSString, NSData>(first: "image\(index)" as NSString, andSecond: data as NSData)
                            videos.append(imageTuple)
                        } else {
                            return
                        }
                    }
                    
                    let duplicateVideoIDasTuples = OSImageHashing.sharedInstance().similarImages(withProvider: .pHash, forImages: videos)
                    var duplicateVideoNumbers: [Int] = []
                    var duplicateVideoGroups: [PhassetGroup] = []
                    U.UI {
                        guard duplicateVideoIDasTuples.count >= 1 else { completionHandler([])
                            return
                        }
                        
                        for index in 1...duplicateVideoIDasTuples.count {
                            let tuple = duplicateVideoIDasTuples[index - 1]
                            var groupAssets: [PHAsset] = []
                            if let first = tuple.first as String?, let second = tuple.second as String? {
                                let firstInteger = first.replacingStringAndConvertToIntegerForImage() - 1
                                let secondInteger = second.replacingStringAndConvertToIntegerForImage() - 1
                                
                                if abs(secondInteger - firstInteger) >= 10 { continue }
                                if !duplicateVideoNumbers.contains(firstInteger) {
                                    duplicateVideoNumbers.append(firstInteger)
                                    groupAssets.append(videoCollection[firstInteger])
                                }
                                
                                if !duplicateVideoNumbers.contains(secondInteger) {
                                    duplicateVideoNumbers.append(secondInteger)
                                    groupAssets.append(videoCollection[secondInteger])
                                }
                                
                                duplicateVideoIDasTuples.filter({$0.first != nil && $0.second != nil}).filter({ $0.first == tuple.first || $0.first == tuple.second || $0.second == tuple.second || $0.second == tuple.first }).forEach({ tuple in
                                    if let firstTuple = tuple.first as String?, let secondTuple = tuple.second as String? {
                                        let firstTupleInteger = firstTuple.replacingStringAndConvertToIntegerForImage() - 1
                                        let secondTupleInteger = secondTuple.replacingStringAndConvertToIntegerForImage() - 1
                                        
                                        if abs(secondTupleInteger - firstTupleInteger) >= 10 {
                                            return
                                        }
                                        
                                        if !duplicateVideoNumbers.contains(firstTupleInteger) {
                                            duplicateVideoNumbers.append(firstTupleInteger)
                                            groupAssets.append(videoCollection[firstTupleInteger])
                                        }
                                        
                                        if !duplicateVideoNumbers.contains(secondTupleInteger) {
                                            duplicateVideoNumbers.append(secondTupleInteger)
                                            groupAssets.append(videoCollection[secondInteger])
                                        }
                                    }
                                })
                                
                                if groupAssets.count >= 2 {
                                    duplicateVideoGroups.append(PhassetGroup(name: "", assets: groupAssets))
                                }
                            }
                        }
                        U.UI {
                            completionHandler(duplicateVideoGroups)
                        }
                    }
                } else {
                    U.UI {
                        completionHandler([])
                    }
                    return
                }
            }
        }
    }
}

//      MARK: - delete selected assets -

extension PhotoManager {
    
    public func deleteSelected(assets: [PHAsset], completion: @escaping ((Bool) -> Void)) {
        
        let assetsSelectedIdentifiers = assets.map({ $0.localIdentifier})
        
        let deletedAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetsSelectedIdentifiers, options: nil)
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(deletedAssets)
        } completionHandler: { success, error in
            U.UI {
                completion(success)
            }
        }
    }
}

//      MARK: - change assets observer -

extension PhotoManager: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        U.UI {
//            self.getPhotoLibrary()
            UpdatingChangesInOpenedScreensMediator.instance.updatingChangedScreenShots()
            UpdatingChangesInOpenedScreensMediator.instance.updatingChangedSelfies()
        }
    }
}

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
