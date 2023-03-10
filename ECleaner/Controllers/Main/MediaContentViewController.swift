//
//  MediaContentViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit
import Photos
import SwiftMessages
import Contacts
import MapKit

enum SearchingProcessingType {
	case singleSearchProcess
	case smartGroupSearchProcess
	case clearSearchingProcessingQueue
}

class MediaContentViewController: UIViewController {
  
    @IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var dateSelectPickerView: DateSelectebleView!
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateSelectContainerHeigntConstraint: NSLayoutConstraint!
    
	private var searchingProcessingType: SearchingProcessingType = .clearSearchingProcessingQueue {
		didSet {
			handleChangeSmartCleanProcessing()
		}
	}

	private var subscriptionManager = SubscriptionManager.instance
    public var mediaContentType: MediaContentType = .none
	private var photoManager = PhotoManager.shared
    private var contactsManager = ContactsManager.shared
	private var smartCleanManager = SmartCleanManager()
	private var progrssAlertController = ProgressAlertController.shared
	
	public let phassetProcessingOperationQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.phassets, maxConcurrentOperationCount: 5, qualityOfService: .userInitiated)
	public let contactsProcessingOperationQueuer = ContactsManager.shared.contactsProcessingOperationQueuer
    
    private var lowerBoundDate: Date {
        get {
            return S.lowerBoundSavedDate
        } set {
            S.lowerBoundSavedDate = newValue
        }
    }

    private var upperBoundDate: Date {
        get {
            return S.upperBoundSavedDate
        } set {
            S.upperBoundSavedDate = newValue
        }
    }
	
	public var singleCleanModel: SingleCleanModel!
	
	private var currentlyScanningProcess: CommonOperationSearchType = .none
	private var smartCleaningDidFinishWithResults: Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		self.contactsManager.setProcess(.search, state: .availible)
        checkForAssetsCount()
        setupUI()
        setupDateInterval()
        updateColors()
        setupNavigation()
        setupTableView()
        setupDelegate()
        setupObserver(for: self.mediaContentType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
		self.resetAllProgressVisual()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		U.application.isIdleTimerDisabled = true
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
			case C.identifiers.segue.showLowerDatePicker:
				self.setupShowDatePickerSelectorController(segue: segue, selectedType: .lowerDateSelectable)
			case C.identifiers.segue.showUpperDatePicker:
				self.setupShowDatePickerSelectorController(segue: segue, selectedType: .upperDateSelectable)
			case C.identifiers.segue.backupContacts:
				self.setupShowContactsBackupController(segue: segue)
			default:
				break
		}
    }
}

/// ??pdate model
extension MediaContentViewController {
	
	private func updateSingleChanged(phasset collection: [PHAsset], content type: PhotoMediaType, completionHandler: @escaping () -> Void) {
		self.singleCleanModel.objects[type]?.phassets = collection
		self.singleCleanModel.objects[type]?.cleanProgress = 100.0
		self.singleCleanModel.objects[type]?.checkForCleanState()
		U.UI {
			if let cell = self.tableView.cellForRow(at: type.singleSearchIndexPath) as? ContentTypeTableViewCell {
				self.configure(cell, at: type.singleSearchIndexPath)
				completionHandler()
			}
		}
	}
	
	private func updateGroupedChanged(phasset group: [PhassetGroup], media type: PhotoMediaType, completionHandler: @escaping () -> Void) {
		self.singleCleanModel.objects[type]?.phassetGroup = group
		self.singleCleanModel.objects[type]?.cleanProgress = 100.0
		self.singleCleanModel.objects[type]?.checkForCleanState()
		U.UI {
			if let cell = self.tableView.cellForRow(at: type.singleSearchIndexPath) as? ContentTypeTableViewCell {
				self.configure(cell, at: type.singleSearchIndexPath)
				completionHandler()
			}
		}
	}
	
	private func updateContactsSingleChanged(contacts: [CNContact], content type: PhotoMediaType, cleanType: ContactasCleaningType, completionHandler: @escaping () -> Void) {
		self.singleCleanModel.objects[type]?.contactCleanType = cleanType
		self.singleCleanModel.objects[type]?.contacts = contacts
		self.singleCleanModel.objects[type]?.cleanProgress = 100.0
		self.singleCleanModel.objects[type]?.checkForCleanState()
		U.UI {
			if let cell = self.tableView.cellForRow(at: type.singleSearchIndexPath) as? ContentTypeTableViewCell {
				self.configure(cell, at: type.singleSearchIndexPath)
				completionHandler()
			}
		}
	}
	
	private func updateGroupedContacts(contacts group: [ContactsGroup], media type: PhotoMediaType, cleanType: ContactasCleaningType, completionHandler: @escaping () ->Void) {
		self.singleCleanModel.objects[type]?.contactCleanType = cleanType
		self.singleCleanModel.objects[type]?.contactsGroup = group
		self.singleCleanModel.objects[type]?.cleanProgress = 100.0
		self.singleCleanModel.objects[type]?.checkForCleanState()
		U.UI {
			if let cell = self.tableView.cellForRow(at: type.singleSearchIndexPath) as? ContentTypeTableViewCell {
				self.configure(cell, at: type.singleSearchIndexPath)
				completionHandler()
			}
		}
	}
}

//      MARK: - show content controller -
extension MediaContentViewController {
    
        /// `0` - simmilar photos
        /// `1` - duplicates
        /// `2` - screenshots
        /// `3` - similar selfies
        /// `4` - live photos
        /// `5` - recently deleted
    
        /// `0` - large video files
        /// `1` - duplicates
        /// `2` - similar videos
        /// `3` - screen records files
        /// `4` - recently deleted files
    
        /// `0` - all contacts
        /// `1` - empty contacts
        /// `2` - duplicated contacts names
        /// `3` - duplicated contacts phones
        /// `4` - duplicated contacts emails
        
    private func showMediaContent(by selectedType: MediaContentType, selected index: Int) {
        
		guard searchingProcessingType == .clearSearchingProcessingQueue else { return}
	
		searchingProcessingType = .singleSearchProcess
		
		U.application.isIdleTimerDisabled = true
        
        switch selectedType {
            case .userPhoto:
                switch index {
                    case 0:
						self.showSimilarPhotos()
                    case 1:
                        self.showDuplicatePhotos()
                    case 2:
                        self.showScreenshots()
                    case 3:
						self.showSimilarSelfies()
                    case 4:
                        self.showLivePhotos()
                    default:
                        return
                }
            case .userVideo:
                switch index {
                    case 0:
                        self.showLargeVideoFiles()
                    case 1:
                        self.showDuplicateVideoFiles()
                    case 2:
                        self.showSimilarVideoFiles()
                    case 3:
                        self.showScreenRecordsVideoFiles()
                    case 5:
                        self.showRecentlyDeletedVideos()
                    default:
                        return
                }
            case .userContacts:
                switch index {
                    case 0:
                        self.showAllContacts()
                    case 1:
                        self.showEmptyGroupsContacts()
                    case 2:
                        self.showContactCleanController(cleanType: .duplicatedContactName)
                    case 3:
                        self.showContactCleanController(cleanType: .duplicatedPhoneNumnber)
                    case 4:
                        self.showContactCleanController(cleanType: .duplicatedEmail)
                    default:
                        return
                }
            case .none:
                return
        }
    }
	
