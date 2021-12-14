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

class MediaContentViewController: UIViewController {
  
    @IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var dateSelectPickerView: DateSelectebleView!
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateSelectContainerHeigntConstraint: NSLayoutConstraint!
    
    public var mediaContentType: MediaContentType = .none
	private var photoManager = PhotoManager.shared
    private var contactsManager = ContactsManager.shared
	
	public let phassetProcessingOperationQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.phassets, maxConcurrentOperationCount: 5, qualityOfService: .background)
	public let contactsProcessingOperationQueuer = OperationProcessingQueuer(name: Constants.key.operation.queue.contacts, maxConcurrentOperationCount: 5, qualityOfService: .background)
    
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
    private var scanningProcessIsRunning: Bool = false
    private var isStartingDateSelected: Bool = false
	
	public var similarPhoto: [PhassetGroup] = []
	public var duplicatedPhoto: [PhassetGroup] = []
    public var allScreenShots: [PHAsset] = []
	public var allSelfies: [PHAsset] = []
    public var allLiveFotos: [PHAsset] = []
    public var allRecentlyDeletedPhotos: [PHAsset] = []
    
    public var allLargeVideos: [PHAsset] = []
    public var allSimmilarVideos: [PhassetGroup] = []
    public var allDuplicatesVideos: [PhassetGroup] = []
    public var allScreenRecords: [PHAsset] = []
    public var allRecentlyDeletedVideos: [PHAsset] = []
    
    public var allContacts: [CNContact] = []
    public var allEmptyContacts: [ContactsGroup] = []
    public var allDuplicatedContacts: [ContactsGroup] = []
    public var allDuplicatedPhoneNumbers: [ContactsGroup] = []
    public var allDuplicatedEmailAdresses: [ContactsGroup] = []
	
	
	/// `photos`
	private var singleSearchPhotoProgress: [CGFloat] = [0,0,0,0,0,0]
	private var totalSearchFindPhotosCountIn: [Int] = [0,0,0,0,0,0]
	/// `videos`
	private var singleSearchVideoProgress: [CGFloat] = [0,0,0,0,0]
	private var totalSearchFindVideosCountInt: [Int] = [0,0,0,0,0]
	/// `contacts`
    private var singleSearchContactsProgress: [CGFloat] = [0,0,0,0,0]
	private var singleSearchContactsAfterProcessing: [CGFloat] = [0,0,0,0,0]
    private var totalSearchFindContactsCountIn: [Int] = [0,0,0,0,0]
	
	
    private var currentProgressForMediaType: [PhotoMediaType : CGFloat] = [:]
    
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
        
        self.navigationItem.backButtonTitle = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case C.identifiers.segue.showDatePicker:
                self.setupShowDatePickerSelectorController(segue: segue)
            default:
                break
        }
    }
}

//      MARK: - show content controller -
extension MediaContentViewController {
    
        /// `0` - simmilar photos
        /// `1` - duplicates
        /// `2` - screenshots
        /// `3` - selfies
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
        
        guard !scanningProcessIsRunning else { return }
        
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
                        self.showSelfies()
                    case 4:
                        self.showLivePhotos()
                    case 5:
                        self.showRecentlyDeletedPhotos()
                    case 6:
                        return
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
    
    private func showGropedContoller(assets title: String, grouped collection: [PhassetGroup], photoContent type: PhotoMediaType) {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
        let viewController  = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.groupedList) as! GroupedAssetListViewController
        viewController.title = title
        viewController.assetGroups = collection
        viewController.mediaType = type
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showAssetViewController(assets title: String, collection: [PHAsset], photoContent type: PhotoMediaType) {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.assetsList) as! SimpleAssetsListViewController
        viewController.title = title
        viewController.assetCollection = collection
        viewController.mediaType = type
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showContactViewController(contacts: [CNContact] = [], contactGroup: [ContactsGroup] = [], contentType: PhotoMediaType) {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.contacts, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.contacts) as! ContactsViewController
        viewController.contacts = contacts
        viewController.contactGroup = contactGroup
        viewController.mediaType = .userContacts
        viewController.contentType = contentType
        self.navigationController?.pushViewController(viewController, animated: true)
    }
        
    private func showGroupedContactsViewController(contacts group: [ContactsGroup], group type: ContactasCleaningType, content: PhotoMediaType) {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.contactsGroup, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.contactsGroup) as! ContactsGroupViewController
        viewController.contactGroup = group
        viewController.navigationTitle = content.mediaTypeName
        viewController.contentType = content
        viewController.mediaType = .userContacts
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

