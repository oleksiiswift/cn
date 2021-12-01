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
    private var contactManager = ContactsManager.shared
    
    let deepCleanOperationQue = OperationPhotoProcessingQueuer(name: "Deep Clean Queuer", maxConcurrentOperationCount: 10, qualityOfService: .default)
        
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
                                       emptyContacts: @escaping ([ContactsGroup]) -> Void,
                                       duplicatedContats: @escaping ([ContactsGroup]) -> Void,
                                       duplicatedPhoneNumbers: @escaping ([ContactsGroup]) -> Void,
                                       duplicatedEmails: @escaping ([ContactsGroup]) -> Void,
                                       completionHandler: @escaping () -> Void) {
        
        var totalResultCount = 0
    
        handler(optionMediaType)
        
//        MARK: - similar video -
        let similarLivePhotoFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start simmilar live photos")
            self.photoManager.getSimilarLivePhotos(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assetsGroup in
                similarLivePhotos(assetsGroup)
                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }
        
//        MARK: - large video -
        let largeVideosFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start fetch large videos")
            self.photoManager.getLargevideoContent(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { asset in
                
                largeVideo(asset)
                
                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }
        
//        MARK: - screenshots -
        let screenshotsFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start fetch screenshots")
            self.photoManager.getScreenShots(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assets in
                
                screenShots(assets)
                
                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }
        
//        MARK: - similar photoassets -
        let similarPhotoFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start similar photo asssets")
            self.photoManager.getSimilarPhotosAssets(from: startingFetchingDate, to: endingFetchingDate, fileSizeCheck: true, isDeepCleanScan: true) { assetsGroup in
                
                similarPhoto(assetsGroup)
                
                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }
        
//        MARK: - duplicated photo assets -
        let duplicatedPhotoFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start dupliacated photo assets")
            self.photoManager.getDuplicatedPhotosAsset(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assetsGroup in

                duplicatedPhoto(assetsGroup)

                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }
     
//        MARK: - similar videos assets -
        let similarVideoFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start simmilar video assets")
            self.photoManager.getSimilarVideoAssets(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assetsGroup in

                similarVideo(assetsGroup)

                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }
        
//        MARK: - duplicated video assets -
        let duplicatedVideoFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start duplicated video assets")
            self.photoManager.getDuplicatedVideoAsset(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assetsGroup in

                duplicatedVideo(assetsGroup)

                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }
        
//        MARK: - screen recordings assets - 
        let screenRecordingsFethcOperation = ConcurrentProcessOperation { _ in
            debugPrint("start screen records vidoes")
            self.photoManager.getScreenRecordsVideos(from: startingFetchingDate, to: endingFetchingDate, isDeepCleanScan: true) { assets in

                screenRecordings(assets)

                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }

//        MARK: - mark fetch contacts -
        let emptyContactsFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start fetch empty Contacts")
            self.contactManager.deepCleanEmptySearchContacts { contactsGroup in
                emptyContacts(contactsGroup)
                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }
        
//        MARK: - duplicated contacts -
        let duplicatedContactsFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start fetch duplicated contacts Contacts")
            self.contactManager.deepCleanDuplicatedContactsSearchContacts { contactsGroup in
                duplicatedContats(contactsGroup)
                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }

//        MARK: - duplicated phone numbers contacts -
        let duplicatedPhoneNumbersContactsFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start fetch phonenumbers duplicated Contacts")
            self.contactManager.deepCleanDuplicatedPhoneNumbersSearchContacts { contacstsGroup in
                duplicatedPhoneNumbers(contacstsGroup)
                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }

//        MARK: - duplicated email contact s-
        let duplicatedEmailContactsFetchOperation = ConcurrentProcessOperation { _ in
            debugPrint("start fetch emails duplicated Contacts")
            self.contactManager.deepCleanDuplicatedEmailsSearchSearchContacts { contacstsGroup in
                duplicatedEmails(contacstsGroup)
                totalResultCount += 1
                if totalResultCount == 12 {
                    completionHandler()
                }
            }
        }
        
        deepCleanOperationQue.addOperation(duplicatedPhotoFetchOperation)
        deepCleanOperationQue.addOperation(similarPhotoFetchOperation)
        deepCleanOperationQue.addOperation(duplicatedVideoFetchOperation)
        deepCleanOperationQue.addOperation(similarVideoFetchOperation)
        deepCleanOperationQue.addOperation(largeVideosFetchOperation)
        deepCleanOperationQue.addOperation(screenRecordingsFethcOperation)
        deepCleanOperationQue.addOperation(screenshotsFetchOperation)
        deepCleanOperationQue.addOperation(similarLivePhotoFetchOperation)
        deepCleanOperationQue.addOperation(emptyContactsFetchOperation)
        deepCleanOperationQue.addOperation(duplicatedContactsFetchOperation)
        deepCleanOperationQue.addOperation(duplicatedPhoneNumbersContactsFetchOperation)
        deepCleanOperationQue.addOperation(duplicatedEmailContactsFetchOperation)
    }
}