	private func showPrescanMediaContent(by selectedType: MediaContentType, selected index: Int) {
		
		let photoMediaType: PhotoMediaType = selectedType.sections[index]
		
		switch photoMediaType.collectionType {
			case .single:
				
				switch mediaContentType {
					case .userContacts:
						if let object = self.singleCleanModel.objects[photoMediaType] {
							
							if object.contactCleanType == .emptyContacts {
								let contactactGroup = object.contactsGroup
								
								if !contactactGroup.isEmpty {
									self.showContactViewController(contacts: [], contactGroup: contactactGroup, contentType: .emptyContacts)
								} else {
									ErrorHandler.shared.showEmptySearchResultsFor(photoMediaType.emptyContentError)
								}
							} else {
								let collection = object.contacts
								if !collection.isEmpty {
									self.showContactViewController(contacts: collection, contentType: photoMediaType)
								} else {
									ErrorHandler.shared.showEmptySearchResultsFor(photoMediaType.emptyContentError)
								}
							}
							
						}
					case .userPhoto, .userVideo:
						if let collection = self.singleCleanModel.objects[photoMediaType]?.phassets, !collection.isEmpty {
							self.showAssetViewController(collection: collection, photoContent: photoMediaType, media: selectedType)
						} else {
							ErrorHandler.shared.showEmptySearchResultsFor(photoMediaType.emptyContentError)
						}
					default:
						return
				}
			case .grouped:
				
				switch mediaContentType {
					case .userContacts:
						if let objects = self.singleCleanModel.objects[photoMediaType] {
							let collectionGroup = objects.contactsGroup
							
							if !collectionGroup.isEmpty {
								self.showGroupedContactsViewController(contacts: collectionGroup, group: objects.contactCleanType, content: photoMediaType)
							} else {
								ErrorHandler.shared.showEmptySearchResultsFor(photoMediaType.emptyContentError)
							}
						} else {
							ErrorHandler.shared.showEmptySearchResultsFor(photoMediaType.emptyContentError)
						}
					case .userPhoto, .userVideo:
						if let phassetGroups = self.singleCleanModel.objects[photoMediaType]?.phassetGroup, !phassetGroups.isEmpty {
							self.showGropedContoller(grouped: phassetGroups, photoContent: photoMediaType, media: selectedType)
						} else {
							ErrorHandler.shared.showEmptySearchResultsFor(photoMediaType.emptyContentError)
						}
					default:
						return
				}
			default:
				return
		}
	}
}

extension MediaContentViewController {
	
	public func handleShortcutProcessing(of processingType: RemoteCleanType) {
		switch processingType {
			case .similarPhotoClean:
				let mediaType: PhotoMediaType = .similarPhotos
				self.showMediaContent(by: .userPhoto, selected: mediaType.singleSearchIndexPath.row)
			case .duplicatedPhotoClean:
				let mediaType: PhotoMediaType = .duplicatedPhotos
				self.showMediaContent(by: .userPhoto, selected: mediaType.singleSearchIndexPath.row)
			case .similiarVideoClean:
				let mediaType: PhotoMediaType = .similarVideos
				self.showMediaContent(by: .userVideo, selected: mediaType.singleSearchIndexPath.row)
			case .duplicatedVideoClean:
				let mediaType: PhotoMediaType = .duplicatedVideos
				self.showMediaContent(by: .userVideo, selected: mediaType.singleSearchIndexPath.row)
			case .duplicatedContactsClean:
				let mediaType: PhotoMediaType = .duplicatedContacts
				self.showMediaContent(by: .userContacts, selected: mediaType.singleSearchIndexPath.row)
			case .photoScan:
				self.startSmartCleanProcessing()
			case .videoScan:
				self.startSmartCleanProcessing()
			case .contactsScan:
				self.searchingProcessingType = .smartGroupSearchProcess
				self.updateContacts {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.smartCleaningDidFinishWithResults = true
				}
			default:
				return
		}
	}
}

//      MARK: - photo content -
extension MediaContentViewController {
    
    /**
     - parameter
     - parameter
    */

    private func showSimilarPhotos() {
	
		self.currentlyScanningProcess = .similarPhotoAssetsOperaton
		
		let getSimilarPhotosAssetsOperation = photoManager.getSimilarPhotosAssetsOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { similarGroup, isCancelled  in
			self.updateGroupedChanged(phasset: similarGroup, media: .similarPhotos) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if !similarGroup.isEmpty {
						self.showGropedContoller(grouped: similarGroup, photoContent: .similarPhotos, media: .userPhoto)
					} else {
						!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(.similarPhotoIsEmpty) : ()
					}
				}
			}
		}
		getSimilarPhotosAssetsOperation.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(getSimilarPhotosAssetsOperation)
    }
	
	private func showDuplicatePhotos() {
	
		self.currentlyScanningProcess = .duplicatedPhotoAssetsOperation
		
		let duplicatedPhotoAssetOperation = photoManager.getDuplicatedPhotosAsset(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { duplicateGroup, isCancelled in
			self.updateGroupedChanged(phasset: duplicateGroup, media: .duplicatedPhotos) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if !duplicateGroup.isEmpty {
						self.showGropedContoller(grouped: duplicateGroup, photoContent: .duplicatedPhotos, media: .userPhoto)
					} else {
						!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(.duplicatedPhotoIsEmpty) : ()
					}
				}
			}
		}
		duplicatedPhotoAssetOperation.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(duplicatedPhotoAssetOperation)
	}
	
	private func showScreenshots() {
		
		self.currentlyScanningProcess = .screenShotsAssetsOperation
		
		let getScreenShotsAssetsOperation = photoManager.getScreenShotsOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { screenshots, isCancelled in
			self.updateSingleChanged(phasset: screenshots, content: .singleScreenShots) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if !screenshots.isEmpty {
						self.showAssetViewController(collection: screenshots, photoContent: .singleScreenShots, media: .userPhoto)
					} else {
						!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(.screenShotsIsEmpty) : ()
					}
				}
			}
		}
		getScreenShotsAssetsOperation.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(getScreenShotsAssetsOperation)
	}
	
	private func showSimilarSelfies() {
	
		self.currentlyScanningProcess = .similarSelfiesAssetsOperation
		
		let getSimilarSelfiesPhotoPhassetsOperation = photoManager.getSimilarSelfiePhotosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { similartSelfiesGroup, isCancelled in
			
			self.updateGroupedChanged(phasset: similartSelfiesGroup, media: .similarSelfies) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if !similartSelfiesGroup.isEmpty {
						self.showGropedContoller(grouped: similartSelfiesGroup, photoContent: .similarSelfies, media: .userPhoto)
					} else {
						!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(.similarSelfiesIsEmpty) : ()
					}
				}
			}
		}
		getSimilarSelfiesPhotoPhassetsOperation.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(getSimilarSelfiesPhotoPhassetsOperation)
	}
	
	private func showLivePhotos() {
		
		self.currentlyScanningProcess = .livePhotoAssetsOperation
		let getLivePhotoAssetsOperation = photoManager.getLivePhotosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { livePhoto, isCancelled in
			
			self.updateSingleChanged(phasset: livePhoto, content: .singleLivePhotos) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if !livePhoto.isEmpty {
						self.showAssetViewController(collection: livePhoto, photoContent: .singleLivePhotos, media: .userPhoto)
					} else {
						!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(.livePhotoIsEmpty) : ()
					}
				}
			}
		}
		getLivePhotoAssetsOperation.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(getLivePhotoAssetsOperation)
	}
    
	private func showRecentlyDeletedPhotos() {
			
		self.currentlyScanningProcess = .recentlyDeletedOperation
		let getSortedRecentlyDeletedAssetsOperation = PHAssetFetchManager.shared.recentlyDeletdSortedAlbumsFetchOperation { photosAssets, videoAssets in
			self.singleCleanModel.objects[.singleRecentlyDeletedPhotos]!.phassets = photosAssets
			
			self.updateSingleChanged(phasset: photosAssets, content: .singleRecentlyDeletedPhotos) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if photosAssets.count != 0 {
						self.showAssetViewController(collection: photosAssets, photoContent: .singleRecentlyDeletedPhotos, media: .userPhoto)
					}
				}
			}
		}
		getSortedRecentlyDeletedAssetsOperation.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(getSortedRecentlyDeletedAssetsOperation)
	}
}

