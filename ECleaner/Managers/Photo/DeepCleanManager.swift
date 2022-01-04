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
	private var progressNotificationManager = ProgressSearchNotificationManager.instance
    
	let wholeCleanOperationQueuer = OperationProcessingQueuer(name: C.key.operation.queue.deepClean, maxConcurrentOperationCount: 5, qualityOfService: .background)
	
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
	
	public func resetProcessingProgressBars() {
		
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .emptyContacts, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .duplicateContacts, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .duplicatedPhoneNumbers, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .duplicatedEmails, totalProgressItems: 0, currentProgressItem: 0)
		
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .largeVideo, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .duplicateVideo, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .similarVideo, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .screenRecordings, totalProgressItems: 0, currentProgressItem: 0)
		
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .similarPhoto, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .duplicatePhoto, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .screenshots, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotificatin(notificationType: .similarLivePhoto, totalProgressItems: 0, currentProgressItem: 0)
	}
}

extension DeepCleanManager {
		
	public func startingDeepCleanProcessing(with selectedCollectionsIDs: [PhotoMediaType : [String]], photoVideoGroups: [PhotoMediaType : [PhassetGroup]], contactsFlowGroups: [PhotoMediaType : [ContactsGroup]], completionHandler: @escaping () -> Void) {
		
		var numberOFProcessingClean = 0
		var photoVideoDeleteProcessingIDS: [String] = []
		var mergeContactsGroupsProcessingIDS:  [String] = []
		var deleteContactsProcessingODS: [String] = []
		var mergeContactsGroups: [ContactsGroup] = []
		
		U.notificationCenter.post(name: .removeContactsStoreObserver, object: nil)
		
		for (key, value) in selectedCollectionsIDs {
			switch key {
				case .similarPhotos, .duplicatedPhotos, .singleScreenShots, .singleLivePhotos, .similarLivePhotos, .singleSelfies, .singleRecentlyDeletedPhotos, .singleLargeVideos, .duplicatedVideos, .similarVideos:
					photoVideoDeleteProcessingIDS.append(contentsOf: value)
				case .emptyContacts:
					deleteContactsProcessingODS.append(contentsOf: value)
				case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
						mergeContactsGroupsProcessingIDS.append(contentsOf: value)
					if let duplicatedContacts = contactsFlowGroups[key] {
						for id in value {
							if let group = duplicatedContacts.first(where: {$0.groupIdentifier == id}) {
								mergeContactsGroups.append(group)
							}
						}
					}
				default:
					return
			}
		}
		
		/// `deleting photos and videos`
		photoVideoDeleteProcessingIDS = Array(Set(photoVideoDeleteProcessingIDS))
		fetchManager.fetchPhassetFromGallery(with: photoVideoDeleteProcessingIDS) { phassets in
			if !phassets.isEmpty {
				let deleteOperaion = self.photoManager.deleteSelectedOperation(assets: phassets) { isDeleted in
					if isDeleted {
						ErrorHandler.shared.deepCleanDeleteAlertError(.photoVideoCleanSuxxessfully, errorsCount: 0)
					} else {
						ErrorHandler.shared.deepCleanDeleteAlertError(.errorPhotoClean, errorsCount: 0)
					}
					numberOFProcessingClean += 1
					if numberOFProcessingClean == 3 {
						completionHandler()
					}
				}
				self.wholeCleanOperationQueuer.addOperation(deleteOperaion)
			} else {
				numberOFProcessingClean += 1
				if numberOFProcessingClean == 3 {
					completionHandler()
				}
			}
		}
		
		
		/// `deleting empty contacts`
		contactManager.getPredicateContacts(with: deleteContactsProcessingODS) { contacts in
			if !contacts.isEmpty {
				self.contactManager.deleteContacts(contacts) { isDeleted, count in
					if isDeleted {
						ErrorHandler.shared.deepCleanDeleteAlertError(.emptyContactsSuxxessfylly, errorsCount: 0)
					} else {
						ErrorHandler.shared.deepCleanDeleteAlertError(.errorEmptyContactsClean, errorsCount: count)
					}
					
					numberOFProcessingClean += 1
					if numberOFProcessingClean == 3 {
						completionHandler()
					}
				}
			} else {
				numberOFProcessingClean += 1
				if numberOFProcessingClean == 3 {
					completionHandler()
				}
			}
		}
		
		/// `merge and delete whole duplicates`
		contactManager.deepCleanDuplicatedSmartMerge(mergeContactsGroups) { suxxess, numberOfErrors in
			if suxxess {
				ErrorHandler.shared.deepCleanDeleteAlertError(.contactsCleanSuxxessfully, errorsCount: 0)
			} else {
				ErrorHandler.shared.deepCleanDeleteAlertError(.errorContactsClean, errorsCount: numberOfErrors)
			}
			numberOFProcessingClean += 1
			if numberOFProcessingClean == 3 {
				completionHandler()
			}
			
		}		
	}
}
