//
//  DeepCleaningViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.07.2021.
//

import UIKit
import Photos
import PhotosUI
import SwiftMessages

enum DeepCleaningState {
	 case redyForStartingCleaning
     case willStartCleaning
     case didCleaning
     case willAvailibleDelete
}

protocol DeepCleanSelectableAssetsDelegate: AnyObject {
     
     func didSelect(assetsListIds: [String], mediaType: PhotoMediaType)
}

class DeepCleaningViewController: UIViewController {
     
     @IBOutlet weak var navigationBar: NavigationBar!
     @IBOutlet weak var bottomButtonView: BottomButtonBarView!
     @IBOutlet weak var dateSelectPickerView: DateSelectebleView!
     @IBOutlet weak var tableView: UITableView!
     @IBOutlet weak var dateSelectContainerHeigntConstraint: NSLayoutConstraint!
     @IBOutlet weak var bottomContainerHeightConstraint: NSLayoutConstraint!

     /// managers∂
     private var deepCleanManager = DeepCleanManager()
	 private var photoManager = PhotoManager.shared
	 private var contactsManager = ContactsManager.shared
     
     /// protocols and delegates
     weak var selectableAssetsDelegate: DeepCleanSelectableAssetsDelegate?
     
     /// properties
     
     private var bottomMenuHeight: CGFloat = 80
     private var processing: Bool = false
     private var isStartingDateSelected: Bool = false

	 
	 public var scansOptions: [PhotoMediaType]?
     private var deepCleaningState: DeepCleaningState = .willStartCleaning

     private var startingDate: String {
          get {
               return S.startingSavedDate
          } set {
               S.startingSavedDate = newValue
          }
     }
     
     private var endingDate: String {
          get {
               return S.endingSavedDate
          } set {
               S.endingSavedDate = newValue
          }
     }
     
     /// files
     /// `selected groups of all assets to delete`
     private var selectedAssetsCollectionID: [PhotoMediaType : [String]] = [:]
     
     /// `file processing check count`
     private var totalFilesOnDevice: Int = 0
     private var totalFilesChecked: Int = 0
     private var totalPercentageCalculated: CGFloat = 0
     private var totalPartitinAssetsCount: [AssetsGroupType: Int] = [:]
     
     private var totalDeepCleanProgress: [CGFloat] = [0,0,0,0,0,0,0,0,0,0,0,0]
     private var totalDeepCleanFilesCountIn: [Int] = [0,0,0,0,0,0,0,0,0,0,0,0]
     
     private var handleSelectedAssetsForRowMediatype: [PhotoMediaType: Bool] = [:]
     private var doneProcessingDeepCleanForMedia: [PhotoMediaType : Bool] = [:]
     private var currentProgressForRawMediatype: [PhotoMediaType: CGFloat] = [:]
          
          /// `finding duplicates and assets`
     private var photoVideoFlowGroup: [PhotoMediaType : [PhassetGroup]] = [:]
     private var contactsFlowGroups: [PhotoMediaType : [ContactsGroup]] = [:]
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
		  deepCleanManager.cancelAllOperation()
		  
          setupUI()
          setProcessingActionButton(.redyForStartingCleaning)
          setupNavigation()
          setupTableView()
          setupDateInterval()
          updateTotalFilesTitleChecked(0)
          setupObserversAndDelegate()
          updateColors()
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

//      MARK: deep cleaning algorithm
extension DeepCleaningViewController {
     
     private func prepareStartDeepCleanProcessing() {
          
          self.photoManager.getPhotoAssetsCount(from: self.startingDate, to: self.endingDate) { allAssetsCount in
               self.totalFilesOnDevice = allAssetsCount
               
               self.photoManager.getPartitionalMediaAssetsCount(from: self.startingDate, to: self.endingDate) { assetGroupPartitionCount in
					self.setProcessingActionButton(.didCleaning)
                    self.totalPartitinAssetsCount = assetGroupPartitionCount
					U.delay(1) {
						 self.startDeepCleanScan()
					}
               }
          }
     }
	 
	 private func showStopDeepCleanScanAlert() {
		  
		  A.showStopDeepCleanSearchProcess {
			   self.stopAllCleaningOperation()
		  }
	 }
	 