//      MARK: - video content -
extension MediaContentViewController {
    
	private func showLargeVideoFiles() {
		
		self.currentlyScanningProcess = .largeVideoContentOperation
		let getLargevideoContentOperation = photoManager.getLargevideoContentOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { largeVodeoAsset, isCancelled in
			self.updateSingleChanged(phasset: largeVodeoAsset, content: .singleLargeVideos) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if largeVodeoAsset.count != 0 {
						self.showAssetViewController(collection: largeVodeoAsset, photoContent: .singleLargeVideos, media: .userVideo)
					} else {
						!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(.largeVideoIsEmpty) : ()
					}
				}
			}
		}
		getLargevideoContentOperation.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(getLargevideoContentOperation)
	}
    
	private func showDuplicateVideoFiles() {
		
		self.currentlyScanningProcess = .duplicatedVideoAssetOperation
		let getDuplicatedVideoAssetOperatioon = photoManager.getDuplicatedVideoAssetOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { duplicatedVideoAsset, isCancelled in
			
			self.updateGroupedChanged(phasset: duplicatedVideoAsset, media: .duplicatedVideos) {
			U.delay(0.1) {
				self.searchingProcessingType = .clearSearchingProcessingQueue
				self.currentlyScanningProcess = .none
				if duplicatedVideoAsset.count != 0 {
					self.showGropedContoller(grouped: duplicatedVideoAsset, photoContent: .duplicatedVideos, media: .userVideo)
				} else {
					!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(.duplicatedVideoIsEmpty) : ()
				}
			}
			}
		}
		getDuplicatedVideoAssetOperatioon.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(getDuplicatedVideoAssetOperatioon)
	}
    
	private func showSimilarVideoFiles() {
		
		self.currentlyScanningProcess = .similarVideoAssetsOperation
		let getSimilarVideoAssetsOperation = photoManager.getSimilarVideoAssetsOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { similiarVideoAsset, isCancelled in
			
			self.updateGroupedChanged(phasset: similiarVideoAsset, media: .similarVideos) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if similiarVideoAsset.count != 0 {
						self.showGropedContoller(grouped: similiarVideoAsset, photoContent: .similarVideos, media: .userVideo)
					} else {
						!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(.similarVideoIsEmpty) : ()
					}
				}
			}
		}
		getSimilarVideoAssetsOperation.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(getSimilarVideoAssetsOperation)
	}
    
	private func showScreenRecordsVideoFiles() {
		
		self.currentlyScanningProcess = .screenRecordingsVideoOperation
		let getScreenRecordsVideosOperation = photoManager.getScreenRecordsVideosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { screenRecordsAssets, isCancelled in
			
			self.updateSingleChanged(phasset: screenRecordsAssets, content: .singleScreenRecordings) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if screenRecordsAssets.count != 0 {
						self.showAssetViewController(collection: screenRecordsAssets, photoContent: .singleScreenRecordings, media: .userVideo)
					} else {
						!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(.screenRecordingIsEmpty) : ()
					}
				}
			}
		}
		getScreenRecordsVideosOperation.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(getScreenRecordsVideosOperation)
	}
	
	private func showRecentlyDeletedVideos() {
		
		self.currentlyScanningProcess = .recentlyDeletedOperation
		let getSortedRecentlyDeletedAssetsOperation = PHAssetFetchManager.shared.recentlyDeletdSortedAlbumsFetchOperation { photosAssets, videoAssets in
			
			self.updateSingleChanged(phasset: videoAssets, content: .singleRecentlyDeletedVideos) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if videoAssets.count != 0 {
						self.showAssetViewController(collection: videoAssets, photoContent: .singleRecentlyDeletedVideos, media: .userVideo)
					}
				}
			}
		}
		getSortedRecentlyDeletedAssetsOperation.name = self.currentlyScanningProcess.rawValue
		phassetProcessingOperationQueuer.addOperation(getSortedRecentlyDeletedAssetsOperation)
	}
    
    private func showSimmilarVideoFilesByTimeStamp() {
		
		let getSimilarVideosByTimeStamp = photoManager.getSimilarVideosByTimeStampOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .singleSearch) { similarVideos in
			self.searchingProcessingType = .clearSearchingProcessingQueue
			if similarVideos.count != 0 {
				self.showGropedContoller(grouped: similarVideos, photoContent: .similarVideos, media: .userVideo)
			} else {
				ErrorHandler.shared.showEmptySearchResultsFor(.similarVideoIsEmpty)
			}
		}
		phassetProcessingOperationQueuer.addOperation(getSimilarVideosByTimeStamp)
    }
	
	private func showVideoContentForCompressingOperation() {
		
		SubscriptionManager.instance.purchasePremiumHandler { status in
			switch status {
				case .purchasedPremium, .lifetime:
					self.photoManager.getVideoCollection(with: .creationDate) { phassets in
						if !phassets.isEmpty {
							self.showCompressVideoPickerController(with: phassets)
						} else {
							ErrorHandler.shared.showEmptySearchResultsFor(.videoLibrararyIsEmpty)
						}
					}
				case .nonPurchased:
					UIPresenter.showViewController(of: .subscription)
			}
		}
	}
	
	private func openContactExportBackupController() {
		SubscriptionManager.instance.purchasePremiumHandler { status in
			switch status {
				case .lifetime, .purchasedPremium:
					self.performSegue(withIdentifier: C.identifiers.segue.backupContacts, sender: self)
				case .nonPurchased:
					UIPresenter.showViewController(of: .subscription)
			}
		}
	}
	
	private func openLocationClenController() {
		SubscriptionManager.instance.purchasePremiumHandler { status in
			switch status {
				case .lifetime, .purchasedPremium:
					self.progrssAlertController.showSimpleProgressAlerControllerBar(of: .parsingLocations, from: self)
					U.delay(0.1) {
						self.photoManager.getPHAssetCollectionWithLocation { phassets, annotations in
							self.progrssAlertController.closeProgressAnimatedController()
							if !phassets.isEmpty {
								Utils.delay(1) {
									self.showLocationViewController(with: phassets, annotationCollection: annotations)									
								}
							} else {
								ErrorHandler.shared.showEmptySearchResultsFor(.photoWithLocationIsEmpty)
							}
						}
					}
				case .nonPurchased:
					UIPresenter.showViewController(of: .subscription)
			}
		}
	}
}

	//      MARK: - contacts content -
