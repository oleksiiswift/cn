//
//  PhotoManagerOLD.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.06.2021.
//

import Foundation
import PhotosUI
import Photos
import CocoaImageHashing
import AVKit


//enum AssetsGroupType {
//    case photo
//    case screenShots
//    case livePhotos
//    case video
//    case screenRecordings
//}

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

//class PhotoManagerOLD: NSObject {
//
////    enum Strictness {
////        case similar
////        case closeToIdentical
////    }
////
////	static let shared: PhotoManagerOLD = {
////		let instance = PhotoManagerOLD()
////		return instance
////	}()
//
////    var assetCollection: PHAssetCollection?
//
////    let operationConcurrentQueue = OperationProcessingQueuer(name: "photoGrabber", maxConcurrentOperationCount: 4, qualityOfService: .default)
//
//    private var fetchManager = PHAssetFetchManager.shared
////    private var progressNotificationManager = DeepCleanNotificationManager.instance
//
//    public override init() {
//        super.init()
//
//        PHPhotoLibrary.shared().register(self)
//    }
//
////    public func getPhotoLibraryAccess() {
////
////        photoLibraryRequestAuth { accessGranted in
////            if accessGranted {
////                S.isLibraryAccessGranted = true
////                self.getPhotoLibrary()
////            } else {
////                S.isLibraryAccessGranted = false
////
////                AlertManager.showOpenSettingsAlert(.allowPhotoLibrary)
////            }
////        }
////    }
//
//
////    public func dcalculateAssetsDiskSpace() {
////        debugPrint("start calculated file size")
////        self.fetchManager.gitAllCalculatedPhassetsSize { photoSize, videoSize, totalSize in
////            debugPrint("end calculated fils size")
////            S.phassetPhotoFilesSizes = photoSize
////            S.phassetVideoFilesSizes = videoSize
////            S.phassetFilesSize = totalSize
////        }
////    }
//
////    public func calculateLargeVideosCount() {
////        debugPrint("start large")
////        self.getLargevideoContent { assets in
////            debugPrint("done with large videos")
////            UpdateContentDataBaseMediator.instance.getLargeVideosAssets(assets)
////        }
////    }
//
////    public func calculateRecentlyDeleted() {
////        debugPrint("try fetch recently deleted photos videos")
////        self.getSortedRecentlyDeletedAssets { photos, videos in
////            debugPrint("done with photos and videos")
////
////            UpdateContentDataBaseMediator.instance.getRecentlyDeletedPhotosAssets(photos)
////            UpdateContentDataBaseMediator.instance.getRecentlyDeletedVideosAssets(videos)
////        }
////    }
//
////    public func calculateVideoCount() {
////        debugPrint("start video count")
////        self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { assets in
////            U.UI {
////                debugPrint("done with video count")
////                UpdateContentDataBaseMediator.instance.updateContentStoreCount(mediaType: .userVideo, itemsCount: assets.count, calculatedSpace: nil)
////            }
////        }
////    }
//
////    public func calculatePhotoCount() {
////        debugPrint("start photo count")
////        self.fetchManager.fetchFromGallery(collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { assets in
////            U.UI {
////                debugPrint("done with gallery count")
////                UpdateContentDataBaseMediator.instance.updateContentStoreCount(mediaType: .userPhoto, itemsCount: assets.count, calculatedSpace: nil)
////            }
////        }
////    }
//
//
////    public func getPhotoAssetsCount(from startDate: String, to endDate: String, completion: @escaping (Int) -> Void) {
////
////        self.fetchManager.fetchTotalAssetsCount(from: startDate, to: endDate) { totalCount in
////            completion(totalCount)
////        }
////    }
////
////    public func getPartitionalMediaAssetsCount(from startDate: String, to endDate: String, completion: @escaping ([AssetsGroupType: Int]) -> Void) {
////
////        var totalProcessingProcess = 0
////
////        var totalPartitinAssetsCount: [AssetsGroupType : Int] = [.photo : 0, // get all photo count
////                                                                 .screenShots : 0, // get all screenshots
////                                                                 .livePhotos : 0, // get all live photosCount
////                                                                 .video : 0, // get all videos
////                                                                 .screenRecordings : 0] // get all screen recordings
////
////        self.fetchManager.fetchPhotoCount(from: startDate, to: endDate) { photoCount in
////            totalPartitinAssetsCount[.photo] = photoCount
////
////            totalProcessingProcess += 1
////            if totalProcessingProcess == 5 {
////                completion(totalPartitinAssetsCount)
////            }
////        }
////
////        self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { result in
////            totalPartitinAssetsCount[.video] = result.count
////
////            totalProcessingProcess += 1
////            if totalProcessingProcess == 5 {
////                completion(totalPartitinAssetsCount)
////            }
////        }
////
////        self.getScreenShots(from: startDate, to: endDate, isDeepCleanScan: false) { assets in
////            totalPartitinAssetsCount[.screenShots] = assets.count
////
////            totalProcessingProcess += 1
////            if totalProcessingProcess == 5 {
////                completion(totalPartitinAssetsCount)
////            }
////        }
////
////        self.fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { result in
////            totalPartitinAssetsCount[.livePhotos] = result.count
////
////            totalProcessingProcess += 1
////            if totalProcessingProcess == 5 {
////                completion(totalPartitinAssetsCount)
////            }
////        }
////
////        self.getScreenRecordsVideos(from: startDate, to: endDate, isDeepCleanScan: false) { screenRecordsAssets in
////            totalPartitinAssetsCount[.screenRecordings] = screenRecordsAssets.count
////
////            totalProcessingProcess += 1
////            if totalProcessingProcess == 5 {
////                completion(totalPartitinAssetsCount)
////            }
////        }
////    }
//
////    public func calculateScreenRecordsCout() {
////        debugPrint("start screen records")
////        self.getScreenRecordsVideos { assets in
////            debugPrint("done with screenrecords")
////
////        }
////    }
//
////    public func calculateScreenShotsCount() {
////        debugPrint("start get screenshots")
////        self.getScreenShots { assets in
////            debugPrint("done with screenshots")
////            UpdateContentDataBaseMediator.instance.getScreenshots(assets)
////        }
////    }
//
////    public func calculateLivePhotoCount() {
////        debugPrint("start live photos")
////        self.getLivePhotos { assets in
////            debugPrint("done with livephoto")
////            UpdateContentDataBaseMediator.instance.getLivePhotosAssets(assets)
////        }
////    }
//
////    public func calculateSelfiesCount() {
////        debugPrint("start selfie")
////        self.getSelfiePhotos { assets in
////            debugPrint("done with selfies")
////            UpdateContentDataBaseMediator.instance.getFrontCameraAssets(assets)
////        }
////    }
//
//    private func getPhotoLibrary() {
//
////        let concurrentOperationFirst = ConcurrentProcessOperation { _ in
////            self.calculateAssetsDiskSpace()
////        }
//
////        let concurrentOperationSecond = ConcurrentProcessOperation { _ in
////            self.calculateLargeVideosCount()
////        }
//
////        let concurrentOperationThird = ConcurrentProcessOperation { _ in
////            self.calculateRecentlyDeleted()
////        }
//
////        let concurrentOperationFourth = ConcurrentProcessOperation { _ in
////            self.calculateVideoCount()
////        }
////
////        let concurrentOperationFifth = ConcurrentProcessOperation { _ in
////            self.calculatePhotoCount()
////        }
//
////        let concurrentOperationSixth = ConcurrentProcessOperation { _ in
////            self.calculateScreenRecordsCout()
////        }
////
////        let concurrentOperationSeventh = ConcurrentProcessOperation { _ in
////            self.calculateScreenShotsCount()
////        }
//
////        let concurrentOperationEighth = ConcurrentProcessOperation { _ in
////            self.calculateLivePhotoCount()
////        }
//
////        let concurrentOperationNinth = ConcurrentProcessOperation { _ in
////            self.calculateSelfiesCount()
////        }
//
////        operationConcurrentQueue.addOperation(concurrentOperationFirst)
////        operationConcurrentQueue.addOperation(concurrentOperationSecond)
////        operationConcurrentQueue.addOperation(concurrentOperationThird)
////        operationConcurrentQueue.addOperation(concurrentOperationFourth)
////        operationConcurrentQueue.addOperation(concurrentOperationFifth)
////        operationConcurrentQueue.addOperation(concurrentOperationSixth)
////        operationConcurrentQueue.addOperation(concurrentOperationSeventh)
////        operationConcurrentQueue.addOperation(concurrentOperationEighth)
////        operationConcurrentQueue.addOperation(concurrentOperationNinth)
//
//    }
//
//////    MARK: - authentification
////    private func photoLibraryRequestAuth(completion: @escaping (_ status: Bool) -> Void ) {
////        if #available(iOS 14, *) {
////            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
////                switch status {
////                    case .notDetermined:
////                        debugPrint("notDetermined")
////                        completion(false)
////                    case .restricted:
////                        debugPrint("restricted")
////                        completion(false)
////                    case .denied:
////                        debugPrint("denied")
////                        completion(false)
////                    case .authorized:
////                        debugPrint("authorized")
////                        completion(true)
////                    case .limited:
////                        debugPrint("limited")
////                        completion(true)
////                    @unknown default:
////                        debugPrint("default")
////                }
////            }
////        } else {
////            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
////                completion(true)
////            } else {
////                PHPhotoLibrary.requestAuthorization { status in
////                    if status == PHAuthorizationStatus.authorized {
////                        completion(true)
////                    } else {
////                        completion(false)
////                    }
////                }
////            }
////        }
////    }
//}

