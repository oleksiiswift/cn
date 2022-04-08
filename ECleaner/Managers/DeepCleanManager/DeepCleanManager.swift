//
//  DeepCleanManager.swift
//  ECleaner
//
//  Created by alekseii sorochan on 23.07.2021.
//

import Foundation
import Photos
import Contacts

class DeepCleanManager {
    
	private var photoManager = PhotoManager.shared
    private var contactManager = ContactsManager.shared
	private var fetchManager = PHAssetFetchManager.shared
	private var progressNotificationManager = ProgressSearchNotificationManager.instance
    
	let wholeCleanOperationQueuer = OperationProcessingQueuer(name: C.key.operation.queue.deepClean, maxConcurrentOperationCount: 3, qualityOfService: .background)
	let deepCleanOperationQueue = OperationProcessingQueuer(name: C.key.operation.queue.deepClean, maxConcurrentOperationCount: 3, qualityOfService: .background)
        
    public func startDeepCleaningFetch(_ optionMediaType: [PhotoMediaType], startingFetchingDate: Date, endingFetchingDate: Date,
                                       handler: @escaping ([PhotoMediaType]) -> Void,
                                       screenShots: @escaping ([PHAsset]) -> Void,
                                       similarPhoto: @escaping ([PhassetGroup]) -> Void,
                                       duplicatedPhoto: @escaping ([PhassetGroup]) -> Void,
									   similarSelfiesPhoto: @escaping ([PhassetGroup]) -> Void,
                                       similarLivePhotos: @escaping ([PhassetGroup]) -> Void,
                                       largeVideo: @escaping ([PHAsset]) -> Void,
                                       similarVideo: @escaping ([PhassetGroup]) -> Void,
                                       duplicatedVideo: @escaping ([PhassetGroup]) -> Void,
                                       screenRecordings: @escaping ([PHAsset]) -> Void,
                                       emptyContacts: @escaping ([ContactsGroup]) -> Void,
                                       duplicatedContats: @escaping ([ContactsGroup]) -> Void,
                                       duplicatedPhoneNumbers: @escaping ([ContactsGroup]) -> Void,
                                       duplicatedEmails: @escaping ([ContactsGroup]) -> Void,
									   completionHandler: @escaping (_ isCancelled: Bool) -> Void) {
        
        var totalResultCount = 0
		var operationQueueHandler: [ConcurrentProcessOperation] = []
        handler(optionMediaType)
		
//        MARK: - similar photoassets -
		let getSimilarPhotosAssetsOperation = photoManager.getSimilarPhotosAssetsOperation(from: startingFetchingDate, to: endingFetchingDate, cleanProcessingType: .deepCleen) { similarGroup, isCancelled in
			similarPhoto(similarGroup)
			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		}
		operationQueueHandler.append(getSimilarPhotosAssetsOperation)
		
//        MARK: - duplicated photo assets -
		let duplicatedPhotoAssetOperation = photoManager.getDuplicatedPhotosAsset(from: startingFetchingDate, to: endingFetchingDate, cleanProcessingType: .deepCleen) { duplicateGroup, isCancelled in
			duplicatedPhoto(duplicateGroup)
			totalResultCount += 1
			debugPrint(totalResultCount)
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		}
		operationQueueHandler.append(duplicatedPhotoAssetOperation)
		
//        MARK: - screenshots -
		let getScreenShotsAssetsOperation = photoManager.getScreenShotsOperation(from: startingFetchingDate, to: endingFetchingDate, cleanProcessingType: .deepCleen) { screenshots, isCancelled in
			screenShots(screenshots)
			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		}
		operationQueueHandler.append(getScreenShotsAssetsOperation)
		
//		MARK: - similar selfies photo -
		
		let getSimilarSelfiesPhotoPhassetOperation = photoManager.getSimilarSelfiePhotosOperation(from: startingFetchingDate, to: endingFetchingDate, cleanProcessingType: .deepCleen) { similartSelfiesGroup, isCancelled in
			similarSelfiesPhoto(similartSelfiesGroup)
			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		}
		operationQueueHandler.append(getSimilarSelfiesPhotoPhassetOperation)
		
//        MARK: - similar live photo -
		let getLivePhotoAssetsOperation = photoManager.getSimilarLivePhotosOperation(from: startingFetchingDate, to: endingFetchingDate, cleanProcessingType: .deepCleen) { similarAssets, isCancelled in
			similarLivePhotos(similarAssets)
			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		}
		operationQueueHandler.append(getLivePhotoAssetsOperation)
		
//        MARK: - large video -
		let getLargevideoContentOperation = photoManager.getLargevideoContentOperation(from: startingFetchingDate, to: endingFetchingDate, cleanProcessingType: .deepCleen) { largeVodepAsset, isCancelled in
			largeVideo(largeVodepAsset)
			
			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		}
		operationQueueHandler.append(getLargevideoContentOperation)
		
//        MARK: - duplicated video assets -
		let getDuplicatedVideoAssetOperatioon = photoManager.getDuplicatedVideoAssetOperation(from: startingFetchingDate, to: endingFetchingDate, cleanProcessingType: .deepCleen) { duplicatedVideoAsset, isCancelled in
			duplicatedVideo(duplicatedVideoAsset)

			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		}
		operationQueueHandler.append(getDuplicatedVideoAssetOperatioon)

//        MARK: - similar videos assets -
		let getSimilarVideoAssetsOperation = photoManager.getSimilarVideoAssetsOperation(from: startingFetchingDate, to: endingFetchingDate, cleanProcessingType: .deepCleen) { similiarVideoAsset, isCancelled in
			similarVideo(similiarVideoAsset)

			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		}
		operationQueueHandler.append(getSimilarVideoAssetsOperation)
		
//        MARK: - screen recordings assets -
		let getScreenRecordsVideosOperation = photoManager.getScreenRecordsVideosOperation(from: startingFetchingDate, to: endingFetchingDate, cleanProcessingType: .deepCleen) { screenRecordsAssets, isCancelled in
			screenRecordings(screenRecordsAssets)

			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		}
		
		operationQueueHandler.append(getScreenRecordsVideosOperation)
		
		operationQueueHandler.forEach { operation in
			self.deepCleanOperationQueue.addOperation(operation)
		}

//        MARK: - mark fetch contacts -
		contactManager.getDeepCleanContactsProcessing { isCancelled in
			
		} emptyContactsCompletion: { emptyContactsGroup, isCancelled in
				/// - empty fields contacts
			emptyContacts(emptyContactsGroup)
			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		} duplicatedContactsCompletion: { duplicatedContactsGroup, isCancelled in
				/// - duplicated contacts -
			duplicatedContats(duplicatedContactsGroup)
			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		} duplicatedPhoneNumbersCompletion: { duplicatedNumbersContactsGroup, isCancelled in
				/// - duplicated phone numbers contacts -
			duplicatedPhoneNumbers(duplicatedNumbersContactsGroup)
			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		} duplicatedEmailsContactsCompletion: { duplicatedEmailsContactsGroup, isCancelled in
				/// duplicated email contact s-
			duplicatedEmails(duplicatedEmailsContactsGroup)
			totalResultCount += 1
			if totalResultCount == 13 {
				completionHandler(isCancelled)
			}
		}
    }
	