extension MediaContentViewController {
	
	private func showAllContacts() {
		
		P.showIndicator()
		self.contactsManager.getAllContacts { contacts in
			self.updateContactsSingleChanged(contacts: contacts, content: .allContacts, cleanType: .none) {
				U.delay(0.4) {
					P.hideIndicator()
					self.searchingProcessingType = .clearSearchingProcessingQueue
					if !contacts.isEmpty {
						self.showContactViewController(contacts: contacts, contentType: .allContacts)
					} else {
						ErrorHandler.shared.showEmptySearchResultsFor(.contactsIsEmpty)
					}
				}
			}
		}
	}
	
	private func showEmptyGroupsContacts() {
		
		self.currentlyScanningProcess = .emptyContactOperation
		
		self.contactsManager.sendNotification(processing: .singleSearch, deepCleanType: .emptyContacts, singleCleanType: .emptyContacts, status: .prepare, totalItems: 0, currentIndex: 0)
		
		self.contactsManager.getSingleDuplicatedCleaningContacts(of: .emptyContacts) { contactsGroup, isCancelled in
			let totalContacts = contactsGroup.map({$0.contacts}).count
			let group = contactsGroup.filter({!$0.contacts.isEmpty})
			self.updateGroupedContacts(contacts: group, media: .emptyContacts, cleanType: .emptyContacts) {
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if totalContacts != 0 {
						self.showContactViewController(contactGroup: group, contentType: .emptyContacts)
					} else {
						!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(.emptyContactsIsEmpty) : ()
					}
				}
			}
		}
	}
	
	private func showContactCleanController(cleanType: ContactasCleaningType) {
		
		switch cleanType {
			case .duplicatedPhoneNumnber:
				self.currentlyScanningProcess = .duplicatedPhoneNumbersOperation
				self.contactsManager.sendNotification(processing: .singleSearch, singleCleanType: .duplicatesNumbers, status: .prepare, totalItems: 0, currentIndex: 0)
			case .duplicatedContactName:
				self.currentlyScanningProcess = .duplicatedNameOperation
				self.contactsManager.sendNotification(processing: .singleSearch, singleCleanType: .duplicatesNames, status: .prepare, totalItems: 0, currentIndex: 0)
			case .duplicatedEmail:
				self.currentlyScanningProcess = .duplicatedEmailsOperation
				self.contactsManager.sendNotification(processing: .singleSearch, singleCleanType: .duplicatesEmails, status: .prepare, totalItems: 0, currentIndex: 0)
			default:
				self.currentlyScanningProcess = .none
		}
		
		self.contactsManager.getSingleDuplicatedCleaningContacts(of: cleanType) { contactsGroup, isCancelled in
			let mediaType = cleanType.photoMediaType
			
			self.updateGroupedContacts(contacts: contactsGroup, media: mediaType, cleanType: cleanType) {
				
				U.delay(0.5) {
					self.searchingProcessingType = .clearSearchingProcessingQueue
					self.currentlyScanningProcess = .none
					if contactsGroup.count != 0 {
						let group = contactsGroup.sorted(by: {$0.name < $1.name})
						self.showGroupedContactsViewController(contacts: group, group: cleanType, content:  cleanType.photoMediaType)
					} else {
						!isCancelled ? ErrorHandler.shared.showEmptySearchResultsFor(cleanType.emptyResultsError) : ()
					}
				}
			}
		}
	}
		
	@objc func handleChangeContactsContainers(_ notification: Notification) {
			/// do not use this observer it call every time when delete or change contacts
			/// when tit calls content calls every time and create new and new threat
			/// danger memerry leaks
//		self.updateContent(type: .userContacts)
	}
	
	@objc func removeStoreObserver() {
		U.notificationCenter.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
	}

	@objc func addStoreObserver() {
		U.notificationCenter.addObserver(self, selector: #selector(handleChangeContactsContainers), name: .CNContactStoreDidChange, object: nil)
	}
	
	@objc func handleStopAnyAnalizeProcessing() {
		
		switch self.searchingProcessingType {
			case .smartGroupSearchProcess:
					self.setCancelSmartSearchOperationQueue {}
			case .singleSearchProcess:
					self.setCancelActiveOperation {}
			case .clearSearchingProcessingQueue:
				return
		}
	}
}

extension MediaContentViewController {
	
	private func showGropedContoller(grouped collection: [PhassetGroup], photoContent type: PhotoMediaType, media content: MediaContentType) {
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
		let viewController  = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.groupedList) as! GroupedAssetListViewController
		viewController.title = type.mediaTypeName
		viewController.assetGroups = collection
		viewController.mediaType = type
		viewController.contentType = content
		viewController.changedPhassetGroupCompletionHandler = { phassetGroup  in
			self.updateGroupedChanged(phasset: phassetGroup, media: type) {}
		}
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	private func showAssetViewController(collection: [PHAsset], photoContent type: PhotoMediaType, media content: MediaContentType) {
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.assetsList) as! SimpleAssetsListViewController
		viewController.title = type.mediaTypeName
		viewController.assetCollection = collection
		viewController.mediaType = type
		viewController.contentType = content
		viewController.changedPhassetCompletionHandler = { changedPhasset in
			self.updateSingleChanged(phasset: changedPhasset, content: type) {}
		}
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	private func showContactViewController(contacts: [CNContact] = [], contactGroup: [ContactsGroup] = [], contentType: PhotoMediaType) {
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.contacts, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.contacts) as! ContactsViewController
		viewController.contacts = contacts
		viewController.contactGroup = contactGroup
		viewController.mediaType = .userContacts
		viewController.contentType = contentType
		