//      MARK: - photo part -
//extension PhotoManagerOLD {
//    
////    /// `simmilar photo algoritm`
////    public func getSimilarPhotosAssets(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", fileSizeCheck: Bool = false, isDeepCleanScan: Bool = false, completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) {
////
////        if !isDeepCleanScan {
////            P.showIndicator()
////        }
////
////        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photosInGallery in
////
////            var group: [PhassetGroup] = []
////            var containsAdd: [Int] = []
////            var similarPhotos: [(asset: PHAsset, date: Int64, imageSize: Int64)] = []
////
////            similarPhotos.reserveCapacity(photosInGallery.count)
////
////            U.BG {
////                if photosInGallery.count != 0 {
////
////                    for index in 1...photosInGallery.count {
////                        debugPrint("index preocessing duplicate")
////                        debugPrint("index \(index)")
////
////                        /// adding notification to handle progress similar photos processing
////                        if isDeepCleanScan {
////
////                            self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .similarPhoto,
////                                                                                         totalProgressItems: photosInGallery.count,
////                                                                                         currentProgressItem: index)
////                        }
////
////                        similarPhotos.append((asset: photosInGallery[index - 1],
////                                              date: Int64(photosInGallery[index - 1].creationDate!.timeIntervalSince1970),
////                                              imageSize: fileSizeCheck ? photosInGallery[index - 1].imageSize : 0))
////                    }
////
////                    similarPhotos.sort { similarPhotoNumberOne, similarPhotoNumberTwo in
////                        return similarPhotoNumberOne.date > similarPhotoNumberTwo.date
////                    }
////
////                    for index in 0...similarPhotos.count - 1 {
////                        debugPrint("similar index precessing: ", index)
////                        var similarIndex = index + 1
////                        if containsAdd.contains(index) { continue }
////                        var similar: [PHAsset] = []
////
////                        if (similarIndex < similarPhotos.count && abs(similarPhotos[index].date - similarPhotos[similarIndex].date) <= 10) {
////                            similar.append(similarPhotos[index].asset)
////                            containsAdd.append(index)
////                            repeat {
////                                if containsAdd.contains(similarIndex) {
////                                    continue
////                                }
////                                similar.append(similarPhotos[similarIndex].asset)
////                                containsAdd.append(similarIndex)
////                                similarIndex += 1
////                            } while similarIndex < similarPhotos.count && abs(similarPhotos[index].date - similarPhotos[similarIndex].date) <= 10
////                        }
////                        if similar.count != 0 {
////                            debugPrint("apend new group")
////                            group.append(PhassetGroup(name: "", assets: similar))
////                        }
////                    }
////                    if !isDeepCleanScan {
////                        P.hideIndicator()
////                        U.UI {
////                            completionHandler(group)
////                        }
////                    } else {
////                        completionHandler(group)
////                    }
////                } else {
////                    if !isDeepCleanScan {
////                        P.hideIndicator()
////                        U.UI {
////                            completionHandler([])
////                        }
////                    } else {
////                        completionHandler([])
////                    }
////                }
////            }
////        }
////    }
//    
//    /// `duplicate photo algorithm`
////    public func getDuplicatedPhotosAsset(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", isDeepCleanScan: Bool = false, completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) {
////
////        if !isDeepCleanScan {
////            P.showIndicator()
////        }
////
////        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumUserLibrary, by: PHAssetMediaType.image.rawValue) { photoGallery in
////            U.BG {
////                var photos: [OSTuple<NSString, NSData>] = []
////
////                if photoGallery.count != 0 {
////
////
////                    for photoPos in 1...photoGallery.count {
////                        debugPrint("loading duplicate")
////                        debugPrint("photoposition \(photoPos)")
////
////                        /// adding notification to handle progress similar photos processing
////                        if isDeepCleanScan {
////                            self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .duplicatePhoto,
////                                                                                     totalProgressItems: photoGallery.count,
////                                                                                     currentProgressItem: photoPos)
////                        }
////
////                        let image = self.fetchManager.getThumbnail(from: photoGallery[photoPos - 1], size: CGSize(width: 150, height: 150))
////                        if let data = image.jpegData(compressionQuality: 0.8) {
////                            let tuple = OSTuple<NSString, NSData>(first: "image\(photoPos)" as NSString, andSecond: data as NSData)
////                            photos.append(tuple)
////                        }
////                    }
////
////                    self.getDuplicatedTuples(for: photos, photosInGallery: photoGallery) { duplicatedPhotoAssetsGroup in
////                        if !isDeepCleanScan {
////                            P.hideIndicator()
////                        }
////                        completionHandler(duplicatedPhotoAssetsGroup)
////                    }
////                } else {
////                    if !isDeepCleanScan {
////                    U.UI {
////                        P.hideIndicator()
////                        completionHandler([])
////                    }
////                    } else {
////                        completionHandler([])
////                    }
////                }
////            }
////        }
////    }
//    
////    /// `load simmiliar live photo` from gallery
////    public func getSimilarLivePhotos(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", isDeepCleanScan: Bool = false, completionHandler: @escaping ((_ assets: [PhassetGroup]) -> Void)) {
////
////        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotoGallery in
////            U.BG {
////                var livePhotos: [OSTuple<NSString, NSData>] = []
////
////                if livePhotoGallery.count != 0 {
////                    for livePosition in 1...livePhotoGallery.count {
////                        debugPrint("live photo position", livePosition)
////
////                        if isDeepCleanScan {
////                            self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .similarLivePhoto,
////                                                                                     totalProgressItems: livePhotoGallery.count,
////                                                                                     currentProgressItem: livePosition)
////                        }
////
////                        let image = self.fetchManager.getThumbnail(from: livePhotoGallery[livePosition - 1], size: CGSize(width: 150, height: 150))
////                        if let data = image.jpegData(compressionQuality: 0.8) {
////                            let tuple = OSTuple<NSString, NSData>(first: "image\(livePosition)" as NSString, andSecond: data as NSData)
////                            livePhotos.append(tuple)
////                        }
////                    }
////
////                    self.getDuplicatedTuples(for: livePhotos, photosInGallery: livePhotoGallery, isDeepCleanScan: isDeepCleanScan) { similarLivePhotoGroup in
////                        completionHandler(similarLivePhotoGroup)
////                    }
////                } else {
////                    if !isDeepCleanScan {
////                        U.UI {
////                            completionHandler([])
////                        }
////                    } else {
////                        completionHandler([])
////                    }
////                }
////            }
////        }
////    }
//    
//    /// `private duplicated tuples` need for service compare
////    private func getDuplicatedTuples(for photos: [OSTuple<NSString, NSData>], photosInGallery: PHFetchResult<PHAsset>, isDeepCleanScan: Bool = false, completionHandler: @escaping ([PhassetGroup]) -> Void){
////
////        var duplicatedPhotosCount: [Int] = []
////        var duplicatedGroup: [PhassetGroup] = []
////        let duplicatedIDS = OSImageHashing.sharedInstance().similarImages(with: OSImageHashingQuality.high, forImages: photos)
////
////        U.BG {
////            guard duplicatedIDS.count >= 1 else {
////                if !isDeepCleanScan {
////                    U.UI {
////                        completionHandler([])
////                    }
////                } else {
////                    completionHandler([])
////                }
////                return
////            }
////
////            for currentPosition in 1...duplicatedIDS.count {
////                let duplicatedTuple = duplicatedIDS[currentPosition - 1]
////                var group: [PHAsset] = []
////
////                debugPrint("checkDuplicated")
////                debugPrint("position \(currentPosition)")
////
////                if let first = duplicatedTuple.first as String?, let second = duplicatedTuple.second as String? {
////                    let firstInteger = first.replacingStringAndConvertToIntegerForImage() - 1
////                    let secondInteger = second.replacingStringAndConvertToIntegerForImage() - 1
////                    debugPrint(first)
////                    debugPrint(second)
////
////                    if abs(secondInteger - firstInteger) >= 10 { continue }
////                    if !duplicatedPhotosCount.contains(firstInteger) {
////                        duplicatedPhotosCount.append(firstInteger)
////                        group.append(photosInGallery[firstInteger])
////                    }
////
////                    if !duplicatedPhotosCount.contains(secondInteger) {
////                        duplicatedPhotosCount.append(secondInteger)
////                        group.append(photosInGallery[secondInteger])
////                    }
////
////                    duplicatedIDS.filter({ $0.first != nil && $0.second != nil}).filter({ $0.first == duplicatedTuple.first || $0.second == duplicatedTuple.second || $0.second == duplicatedTuple.second || $0.second == duplicatedTuple.first}).forEach ({ tuple in
////                        if let first = tuple.first as String?, let second = tuple.second as String? {
////                            let firstInt = first.replacingStringAndConvertToIntegerForImage() - 1
////                            let socondInt = second.replacingStringAndConvertToIntegerForImage() - 1
////
////                            if abs(secondInteger - firstInteger) >= 10 {
////                                return
////                            }
////
////                            debugPrint(first)
////                            debugPrint(second)
////
////                            if !duplicatedPhotosCount.contains(firstInt) {
////                                duplicatedPhotosCount.append(firstInt)
////                                group.append(photosInGallery[firstInt])
////                            }
////
////                            if !duplicatedPhotosCount.contains(socondInt) {
////                                duplicatedPhotosCount.append(socondInt)
////                                group.append(photosInGallery[socondInt])
////                            }
////                        } else {
////                            return
////                        }
////                    })
////                    if group.count >= 2 {
////                        duplicatedGroup.append(PhassetGroup(name: "", assets: group))
////                    }
////                }
////            }
////            if !isDeepCleanScan {
////                U.UI {
////                    completionHandler(duplicatedGroup)
////                }
////            } else {
////                completionHandler(duplicatedGroup)
////            }
////        }
////    }
//    
////    /// `load selfies` from gallery
////    public func getSelfiePhotos(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", isDeepCleanScan: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
////
////        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumSelfPortraits, by: PHAssetMediaType.image.rawValue) { selfiesInLibrary in
////
////            U.BG {
////                var selfies: [PHAsset] = []
////                if selfiesInLibrary.count == 0 {
////                    if !isDeepCleanScan {
////                        U.UI {
////                            completionHandler([])
////                        }
////                    } else {
////                        completionHandler([])
////                    }
////                    return
////                }
////
////                for selfiePos in 1...selfiesInLibrary.count {
////                    selfies.append(selfiesInLibrary[selfiePos - 1])
////                }
////                if !isDeepCleanScan {
////                    U.UI {
////                        completionHandler(selfies)
////                    }
////                } else {
////                    completionHandler(selfies)
////                }
////            }
////        }
////    }
//    
////    /// `load live photos` from gallery
////    public func getLivePhotos(isDeepCleanScan: Bool = false,_ completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
////
////        fetchManager.fetchFromGallery(collectiontype: .smartAlbumLivePhotos, by: PHAssetMediaType.image.rawValue) { livePhotosLibrary in
////
////            U.BG {
////                var livePhotos: [PHAsset] = []
////                if livePhotosLibrary.count == 0 {
////                    if !isDeepCleanScan {
////                        U.UI {
////                            completionHandler([])
////                        }
////                    } else {
////                        completionHandler([])
////                    }
////                    return
////                }
////
////                for livePhoto in 1...livePhotosLibrary.count {
////                    livePhotos.append(livePhotosLibrary[livePhoto - 1])
////                }
////                if !isDeepCleanScan {
////                    U.UI {
////                        completionHandler(livePhotos)
////                    }
////                } else {
////                    completionHandler(livePhotos)
////                }
////            }
////        }
////    }
//    
//
//}