	 private func stopAllCleaningOperation() {
		  
		  deepCleanManager.cancelAllOperation()
//		  photoManager.setStopSearchProcessing()
//		  contactsManager.setStopSearchProcessing()
//		  resetAllValues()
//		  U.delay(1) {
//			   self.setProcessingActionButton(.redyForStartingCleaning)
//
//			   self.photoManager.setAvailibleSearchProcessing()
//			   self.navigationBar.temporaryLockLeftButton(false)
//		  }
	 }
	 
	 private func resetAllValues() {
		  
		  totalFilesOnDevice = 0
		  totalFilesChecked = 0
		  totalPercentageCalculated = 0
		  totalPartitinAssetsCount = [:]
		  totalDeepCleanProgress = [0,0,0,0,0,0,0,0,0,0,0,0]
		  totalDeepCleanFilesCountIn = [0,0,0,0,0,0,0,0,0,0,0,0]
		  handleSelectedAssetsForRowMediatype = [:]
		  doneProcessingDeepCleanForMedia = [:]
		  currentProgressForRawMediatype = [:]
		  photoVideoFlowGroup = [:]
		  contactsFlowGroups = [:]
		  
		  self.tableView.reloadData()
	 }
     
     private func startDeepCleanScan() {
          
          guard let options = scansOptions else { return }
		  
		  navigationBar.temporaryLockLeftButton(true)
          
          deepCleanManager.startDeepCleaningFetch(options, startingFetchingDate: startingDate, endingFetchingDate: endingDate) { mediaType in
               self.scansOptions = mediaType
          } screenShots: { assets in
                    /// `processing single screenshots`
               let photoMediaType: PhotoMediaType = .singleScreenShots
               debugPrint(assets.count, photoMediaType.rawValue)
               let screenShotGroup = PhassetGroup(name: photoMediaType.rawValue, assets: assets)
               self.updateAssetsProcessingOfType(group: [screenShotGroup], mediaType: .userPhoto, contentType: photoMediaType, phassetsCount: assets.count)
          } similarPhoto: { assetsGroup in
                    /// `processing similar assets group`
               let assetsCount = self.getAssetsCount(for: assetsGroup)
               let photoMediaType: PhotoMediaType = .similarPhotos
               debugPrint(assetsGroup.count, photoMediaType.rawValue)
               self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userPhoto, contentType: photoMediaType, phassetsCount: assetsCount)
          } duplicatedPhoto: { assetsGroup in
                    /// `processing duplicated assets group`
               let assetsCount = self.getAssetsCount(for: assetsGroup)
               let photoMediaType: PhotoMediaType = .duplicatedPhotos
               debugPrint(assetsGroup.count, photoMediaType.rawValue)
               self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userPhoto, contentType: photoMediaType, phassetsCount: assetsCount)
          } similarLivePhotos: { assetsGroup in
                    /// `processing similar live video group`
               let assetsCount = self.getAssetsCount(for: assetsGroup)
               let photoMediaType: PhotoMediaType = .similarLivePhotos
               debugPrint(assetsGroup.count, photoMediaType.rawValue)
               self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userPhoto, contentType: photoMediaType, phassetsCount: assetsCount)
          } largeVideo: { assets in
                    /// `processing large video group`
               let photoMediaType: PhotoMediaType = .singleLargeVideos
               debugPrint(assets.count, photoMediaType.rawValue)
               let largeVideoGroup = PhassetGroup(name: photoMediaType.rawValue, assets: assets)
               self.updateAssetsProcessingOfType(group: [largeVideoGroup], mediaType: .userVideo  , contentType: photoMediaType, phassetsCount: assets.count)
          } similarVideo: { assetsGroup in
                    /// `processing similar videos`
               let assetsCount = self.getAssetsCount(for: assetsGroup)
               let photoMediaType: PhotoMediaType = .similarVideos
               debugPrint(assetsGroup.count, photoMediaType.rawValue)
               self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userVideo, contentType: photoMediaType, phassetsCount: assetsCount)
          } duplicatedVideo: { assetsGroup in
                    /// `duplicated video`
               let assetsCount = self.getAssetsCount(for: assetsGroup)
               let photoMediaType: PhotoMediaType = .duplicatedVideos
               debugPrint(assetsGroup.count, photoMediaType.rawValue)
               self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userVideo, contentType: photoMediaType, phassetsCount: assetsCount)
          } screenRecordings: { assets in
                    /// `screen recording`
               let photoMediaType: PhotoMediaType = .singleScreenRecordings
               debugPrint(assets.count, photoMediaType.rawValue)
               let screenRecordings = PhassetGroup(name: photoMediaType.rawValue, assets: assets)
               self.updateAssetsProcessingOfType(group: [screenRecordings], mediaType: .userVideo  , contentType: photoMediaType, phassetsCount: assets.count)
          } emptyContacts: { contactsGroup in
                    /// `empty contacts`
               let contactsCount = self.getContactsCount(for: contactsGroup)
               let contentType: PhotoMediaType = .emptyContacts
               debugPrint(contactsGroup.count, contentType.rawValue)
               self.updateContactsProcessing(group: contactsGroup, contentType: contentType, contactsCount: contactsCount)
          } duplicatedContats: { contactsGroup in
                    /// `duplicated contacts`
               let contactsCount = self.getContactsCount(for: contactsGroup)
               let contentType:  PhotoMediaType = .duplicatedContacts
               debugPrint(contactsGroup.count, contentType.rawValue)
               self.updateContactsProcessing(group: contactsGroup, contentType: contentType, contactsCount: contactsCount)
          } duplicatedPhoneNumbers: { contactsGroup in
                    /// `duplicated phone numbers contacts`
               let contactsCount = self.getContactsCount(for: contactsGroup)
               let contentType:  PhotoMediaType = .duplicatedPhoneNumbers
               debugPrint(contactsGroup.count, contentType.rawValue)
               self.updateContactsProcessing(group: contactsGroup, contentType: contentType, contactsCount: contactsCount)
          } duplicatedEmails: { contactsGroup in
                    /// `dublicated email contacts`
               let contactsCount = self.getContactsCount(for: contactsGroup)
               let contentType:  PhotoMediaType = .duplicatedEmails
               debugPrint(contactsGroup.count, contentType.rawValue)
               self.updateContactsProcessing(group: contactsGroup, contentType: contentType, contactsCount: contactsCount)
          } completionHandler: {
               self.processing = false
               U.UI {
					self.setProcessingActionButton(.willAvailibleDelete)
					self.checkCleaningButtonState()
					self.navigationBar.temporaryLockLeftButton(false)
               }
          }
          
          U.delay(1) {
               self.processing = true
          }
     }
     
     private func updateAssetsProcessingOfType(group: [PhassetGroup], mediaType: MediaContentType, contentType: PhotoMediaType, phassetsCount: Int) {
          self.doneProcessingDeepCleanForMedia[contentType] = true
          self.photoVideoFlowGroup[contentType] = group
          self.updateCellInfoCount(by: mediaType, contentType: contentType, assetsCount: phassetsCount)
     }
     
     private func updateContactsProcessing(group: [ContactsGroup], contentType: PhotoMediaType, contactsCount: Int) {
          self.doneProcessingDeepCleanForMedia[contentType] = true
          self.contactsFlowGroups[contentType] = group
          self.updateCellInfoCount(by: .userContacts, contentType: contentType, assetsCount: contactsCount)
     }
     
     private func updateAssetsFieldCount(at indexPath: IndexPath, assetsCount: Int) {
          
          guard !indexPath.isEmpty, let cell = self.tableView.cellForRow(at: indexPath) as? ContentTypeTableViewCell else { return }
          
          self.configure(cell, at: indexPath)
     }
     
     private func updateCellInfoCount(by type: MediaContentType, contentType: PhotoMediaType, assetsCount: Int) {
          
          if Thread.isMainThread {
               self.updateAssetsFieldCount(at: contentType.deepCleanIndexPath, assetsCount: assetsCount)
          } else {
               U.UI {
                    self.updateAssetsFieldCount(at: contentType.deepCleanIndexPath, assetsCount: assetsCount)
               }
          }
     }
     
     private func getAssetsCount(for groups: [PhassetGroup]) -> Int {
          return groups.map({$0.assets}).map({$0}).count
     }
     
     private func getContactsCount(for groups: [ContactsGroup]) -> Int {
          return groups.map({$0.contacts}).map({$0}).count
     }
     
     private func getPhassetTotalCount(for contentType: PhotoMediaType) -> Int {

          switch contentType {
               case .singleScreenShots, .singleLargeVideos, .singleScreenRecordings:
                    if let firstGroup = photoVideoFlowGroup[contentType] {
                         if let assets = firstGroup.first {
                              return assets.assets.count
                         }
                    } else {
                         return 0
                    }
               case .similarPhotos, .duplicatedPhotos, .similarLivePhotos, .similarVideos, .duplicatedVideos:
                    if let phassetGroup = photoVideoFlowGroup[contentType] {
                         return getAssetsCount(for: phassetGroup)
                    } else {
                         return 0
                    }
               case .emptyContacts, .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
                    if let contactsGroup = contactsFlowGroups[contentType] {
                         return getContactsCount(for: contactsGroup)
                    } else {
                         return 0
                    }
               default:
                    return 0
          }
          return 0
     }
}