		viewController.updateContentAfterProcessing = {changedContacts, changedContactsGroups, currentChangedMediaType, storeDidChange in
			
			guard storeDidChange else { return }
			
			self.smartCleaningDidFinishWithResults = false
			switch currentChangedMediaType {
					
				case .allContacts:
					self.updateContactsSingleChanged(contacts: changedContacts, content: currentChangedMediaType, cleanType: .none) {}
					self.updateContacts {}
				default:
					self.updateGroupedContacts(contacts: changedContactsGroups, media: currentChangedMediaType, cleanType: .none) {}
					self.updateContacts {}
			}
		}
	
		self.navigationController?.pushViewController(viewController, animated: true)
	}
		
	private func showGroupedContactsViewController(contacts group: [ContactsGroup], group type: ContactasCleaningType, content: PhotoMediaType) {
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.contactsGroup, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.contactsGroup) as! ContactsGroupViewController
		viewController.contactGroup = group
		viewController.navigationTitle = content.mediaTypeName
		viewController.contentType = content
		viewController.mediaType = .userContacts
		viewController.cleaningType = type
		viewController.updatableContactsAfterProcessing = { changedContactsGroup, currentChangedMediaType, storeDidChange in
	
			guard storeDidChange else { return}
			
			self.smartCleaningDidFinishWithResults = false
			
			self.updateGroupedContacts(contacts: changedContactsGroup, media: currentChangedMediaType, cleanType: type) {}
			
			self.updateContacts {}
		}

		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	private func showCompressVideoPickerController(with videoPHAsset: [PHAsset]) {
		
		let type: PhotoMediaType = .compress
		let content: MediaContentType = .userVideo
		
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.videoCompressCollection) as! VideoCollectionCompressingViewController
		viewController.title = type.mediaTypeName
		viewController.assetCollection = videoPHAsset
		viewController.mediaType = type
		viewController.contentType = content
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	private func showLocationViewController(with photoPHAssets: [PHAsset], annotationCollection: [MKAnnotation]) {
		
		let type: PhotoMediaType = .locationPhoto
		let content: MediaContentType = .userPhoto
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.location, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.location) as! LocationViewController
		viewController.title = type.mediaTypeName
		viewController.assetCollection = photoPHAssets
		viewController.preloadedStartedAnnotations = annotationCollection
		viewController.mediaType = type
		viewController.contentType = content
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}

extension MediaContentViewController {
	
	private func checkForAssetsCount() {
		self.updateContent(type: self.mediaContentType)
	}
	
	private func updateContent(type: MediaContentType) {
		switch type {
			case .userPhoto:
				self.updatePhoto()
			case .userVideo:
				self.updateVideo()
			case .userContacts:
				self.updateContacts {}
			case .none:
				debugPrint("")
		}
	}
	
	private func updatePhoto() {
		let getScreenShotsAssetsOperation = photoManager.getScreenShotsOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .background) { screenshots, _ in
			self.updateSingleChanged(phasset: screenshots, content: .singleScreenShots) {}
		}
		phassetProcessingOperationQueuer.addOperation(getScreenShotsAssetsOperation)
		
		let getLivePhotoAssetsOperation = photoManager.getLivePhotosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .background) { livePhoto, _ in
			
			self.updateSingleChanged(phasset: livePhoto, content: .singleLivePhotos) {}
		}
		phassetProcessingOperationQueuer.addOperation(getLivePhotoAssetsOperation)
	}
	
	
	private func updateVideo() {
		let screenRecordsVideosOperation = photoManager.getScreenRecordsVideosOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .background) { screenRecordsAssets, _ in
			self.updateSingleChanged(phasset: screenRecordsAssets, content: .singleScreenRecordings) {}
		}
		phassetProcessingOperationQueuer.addOperation(screenRecordsVideosOperation)
		
		let largeVideosOperation = photoManager.getLargevideoContentOperation(from: lowerBoundDate, to: upperBoundDate, cleanProcessingType: .background) { videoAssets, _ in
			self.updateSingleChanged(phasset: videoAssets, content: .singleLargeVideos) {}
		}
		phassetProcessingOperationQueuer.addOperation(largeVideosOperation)
	}
	
	private func updateContacts(completionHandler: @escaping () -> Void) {
		self.contactsManager.getUpdatingContactsAfterContainerDidChange(cleanProcessingType: .background) { _ in
			completionHandler()
		} allContacts: { contacts in
			self.updateContactsSingleChanged(contacts: contacts, content: .allContacts, cleanType: .none) {}
		} emptyContacts: { emptyContactsGroup in
			let group = emptyContactsGroup.filter({!$0.contacts.isEmpty})
			self.updateGroupedContacts(contacts: group, media: .emptyContacts, cleanType: .emptyContacts) {}
		} duplicatedNames: { duplicatedContacts in
			self.updateGroupedContacts(contacts: duplicatedContacts, media: .duplicatedContacts, cleanType: .duplicatedContactName) {}
		} duplicatedPhoneNumbers: { duplicatedPhoneNumbers in
			self.updateGroupedContacts(contacts: duplicatedPhoneNumbers, media: .duplicatedPhoneNumbers, cleanType: .duplicatedPhoneNumnber) {}
		} duplicatedEmailGrops: { duplicatedEmailGroups in
			self.updateGroupedContacts(contacts: duplicatedEmailGroups, media: .duplicatedEmails, cleanType: .duplicatedEmail) {}
		}
	}
}

//      MARK: - handle progressUpdating cell content

extension MediaContentViewController {
    