//  MARK: - video part -
//extension PhotoManagerOLD {
//
////    /// `fetch large videos` from gallery
////    public func getLargevideoContent(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", isDeepCleanScan: Bool = false, completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
////
////        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
////            U.BG {
////                var videos: [PHAsset] = []
////
////                if videoContent.count == 0 {
////                    if !isDeepCleanScan {
////                        U.UI {
////                            completionHandler([])
////                        }
////                    } else {
////                        completionHandler([])
////                    }
////                    return
////                }
////
////                for videosPosition in 1...videoContent.count {
////
////                    if videoContent[videosPosition - 1].imageSize > 55000000 {
////                        videos.append(videoContent[videosPosition - 1])
////                    }
////
////                    if isDeepCleanScan {
////                        self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .largeVideo,
////                                                                                 totalProgressItems: videoContent.count,
////                                                                                 currentProgressItem: videosPosition)
////                    }
////                }
////
////                if !isDeepCleanScan {
////                    U.UI {
////                        completionHandler(videos)
////                    }
////                } else {
////                    completionHandler(videos)
////                }
////            }
////        }
////    }
//
////    /// `similar Videos` from gallery
////    public func getSimilarVideoAssets(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", isDeepCleanScan: Bool = false,  completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) {
////
////        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
////            U.BG {
////                var assets: [PHAsset] = []
////
////                if videoContent.count == 0 {
////                    if !isDeepCleanScan {
////                        U.UI {
////                            completionHandler([])
////                        }
////                    } else {
////                        completionHandler([])
////                    }
////                    return
////                }
////
////                for videoPosition in 1...videoContent.count {
////                    let asset = videoContent[videoPosition - 1]
////                    assets.append(asset)
////                }
////
////                let similarVideoPhassetGroup = self.findDupes(assets: assets, strictness: .similar, isDeepCleanScan: isDeepCleanScan)
////
////                if !isDeepCleanScan {
////                    U.UI {
////                        completionHandler(similarVideoPhassetGroup)
////                    }
////                } else {
////                    completionHandler(similarVideoPhassetGroup)
////                }
////            }
////        }
////    }
//
////    /// `similar videos by time stamp`
////    public func getSimilarVideosByTimeStamp(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", isDeepCleanScan: Bool = false, completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) {
////
////        fetchManager.fetchFromGallery(from: startDate, to: endDate, collectiontype: .smartAlbumVideos, by: PHAssetMediaType.video.rawValue) { videoContent in
////            U.BG {
////                var assets: [PHAsset] = []
////                var grouped: [PhassetGroup] = []
////
////                if videoContent.count == 0 {
////                    if !isDeepCleanScan {
////                        U.UI {
////                            completionHandler([])
////                        }
////                    } else {
////                        completionHandler([])
////                    }
////                    return
////                }
////
////                for videoPosition in 1...videoContent.count {
////                    assets.append(videoContent[videoPosition - 1])
////                }
////
////                for video in assets {
////                    var compareAsset: [PHAsset] = []
////                    debugPrint("->>>>>>>>>>")
////                    debugPrint(video.localIdentifier)
////
////                    for check in assets {
////                        debugPrint("........")
////                        debugPrint(check.localIdentifier)
////                        if video.localIdentifier != check.localIdentifier {
////                            if video.duration == check.duration && video.creationDate == check.creationDate {
////                                compareAsset.append(video)
////                                compareAsset.append(check)
////                            } else {
////
////                            }
////                        }
////                    }
////
////                    if compareAsset.count != 0 {
////                        grouped.append(PhassetGroup.init(name: "", assets: compareAsset))
////                    }
////                }
////
////                if !isDeepCleanScan {
////                    U.UI {
////                        completionHandler(grouped.isEmpty ? [] : grouped)
////                    }
////                } else {
////                    completionHandler(grouped.isEmpty ? [] : grouped)
////                }
////            }
////        }
////    }
//
//
////    /// `duplicated videos compare algorithm`
////    public func getDuplicatedVideoAsset(from startDate: String = "01-01-1970 00:00:00", to endDate: String = "01-01-2666 00:00:00", isDeepCleanScan: Bool = false, completionHandler: @escaping ((_ videoAssets: [PhassetGroup]) -> Void)) {
////
////        fetchManager.fetchFromGallery(from: startDate,
////                                      to: endDate,
////                                      collectiontype: .smartAlbumVideos,
////                                      by: PHAssetMediaType.video.rawValue) { videoCollection in
////            var videos: [OSTuple<NSString, NSData>] = []
////
////            U.BG {
////                if videoCollection.count != 0 {
////                    for index in 1...videoCollection.count {
////
////                        if isDeepCleanScan {
////                            self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .duplicateVideo,
////                                                                                     totalProgressItems: videoCollection.count,
////                                                                                     currentProgressItem: index)
////                        }
////
////                        let image = self.fetchManager.getThumbnail(from: videoCollection[index - 1], size: CGSize(width: 150, height: 150))
////                        if let data = image.jpegData(compressionQuality: 0.8) {
////                            let imageTuple = OSTuple<NSString, NSData>(first: "image\(index)" as NSString, andSecond: data as NSData)
////                            videos.append(imageTuple)
////                        } else {
//////                            return
////                        }
////                    }
////
////                    let duplicateVideoIDasTuples = OSImageHashing.sharedInstance().similarImages(withProvider: .pHash, forImages: videos)
////                    var duplicateVideoNumbers: [Int] = []
////                    var duplicateVideoGroups: [PhassetGroup] = []
////
////                    guard duplicateVideoIDasTuples.count >= 1 else {
////                        if !isDeepCleanScan {
////                            U.UI {
////                                completionHandler([])
////                            }
////                        } else {
////                            completionHandler([])
////                        }
////                        return
////                    }
////
////                    for index in 1...duplicateVideoIDasTuples.count {
////
////                        let tuple = duplicateVideoIDasTuples[index - 1]
////                        var groupAssets: [PHAsset] = []
////                        if let first = tuple.first as String?, let second = tuple.second as String? {
////                            let firstInteger = first.replacingStringAndConvertToIntegerForImage() - 1
////                            let secondInteger = second.replacingStringAndConvertToIntegerForImage() - 1
////
////                            if abs(secondInteger - firstInteger) >= 10 { continue }
////                            if !duplicateVideoNumbers.contains(firstInteger) {
////                                duplicateVideoNumbers.append(firstInteger)
////                                groupAssets.append(videoCollection[firstInteger])
////                            }
////
////                            if !duplicateVideoNumbers.contains(secondInteger) {
////                                duplicateVideoNumbers.append(secondInteger)
////                                groupAssets.append(videoCollection[secondInteger])
////                            }
////
////                            duplicateVideoIDasTuples.filter({$0.first != nil && $0.second != nil}).filter({ $0.first == tuple.first || $0.first == tuple.second || $0.second == tuple.second || $0.second == tuple.first }).forEach({ tuple in
////                                if let firstTuple = tuple.first as String?, let secondTuple = tuple.second as String? {
////                                    let firstTupleInteger = firstTuple.replacingStringAndConvertToIntegerForImage() - 1
////                                    let secondTupleInteger = secondTuple.replacingStringAndConvertToIntegerForImage() - 1
////
////                                    if abs(secondTupleInteger - firstTupleInteger) >= 10 {
////                                        return
////                                    }
////
////                                    if !duplicateVideoNumbers.contains(firstTupleInteger) {
////                                        duplicateVideoNumbers.append(firstTupleInteger)
////                                        groupAssets.append(videoCollection[firstTupleInteger])
////                                    }
////
////                                    if !duplicateVideoNumbers.contains(secondTupleInteger) {
////                                        duplicateVideoNumbers.append(secondTupleInteger)
////                                        groupAssets.append(videoCollection[secondInteger])
////                                    }
////                                }
////                            })
////
////                            if groupAssets.count >= 2 {
////                                duplicateVideoGroups.append(PhassetGroup(name: "", assets: groupAssets))
////                            }
////                        }
////                    }
////
////                    if !isDeepCleanScan {
////                        U.UI {
////                            completionHandler(duplicateVideoGroups)
////                        }
////                    } else {
////                        completionHandler(duplicateVideoGroups)
////                    }
////
////                } else {
////                    if !isDeepCleanScan {
////                        U.UI {
////                            completionHandler([])
////                        }
////                    } else {
////                        completionHandler([])
////                    }
////                    return
////                }
////            }
////        }
////    }
//
////    /// similar close to identical videos algoritm
////    public func findDupes(assets: [PHAsset], strictness: Strictness, isDeepCleanScan: Bool) -> [PhassetGroup] {
////
////        var phassetGroup: [PhassetGroup] = []
////
////        let rawTuples: [OSTuple<NSString, NSData>] = assets.enumerated().map { (index, asset) -> OSTuple<NSString, NSData> in
////            let imageData = asset.thumbnailSync?.pngData()
////            return OSTuple<NSString, NSData>.init(first: "\(index)" as NSString, andSecond: imageData as NSData?)
////        }
////
////        let toCheckTuples = rawTuples.filter({ $0.second != nil })
////
////        let providerId = OSImageHashingProviderIdForHashingQuality(.medium)
////        let provider = OSImageHashingProviderFromImageHashingProviderId(providerId);
////        let defaultHashDistanceTreshold = provider.hashDistanceSimilarityThreshold()
////        let hashDistanceTreshold: Int64
////
////        switch strictness {
////            case .similar:
////                hashDistanceTreshold = defaultHashDistanceTreshold
////            case .closeToIdentical:
////                hashDistanceTreshold = 1
////        }
////
////        let similarImageIdsAsTuples = OSImageHashing.sharedInstance().similarImages(withProvider: providerId, withHashDistanceThreshold: hashDistanceTreshold, forImages: toCheckTuples)
////
////        var assetToGroupIndex = [PHAsset: Int]()
////
////        var notificationStarterIndex = 1
////
////        for pair in similarImageIdsAsTuples {
////
////            if isDeepCleanScan {
////                self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .similarVideo,
////                                                                             totalProgressItems: notificationStarterIndex,
////                                                                             currentProgressItem: similarImageIdsAsTuples.count)
////                notificationStarterIndex += 1
////            }
////
////            let assetIndex1 = Int(pair.first! as String)!
////            let assetIndex2 = Int(pair.second! as String)!
////            let asset1 = assets[assetIndex1]
////            let asset2 = assets[assetIndex2]
////            let groupIndex1 = assetToGroupIndex[asset1]
////            let groupIndex2 = assetToGroupIndex[asset2]
////            if groupIndex1 == nil && groupIndex2 == nil {
////
////                let group = PhassetGroup.init(name: "", assets: [asset1, asset2])
////                phassetGroup.append(group)
////                let groupIndex = phassetGroup.count - 1
////                assetToGroupIndex[asset1] = groupIndex
////                assetToGroupIndex[asset2] = groupIndex
////            } else if groupIndex1 == nil && groupIndex2 != nil {
////                phassetGroup[groupIndex2!].assets.append(asset1)
////                assetToGroupIndex[asset1] = groupIndex2!
////            } else if groupIndex1 != nil && groupIndex2 == nil {
////                phassetGroup[groupIndex1!].assets.append(asset2)
////                assetToGroupIndex[asset2] = groupIndex1!
////            }
////        }
////        return phassetGroup
////    }
//}