extension DeepCleaningViewController: DateSelectebleViewDelegate {
     
     func didSelectStartingDate() {
          self.isStartingDateSelected = true
          performSegue(withIdentifier: C.identifiers.segue.showDatePicker, sender: self)
     }
     
     func didSelectEndingDate() {
          self.isStartingDateSelected = false
          performSegue(withIdentifier: C.identifiers.segue.showDatePicker, sender: self)
     }
}

extension DeepCleaningViewController: DeepCleanSelectableAssetsDelegate {
     
     
     func didSelect(assetsListIds: [String], mediaType: PhotoMediaType) {
          
          if let cell = self.tableView.cellForRow(at: mediaType.deepCleanIndexPath) as? ContentTypeTableViewCell {
               let isSelected = !assetsListIds.isEmpty
               self.handleSelectedAssetsForRowMediatype[mediaType] = isSelected
               self.selectedAssetsCollectionID[mediaType] = assetsListIds
               
               U.UI {
                    cell.setupCellSelected(at: mediaType.deepCleanIndexPath, isSelected: isSelected)
					self.checkCleaningButtonState()
               }
          }
     }
}

//      MARK: - updating progress notification roating -
extension DeepCleaningViewController {
     
     @objc func flowRoatingHandleNotification(_ notification: Notification) {
          
          switch notification.name {
               case .deepCleanSimilarPhotoPhassetScan:
                    self.recieveNotification(by: .similarPhoto,
                                             info: notification.userInfo)
               case .deepCleanDuplicatedPhotoPhassetScan:
                    self.recieveNotification(by: .duplicatePhoto,
                                             info: notification.userInfo)
               case .deepCleanScreenShotsPhassetScan:
                    self.recieveNotification(by: .screenshots,
                                             info: notification.userInfo)
               case .deepCleanSimilarLivePhotosPhaassetScan:
                    self.recieveNotification(by: .similarLivePhoto,
                                             info: notification.userInfo)
               case .deepCleanLargeVideoPhassetScan:
                    self.recieveNotification(by: .largeVideo,
                                             info: notification.userInfo)
               case .deepCleanDuplicateVideoPhassetScan:
                    self.recieveNotification(by: .duplicateVideo,
                                             info: notification.userInfo)
               case .deepCleanSimilarVideoPhassetScan:
                    self.recieveNotification(by: .similarVideo,
                                             info: notification.userInfo)
               case .deepCleanScreenRecordingsPhassetScan:
                    self.recieveNotification(by: .screenRecordings,
                                             info: notification.userInfo)
               case .deepCleanEmptyContactsScan:
                    self.recieveNotification(by: .emptyContacts,
                                             info: notification.userInfo)
               case .deepCleanDuplicatedContactsScan:
                    self.recieveNotification(by: .duplicateContacts,
                                             info: notification.userInfo)
               case .deepCleanDuplicatedPhoneNumbersScan:
                    self.recieveNotification(by: .duplicatedPhoneNumbers,
                                             info: notification.userInfo)
               case .deepCleanDupLicatedMailsScan:
                    self.recieveNotification(by: .duplicatedEmails,
                                             info: notification.userInfo)
               default:
                    return
          }
     }
     