    @objc func handleContentProgressUpdateNotification(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
		
        switch notification.name {
				/// `photo phasset
			case .singleSearchSimilarPhotoScan:
				recieveNotification(by: .similarPhoto, userInfo: userInfo)
			case .singleSearchDuplicatedPhotoScan:
				recieveNotification(by: .duplicatedPhoto, userInfo: userInfo)
			case .singleSearchScreenShotsPhotoScan:
				recieveNotification(by: .screenShots, userInfo: userInfo)
			case .singleSearchSimilarSelfiePhotoScan:
				recieveNotification(by: .similarSelfiesPhoto, userInfo: userInfo)
			case .singleSearchLivePhotoScan:
				recieveNotification(by: .livePhoto, userInfo: userInfo)
			case .singleSearchRecentlyDeletedPhotoScan:
				recieveNotification(by: .recentlyDeletedPhoto, userInfo: userInfo)
				/// `videp phasset`
			case .singleSearchLargeVideoScan:
				recieveNotification(by: .largeVideo, userInfo: userInfo)
			case .singleSearchDuplicatedVideoScan:
				recieveNotification(by: .duplicatedVideo, userInfo: userInfo)
			case .singleSearchSimilarVideoScan:
				recieveNotification(by: .similarVideo, userInfo: userInfo)
			case .singleSearchScreenRecordingVideoScan:
				recieveNotification(by: .screenRecordings, userInfo: userInfo)
			case .singleSearchRecentlyDeletedVideoScan:
				recieveNotification(by: .recentlyDeletedVideo, userInfo: userInfo)
                    /// `contacts`
            case .singleSearchAllContactsScan:
                recieveNotification(by: .allContacts, userInfo: userInfo)
            case .singleSearchEmptyContactsScan:
                recieveNotification(by: .emptyContacts, userInfo: userInfo)
            case .singleSearchDuplicatesNamesContactsScan:
                recieveNotification(by: .duplicatesNames, userInfo: userInfo)
            case .singleSearchDuplicatesNumbersContactsScan:
                recieveNotification(by: .duplicatesNumbers, userInfo: userInfo)
            case .singleSearchDupliatesEmailsContactsScan:
                recieveNotification(by: .duplicatesEmails, userInfo: userInfo)
            default:
                return
        }
    }
    
    private func recieveNotification(by type: SingleContentSearchNotificationType, userInfo: [AnyHashable: Any]) {
		
		guard let status = userInfo[type.dictionaryProcessingState] as? ProcessingProgressOperationState,
			let totalProcessingCount = userInfo[type.dictionaryCountName] as? Int,
              let currentIndex = userInfo[type.dictioanartyIndexName] as? Int else { return }
                
        calculateProgressPercentage(total: totalProcessingCount, current: currentIndex) { progress in
            U.UI {
				self.progressUpdate(type, status: status, currentProgress: progress)
            }
        }
    }
    
    private func calculateProgressPercentage(total: Int, current: Int, completionHandler: @escaping (CGFloat) -> Void) {
		U.GLB(qos: .background) {
			 let totalPercent = CGFloat(Double(current) / Double(total)) * 100
			 U.UI {
				 completionHandler(totalPercent)
			 }
		}
    }
    
	private func progressUpdate(_ notificationType: SingleContentSearchNotificationType, status: ProcessingProgressOperationState, currentProgress: CGFloat) {
		
        let indexPath = notificationType.mediaTypeRawValue.singleSearchIndexPath
		let mediaType: PhotoMediaType = notificationType.mediaTypeRawValue
		
		self.singleCleanModel.objects[mediaType]?.cleanState = status
		self.singleCleanModel.objects[mediaType]?.cleanProgress = currentProgress
      
        guard !indexPath.isEmpty else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? ContentTypeTableViewCell else { return }
        
		self.configure(cell, at: indexPath)
    }
    	
	private func setCancelActiveOperation(completionHandler: @escaping () -> Void) {
		
		self.searchingProcessingType = .clearSearchingProcessingQueue
		
		if self.mediaContentType == .userContacts {
			if let operation = self.contactsProcessingOperationQueuer.operations.first(where: {$0.name == self.currentlyScanningProcess.rawValue}) {
				if let name = operation.name {
					self.contactsProcessingOperationQueuer.cancelOperation(with: name)
					U.delay(1) {
						self.updateProcessingCancel(for: name)
						U.delay(0.33) {
							completionHandler()
						}
					}
				}
			}
		} else {
			let managerOperationsOperations = self.photoManager.phassetProcessingOperationQueuer.operations
			for operation in managerOperationsOperations {
				if let name = operation.name {
					self.photoManager.phassetProcessingOperationQueuer.cancelOperation(with: name)
				}
			}
			for operation in self.phassetProcessingOperationQueuer.operations {
				if let name = operation.name {
					self.phassetProcessingOperationQueuer.cancelOperation(with: name)
				}
			}

			U.delay(1) {
				self.updateProcessingCancel(for: self.currentlyScanningProcess.rawValue)
				U.delay(0.33) {
					completionHandler()
				}
			}
		}
	}
	
	private func setCancelSmartSearchOperationQueue(completionHandler: @escaping () -> Void) {
		
		self.searchingProcessingType = .clearSearchingProcessingQueue
		
		let operations = self.smartCleanManager.smarCleanOperationQueue.operations
		var cleanedOperation = 0
		
		if !operations.isEmpty {
			for operation in operations {
				if let name = operation.name {
					self.smartCleanManager.smarCleanOperationQueue.cancelOperation(with: name)
					cleanedOperation += 1
					U.delay(0.33) {
						self.updateProcessingCancel(for: name)
						if cleanedOperation == operations.count {
							completionHandler()
						}
					}
				}
			}
		}
	}
	
	private func updateProcessingCancel(for operationName: String) {
		
		if let operation = CommonOperationSearchType.getOperationType(from: operationName) {
			
			let type = operation.mediaType
			
			guard let object = self.singleCleanModel.objects[type] else { return }
			
			object.resetSingleMode()
			
			U.UI {
				if let cell = self.tableView.cellForRow(at: type.singleSearchIndexPath) as? ContentTypeTableViewCell {
					self.configure(cell, at: type.singleSearchIndexPath)
				}
			}
		}
	}
	
	private func desintagrateSearchingResults() {
		
		self.resetRecievingData()
		self.resetAllProgressVisual()
		self.smartCleaningDidFinishWithResults = false
		UIView.performWithoutAnimation {
			self.tableView.reloadData()
		}
	}
	
	private func resetRecievingData() {
		for ( _ , value) in singleCleanModel.objects {
			value.resetSingleMode()
		}
	}
	
	private func resetAllProgressVisual() {
		let numberOFOperationElemtnth = self.tableView.numberOfRows(inSection: 0)
		let allSectionIndexPath = (0..<numberOFOperationElemtnth).map {IndexPath(row: $0, section: 0)}
		
		allSectionIndexPath.forEach { indexPath in
			if let cell = tableView.cellForRow(at: indexPath) as? ContentTypeTableViewCell {
				cell.resetProgress()
			}
		}
	}
}

extension MediaContentViewController {
	
