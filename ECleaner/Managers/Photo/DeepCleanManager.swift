//
//  DeepCleanManager.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.07.2021.
//

import Foundation
import Photos

class DeepCleanManager {
    
    private var photoManager = PhotoManager.manager
        
    public func startDeepCleaningFetch(_ optionMediaType: [PhotoMediaType], startingFetchingDate: String, endingFetchingDate: String,
                                       handler: @escaping ([PhotoMediaType]) -> Void,
                                       screenShots: @escaping ([PHAsset]) -> Void,
                                       similarPhoto: @escaping ([PhassetGroup]) -> Void,
                                       duplicatedPhoto: @escaping ([PhassetGroup]) -> Void,
                                       similarLivePhotos: @escaping ([PhassetGroup]) -> Void,
                                       largeVideo: @escaping ([PHAsset]) -> Void,
                                       similarVideo: @escaping ([PhassetGroup]) -> Void,
                                       duplicatedVideo: @escaping ([PhassetGroup]) -> Void,
                                       screenRecordings: @escaping ([PHAsset]) -> Void,
                                       completionHandler: @escaping () -> Void) {
        
        let fetchingPhassetQueue: OperationQueue = {
            let operation = OperationQueue()
            operation.qualityOfService = .userInitiated
            operation.maxConcurrentOperationCount = 10
            return operation
        }()

        var totalResultCount = 0
    
        handler(optionMediaType)
        
        fetchingPhassetQueue.addOperation {
            debugPrint("start simmilar photos")
            self.photoManager.getSimilarLivePhotos(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assetsGroup in

                similarLivePhotos(assetsGroup)

                totalResultCount += 1
                if totalResultCount == 8 {
                    completionHandler()
                }
            }
        }
        
        fetchingPhassetQueue.addOperation {
            debugPrint("start fetch large videos")
            self.photoManager.getLargevideoContent(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { asset in
                
                largeVideo(asset)
                
                totalResultCount += 1
                if totalResultCount == 8 {
                    completionHandler()
                }
            }
        }
        
        fetchingPhassetQueue.addOperation {
            debugPrint("start fetch screenshots")
            self.photoManager.getScreenShots(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assets in
                
                screenShots(assets)
                
                totalResultCount += 1
                if totalResultCount == 8 {
                    completionHandler()
                }
            }
        }
        
        fetchingPhassetQueue.addOperation {
            debugPrint("start similar photo asssets")
            self.photoManager.getSimilarPhotosAssets(from: startingFetchingDate, to: endingFetchingDate, fileSizeCheck: false, isDeepCleanScan: true) { assetsGroup in
                
                similarPhoto(assetsGroup)
                
                totalResultCount += 1
                if totalResultCount == 8 {
                    completionHandler()
                }
            }
        }
        
        fetchingPhassetQueue.addOperation {
            debugPrint("start dupliacated photo assets")
            self.photoManager.getDuplicatedPhotosAsset(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assetsGroup in

                duplicatedPhoto(assetsGroup)

                totalResultCount += 1
                if totalResultCount == 8 {
                    completionHandler()
                }
            }
        }
            
        fetchingPhassetQueue.addOperation {
            debugPrint("start simmilar video assets")
            self.photoManager.getSimilarVideoAssets(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assetsGroup in

                similarVideo(assetsGroup)

                totalResultCount += 1
                if totalResultCount == 8 {
                    completionHandler()
                }
            }
        }
        
        fetchingPhassetQueue.addOperation {
            debugPrint("start duplicated video assets")
            self.photoManager.getDuplicatedVideoAsset(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assetsGroup in

                duplicatedVideo(assetsGroup)

                totalResultCount += 1
                if totalResultCount == 8 {
                    completionHandler()
                }
            }
        }
        
        fetchingPhassetQueue.addOperation {
            debugPrint("start screen records vidoes")
            self.photoManager.getScreenRecordsVideos(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assets in

                screenRecordings(assets)

                totalResultCount += 1
                if totalResultCount == 8 {
                    completionHandler()
                }
            }
        }
    }
}