     private func recieveNotification(by type: DeepCleanNotificationType, info: [AnyHashable: Any]?) {
     
          guard let userInfo = info,
                let totalProcessingAssetsCount = userInfo[type.dictionaryCountName] as? Int,
                let index = userInfo[type.dictionaryIndexName] as? Int else { return }
          sleep(UInt32(0.1))
          handleTotalFilesChecked(by: type, files: index)
 
          calculateProgressPercentage(total: totalProcessingAssetsCount, current: index) { title, progress in
               if Thread.isMainThread {
                    self.progressUpdate(type, progress: progress, title: title)
               } else {
					U.delay(0.1) {
						 self.progressUpdate(type, progress: progress, title: title)
					}
               }
          }
     }
     
     private func handleTotalFilesChecked(by type: DeepCleanNotificationType, files count: Int) {

          debugPrint("-!!!>>>> \(type.mediaTypeRawValue)")
     
//          self.totalDeepCleanFilesCountIn[type.mediaTypeRawValue] =  count
          switch type {
               case .similarPhoto:
                    self.totalDeepCleanFilesCountIn[0] = count
               case .duplicatePhoto:
                    self.totalDeepCleanFilesCountIn[1] = count
               case .screenshots:
                    self.totalDeepCleanFilesCountIn[2] = count
               case .similarLivePhoto:
                    self.totalDeepCleanFilesCountIn[3] = count
               case .largeVideo:
                    self.totalDeepCleanFilesCountIn[4] = count
               case .duplicateVideo:
                    self.totalDeepCleanFilesCountIn[5] = count
               case .similarVideo:
                    self.totalDeepCleanFilesCountIn[6] = count
               case .screenRecordings:
                    self.totalDeepCleanFilesCountIn[7] = count
               case .emptyContacts:
                    self.totalDeepCleanFilesCountIn[8] = count
               case .duplicateContacts:
                    self.totalDeepCleanFilesCountIn[9] = count
               case .duplicatedPhoneNumbers:
                    self.totalDeepCleanFilesCountIn[10] = count
               case .duplicatedEmails:
                    self.totalDeepCleanFilesCountIn[11] = count
          }
     }
     