	private func startSmartCleanProcessing() {
		
		self.searchingProcessingType = .smartGroupSearchProcess
		
		smartCleanManager.startSmartCleanFetch(self.mediaContentType.sections,
											   lowerBoundDate: self.lowerBoundDate,
											   upperBoundDate: self.upperBoundDate) { _ in
			
		} similarPhoto: { phassetGroups in
			self.updateGroupedChanged(phasset: phassetGroups, media: .similarPhotos) {}
		} duplicatedPhoto: { phassetGroups in
			self.updateGroupedChanged(phasset: phassetGroups, media: .duplicatedPhotos) {}
		} screenShots: { phassets in
			self.updateSingleChanged(phasset: phassets, content: .singleScreenShots) {}
		} similarSelfie: { phassetGroups in
			self.updateGroupedChanged(phasset: phassetGroups, media: .similarSelfies) {}
		} livePhotos: { phassets in
			self.updateSingleChanged(phasset: phassets, content: .singleLivePhotos) {}
		} largeVideo: { phassets in
			self.updateSingleChanged(phasset: phassets, content: .singleLargeVideos) {}
		} duplicatedVideo: { phassetGroups in
			self.updateGroupedChanged(phasset: phassetGroups, media: .duplicatedVideos) {}
		} similarVideo: { phassetGroups in
			self.updateGroupedChanged(phasset: phassetGroups, media: .similarVideos) {}
		} screenRecordings: { phassets in
			self.updateSingleChanged(phasset: phassets, content: .singleScreenRecordings) {}
		} completionHandler: { isCanceled in
			self.searchingProcessingType = .clearSearchingProcessingQueue
			self.smartCleaningDidFinishWithResults = !isCanceled
		}
	}
	
	private func startSmartContactsCleanProcessing() {
		
		self.searchingProcessingType = .smartGroupSearchProcess
		
		smartCleanManager.startSmartContactCleanFetch {
			debugPrint("handler?")
		} fetchAllContacts: { contacts in
			self.updateContactsSingleChanged(contacts: contacts, content: .allContacts, cleanType: .none) {}
		} emptyContacts: { emptyContacts in
			let group = emptyContacts.filter({!$0.contacts.isEmpty})
			self.updateGroupedContacts(contacts: group, media: .emptyContacts, cleanType: .emptyContacts) {}
		} duplicatedNames: { duplicatedNames in
			self.updateGroupedContacts(contacts: duplicatedNames, media: .duplicatedContacts, cleanType: .duplicatedContactName) {}
		} duplicatedPhoneNumbers: { duplicatedPhoneNumbers in
			self.updateGroupedContacts(contacts: duplicatedPhoneNumbers, media: .duplicatedPhoneNumbers, cleanType: .duplicatedPhoneNumnber) {}
		} duplicatedEmail: { duplicatedEmails in
			self.updateGroupedContacts(contacts: duplicatedEmails, media: .duplicatedEmails, cleanType: .duplicatedEmail) {}
		} completionHandler: { isCanceled in
			self.searchingProcessingType = .clearSearchingProcessingQueue
			self.smartCleaningDidFinishWithResults = !isCanceled
		}
	}
	
	private func handleChangeSmartCleanProcessing() {
		Utils.UI { [self] in
			switch self.searchingProcessingType {
				case .clearSearchingProcessingQueue:
					self.navigationBar.changeHotRightTitle(newTitle: LocalizationService.Buttons.getButtonTitle(of: .analize))
					self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
				case .singleSearchProcess:
					self.navigationBar.changeHotRightTitle(newTitle: LocalizationService.Buttons.getButtonTitle(of: .analize))
					self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
				case .smartGroupSearchProcess:
					self.navigationBar.changeHotRightButton(with: I.systemItems.navigationBarItems.stopMagic)
					self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
			}
		}
	}
}

extension MediaContentViewController: DateSelectebleViewDelegate {
    
    func didSelectStartingDate() {
		
		guard self.searchingProcessingType == .clearSearchingProcessingQueue else { return }
		
		performSegue(withIdentifier: C.identifiers.segue.showLowerDatePicker, sender: self)
    }
    
    func didSelectEndingDate() {
		
		guard self.searchingProcessingType == .clearSearchingProcessingQueue else { return }
		
		performSegue(withIdentifier: C.identifiers.segue.showUpperDatePicker, sender: self)
    }
}

extension MediaContentViewController: NavigationBarDelegate {
    
    func didTapLeftBarButton(_ sender: UIButton) {
		
		switch self.searchingProcessingType {
			case .smartGroupSearchProcess:
				SearchOperationStateHandler.alertHandler(for: .resetSmartSingleCleanSearch) {
					self.setCancelSmartSearchOperationQueue {
						self.navigationController?.popViewController(animated: true)
					}
				}
			case .singleSearchProcess:
				SearchOperationStateHandler.alertHandler(for: .resetSingleCleanSearch) {
					self.setCancelActiveOperation {
						self.navigationController?.popViewController(animated: true)
					}
				}
			case .clearSearchingProcessingQueue:
				self.navigationController?.popViewController(animated: true)
		}
    }
    
	func didTapRightBarButton(_ sender: UIButton) {
		
		switch searchingProcessingType {
			case .clearSearchingProcessingQueue:
				self.prepareStartSmartCleaningProcessing()
			case .smartGroupSearchProcess:
				SearchOperationStateHandler.alertHandler(for: .resetSmartSingleCleanSearch) {
					self.setCancelSmartSearchOperationQueue() {}
				}
			case .singleSearchProcess:
				SearchOperationStateHandler.alertHandler(for: .resetSingleCleanSearch) {
					self.setCancelActiveOperation() {
						self.prepareStartSmartCleaningProcessing()
					}
				}
		}
	}
	
	private func prepareStartSmartCleaningProcessing() {
		
		if self.mediaContentType == .userContacts {
			self.startSmartContactsCleanProcessing()
		} else {
			startSmartCleanProcessing()
		}
	}
}


extension MediaContentViewController: ContentTypeCellDelegate {
	
	func setCancelProcessOperaion(for cell: ContentTypeTableViewCell) {
		self.setCancelActiveOperation {
			debugPrint("cancel")
		}
	}
}

extension MediaContentViewController: UITableViewDelegate, UITableViewDataSource {

	private func setupTableView() {
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.separatorStyle = .none
		self.tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
		self.tableView.register(UINib(nibName: C.identifiers.xibs.contentBannerCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentBannerCell)
		
		if mediaContentType == .userContacts {
			self.tableView.contentInset.top = AppDimensions.ContenTypeCells.mediaContentCutTypeInset
		} else {
			self.tableView.contentInset.top = AppDimensions.ContenTypeCells.mediaContentTypeTopInset
		}
		self.tableView.contentInset.bottom = AppDimensions.ContenTypeCells.mediaContentBottomInset
	}
	
	func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath) {
		let photoMediaType: PhotoMediaType = .getSingleSearchMediaContentType(from: indexPath, type: mediaContentType)
		let singleModel = self.singleCleanModel.objects[photoMediaType]!
		cell.singleCleanCellConfigure(with: singleModel, mediaType: photoMediaType, indexPath: indexPath, for: self.searchingProcessingType == .smartGroupSearchProcess)
		cell.delegate = self
	}
	
	func configureBannerContent(cell: ContentBannerTableViewCell, at indexPath: IndexPath) {
		let mediaType: PhotoMediaType = .getSingleSearchMediaContentType(from: indexPath, type: mediaContentType)
		cell.configure(by: mediaType)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return mediaContentType.numberOfSection
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return self.setupCellFor(rowAt: indexPath)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.mediaContentType.getNumbersOfRows(for: section)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.mediaContentType.getRowHeight(for: indexPath.section)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.didSelect(rowAt: indexPath)
	}
}