//      MARK: - photo content -
extension MediaContentViewController {
    
    /**
     - parameter
     - parameter
    */

    private func showSimilarPhotos() {
		
		self.scanningProcessIsRunning = !self.scanningProcessIsRunning
		
		let getSimilarPhotosAssetsOperation = photoManager.getSimilarPhotosAssetsOperation(from: lowerBoundDate, to: upperBoundDate, enableSingleProcessingNotification: true) { similarGroup in
			self.similarPhoto = similarGroup
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .similarPhoto, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					self.scanningProcessIsRunning = !self.scanningProcessIsRunning
					if !similarGroup.isEmpty {
						self.showGropedContoller(assets: PhotoMediaType.similarPhotos.mediaTypeName, grouped: similarGroup, photoContent: .similarPhotos)
					} else {
						AlertManager.showCantFindMediaContent(by: .noSimiliarPhoto) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getSimilarPhotosAssetsOperation)
    }
	
	private func showDuplicatePhotos() {
		
		let duplicatedPhotoAssetOperation = photoManager.getDuplicatedPhotosAsset(from: lowerBoundDate, to: upperBoundDate, enableSingleProcessingNotification: true) { duplicateGroup in
			self.duplicatedPhoto = duplicateGroup
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .duplicatedPhoto, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					self.scanningProcessIsRunning = !self.scanningProcessIsRunning
					if !duplicateGroup.isEmpty {
						self.showGropedContoller(assets: PhotoMediaType.duplicatedPhotos.mediaTypeName, grouped: duplicateGroup, photoContent: .duplicatedPhotos)
					} else {
						AlertManager.showCantFindMediaContent(by: .noDuplicatesPhoto) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(duplicatedPhotoAssetOperation)
	}
	
	private func showScreenshots() {
		
		let getScreenShotsAssetsOperation = photoManager.getScreenShotsOperation(from: lowerBoundDate, to: upperBoundDate, enableSingleProcessingNotification: true) { screenshots in
			self.allScreenShots = screenshots
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .screenShots, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					if screenshots.count != 0 {
						self.showAssetViewController(assets: PhotoMediaType.singleSelfies.mediaTypeName, collection: screenshots, photoContent: .singleScreenShots)
					} else {
						AlertManager.showCantFindMediaContent(by: .noScreenShots) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getScreenShotsAssetsOperation)
	}
	
	private func showSelfies() {
		
		let getSelfiesPhotoAssetOperation = photoManager.getSelfiePhotosOperation(from: lowerBoundDate, to: upperBoundDate, enableSingleProcessingNotification: true) { selfies in
			self.allSelfies = selfies
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .selfies, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					if selfies.count != 0 {
						self.showAssetViewController(assets: PhotoMediaType.singleSelfies.mediaTypeName, collection: selfies, photoContent: .singleSelfies)
					} else {
						AlertManager.showCantFindMediaContent(by: .noSelfie) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getSelfiesPhotoAssetOperation)
	}
	
    private func showLivePhotos() {
		
		let getLivePhotoAssetsOperation = photoManager.getLivePhotosOperation(from: lowerBoundDate, to: upperBoundDate, enableSingleProcessingNotification: true) { livePhoto in
			self.allLiveFotos = livePhoto
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .livePhoto, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					if !livePhoto.isEmpty {
						self.showAssetViewController(assets: PhotoMediaType.singleLivePhotos.mediaTypeName, collection: livePhoto, photoContent: .singleLivePhotos)
					} else {
						AlertManager.showCantFindMediaContent(by: .noLivePhoto) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getLivePhotoAssetsOperation)
    }
    
	private func showRecentlyDeletedPhotos() {
		
		let getSortedRecentlyDeletedAssetsOperation = PHAssetFetchManager.shared.recentlyDeletdSortedAlbumsFetchOperation { photosAssets, videoAssets in
			self.allRecentlyDeletedPhotos = photosAssets
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .recentlyDeletedPhoto, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					if photosAssets.count != 0 {
						self.showAssetViewController(assets: PhotoMediaType.singleRecentlyDeletedPhotos.mediaTypeName, collection: photosAssets, photoContent: .singleRecentlyDeletedPhotos)
					} else {
						AlertManager.showCantFindMediaContent(by: .noRecentlyDeletedPhotos) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getSortedRecentlyDeletedAssetsOperation)
	}
}

//      MARK: - video content -
extension MediaContentViewController {
    
	private func showLargeVideoFiles() {
		
		let getLargevideoContentOperation = photoManager.getLargevideoContentOperation(from: lowerBoundDate, to: upperBoundDate, enableSingleProcessingNotification: true) { largeVodeoAsset in
			self.allLargeVideos = largeVodeoAsset
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .largeVideo, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					if largeVodeoAsset.count != 0 {
						self.showAssetViewController(assets: PhotoMediaType.singleLargeVideos.mediaTypeName, collection: largeVodeoAsset, photoContent: .singleLargeVideos)
					} else {
						AlertManager.showCantFindMediaContent(by: .noLargeVideo) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getLargevideoContentOperation)
	}
    
	private func showDuplicateVideoFiles() {
		
		let getDuplicatedVideoAssetOperatioon = photoManager.getDuplicatedVideoAssetOperation(from: lowerBoundDate, to: upperBoundDate, enableSingleProcessingNotification: true) { duplicatedVideoAsset in
			self.allDuplicatesVideos = duplicatedVideoAsset
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .duplicatedVideo, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					if duplicatedVideoAsset.count != 0 {
						self.showGropedContoller(assets: PhotoMediaType.duplicatedVideos.mediaTypeName, grouped: duplicatedVideoAsset, photoContent: .duplicatedVideos)
					} else {
						AlertManager.showCantFindMediaContent(by: .noDuplicatesVideo) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getDuplicatedVideoAssetOperatioon)
	}
    
	private func showSimilarVideoFiles() {
		
		let getSimilarVideoAssetsOperation = photoManager.getSimilarVideoAssetsOperation(from: lowerBoundDate, to: upperBoundDate, enableSingleProcessingNotification: true) { similiarVideoAsset in
			self.allSimmilarVideos = similiarVideoAsset
			
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .similarVideo, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					if similiarVideoAsset.count != 0 {
						self.showGropedContoller(assets: PhotoMediaType.similarVideos.mediaTypeName, grouped: similiarVideoAsset, photoContent: .similarVideos)
					} else {
						AlertManager.showCantFindMediaContent(by: .noSimilarVideo) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getSimilarVideoAssetsOperation)
	}
    
    private func showScreenRecordsVideoFiles() {
		
		let getScreenRecordsVideosOperation = photoManager.getScreenRecordsVideosOperation(from: lowerBoundDate, to: upperBoundDate, enableSingleProcessingNotification: true) { screenRecordsAssets in
			self.allScreenRecords = screenRecordsAssets
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .screenRecordings, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					if screenRecordsAssets.count != 0 {
						self.showAssetViewController(assets: PhotoMediaType.singleScreenRecordings.mediaTypeName, collection: screenRecordsAssets, photoContent: .singleScreenRecordings)
					} else {
						AlertManager.showCantFindMediaContent(by: .noScreenRecording) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getScreenRecordsVideosOperation)
    }
	
	private func showRecentlyDeletedVideos() {
		
		let getSortedRecentlyDeletedAssetsOperation = PHAssetFetchManager.shared.recentlyDeletdSortedAlbumsFetchOperation { photosAssets, videoAssets in
			self.allRecentlyDeletedVideos = videoAssets
			U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .recentlyDeletedVideo, totalProgressItems: 1, currentProgressItem: 1)
				U.delay(1) {
					if videoAssets.count != 0 {
						self.showAssetViewController(assets: PhotoMediaType.singleRecentlyDeletedVideos.mediaTypeName, collection: videoAssets, photoContent: .singleRecentlyDeletedVideos)
					} else {
						AlertManager.showCantFindMediaContent(by: .noRecentlyDeletedVideos) {}
					}
				}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getSortedRecentlyDeletedAssetsOperation)
	}
    
    private func showSimmilarVideoFilesByTimeStamp() {
		
		let getSimilarVideosByTimeStamp = photoManager.getSimilarVideosByTimeStampOperation(from: lowerBoundDate, to: upperBoundDate, enableSingleProcessingNotification: true) { similarVideos in
			if similarVideos.count != 0 {
				self.showGropedContoller(assets: "similar by time stam", grouped: similarVideos, photoContent: .similarVideos)
			} else {
				AlertManager.showCantFindMediaContent(by: .noSimilarVideo) {}
			}
		}
		phassetProcessingOperationQueuer.addOperation(getSimilarVideosByTimeStamp)
    }
}

extension MediaContentViewController {
	
	private func checkForAssetsCount() {
		
		if self.allScreenRecords.isEmpty {
			let screenRecordsVideosOperation = photoManager.getScreenRecordsVideosOperation(from: lowerBoundDate, to: upperBoundDate) { screenRecordsAssets in
				if screenRecordsAssets.count != 0 {
					self.allScreenRecords = screenRecordsAssets
				}
			}
			phassetProcessingOperationQueuer.addOperation(screenRecordsVideosOperation)
		}
		
		if self.allLargeVideos.isEmpty {
			
			let largeVideosOperation = photoManager.getLargevideoContentOperation(from: lowerBoundDate, to: upperBoundDate) { videoAssets in
				if videoAssets.count != 0 {
					self.allLargeVideos = videoAssets
				}
			}
			
			phassetProcessingOperationQueuer.addOperation(largeVideosOperation)
		}
	}
}

//      MARK: - contacts content -
extension MediaContentViewController {
    
    private func showAllContacts() {
        P.showIndicator()
        self.contactsManager.getAllContacts { contacts in
            self.allContacts = contacts
            U.UI {
                P.hideIndicator()
                if !contacts.isEmpty {
                    self.showContactViewController(contacts: contacts, contentType: .allContacts)
                } else {
                    A.showEmptyContactsToPresent(of: .contactsIsEmpty) {}
                }
            }
        }
    }
    
    private func showEmptyGroupsContacts() {
        P.showIndicator()
		self.contactsManager.getSingleDuplicatedCleaningContacts(of: .emptyContacts) { contactsGroup in
            U.UI {
                P.hideIndicator()
                let totalContacts = contactsGroup.map({$0.contacts}).count
                let group = contactsGroup.filter({!$0.contacts.isEmpty})
                
                if totalContacts != 0 {
                    self.showContactViewController(contactGroup: group, contentType: .emptyContacts)
                } else {
                    A.showEmptyContactsToPresent(of: .emptyContactsIsEmpty) {}
                }
            }
        }
    }
    
    private func showContactCleanController(cleanType: ContactasCleaningType) {
        self.scanningProcessIsRunning = !scanningProcessIsRunning
        
		self.contactsManager.getSingleDuplicatedCleaningContacts(of: cleanType) { contactsGroup in
            self.updateContactsCleanSearchCount(groupType: cleanType, contactsGroup: contactsGroup)
            U.delay(0.5) {
				ProgressSearchNotificationManager.instance.sendSingleSearchProgressNotification(notificationtype: cleanType.notificationType, totalProgressItems: 1, currentProgressItem: 1)
                U.delay(0.5) {
                    self.scanningProcessIsRunning = !self.scanningProcessIsRunning
                    if contactsGroup.count != 0 {
                        let group = contactsGroup.sorted(by: {$0.name < $1.name})
                        self.showGroupedContactsViewController(contacts: group, group: cleanType, content:  cleanType.photoMediaType)
                    } else {
                        A.showEmptyContactsToPresent(of: cleanType.alertEmptyType) {}
                    }
                }
            }
        }
    }
    
    private func updateContactsCleanSearchCount(groupType: ContactasCleaningType, contactsGroup: [ContactsGroup]) {
        switch groupType {
            case .duplicatedPhoneNumnber:
                self.allDuplicatedPhoneNumbers = contactsGroup
            case .duplicatedContactName:
                self.allDuplicatedContacts = contactsGroup
            case .duplicatedEmail:
                self.allDuplicatedEmailAdresses = contactsGroup
            default: return
        }
    }
    
    
    @objc func handleChangeContactsContainers(_ notification: Notification) {
        
        contactsManager.getUpdatingContactsAfterContainerDidChange {
            self.tableView.reloadData()
        } allContacts: { contacts in
            self.allContacts = contacts
            self.updateValues(of: .allContacts)
        } emptyContacts: { contactsGrop in
            self.allEmptyContacts = contactsGrop
            self.updateValues(of: .emptyContacts)
        } duplicatedNames: { contactsGroup in
            self.allDuplicatedContacts = contactsGroup
            self.updateValues(of: .duplicatedContacts)
        } duplicatedPhoneNumbers: { contactsGroup in
            self.allDuplicatedPhoneNumbers = contactsGroup
            self.updateValues(of: .duplicatedPhoneNumbers)
        } duplicatedEmailGrops: { contactsGroup in
            self.allDuplicatedEmailAdresses = contactsGroup
            self.updateValues(of: .duplicatedEmails)
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
			case .singleSearchSelfiePhotoScan:
				recieveNotification(by: .selfies, userInfo: userInfo)
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
        
        guard let totalProcessingCount = userInfo[type.dictionaryCountName] as? Int,
              let currentIndex = userInfo[type.dictioanartyIndexName] as? Int else { return }
        
        handleSearchProgress(by: type, files: currentIndex)
        
        calculateProgressPercentage(total: totalProcessingCount, current: currentIndex) { optionalTitle, progress in
            U.UI {
                self.progressUpdate(type, progress: progress, title: optionalTitle)
            }
        }
    }
    
    private func handleSearchProgress(by type: SingleContentSearchNotificationType, files count: Int) {
        
        switch type {
				/// `Photos`
			case .similarPhoto:
				totalSearchFindPhotosCountIn[0] = count
			case .duplicatedPhoto:
				totalSearchFindPhotosCountIn[1] = count
			case .screenShots:
				totalSearchFindPhotosCountIn[2] = count
			case .selfies:
				totalSearchFindPhotosCountIn[3] = count
			case .livePhoto:
				totalSearchFindPhotosCountIn[4] = count
			case .recentlyDeletedPhoto:
				totalSearchFindPhotosCountIn[5] = count
			case .largeVideo:
				totalSearchFindVideosCountInt[0] = count
			case .duplicatedVideo:
				totalSearchFindVideosCountInt[1] = count
			case .similarVideo:
				totalSearchFindVideosCountInt[2] = count
			case .screenRecordings:
				totalSearchFindVideosCountInt[3] = count
			case .recentlyDeletedVideo:
				totalSearchFindVideosCountInt[4] = count
                    /// `Contacts:
            case .allContacts:
                totalSearchFindContactsCountIn[0] = count
            case .emptyContacts:
				totalSearchFindContactsCountIn[1] = count
            case .duplicatesNames:
				totalSearchFindContactsCountIn[2] = count
            case .duplicatesNumbers:
				totalSearchFindContactsCountIn[3] = count
            case .duplicatesEmails:
				totalSearchFindContactsCountIn[4] = count
            default:
                return
        }
    }
    
    private func calculateProgressPercentage(total: Int, current: Int, completionHandler: @escaping (String, CGFloat) -> Void) {
        
        let percentString: String = "%. f %%"
        let totalPercent = CGFloat(Double(current) / Double(total))
        let stringFormat = String(format: percentString, totalPercent)
        completionHandler(stringFormat, totalPercent)
    }
    
    private func progressUpdate(_ notificationType: SingleContentSearchNotificationType, progress: CGFloat, title: String) {
        
        let indexPath = notificationType.mediaTypeRawValue.singleSearchIndexPath
        self.currentProgressForMediaType[notificationType.mediaTypeRawValue] = progress
        
        switch notificationType {
			case .similarPhoto:
				self.singleSearchPhotoProgress[0] = progress
			case .duplicatedPhoto:
				self.singleSearchPhotoProgress[1] = progress
			case .screenShots:
				self.singleSearchPhotoProgress[2] = progress
			case .selfies:
				self.singleSearchPhotoProgress[3] = progress
			case .livePhoto:
				self.singleSearchPhotoProgress[4] = progress
			case .recentlyDeletedPhoto:
				self.singleSearchPhotoProgress[5] = progress
			case .largeVideo:
				self.singleSearchVideoProgress[0] = progress
			case .duplicatedVideo:
				self.singleSearchVideoProgress[2] = progress
			case .similarVideo:
				self.singleSearchVideoProgress[3] = progress
			case .screenRecordings:
				self.singleSearchVideoProgress[4] = progress
			case .recentlyDeletedVideo:
				self.singleSearchVideoProgress[5] = progress
            case .allContacts:
                self.singleSearchContactsProgress[0] = progress
            case .emptyContacts:
                self.singleSearchContactsProgress[1] = progress
            case .duplicatesNames:
                self.singleSearchContactsProgress[2] = progress
            case .duplicatesNumbers:
                self.singleSearchContactsProgress[3] = progress
            case .duplicatesEmails:
                self.singleSearchContactsProgress[4] = progress
            default:
                return
        }
        
        guard !indexPath.isEmpty else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? ContentTypeTableViewCell else { return }
        
        let isSearchStarted = progress != 0 || progress != 1.0
        
        self.configure(cell, at: indexPath, isSearchingStarted: isSearchStarted)
    }
    
    private func updateValues(of type: PhotoMediaType) {
        
        let indexPath = type.singleSearchIndexPath
        U.UI {
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}


extension MediaContentViewController: DateSelectebleViewDelegate {
    
    func didSelectStartingDate() {
        
        self.isStartingDateSelected = true
        performSegue(withIdentifier: C.identifiers.segue.showDatePicker, sender: self)
    }
    
    func didSelectEndingDate() {
        
        self.isStartingDateSelected = false
        performSegue(withIdentifier: C.identifiers.segue.showDatePicker, sender: self)
    }
}

extension MediaContentViewController: NavigationBarDelegate {
    
    func didTapLeftBarButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightBarButton(_ sender: UIButton) {}
}

extension MediaContentViewController: UITableViewDelegate, UITableViewDataSource {

	private func setupTableView() {
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorStyle = .none
		tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
		if mediaContentType == .userContacts {
			tableView.contentInset.top = 20
		} else {
			tableView.contentInset.top = 50
			tableView.contentInset.bottom = 40
		}
	}
	
	func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath, isSearchingStarted: Bool = false) {
	
		let  photoMediaType: PhotoMediaType = .getSingleSearchMediaContentType(from: indexPath, type: mediaContentType)
		var assetContentCount: Int {
			switch photoMediaType {
				case .similarPhotos:
					return self.similarPhoto.map({$0.assets}).reduce([], +).count
				case .duplicatedPhotos:
					return self.duplicatedPhoto.map({$0.assets}).reduce([], +).count
				case .singleScreenShots:
					return self.allScreenShots.count
				case .singleLivePhotos:
					return self.allLiveFotos.count
				case .singleLargeVideos:
					return self.allLargeVideos.count
				case .duplicatedVideos:
					return self.allDuplicatesVideos.map({$0.assets}).reduce([], +).count
				case .similarVideos:
					return self.allSimmilarVideos.map({$0.assets}).reduce([], +).count
				case .singleSelfies:
					return self.allSelfies.count
				case .singleScreenRecordings:
					return self.allScreenRecords.count
				case .singleRecentlyDeletedPhotos:
					return self.allRecentlyDeletedPhotos.count
				case .singleRecentlyDeletedVideos:
					return self.allRecentlyDeletedVideos.count
				case .allContacts:
					return self.allContacts.count
				case .emptyContacts:
					return self.allEmptyContacts.count
				case .duplicatedContacts:
					return self.allDuplicatedContacts.count
				case .duplicatedPhoneNumbers:
					return self.allDuplicatedPhoneNumbers.count
				case .duplicatedEmails:
					return self.allDuplicatedEmailAdresses.count
				default:
					return 0
			}
		}
		
		let progress = self.currentProgressForMediaType[photoMediaType] ?? 0
		
		cell.cellConfig(contentType: self.mediaContentType,
						photoMediaType: photoMediaType,
						indexPath: indexPath,
						phasetCount: assetContentCount,
						presentingType: .singleSearch,
						progress: progress,
						isProcessingComplete: isSearchingStarted)
	}
		
	func numberOfSections(in tableView: UITableView) -> Int {
		return mediaContentType.numberOfSection
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contentTypeCell, for: indexPath) as! ContentTypeTableViewCell
		configure(cell, at: indexPath)
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return mediaContentType.numberOfRows
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.showMediaContent(by: mediaContentType, selected: indexPath.row)
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
										  rightBarButtonImage: I.systemItems.navigationBarItems.magic,
										  mediaType: mediaContentType,
										  leftButtonTitle: nil,
										  rightButtonTitle: nil)
		} else {
			navigationBar.setupNavigation(title: mediaContentType.navigationTitle,
										  leftBarButtonImage: I.systemItems.navigationBarItems.back,
										  rightBarButtonImage: nil,
										  mediaType: mediaContentType,
										  leftButtonTitle: nil,
										  rightButtonTitle: nil)
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
				U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchSelfiePhotoScan, object: nil)
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
            case .none:
                return
        }
    }
    
    private func setupDateInterval() {
		
		dateSelectPickerView.setupDisplaysDate(lowerDate: self.lowerBoundDate, upperdDate: self.upperBoundDate)
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    private func setupShowDatePickerSelectorController(segue: UIStoryboardSegue) {
        
        guard let segue = segue as? SwiftMessagesSegue else { return }
        
        segue.configure(layout: .bottomMessage)
        segue.dimMode = .gray(interactive: false)
        segue.interactiveHide = false
        segue.messageView.configureNoDropShadow()
        segue.messageView.backgroundHeight = Device.isSafeAreaiPhone ? 458 : 438
        
        if let dateSelectorController = segue.destination as? DateSelectorViewController {
            dateSelectorController.isStartingDateSelected = self.isStartingDateSelected
            dateSelectorController.setPicker(self.isStartingDateSelected ? self.lowerBoundDate : self.upperBoundDate)
            
            dateSelectorController.selectedDateCompletion = { selectedDate in
                self.isStartingDateSelected ? (self.lowerBoundDate = selectedDate) : (self.upperBoundDate = selectedDate)
				self.dateSelectPickerView.setupDisplaysDate(lowerDate: self.lowerBoundDate, upperdDate: self.upperBoundDate)
            }
        }
    }
}