     private func updateTotalFilesTitleChecked(_ totalFiles: Int) {
                    
          let totalVideoProcessing = (totalDeepCleanFilesCountIn[5] + totalDeepCleanFilesCountIn[6]) / 2
          let totalPhotoProcessing = (totalDeepCleanFilesCountIn[0] + totalDeepCleanFilesCountIn[1]) / 2
          
          totalFilesChecked = (totalPhotoProcessing + totalVideoProcessing)
   
          if self.totalFilesOnDevice == 0 {
               totalPercentageCalculated = 0
          } else {
               totalPercentageCalculated = self.totalDeepCleanProgress.sum() / 12
          }
          
          if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DeepCleanInfoTableViewCell {
               
               if totalPercentageCalculated == 100 {
                    let total = (totalPartitinAssetsCount[.photo] ?? 0) + (totalPartitinAssetsCount[.video] ?? 0)
                    totalFilesChecked = total
                    cell.setProgress(files: total)
                    P.showIndicator(in: self)
               } else {
                    cell.setProgress(files: totalFilesChecked)
               }
               cell.setRoundedProgress(value: totalPercentageCalculated.rounded())
          }
     }
     
     private func progressUpdate(_ notificationType: DeepCleanNotificationType, progress: CGFloat, title: String) {
          
          let indexPath = notificationType.mediaTypeRawValue.deepCleanIndexPath
          self.currentProgressForRawMediatype[notificationType.mediaTypeRawValue] = progress
  
          switch notificationType {
               case .similarPhoto:
                    self.totalDeepCleanProgress[0] = progress
               case .duplicatePhoto:
                    self.totalDeepCleanProgress[1] = progress
               case .screenshots:
                    self.totalDeepCleanProgress[2] = progress
               case .similarLivePhoto:
                    self.totalDeepCleanProgress[3] = progress
               case .largeVideo:
                    self.totalDeepCleanProgress[4] = progress
               case .duplicateVideo:
                    self.totalDeepCleanProgress[5] = progress
               case .similarVideo:
                    self.totalDeepCleanProgress[6] = progress
               case .screenRecordings:
                    self.totalDeepCleanProgress[7] = progress
               case .emptyContacts:
                    self.totalDeepCleanProgress[8] = progress
               case .duplicateContacts:
                    self.totalDeepCleanProgress[9] = progress
               case .duplicatedPhoneNumbers:
                    self.totalDeepCleanProgress[10] = progress
               case .duplicatedEmails:
                    self.totalDeepCleanProgress[11] = progress
          }
          
          guard !indexPath.isEmpty else { return }
          
          guard let cell = tableView.cellForRow(at: indexPath) as? ContentTypeTableViewCell else { return }

          self.configure(cell, at: indexPath, currentProgress: progress)
          updateTotalFilesTitleChecked(0)
     }
     