extension MediaContentViewController {
	
	private func setupCellFor(rowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contentBannerCell, for: indexPath) as! ContentBannerTableViewCell
				self.configureBannerContent(cell: cell, at: indexPath)
				return cell
			default:
				let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contentTypeCell, for: indexPath) as! ContentTypeTableViewCell
				self.configure(cell, at: indexPath)
				return cell
		}
	}
	
	private func didSelect(rowAt indexPath: IndexPath) {
		
		if self.mediaContentType == .userVideo || self.mediaContentType == .userPhoto {
			
			if !PhotoLibraryPermissions().authorized {
				return
			}
		} else if self.mediaContentType == .userContacts {
			if !ContactsPermissions().authorized {
				return
			}
		}
	
		switch indexPath.section {
			case 1:
				guard searchingProcessingType == .clearSearchingProcessingQueue else { return}
				
				switch self.mediaContentType {
					case .userPhoto:
						self.openLocationClenController()
					case .userVideo:
						self.showVideoContentForCompressingOperation()
					case .userContacts:
						self.openContactExportBackupController()
					default:
						return
				}
			default:
				if self.smartCleaningDidFinishWithResults {
					self.showPrescanMediaContent(by: self.mediaContentType, selected: indexPath.row)
				} else {
					self.showMediaContent(by: self.mediaContentType, selected: indexPath.row)
				}
		}
	}
}

extension MediaContentViewController: Themeble {
    
    private func setupUI() {
        
        if mediaContentType == .userContacts {
            dateSelectContainerHeigntConstraint.constant = 0
			dateSelectPickerView.isHidden = true
		} else {
			dateSelectContainerHeigntConstraint.constant = 60
		}
		dateSelectPickerView.layoutIfNeeded()
    }
    
    private func setupNavigation() {
		
		if mediaContentType != .userContacts {
			
			navigationBar.setIsDropShadow = false
			
			navigationBar.setupNavigation(title: mediaContentType.navigationTitle,
										  leftBarButtonImage: I.systemItems.navigationBarItems.back,
										  rightBarButtonImage: nil,
										  contentType: mediaContentType,
										  leftButtonTitle: nil,
										  rightButtonTitle: LocalizationService.Buttons.getButtonTitle(of: .analize))
		} else {
			navigationBar.setupNavigation(title: mediaContentType.navigationTitle,
										  leftBarButtonImage: I.systemItems.navigationBarItems.back,
										  rightBarButtonImage: nil,
										  contentType: mediaContentType,
										  leftButtonTitle: nil,
										  rightButtonTitle: LocalizationService.Buttons.getButtonTitle(of: .analize))
		}
    }
    
    private func setupDelegate() {
		
		self.dateSelectPickerView.delegate = self
        self.navigationBar.delegate = self
    }
    
    private func setupObserver(for contentType: MediaContentType) {
        
        switch contentType {
            case .userPhoto:
				    /// `photo notification updates`
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchSimilarPhotoScan, object: nil)
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchDuplicatedPhotoScan, object: nil)
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchScreenShotsPhotoScan, object: nil)
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchSimilarSelfiePhotoScan, object: nil)
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchLivePhotoScan, object: nil)
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchRecentlyDeletedPhotoScan, object: nil)
            case .userVideo:
				    /// `video notification updates`
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchLargeVideoScan, object: nil)
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchDuplicatedVideoScan, object: nil)
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchSimilarVideoScan, object: nil)
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchScreenRecordingVideoScan, object: nil)
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchRecentlyDeletedVideoScan, object: nil)
            case .userContacts:
                    /// `contacts notification updates`
                U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchAllContactsScan, object: nil)
                U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchEmptyContactsScan, object: nil)
                U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchDuplicatesNamesContactsScan, object: nil)
                U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchDuplicatesNumbersContactsScan, object: nil)
                U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchDupliatesEmailsContactsScan, object: nil)
				
                U.notificationCenter.addObserver(self, selector: #selector(handleChangeContactsContainers(_:)), name: .CNContactStoreDidChange, object: nil)
				
				U.notificationCenter.addObserver(self, selector: #selector(removeStoreObserver), name: .removeContactsStoreObserver, object: nil)
				U.notificationCenter.addObserver(self, selector: #selector(addStoreObserver), name: .addContactsStoreObserver, object: nil)
            case .none:
                return
        }
		
		U.notificationCenter.addObserver(self, selector: #selector(handleStopAnyAnalizeProcessing), name: .incomingRemoteActionRecived, object: nil)
    }
    
    private func setupDateInterval() {
		
		dateSelectPickerView.setupDisplaysDate(lowerDate: self.lowerBoundDate, upperdDate: self.upperBoundDate)
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor
    }
    	
	private func setupShowDatePickerSelectorController(segue: UIStoryboardSegue, selectedType: PickerDateSelectType) {
		
		guard let segue = segue as? SwiftMessagesSegue else { return }
		
		segue.configure(layout: .bottomMessage)
		segue.dimMode = .gray(interactive: true)
		segue.interactiveHide = true
		segue.messageView.configureNoDropShadow()
		
		let height = selectedType == .lowerDateSelectable ? AppDimensions.DateSelectController.datePickerContainerHeightLower :
		AppDimensions.DateSelectController.datePickerContainerHeightUper
		
		segue.messageView.backgroundHeight = height
		
		if let dateSelectedController = segue.destination as? DateSelectorViewController {
			dateSelectedController.dateSelectedType = selectedType
			dateSelectedController.setPicker(selectedType.rawValue)
			dateSelectedController.selectedDateCompletion = { selectedDate in
				switch selectedType {
					case .lowerDateSelectable:
						if self.lowerBoundDate != selectedDate {
							self.lowerBoundDate = selectedDate
							self.desintagrateSearchingResults()
						}
					case .upperDateSelectable:
						if self.upperBoundDate != selectedDate {
							self.upperBoundDate = selectedDate
							self.desintagrateSearchingResults()
						}
					default:
						return
				}
				self.dateSelectPickerView.setupDisplaysDate(lowerDate: self.lowerBoundDate, upperdDate: self.upperBoundDate)
			}
		}
	}
	
	private func setupShowContactsBackupController(segue: UIStoryboardSegue) {
		
		guard let segue = segue as? SwiftMessagesSegue else { return }
		
		segue.configure(layout: .bottomMessage)
		segue.dimMode = .gray(interactive: false)
		segue.interactiveHide = true
		segue.messageView.setupForShadow(shadowColor: theme.bottomShadowColor, cornerRadius: 14, shadowOffcet: CGSize(width: 6, height: 6), shadowOpacity: 10, shadowRadius: 14)
		segue.messageView.configureNoDropShadow()
	}
}