	public func cancelAllOperation() {
		photoManager.serviceUtilsCalculatedOperationsQueuer.cancelAll()
		deepCleanOperationQueue.cancelAll()
		contactManager.contactsProcessingOperationQueuer.cancelAll()
	}
	
	public func resetProcessingProgressBars() {
		
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .emptyContacts, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .duplicateContacts, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .duplicatedPhoneNumbers, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .duplicatedEmails, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .largeVideo, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .duplicateVideo, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .similarVideo, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .screenRecordings, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .similarPhoto, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .duplicatePhoto, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .screenshots, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
		self.progressNotificationManager.sendDeepProgressNotification(notificationType: .similarLivePhoto, status: .sleeping, totalProgressItems: 0, currentProgressItem: 0)
	}
}

extension DeepCleanManager {
	
	public func startingDeepCleaningProcessing(with model: DeepCleanModel, completionHandler: @escaping (Int) -> Void, concelCompletionHandler: @escaping () -> Void) {
		
		U.notificationCenter.post(name: .removeContactsStoreObserver, object: nil)
		
		var photoVideoDeleteProcessingIDS: [String] = []
		var deleteContactsProcessingODS: [String] = []
		var mergeContactsGroups: [ContactsGroup] = []
		var errorsCount: Int = 0
		
		self.handleProgressNotification(of: .prepareCleaning, with: 0, and: 0)
		
		for (key, value) in model.objects {
			switch key {
				case .similarPhotos, .duplicatedPhotos, .singleScreenShots, .similarSelfies, .similarLivePhotos, .singleLargeVideos, .duplicatedVideos, .similarVideos, .singleScreenRecordings:
					photoVideoDeleteProcessingIDS.append(contentsOf: value.selectedAssetsCollectionID)
				case .emptyContacts:
					deleteContactsProcessingODS.append(contentsOf: value.selectedAssetsCollectionID)
				case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
					mergeContactsGroups.append(contentsOf: value.getContactsMergeGroups())
				default:
					debugPrint("")
			}
		}
	
		let deepCleanProcessingCleaningOperation = ConcurrentProcessOperation { operation in
			
			photoVideoDeleteProcessingIDS = Array(Set(photoVideoDeleteProcessingIDS))
			
			
			self.fetchManager.fetchPhassetFromGallery(with: photoVideoDeleteProcessingIDS) { phassets in
				if !phassets.isEmpty {
					let assetsSelectedIdentifiers = phassets.map({ $0.localIdentifier})
					let deletedAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetsSelectedIdentifiers, options: nil)
					PHPhotoLibrary.shared().performChanges {
						if operation.isCancelled {
							concelCompletionHandler()
							return
						}
						PHAssetChangeRequest.deleteAssets(deletedAssets)
					} completionHandler: { success, error in
						error != nil ? errorsCount += 1 : ()
					
						for position in 1...phassets.count {
							U.delay(0.1) {
								self.handleProgressNotification(of: .photoCleaning, with: position, and: phassets.count)
							}
						}
					}
				}
			}
			
			sleep(UInt32(3))
				/// delete contacts
			self.contactManager.getPredicateContacts(with: deleteContactsProcessingODS) { contacts in
				if !contacts.isEmpty {
					var operationDeleteCount = 0
					
					for contact in contacts {
						if operation.isCancelled {
							concelCompletionHandler()
							return
						}
						
						self.contactManager.deleteContact(contact) { success in
							operationDeleteCount += 1
							!success ? errorsCount += 1 : ()
							self.handleProgressNotification(of: .contactsEmptyCleaning, with: operationDeleteCount, and: contacts.count)
						}
					}
				}
			}
			
			if mergeContactsGroups.isEmpty {
				completionHandler(errorsCount)
				return
			}
			
			var deletingContacts: [CNContact] = []
			var bestContactsIDs: [String] = []
			var index = 0
			
				/// merge contacts
			let dispatchGroup = DispatchGroup()
			dispatchGroup.enter()
			
			for group in mergeContactsGroups {
				
				if operation.isCancelled {
					concelCompletionHandler()
					return
				}
				
				self.contactManager.contactsMerge(in: group) { mutableID, contacts in
					deletingContacts.append(contentsOf: contacts)
					bestContactsIDs.append(mutableID)
					index += 1
					
					self.handleProgressNotification(of: .contactsMergeCleaning, with: index, and: mergeContactsGroups.count)
					
					if index == mergeContactsGroups.count {
						dispatchGroup.leave()
					}
				}
			}
			/// delete contacts after merge
			dispatchGroup.notify(queue: DispatchQueue.global()) {
					
				self.contactManager.getPredicateContacts(with: bestContactsIDs) { contacts in
					let _ = Set(contacts).intersection(Set(deletingContacts))
					let deletingContacts = Set(deletingContacts).subtracting(Set(contacts))
					
					var operationDeleteCount = 0
					
					for deletingContact in deletingContacts {
						
						if operation.isCancelled {
							concelCompletionHandler()
							return
						}
						
						self.contactManager.deleteContact(deletingContact) { success in
							
							operationDeleteCount += 1
							!success ? errorsCount += 1 : ()
							
							self.handleProgressNotification(of: .contactsDeleteCleaning, with: operationDeleteCount, and: deletingContacts.count)
							
							if deletingContacts.count == operationDeleteCount {
								completionHandler(errorsCount)
							}
						}
					}
				}
			}
		}
		
		deepCleanProcessingCleaningOperation.name = C.key.operation.name.deepCleanProcessingCleaningOperation
		wholeCleanOperationQueuer.addOperation(deepCleanProcessingCleaningOperation)
	}
	
	private func handleProgressNotification(of type: DeepCleaningType, with position: Int, and count: Int) {
		
		let progress: CGFloat = type == .prepareCleaning ? 0 : CGFloat(100 * position / count)
		let processingTitle: String = type == .prepareCleaning ? type.progressTitle : type.progressTitle + " \(Int(progress))%"
		
		let infoDictionary: [String: Any ] = [C.key.notificationDictionary.progressAlert.deepCleanProgressValue: type == .prepareCleaning ? CGFloat(0) : progress / 100,
											  C.key.notificationDictionary.progressAlert.deepCleanProcessingChangedTitle: processingTitle]
		sleep(UInt32(0.5))
		U.notificationCenter.post(name: .progressDeepCleanDidChangeProgress, object: nil, userInfo: infoDictionary)
	}
	
	public func stopDeepCleanOperation() {
		self.wholeCleanOperationQueuer.cancelAll()
		self.deepCleanOperationQueue.cancelAll()
	}
}