     private func calculateProgressPercentage(total: Int, current: Int, completion: @escaping (String, CGFloat) -> Void) {
          
          let percentLabelFormat: String = "%.f %%"
          let totalPercent = CGFloat(Double(current) / Double(total)) * 100
          let stingFormat = String(format: percentLabelFormat, totalPercent)
          completion(stingFormat, totalPercent)
     }
}

//      MARK: - show cleaning view controllers -
extension DeepCleaningViewController {
     
     private func selectCleaningMedia(at indexPath: IndexPath) {
          
          let mediaContentInRow: PhotoMediaType = .getDeepCleanMediaContentType(from: indexPath)
          self.showCleaningListViewControler(by: mediaContentInRow)
     }
     
     private func showCleaningListViewControler(by type: PhotoMediaType) {
          
//
//          #warning("refactor!!>")
//          switch type {
//               case .similarPhotos:
//                    if !similarPhoto.isEmpty {
//                         self.showGropedContoller(assets: type.mediaTypeName,
//                                                  grouped: similarPhoto,
//                                                  photoContent: type)
//                    }
//               case .duplicatedPhotos:
//                    if !duplicatedPhoto.isEmpty {
//                         self.showGropedContoller(assets: type.mediaTypeName,
//                                                  grouped: duplicatedPhoto,
//                                                  photoContent: type)
//                    }
//               case .singleScreenShots:
//                    if !screenShots.isEmpty {
//                         self.showAssetViewController(assets: type.mediaTypeName,
//                                                      collection: screenShots,
//                                                      photoContent: type)
//                    }
//               case .similarLivePhotos:
//                    if !similarLivePhotos.isEmpty {
//                         self.showGropedContoller(assets: type.mediaTypeName,
//                                                  grouped: similarLivePhotos,
//                                                  photoContent: type)
//                    }
//               case .singleLargeVideos:
//                    if !largeVideos.isEmpty {
//                         self.showAssetViewController(assets: type.mediaTypeName,
//                                                      collection: largeVideos,
//                                                      photoContent: type)
//                    }
//               case .duplicatedVideos:
//                    if !duplicatedVideo.isEmpty {
//                         self.showGropedContoller(assets: type.mediaTypeName,
//                                                  grouped: duplicatedVideo,
//                                                  photoContent: type)
//                    }
//               case .similarVideos:
//                    if !similarVideo.isEmpty {
//                         self.showGropedContoller(assets: type.mediaTypeName,
//                                                  grouped: similarVideo,
//                                                  photoContent: type)
//                    }
//               case .singleScreenRecordings:
//                    if !screenRecordings.isEmpty {
//                         self.showAssetViewController(assets: type.mediaTypeName,
//                                                      collection: screenRecordings,
//                                                      photoContent: type)
//                    }
//               default:
//                    return
//          }
     }
     
     private func showGropedContoller(assets title: String, grouped collection: [PhassetGroup], photoContent type: PhotoMediaType) {
          let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
          let viewController  = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.groupedList) as! GroupedAssetListViewController
          viewController.title = title
          viewController.isDeepCleaningSelectableFlow = true
          viewController.assetGroups = collection
          viewController.selectedAssetsDelegate = self
          viewController.mediaType = type
          
          if let selectedStrings = selectedAssetsCollectionID[type] {
               viewController.handlePreviousSelected(selectedAssetsIDs: selectedStrings, assetGroupCollection: collection)
          }
          self.navigationController?.pushViewController(viewController, animated: true)
     }
     
     private func showAssetViewController(assets title: String, collection: [PHAsset], photoContent type: PhotoMediaType) {
          let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
          let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.assetsList) as! SimpleAssetsListViewController
          viewController.title = title
          viewController.isDeepCleaningSelectableFlow = true
          viewController.assetCollection = collection
          viewController.selectedAssetsDelegate = self
          viewController.mediaType = type
          
          if let selectedStrings = selectedAssetsCollectionID[type] {
               viewController.handleAssetsPreviousSelected(selectedAssetsIDs: selectedStrings, assetCollection: collection)
          }
          
          self.navigationController?.pushViewController(viewController, animated: true)
     }
}

extension DeepCleaningViewController: UITableViewDelegate, UITableViewDataSource {
     
