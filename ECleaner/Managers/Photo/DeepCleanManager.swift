//
//  DeepCleanManager.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.07.2021.
//

import Foundation
import Photos

class DeepCleanManager {
    
	private var photoManager = PhotoManager.shared
    private var contactManager = ContactsManager.shared
	private var fetchManager = PHAssetFetchManager.shared
    
	let deepCleanOperationQue = OperationProcessingQueuer(name: C.key.operation.queue.deepClean, maxConcurrentOperationCount: 5, qualityOfService: .default)
        
    public func startDeepCleaningFetch(_ optionMediaType: [PhotoMediaType], startingFetchingDate: Date, endingFetchingDate: Date,
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
		
		
//        MARK: - similar photoassets -
		let getSimilarPhotosAssetsOperation = photoManager.getSimilarPhotosAssetsOperation(from: startingFetchingDate, to: endingFetchingDate, enableDeepCleanProcessingNotification: true) { similarGroup in
			similarPhoto(similarGroup)
			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		}
		
		
//        MARK: - duplicated photo assets -
		let duplicatedPhotoAssetOperation = photoManager.getDuplicatedPhotosAsset(from: startingFetchingDate, to: endingFetchingDate, enableDeepCleanProcessingNotification: true) { duplicateGroup in
			duplicatedPhoto(duplicateGroup)
			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		}
		
//        MARK: - screenshots -
		let getScreenShotsAssetsOperation = photoManager.getScreenShotsOperation(from: startingFetchingDate, to: endingFetchingDate, enableDeepCleanProcessingNotification: true) { screenshots in
			screenShots(screenshots)
			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		}
		
//        MARK: - similar live photo -
		let getLivePhotoAssetsOperation = photoManager.getSimilarLivePhotosOperation(from: startingFetchingDate, to: endingFetchingDate, enableDeepCleanProcessingNotification: true) { similarAssets in
			similarLivePhotos(similarAssets)
			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		}
		
//        MARK: - large video -
		let getLargevideoContentOperation = photoManager.getLargevideoContentOperation(from: startingFetchingDate, to: endingFetchingDate, enableDeepCleanProcessingNotification: true) { largeVodepAsset in
			largeVideo(largeVodepAsset)
			
			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		}
		
//        MARK: - duplicated video assets -
		let getDuplicatedVideoAssetOperatioon = photoManager.getDuplicatedVideoAssetOperation(from: startingFetchingDate, to: endingFetchingDate, enableDeepCleanProcessingNotification: true) { duplicatedVideoAsset in
			duplicatedVideo(duplicatedVideoAsset)

			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		}

//        MARK: - similar videos assets -
		let getSimilarVideoAssetsOperation = photoManager.getSimilarVideoAssetsOperation(from: startingFetchingDate, to: endingFetchingDate, enableDeepCleanProcessingNotification: true) { similiarVideoAsset in
			similarVideo(similiarVideoAsset)

			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		}
		
//        MARK: - screen recordings assets -
		let getScreenRecordsVideosOperation = photoManager.getScreenRecordsVideosOperation(from: startingFetchingDate, to: endingFetchingDate, enableDeepCleanProcessingNotification: true) { screenRecordsAssets in
			screenRecordings(screenRecordsAssets)

			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		}
		
		deepCleanOperationQue.addOperation(getSimilarPhotosAssetsOperation)
		deepCleanOperationQue.addOperation(duplicatedPhotoAssetOperation)
		deepCleanOperationQue.addOperation(getScreenShotsAssetsOperation)
		deepCleanOperationQue.addOperation(getLivePhotoAssetsOperation)
		deepCleanOperationQue.addOperation(getLargevideoContentOperation)
		deepCleanOperationQue.addOperation(getDuplicatedVideoAssetOperatioon)
		deepCleanOperationQue.addOperation(getSimilarVideoAssetsOperation)
		deepCleanOperationQue.addOperation(getScreenRecordsVideosOperation)
		

//        MARK: - mark fetch contacts -
		contactManager.getDeepCleanContactsProcessing {
			
			
		} emptyContactsCompletion: { emptyContactsGroup in
				/// - empty fields contacts
			emptyContacts(emptyContactsGroup)
			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		} duplicatedContactsCompletion: { duplicatedContactsGroup in
				/// - duplicated contacts -
			duplicatedContats(duplicatedContactsGroup)
			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		} duplicatedPhoneNumbersCompletion: { duplicatedNumbersContactsGroup in
				/// - duplicated phone numbers contacts -
			duplicatedPhoneNumbers(duplicatedNumbersContactsGroup)
			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		} duplicatedEmailsContactsCompletion: { duplicatedEmailsContactsGroup in
				/// duplicated email contact s-
			duplicatedEmails(duplicatedEmailsContactsGroup)
			totalResultCount += 1
			if totalResultCount == 12 {
				completionHandler()
			}
		}
    }
	
	public func cancelAllOperation() {
		photoManager.serviceUtilsCalculatedOperationsQueuer.cancelAll()
		deepCleanOperationQue.cancelAll()
		contactManager.contactsProcessingOperationQueuer.cancelAll()
	}
}