//extension PhotoManagerOLD {
//
//	public func setAvailibleSearchProcessing() {
//
//	}
//
//	public func setStopSearchProcessing() {
//
//	}
//}

//      MARK: - delete selected assets -

//extension PhotoManagerOLD {
//
////    public func deleteSelected(assets: [PHAsset], completion: @escaping ((Bool) -> Void)) {
////
////        let assetsSelectedIdentifiers = assets.map({ $0.localIdentifier})
////
////        let deletedAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetsSelectedIdentifiers, options: nil)
////
////        PHPhotoLibrary.shared().performChanges {
////            PHAssetChangeRequest.deleteAssets(deletedAssets)
////        } completionHandler: { success, error in
////            U.UI {
////                completion(success)
////            }
////        }
////    }
//
////    /// fetch `recently deleted assets`
////    public func getRecentlyDeletedAssets(completion: @escaping ([PHAsset]) -> Void) {
////
////        fetchManager.recentlyDeletedAlbumFetch { assets in
////            completion(assets)
////        }
////    }
////
////    public func getSortedRecentlyDeletedAssets(completion: @escaping (_ photos: [PHAsset],_ videos: [PHAsset]) -> Void) {
////
////        fetchManager.recentlyDeletedSortedAlbumFetch { photos, videos in
////            completion(photos, videos)
////        }
////    }
//}

//      MARK: - change assets observer -

//extension PhotoManagerOLD: PHPhotoLibraryChangeObserver {
//
//    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        U.UI {
//            UpdatingChangesInOpenedScreensMediator.instance.updatingChangedScreenShots()
//            UpdatingChangesInOpenedScreensMediator.instance.updatingChangedSelfies()
//        }
//    }
//}