     private func setupTableView() {
          
          tableView.delegate = self
          tableView.dataSource = self
          tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
          tableView.register(UINib(nibName: C.identifiers.xibs.cleanInfoCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.cleanInfoCell)
          tableView.separatorStyle = .none
          tableView.contentInset.top = 30
          tableView.contentInset.bottom = 40
     }
     
     private func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath, currentProgress: CGFloat? = nil) {
          
          let photoMediaType: PhotoMediaType = .getDeepCleanMediaContentType(from: indexPath)
          let contentType: MediaContentType = .getDeepCleanSectionType(indexPath: indexPath)
          
          let isSelected = self.handleSelectedAssetsForRowMediatype[photoMediaType] ?? false
          cell.setupCellSelected(at: indexPath, isSelected: isSelected)
          
          var phassetMediaTupeCount: Int {
               return getPhassetTotalCount(for: photoMediaType)
          }
          
          var progress: CGFloat {
               if let currentProgress = currentProgress {
                    return currentProgress
               } else if let currentProgress = self.currentProgressForRawMediatype[photoMediaType] {
                    return currentProgress
               } else {
                    return 0
               }
          }

          cell.cellConfig(contentType: contentType,
                          photoMediaType: photoMediaType,
                          indexPath: indexPath,
                          phasetCount: phassetMediaTupeCount,
                          presentingType: .deepCleen,
                          progress: self.currentProgressForRawMediatype[photoMediaType] ?? 0,
                          isProcessingComplete: self.doneProcessingDeepCleanForMedia[photoMediaType] ?? false)
     }
     
     private func configureInfoCell(_ cell: DeepCleanInfoTableViewCell, at indexPath: IndexPath) {
          
          cell.setProgress(files: self.totalFilesChecked)
          cell.setRoundedProgress(value: totalPercentageCalculated)
     }
     
     func numberOfSections(in tableView: UITableView) -> Int {
          return 4
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          let mediaTypeSection: MediaContentType = .getMediaContentType(at: section)
          
          switch section {
               case 0:
                    return 1
               case 1, 2, 3:
                    return mediaTypeSection.deepCleanNumbersOfRows
               default:
                    return 0
          }
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
          switch indexPath.section {
               case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.cleanInfoCell, for: indexPath) as! DeepCleanInfoTableViewCell
                    configureInfoCell(cell, at: indexPath)
                    return cell
               default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contentTypeCell, for: indexPath) as! ContentTypeTableViewCell
                    configure(cell, at: indexPath)
                    return cell
          }
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          
          guard indexPath.section != 0, !processing else { return}
          
          self.selectCleaningMedia(at: indexPath)
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return indexPath.section == 0 ? 151 : 100
     }
     
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          
          let view = UIView(frame: CGRect(x: 0, y: 0, width: U.screenWidth, height: 30))
          let sectionTitleTextLabel = UILabel()
          
          sectionTitleTextLabel.font = UIFont(font: FontManager.robotoBlack, size: 16.0)
          sectionTitleTextLabel.textColor = theme.titleTextColor
          
          view.addSubview(sectionTitleTextLabel)
          sectionTitleTextLabel.translatesAutoresizingMaskIntoConstraints = false
          
          sectionTitleTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
          sectionTitleTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
          sectionTitleTextLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
          
          view.layoutIfNeeded()
          
          switch section {
               case 0:
                    view.frame = CGRect(x: 0, y: 0, width: U.screenWidth, height: 0)
               case 1:
                    sectionTitleTextLabel.text = "PHOTOS_NAV_TITLE".localized()
               case 2:
                    sectionTitleTextLabel.text = "VIDEOS_NAV_TITLE".localized()
               default:
                    sectionTitleTextLabel.text = "CONTACTS_NAV_TITLE".localized()
          }
          return view
     }
}

extension DeepCleaningViewController {
     
     private func setupUI() {
     
          dateSelectContainerHeigntConstraint.constant = 60
     }
     
     private func setupDateInterval() {
          
          dateSelectPickerView.setupDisplaysDate(startingDate: self.startingDate, endingDate: self.endingDate)
     }
     
     private func setupObserversAndDelegate() {
          
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanSimilarPhotoPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDuplicatedPhotoPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanScreenShotsPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanSimilarLivePhotosPhaassetScan, object: nil)
          
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanLargeVideoPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDuplicateVideoPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanSimilarVideoPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanScreenRecordingsPhassetScan, object: nil)
          
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanEmptyContactsScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDuplicatedContactsScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDuplicatedPhoneNumbersScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDupLicatedMailsScan, object: nil)
          
          dateSelectPickerView.delegate = self
          bottomButtonView.delegate = self
          selectableAssetsDelegate = self
          navigationBar.delegate = self
     }
     
     private func setupNavigation() {
          
          self.navigationController?.navigationBar.isHidden = true
          
          navigationBar.setIsDropShadow = false
          navigationBar.setupNavigation(title: "DEEP_CLEEN".localized(),
                                        leftBarButtonImage: I.systemItems.navigationBarItems.back,
                                        rightBarButtonImage: I.systemItems.navigationBarItems.magic,
                                        mediaType: .none,
                                        leftButtonTitle: nil,
                                        rightButtonTitle: nil)
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
               dateSelectorController.setPicker(self.isStartingDateSelected ? self.startingDate : self.endingDate)
               
               dateSelectorController.selectedDateCompletion = { selectedDate in
                    self.isStartingDateSelected ? (self.startingDate = selectedDate) : (self.endingDate = selectedDate)
                    self.dateSelectPickerView.setupDisplaysDate(startingDate: self.startingDate, endingDate: self.endingDate)
               }
          }
     }
     
     private func setProcessingActionButton(_ state: DeepCleaningState) {
		  
		  deepCleaningState = state
		  U.UI {
			   switch state {
					case .redyForStartingCleaning:
						 self.bottomButtonView.setButtonProcess(false)
						 self.bottomButtonView.setImage(I.systemItems.defaultItems.deepClean, with: CGSize(width: 24, height: 22))
						 self.bottomButtonView.title("start cleaning".uppercased())
					case .willStartCleaning:
						 self.bottomButtonView.setButtonProcess(true)
					case .didCleaning:
						 self.bottomButtonView.setImage(I.systemItems.defaultItems.refreshFull, with: CGSize(width: 24, height: 22))
						 self.bottomButtonView.title("stop".uppercased())
						 self.bottomButtonView.setButtonProcess(false)
					case .willAvailibleDelete:
						 self.bottomButtonView.title("delete".uppercased())
						 self.bottomButtonView.setButtonProcess(false)
						 self.bottomButtonView.setImage(I.systemItems.defaultItems.delete, with: CGSize(width: 18, height: 24))
			   }
		  }
     }
	 
	 private func checkCleaningButtonState() {
		  
		  if deepCleaningState == .willAvailibleDelete {
			   handleButtonStateActive()
		  } else {
			   
		  }
	 }
	 
	 private func handleButtonStateActive() {
		  
		  let selectedAssetsCount = selectedAssetsCollectionID.values.compactMap({$0}).flatMap({$0}).count
		  bottomContainerHeightConstraint.constant = selectedAssetsCount > 0 ? (bottomMenuHeight + U.bottomSafeAreaHeight - 5) : 0
		  self.tableView.contentInset.bottom = selectedAssetsCount > 0 ? 10 : 5
		  
		  U.animate(0.5) {
			   self.tableView.layoutIfNeeded()
			   self.view.layoutIfNeeded()
		  }
	 }
}

extension DeepCleaningViewController: BottomActionButtonDelegate {
     
     func didTapActionButton() {
          
		  if deepCleaningState == .redyForStartingCleaning {
			   setProcessingActionButton(.willStartCleaning)
			   prepareStartDeepCleanProcessing()
		  } else  if deepCleaningState == .didCleaning {
			   self.showStopDeepCleanScanAlert()
			   
		  } else if deepCleaningState == .willAvailibleDelete {
			   debugPrint("start delete")
		  }
     }
}

extension DeepCleaningViewController: Themeble {
     
     func updateColors() {
          
          self.view.backgroundColor = theme.backgroundColor
          tableView.backgroundColor = .clear
          bottomButtonView.backgroundColor = .clear
          bottomButtonView.buttonColor = theme.customRedColor
          bottomButtonView.buttonTintColor = theme.activeTitleTextColor
          bottomButtonView.buttonTitleColor = theme.activeTitleTextColor
          bottomButtonView.activityIndicatorColor = theme.backgroundColor
          bottomButtonView.updateColorsSettings()
     }
}

extension DeepCleaningViewController: NavigationBarDelegate {
     
     func didTapLeftBarButton(_ sender: UIButton) {
          self.navigationController?.popViewController(animated: true)
     }
     
     func didTapRightBarButton(_ sender: UIButton) {
          debugPrint("show magic")
     }
}
