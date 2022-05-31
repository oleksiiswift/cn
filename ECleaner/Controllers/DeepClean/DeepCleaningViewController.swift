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
import Contacts

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
	 
	 private var progressAlert = ProgressAlertController.shared
     
     /// protocols and delegates
     weak var selectableAssetsDelegate: DeepCleanSelectableAssetsDelegate?
	 var updateMediaStoreDelegate: UpdateMediaStoreSizeDelegate?
     
     /// properties
	 private var isDeepCleanSearchingProcessRunning: Bool = false {
		  didSet {
			   navigationBar.temporaryLockLeftButton(isDeepCleanSearchingProcessRunning)
		  }
	 }
	 
	 public var scansOptions: [PhotoMediaType]?
     private var deepCleaningState: DeepCleaningState = .willStartCleaning
	 
	 private var handleSearchingResults: Bool {
		  if let values = deepCleanModel.map({$0.objects.map({$0.value.resultsCount})}) {
			   return values.sum() > 0
		  }
		  return false
	 }

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
	 
     /// `file processing check count`
     private var totalFilesOnDevice: Int = 0
     private var totalFilesChecked: Int = 0
     private var totalPartitinAssetsCount: [AssetsGroupType: Int] = [:]
	 private var futuredCleaningSpaceUsage: Int64?
	 private var totalDeepCleanProgress = DeepCleanTotalProgress()
	 private var deepCleanModel: DeepCleanModel!
	 private var mediaStoreModel: MediaStoreInfoModel!
	 	 
     override func viewDidLoad() {
          super.viewDidLoad()
          
		  initializeDeepCleanModel()
		  initializePhotoLibrarySizeCheckerModel()
		  deepCleanManager.cancelAllOperation()
          setupUI()
          setupNavigation()
          setupTableView()
          setupDateInterval()
          updateTotalFilesTitleChecked()
          setupObservers()
		  setupDelegate()
          updateColors()
		  setProcessingActionButton(.willStartCleaning)
		  prepareStartDeepCleanProcessing()
     }
	      
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		  switch segue.identifier {
			   case C.identifiers.segue.showLowerDatePicker:
					self.setupShowDatePickerSelectorController(segue: segue, selectedType: .lowerDateSelectable)
			   case C.identifiers.segue.showUpperDatePicker:
					self.setupShowDatePickerSelectorController(segue: segue, selectedType: .upperDateSelectable)
			   default:
					break
		  }
     }
	 
	 private func initializeDeepCleanModel() {
		  
		  var objects: [PhotoMediaType : DeepCleanStateModel] = [:]
		  
		  objects[.similarPhotos] = 			DeepCleanStateModel(type: .similarPhotos)
		  objects[.duplicatedPhotos] = 			DeepCleanStateModel(type: .duplicatedPhotos)
		  objects[.singleScreenShots] = 		DeepCleanStateModel(type: .singleScreenShots)
		  objects[.similarSelfies] = 			DeepCleanStateModel(type: .similarSelfies)
		  objects[.similarLivePhotos] = 		DeepCleanStateModel(type: .similarLivePhotos)
		  objects[.singleLargeVideos] = 		DeepCleanStateModel(type: .singleLargeVideos)
		  objects[.duplicatedVideos] = 			DeepCleanStateModel(type: .duplicatedVideos)
		  objects[.similarVideos] = 			DeepCleanStateModel(type: .similarVideos)
		  objects[.singleScreenRecordings] =  	DeepCleanStateModel(type: .singleScreenRecordings)
		  objects[.emptyContacts] = 			DeepCleanStateModel(type: .emptyContacts)
		  objects[.duplicatedContacts] = 		DeepCleanStateModel(type: .duplicatedContacts)
		  objects[.duplicatedPhoneNumbers] =    DeepCleanStateModel(type: .duplicatedPhoneNumbers)
		  objects[.duplicatedEmails] = 			DeepCleanStateModel(type: .duplicatedEmails)
		  
		  self.deepCleanModel = DeepCleanModel(objects: objects)
	 }
	 
	 private func initializePhotoLibrarySizeCheckerModel() {
		  
		  var objects: [MediaContentType: MediaInfoContainerModel] = [:]
		  objects[.userPhoto] = MediaInfoContainerModel(contentType: .userPhoto)
		  objects[.userVideo] = MediaInfoContainerModel(contentType: .userVideo)
		  objects[.userContacts] = MediaInfoContainerModel(contentType: .userContacts)
		  self.mediaStoreModel = MediaStoreInfoModel(objects: objects)
	 }
}

//      MARK: deep cleaning algorithm
extension DeepCleaningViewController {
     
	 private func prepareStartDeepCleanProcessing() {
		  self.progressAlert.showSimpleProgressAlerControllerBar(of: .prepareDeepClean, from: self, delegate: nil)
		  U.delay(3) {
			   self.photoManager.getPhotoAssetsCount(from: self.lowerBoundDate, to: self.upperBoundDate) { allAssetsCount in
					self.totalFilesOnDevice = allAssetsCount
					
					self.photoManager.getPartitionalMediaAssetsCount(from: self.lowerBoundDate, to: self.upperBoundDate) { assetGroupPartitionCount in
						 self.progressAlert.closeProgressAnimatedController()
						 self.setProcessingActionButton(.didCleaning)
						 self.totalPartitinAssetsCount = assetGroupPartitionCount
						 self.futuredCleaningSpaceUsage = 0
						 self.tableView.reloadRowWithoutAnimation(at: IndexPath(row: 0, section: 0))
						 U.delay(1) {
							  self.startDeepCleanScan()
						 }
					}
			   }
		  }
	 }
	 
	 private func getTotalPhassetCount() {
		  self.photoManager.getPhotoAssetsCount(from: S.lowerBoundSavedDate, to: S.upperBoundSavedDate) { allPhassets in
			   self.totalFilesOnDevice = allPhassets
		  }
	 }

	 private func showStopDeepCleanScanAlert() {
		  
		  A.showStopDeepCleanSearchProcess {
			   self.stopAllCleaningOperation()
		  }
	 }
	 
	 private func stopAllCleaningOperation() {
		  
		  self.removeObservers()
		  deepCleanManager.cancelAllOperation()
		  deepCleaningState = .canclel
		  P.showIndicator()
		  U.delay(0.5) {
			   self.mediaStoreModel.resetAllValues()
			   self.resetProgress()
			   self.resetAllValues()
			   self.tableView.reloadData()
			   U.delay(1) {
					P.hideIndicator()
					self.showBottomButtonBar()
					U.delay(2) {
						 self.setupObservers()
						 U.delay(1) {
							  self.setProcessingActionButton(.redyForStartingCleaning)
						 }
					}
			   }
		  }
	 }
	 
	 private func resetProgress() {
		  
		  var updatableIndexPath =  getAllIndexPathsInSection(section: 1)
		  let secondSectionPath = getAllIndexPathsInSection(section: 2)
		  let thirdSectionPath = getAllIndexPathsInSection(section: 3)
		  
		  updatableIndexPath.append(contentsOf: secondSectionPath)
		  updatableIndexPath.append(contentsOf: thirdSectionPath)
		  
		  updatableIndexPath.forEach { indexPath in
			   if let cell = tableView.cellForRow(at: indexPath) as? ContentTypeTableViewCell {
					cell.resetProgress()
			   }
		  }
	 }
	 
	 func getAllIndexPathsInSection(section : Int) -> [IndexPath] {
		 let count = tableView.numberOfRows(inSection: section);
		 return (0..<count).map { IndexPath(row: $0, section: section) }
	 }
	 
	 private func resetAllValues() {
		  DispatchQueue.main.async {
			   self.totalFilesOnDevice = 0
			   self.totalFilesChecked = 0
			   self.totalPartitinAssetsCount = [:]
			   self.totalDeepCleanProgress.progressForMediaType = [:]
			   self.deepCleanModel.objects = [:]
			   self.initializeDeepCleanModel()
		  }
	 }
	 
     private func startDeepCleanScan() {
          
          guard let options = scansOptions else { return }
		  
		  let timer = BenchTimer()
	 
		  isDeepCleanSearchingProcessRunning = !isDeepCleanSearchingProcessRunning
		  U.application.isIdleTimerDisabled = true
		  
          deepCleanManager.startDeepCleaningFetch(options, startingFetchingDate: lowerBoundDate, endingFetchingDate: upperBoundDate) { mediaType in
               self.scansOptions = mediaType
          } screenShots: { assets in
                    /// `processing single screenshots`
					debugPrint("incoming completion for # screesn shots")
               let photoMediaType: PhotoMediaType = .singleScreenShots
			   let screenShotGroup = PhassetGroup(name: photoMediaType.rawValue, assets: assets, creationDate: assets.first?.creationDate)
               self.updateAssetsProcessingOfType(group: [screenShotGroup], mediaType: .userPhoto, contentType: photoMediaType)
          } similarPhoto: { assetsGroup in
                    /// `processing similar assets group`
               let photoMediaType: PhotoMediaType = .similarPhotos
               self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userPhoto, contentType: photoMediaType)
			   debugPrint("incoming completion for # similar photo")
          } duplicatedPhoto: { assetsGroup in
                    /// `processing duplicated assets group`
               let photoMediaType: PhotoMediaType = .duplicatedPhotos
               self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userPhoto, contentType: photoMediaType)
			   debugPrint("incoming completion for # dupliated photo")
		  } similarSelfiesPhoto: { assetsGroup in
					/// `processing similar selfies assets group`
			   let photoMediaType: PhotoMediaType = .similarSelfies
			   self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userPhoto, contentType: photoMediaType)
			   debugPrint("incoming completion for # similar selfies")
		  } similarLivePhotos: { assetsGroup in
					/// `processing similar live video group`
			   let photoMediaType: PhotoMediaType = .similarLivePhotos
			   self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userPhoto, contentType: photoMediaType)
			   debugPrint("incoming completion for # similar live photo")
		  } largeVideo: { assets in
                    /// `processing large video group`
               let photoMediaType: PhotoMediaType = .singleLargeVideos
			   let largeVideoGroup = PhassetGroup(name: photoMediaType.rawValue, assets: assets, creationDate: assets.first?.creationDate)
               self.updateAssetsProcessingOfType(group: [largeVideoGroup], mediaType: .userVideo  , contentType: photoMediaType)
			   debugPrint("incoming completion for # large video")
          } similarVideo: { assetsGroup in
                    /// `processing similar videos`
               let photoMediaType: PhotoMediaType = .similarVideos
               self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userVideo, contentType: photoMediaType)
			   debugPrint("incoming completion for # similar video")
          } duplicatedVideo: { assetsGroup in
                    /// `duplicated video`
               let photoMediaType: PhotoMediaType = .duplicatedVideos
               self.updateAssetsProcessingOfType(group: assetsGroup, mediaType: .userVideo, contentType: photoMediaType)
			   debugPrint("incoming completion for # duplicated video")
          } screenRecordings: { assets in
                    /// `screen recording`
               let photoMediaType: PhotoMediaType = .singleScreenRecordings
			   let screenRecordings = PhassetGroup(name: photoMediaType.rawValue, assets: assets, creationDate: assets.first?.creationDate)
               self.updateAssetsProcessingOfType(group: [screenRecordings], mediaType: .userVideo  , contentType: photoMediaType)
			   debugPrint("incoming completion for # screen recordings")
          } emptyContacts: { contactsGroup in
                    /// `empty contacts`
               let contentType: PhotoMediaType = .emptyContacts
               self.updateContactsProcessing(group: contactsGroup, contentType: contentType)
			   debugPrint("incoming completion for # empty contacts")
          } duplicatedContats: { contactsGroup in
                    /// `duplicated contacts`
               let contentType:  PhotoMediaType = .duplicatedContacts
               self.updateContactsProcessing(group: contactsGroup, contentType: contentType)
			   debugPrint("incoming completion for # duplicated contacts")
          } duplicatedPhoneNumbers: { contactsGroup in
                    /// `duplicated phone numbers contacts`
               let contentType:  PhotoMediaType = .duplicatedPhoneNumbers
               self.updateContactsProcessing(group: contactsGroup, contentType: contentType)
			   debugPrint("incoming completion for # duplicated duplicated phone numbers")
          } duplicatedEmails: { contactsGroup in
                    /// `dublicated email contacts`
               let contentType:  PhotoMediaType = .duplicatedEmails
               self.updateContactsProcessing(group: contactsGroup, contentType: contentType)
			   debugPrint("incoming completion for # duplicated emails")
          } completionHandler: { isCancelled in
			   self.isDeepCleanSearchingProcessRunning = !self.isDeepCleanSearchingProcessRunning
			   U.UI {
					if isCancelled {
						 self.removeObservers()
						 U.delay(1) {
							  self.cleanAndResetAllValues()
						 }
					} else {
						 self.setProcessingActionButton(.willAvailibleDelete)
						 self.handleButtonStateActive()
						 U.application.isIdleTimerDisabled = true
						 self.mediaStoreModel.saveValues()
					}
			   }
			   debugPrint("!!!! deep clean complete ->>> \(timer.stop())")
			   self.photoManager.clearRequestsAfterDeepCleanProcessing()
		  } emptyResultsHandler: {
			   U.delay(1) {
					ErrorHandler.shared.showEmptySearchResultsFor(.deepCleanResultsIsEmpty) {
						 self.navigationController?.popViewController(animated: true)
					}
			   }
			   self.photoManager.clearRequestsAfterDeepCleanProcessing()
			   debugPrint("!!!! deep clean complete ->>> \(timer.stop())")
		  }
     }
	      
	 /// `for photos and video`
	 private func updateAssetsProcessingOfType(group: [PhassetGroup], mediaType: MediaContentType, contentType: PhotoMediaType) {
		  
		  guard deepCleaningState != .canclel else { return }
		  DispatchQueue.main.async {
			   self.deepCleanModel.objects[contentType]?.deepCleanProgress = 100.0
			   self.deepCleanModel.objects[contentType]?.mediaFlowGroup = group
			   self.totalDeepCleanProgress.progressForMediaType[contentType] = 100.0
			   U.delay(0.5) {
					self.deepCleanModel.objects[contentType]?.checkForCleanState()
					self.updateCellInfoCount(by: mediaType, contentType: contentType)
					self.updateTotalFilesTitleChecked()
					if !group.isEmpty {
						 Vibration.success.vibrate()
					}
			   }
		  }
	 }
     
	 private func updateContactsProcessing(group: [ContactsGroup], contentType: PhotoMediaType) {
		  
		  guard deepCleaningState != .canclel else { return }
		  
		  self.deepCleanModel.objects[contentType]?.deepCleanProgress = 100.0
		  self.deepCleanModel.objects[contentType]?.contactsFlowGroup = group
		  self.totalDeepCleanProgress.progressForMediaType[contentType] = 100.0
		  U.delay(0.5) {
			   self.deepCleanModel.objects[contentType]?.checkForCleanState()
			   self.updateCellInfoCount(by: .userContacts, contentType: contentType)
			   self.updateTotalFilesTitleChecked()
			   if !group.isEmpty {
					Vibration.success.vibrate()
			   }
		  }
	 }
     
	 private func updateAssetsFieldCount(at indexPath: IndexPath) {
          
          guard !indexPath.isEmpty, let cell = self.tableView.cellForRow(at: indexPath) as? ContentTypeTableViewCell else { return }
		  U.UI {
			   self.configure(cell, at: indexPath)
		  }
     }
     
	 private func updateCellInfoCount(by type: MediaContentType, contentType: PhotoMediaType) {
          
          if Thread.isMainThread {
               self.updateAssetsFieldCount(at: contentType.deepCleanIndexPath)
          } else {
			   DispatchQueue.main.async {
                    self.updateAssetsFieldCount(at: contentType.deepCleanIndexPath)
               }
          }
     }
}

extension DeepCleaningViewController: DateSelectebleViewDelegate {
	 
	 func didSelectStartingDate() {
		  if isDeepCleanSearchingProcessRunning {
			   showStopDeepCleanScanAlert()
		  } else {
			   performSegue(withIdentifier: C.identifiers.segue.showLowerDatePicker, sender: self)
		  }
	 }
	 
	 func didSelectEndingDate() {
		  if isDeepCleanSearchingProcessRunning {
			   showStopDeepCleanScanAlert()
		  } else {
			   performSegue(withIdentifier: C.identifiers.segue.showUpperDatePicker, sender: self)
		  }
	 }
}

extension DeepCleaningViewController: DeepCleanSelectableAssetsDelegate {
	 
	 func didSelect(assetsListIds: [String], contentType: PhotoMediaType, updatableGroup: [PhassetGroup], updatableAssets: [PHAsset], updatableContactsGroup: [ContactsGroup]) {
		  
		  var enabled: Bool
		  let isSelected = !assetsListIds.isEmpty
		  let topIndexPath = IndexPath(row: 0, section: 0)
		  
		  switch contentType {
			   case .singleScreenShots, .singleLargeVideos, .singleScreenRecordings:
					self.deepCleanModel.objects[contentType]!.mediaFlowGroup.first?.assets = updatableAssets
					enabled = !updatableAssets.isEmpty
			   case .similarPhotos, .duplicatedPhotos, .similarSelfies, .similarLivePhotos, .similarVideos, .duplicatedVideos:
					self.deepCleanModel.objects[contentType]!.mediaFlowGroup = updatableGroup
					enabled = !updatableGroup.isEmpty
			   case .emptyContacts, .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
					self.deepCleanModel.objects[contentType]!.contactsFlowGroup = updatableContactsGroup
					enabled = !updatableContactsGroup.isEmpty
			   default:
					return
		  }
		  
		  let state: ProcessingProgressOperationState = isSelected ? .selected : enabled ? .complete : .empty
		  
		  self.deepCleanModel.objects[contentType]!.selectedAssetsCollectionID = assetsListIds
		  self.deepCleanModel.objects[contentType]!.cleanState = state
		  
		  let allSelectedAssetsIDS = Array(Set(self.deepCleanModel.objects.compactMap({$0.value}).flatMap({$0.selectedAssetsCollectionID})))
		  if !allSelectedAssetsIDS.isEmpty {
			   
			   switch contentType {
					case .singleScreenShots, .singleLargeVideos, .singleScreenRecordings, .similarPhotos, .duplicatedPhotos, .similarLivePhotos, .similarVideos, .duplicatedVideos, .similarSelfies:
						 self.checkCleaningButtonState()
					case .emptyContacts, .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
						 self.checkCleaningButtonState()
					default:
						 return
			   }
		  } else {
			   self.futuredCleaningSpaceUsage = 0
			   self.tableView.reloadRowWithoutAnimation(at: topIndexPath)
			   self.checkCleaningButtonState()
		  }
		  
		  U.UI {
			   self.tableView.reloadRowWithoutAnimation(at: contentType.deepCleanIndexPath)
		  }
	 }
}

//      MARK: - updating progress notification roating -
extension DeepCleaningViewController {
     
	 @objc func flowRoatingHandleNotification(_ notification: Notification) {
		  
		  guard deepCleaningState == .didCleaning else { return }
		  
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
			   case .deepCleanSimilarSelfiesPhassetScan:
					self.recieveNotification(by: .similarSelfiePhotos,
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
				let status = userInfo[type.dictionaryProcessingState] as? ProcessingProgressOperationState,
                let totalProcessingAssetsCount = userInfo[type.dictionaryCountName] as? Int,
                let index = userInfo[type.dictionaryIndexName] as? Int else { return }
		  self.calculateProgressPercentage(total: totalProcessingAssetsCount, current: index) { progress in
			   U.UI {
					self.deepCleanProgressStatusUpdate(type, status: status, currentProgress: progress)					
			   }
		  }
     }
	 
	 @objc private func recievFilesSizeNotification(_ notification: Notification) {
		  
		  guard deepCleaningState == .didCleaning else { return }
		  switch notification.name {
			   case .deepCleanPhotoFilesScan:
					self.recieveSizeNotification(by: .photoFilesSize, info: notification.userInfo)
			   case .deepCleanVideoFilesScan:
					self.recieveSizeNotification(by: .videoFilesSize, info: notification.userInfo)
			   default:
					return
		  }
	 }
		  
	 private func recieveSizeNotification(by type: DeepCleanNotificationType, info: [AnyHashable: Any]?) {
		  
		  guard let userInfo = info,
				let _ = userInfo[type.dictionaryCountName] as? Int,
				let currentProcessingIndex = userInfo[type.dictionaryIndexName] as? Int,
				let processingValue = userInfo[type.dictionaryProcessingSizeValue] as? Int64 else { return }
		  
		  self.mediaStoreModel.objects[type.contentTypeRawValue]?.processingCurrentIndex = currentProcessingIndex
		  self.mediaStoreModel.objects[type.contentTypeRawValue]?.sizeProcessingCount += processingValue
		  
		  U.UI {
			   if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DeepCleanInfoTableViewCell {
					cell.setProgress(files: self.mediaStoreModel.totalFilesProcesingCount)
					cell.setMemmoryChecker(bytes: self.mediaStoreModel.totalPhotoLibrarySizeCount)
			   }
		  }
	 }
	 
     private func updateTotalFilesTitleChecked() {

		  totalFilesChecked = (totalFilesOnDevice / 100) * Int(self.totalDeepCleanProgress.totalProgress)
          
          if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DeepCleanInfoTableViewCell {
			   cell.setRoundedProgress(value: self.totalDeepCleanProgress.totalProgress.rounded())
          }
     }
	 
	 private func deepCleanProgressStatusUpdate(_ notificationType: DeepCleanNotificationType, status: ProcessingProgressOperationState, currentProgress: CGFloat) {
		  
		  guard deepCleaningState == .didCleaning else { return }
		  
		  let mediaType: PhotoMediaType = notificationType.mediaTypeRawValue
		  
		  self.deepCleanModel.objects[mediaType]?.cleanState = status
		  self.deepCleanModel.objects[mediaType]?.deepCleanProgress = currentProgress
		  
		  if !currentProgress.isNaN {
			   self.totalDeepCleanProgress.progressForMediaType[mediaType] = currentProgress
		  }
		  let objectIndexPath = notificationType.mediaTypeRawValue.deepCleanIndexPath

		  if status == .result {
			   U.delay(1) {
					self.deepCleanModel.objects[mediaType]?.checkForCleanState()
					if let cell = self.tableView.cellForRow(at: objectIndexPath) as? ContentTypeTableViewCell {
					self.configure(cell, at: objectIndexPath, currentProgress: currentProgress)
					}
			   }
		  }
		  
		  guard !objectIndexPath.isEmpty else { return }
		  guard let cell = tableView.cellForRow(at: objectIndexPath) as? ContentTypeTableViewCell else { return }
		  self.configure(cell, at: objectIndexPath, currentProgress: currentProgress)
		  self.updateTotalFilesTitleChecked()
	 }
	 
     private func calculateProgressPercentage(total: Int, current: Int, completion: @escaping (CGFloat) -> Void) {
			   completion(CGFloat(Double(current) / Double(total)) * 100)
     }
	 
	 @objc func handleStopAnyAnalizeProcessing() {
		  self.removeObservers()
		  self.deepCleanManager.stopDeepCleanOperation()
		  self.cleanAndResetAllValues()
	 }
}

//      MARK: - show cleaning view controllers -
extension DeepCleaningViewController {
     
     private func selectCleaningMedia(at indexPath: IndexPath) {
          
          let mediaContentInRow: PhotoMediaType = .getDeepCleanMediaContentType(from: indexPath)
          self.showCleaningListViewControler(by: mediaContentInRow)
     }
     
     private func showCleaningListViewControler(by type: PhotoMediaType) {
		  
		  guard !isDeepCleanSearchingProcessRunning else { return }
		  
		  guard let model = self.deepCleanModel.objects[type] else { return }
		  
          switch type {
			   case .similarPhotos, .duplicatedPhotos, .similarSelfies, .similarLivePhotos, .duplicatedVideos, .similarVideos:
					if !model.mediaFlowGroup.isEmpty {
						 self.showGropedContoller(assets: type.rawValue, object: model, grouped: model.mediaFlowGroup, photoContent: type, media: type.contenType)
					}
			   case .singleScreenShots, .singleLargeVideos, .singleScreenRecordings:
					if !model.mediaFlowGroup.isEmpty {
						 if let assets = model.mediaFlowGroup.first?.assets {
							  self.showAssetViewController(assets: type.rawValue, object: model, collection: assets, photoContent: type, media: type.contenType)
						 }
					}
			   case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
					if !model.contactsFlowGroup.isEmpty {
						 self.showGroupedContactsViewController(object: model, contacts: model.contactsFlowGroup, group: type.contactsCleaningType, content: type)
					}
			   case .emptyContacts:
					if !model.contactsFlowGroup.isEmpty {
						 self.showContactViewController(object: model, contactGroup: model.contactsFlowGroup, contentType: .emptyContacts)
					}
               default:
                    return
          }
     }
     
	 private func showGropedContoller(assets title: String, object model: DeepCleanStateModel, grouped collection: [PhassetGroup], photoContent type: PhotoMediaType, media content: MediaContentType) {
          let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
          let viewController  = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.groupedList) as! GroupedAssetListViewController
		  viewController.previousSelectedIDs = model.selectedAssetsCollectionID
          viewController.title = title
          viewController.isDeepCleaningSelectableFlow = true
          viewController.assetGroups = collection
		  viewController.mediaType = type
		  viewController.contentType = content
		  viewController.selectedAssetsDelegate = self
          self.navigationController?.pushViewController(viewController, animated: true)
     }
     
	 private func showAssetViewController(assets title: String, object model: DeepCleanStateModel, collection: [PHAsset], photoContent type: PhotoMediaType, media content: MediaContentType) {
          let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
          let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.assetsList) as! SimpleAssetsListViewController
		  viewController.previousSelectedIDs = model.selectedAssetsCollectionID
          viewController.title = title
          viewController.isDeepCleaningSelectableFlow = true
          viewController.assetCollection = collection
          viewController.selectedAssetsDelegate = self
          viewController.mediaType = type
		  viewController.contentType = content
          self.navigationController?.pushViewController(viewController, animated: true)
     }
	 
	 private func showContactViewController(object model: DeepCleanStateModel, contacts: [CNContact] = [], contactGroup: [ContactsGroup] = [], contentType: PhotoMediaType) {
		  let storyboard = UIStoryboard(name: C.identifiers.storyboards.contacts, bundle: nil)
		  let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.contacts) as! ContactsViewController
		  viewController.handleContactsPreviousSelected(selectedContactsIDs: model.selectedAssetsCollectionID, contactsCollection: contacts, contactsGroupCollection: contactGroup.filter({!$0.contacts.isEmpty}))
		  viewController.isDeepCleaningSelectableFlow = true
		  viewController.contacts = contacts
		  viewController.contactGroup = contactGroup.filter({!$0.contacts.isEmpty})
		  viewController.mediaType = .userContacts
		  viewController.contentType = contentType
		  viewController.selectedContactsDelegate = self
		  self.navigationController?.pushViewController(viewController, animated: true)
	 }
		 
	 private func showGroupedContactsViewController(object model: DeepCleanStateModel, contacts group: [ContactsGroup], group type: ContactasCleaningType, content: PhotoMediaType) {
		  let storyboard = UIStoryboard(name: C.identifiers.storyboards.contactsGroup, bundle: nil)
		  let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.contactsGroup) as! ContactsGroupViewController
		  viewController.handleContactsPreviousSelected(selectedContactsIDs: model.selectedAssetsCollectionID, contactsGroupCollection:  group.filter({!$0.contacts.isEmpty}))
		  viewController.isDeepCleaningSelectableFlow = true
		  viewController.contactGroup = group.filter({!$0.contacts.isEmpty})
		  viewController.navigationTitle = content.mediaTypeName
		  viewController.contentType = content
		  viewController.mediaType = .userContacts
		  viewController.selectedContactsDelegate = self
		  self.navigationController?.pushViewController(viewController, animated: true)
	 }
	 
	 private func prefetchPHAssets(_ assets: [PHAsset]) {
		  U.BG {
			   self.photoManager.prefetchsForPHAssets(assets)
		  }
	 }
}

extension DeepCleaningViewController: UITableViewDelegate, UITableViewDataSource {
     
     private func setupTableView() {
          
          tableView.delegate = self
          tableView.dataSource = self
          tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
          tableView.register(UINib(nibName: C.identifiers.xibs.cleanInfoCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.cleanInfoCell)
          tableView.separatorStyle = .none
		  tableView.contentInset.top = U.UIHelper.AppDimensions.ContenTypeCells.deepCleanMediaContentTypeTopInset
		  tableView.contentInset.bottom = U.UIHelper.AppDimensions.bottomBarDefaultHeight - 20
		  UIView.performWithoutAnimation {
			   tableView.layoutIfNeeded()
			   self.view.layoutIfNeeded()
		  }
     }
     
	 private func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath, currentProgress: CGFloat? = nil) {
		  
          let photoMediaType: PhotoMediaType = .getDeepCleanMediaContentType(from: indexPath)
		  let deepModel = self.deepCleanModel.objects[photoMediaType]!
		  	 		  
          var progress: CGFloat {
               if let currentProgress = currentProgress {
                    return currentProgress
			   } else {
					return deepModel.deepCleanProgress
               }
          }

		  var isReadyForCleanding: Bool {
			   return deepModel.selectedAssetsCollectionID.count != 0
		  }
		  
		  cell.deepCleanCellConfigure(with: deepModel, mediaType: photoMediaType, indexPath: indexPath)
     }
     
     private func configureInfoCell(_ cell: DeepCleanInfoTableViewCell, at indexPath: IndexPath) {
          
		  cell.selectionStyle = .none
		  cell.isUserInteractionEnabled = false
		  cell.setProgress(files: self.mediaStoreModel.totalFilesProcesingCount)
		  cell.setMemmoryChecker(bytes: self.mediaStoreModel.totalPhotoLibrarySizeCount)
		  cell.setRoundedProgress(value: self.totalDeepCleanProgress.totalProgress)
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
          
          guard indexPath.section != 0 else { return}
          
          self.selectCleaningMedia(at: indexPath)
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		  return indexPath.section == 0 ? U.UIHelper.AppDimensions.ContenTypeCells.heightOfTopHelperCellBanner : U.UIHelper.AppDimensions.ContenTypeCells.heightOfRowOfMediaContentType
     }
     
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          
          let view = UIView(frame: CGRect(x: 0, y: 0, width: U.screenWidth, height: 30))
          let sectionTitleTextLabel = UILabel()
		  sectionTitleTextLabel.font = FontManager.deepCleanScreenFont(of: .headerTitle)
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
		  
		  dateSelectContainerHeigntConstraint.constant = U.UIHelper.AppDimensions.dateSelectableHeight
		  bottomContainerHeightConstraint.constant = U.UIHelper.AppDimensions.bottomBarDefaultHeight
     }
     
     private func setupDateInterval() {
          
		  dateSelectPickerView.setupDisplaysDate(lowerDate: self.lowerBoundDate, upperdDate: self.upperBoundDate)
     }
     
     private func setupObservers() {
          
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanSimilarPhotoPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDuplicatedPhotoPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanScreenShotsPhassetScan, object: nil)
		  U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanSimilarSelfiesPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanSimilarLivePhotosPhaassetScan, object: nil)
          
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanLargeVideoPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDuplicateVideoPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanSimilarVideoPhassetScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanScreenRecordingsPhassetScan, object: nil)
          
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanEmptyContactsScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDuplicatedContactsScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDuplicatedPhoneNumbersScan, object: nil)
          U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDupLicatedMailsScan, object: nil)
		  
		  U.notificationCenter.addObserver(self, selector: #selector(handleDeepCleanProgressNotification(_:)), name: .progressDeepCleanDidChangeProgress, object: nil)
		  
		  U.notificationCenter.addObserver(self, selector: #selector(recievFilesSizeNotification(_:)), name: .deepCleanPhotoFilesScan, object: nil)
		  U.notificationCenter.addObserver(self, selector: #selector(recievFilesSizeNotification(_:)), name: .deepCleanVideoFilesScan, object: nil)
		  U.notificationCenter.addObserver(self, selector: #selector(handleStopAnyAnalizeProcessing), name: .incomingRemoteActionRecived, object: nil)
     }
	 
	 private func removeObservers() {
	 
		  U.notificationCenter.removeObserver(self, name: .deepCleanSimilarPhotoPhassetScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanDuplicatedPhotoPhassetScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanScreenShotsPhassetScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanSimilarSelfiesPhassetScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanSimilarLivePhotosPhaassetScan, object: nil)
		  
		  U.notificationCenter.removeObserver(self, name: .deepCleanLargeVideoPhassetScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanDuplicateVideoPhassetScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanSimilarVideoPhassetScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanScreenRecordingsPhassetScan, object: nil)
		  
		  U.notificationCenter.removeObserver(self, name: .deepCleanEmptyContactsScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanDuplicatedContactsScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanDuplicatedPhoneNumbersScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanDupLicatedMailsScan, object: nil)
		  
		  U.notificationCenter.removeObserver(self, name: .progressDeepCleanDidChangeProgress, object: nil)
		  
		  U.notificationCenter.removeObserver(self, name: .deepCleanPhotoFilesScan, object: nil)
		  U.notificationCenter.removeObserver(self, name: .deepCleanVideoFilesScan, object: nil)
	 }
	 
	 private func setupDelegate() {
		  dateSelectPickerView.delegate = self
		  bottomButtonView.delegate = self
		  selectableAssetsDelegate = self
		  navigationBar.delegate = self
		  progressAlert.delegate = self
	 }
     
     private func setupNavigation() {
          
          self.navigationController?.navigationBar.isHidden = true
          
          navigationBar.setIsDropShadow = false
          navigationBar.setupNavigation(title: "DEEP_CLEEN".localized(),
                                        leftBarButtonImage: I.systemItems.navigationBarItems.back,
                                        rightBarButtonImage: nil,
										contentType: .none,
                                        leftButtonTitle: nil,
                                        rightButtonTitle: nil)
     }
     
	 private func setupShowDatePickerSelectorController(segue: UIStoryboardSegue, selectedType: PickerDateSelectType) {
          
          guard let segue = segue as? SwiftMessagesSegue else { return }
          
          segue.configure(layout: .bottomMessage)
		  segue.dimMode = .gray(interactive: true)
		  segue.interactiveHide = true
		  segue.messageView.configureNoDropShadow()
		  
		  let height = selectedType == .lowerDateSelectable ? U.UIHelper.AppDimensions.DateSelectController.datePickerContainerHeightLower :
		  U.UIHelper.AppDimensions.DateSelectController.datePickerContainerHeightUper
		  
		  segue.messageView.backgroundHeight = height
		  
		  if let dateSelectedController = segue.destination as? DateSelectorViewController {
			   dateSelectedController.dateSelectedType = selectedType
			   dateSelectedController.setPicker(selectedType.rawValue)
			   dateSelectedController.selectedDateCompletion = { selectedDate in
					switch selectedType {
						 case .lowerDateSelectable:
							  if self.lowerBoundDate != selectedDate {
								   self.lowerBoundDate = selectedDate
								   self.removeObservers()
								   self.cleanAndResetAllValues()
							  }
						 case .upperDateSelectable:
							  if self.upperBoundDate != selectedDate {
								   self.upperBoundDate = selectedDate
								   self.removeObservers()
								   self.cleanAndResetAllValues()
							  }
						 default:
							  return
					}
					self.dateSelectPickerView.setupDisplaysDate(lowerDate: self.lowerBoundDate, upperdDate: self.upperBoundDate)
			   }
		  }
     }
     
     private func setProcessingActionButton(_ state: DeepCleaningState) {
		  
		  deepCleaningState = state
		  U.UI {
			   switch state {
					case .redyForStartingCleaning:
						 self.bottomButtonView.stopAnimatingButton()
						 self.bottomButtonView.setButtonProcess(false)
						 self.bottomButtonView.setImage(I.systemItems.defaultItems.deepClean, with: CGSize(width: 24, height: 22))
						 self.bottomButtonView.title("start analyzing".uppercased())
					case .willStartCleaning:
						 self.bottomButtonView.stopAnimatingButton()
						 self.bottomButtonView.setButtonProcess(true)
					case .didCleaning:
						 self.bottomButtonView.setImage(I.systemItems.defaultItems.refreshFull, with: CGSize(width: 24, height: 22))
						 self.bottomButtonView.startAnimatingButton()
						 self.bottomButtonView.title("stop analyzing".uppercased())
						 self.bottomButtonView.setButtonProcess(false)
					case .willAvailibleDelete:
						 self.bottomButtonView.stopAnimatingButton()
						 self.bottomButtonView.title("start cleaning".uppercased())
						 self.bottomButtonView.setButtonProcess(false)
						 self.bottomButtonView.setImage(I.systemItems.defaultItems.delete, with: CGSize(width: 18, height: 24))
					case .canclel:
						 return
			   }
		  }
     }
	 
	 private func updateCleaningItemPopUpinfo() {
		  
		  let selectedAssetsCollectionsIDs = self.deepCleanModel.objects.compactMap({$0.value}).flatMap({$0.selectedAssetsCollectionID})
		  
		  guard !selectedAssetsCollectionsIDs.isEmpty else { return }
		  
		  var fullMessageBody: String = ""
		  let deepCleanSelectedTitle: String = "Deep Clean Selected Info:"
		  let diskSpaceAfterCleanMessage: String = "Calculated space after clean:"
		  let selectedPhotoVideoMessage: String = "Selected photo (video):"
		  let selectedContactsMessage: String = "Selected contacts:"
		  
		  var photosVideoID: [String] = []
		  var contactsIDS: [String] = []
		  
		  if let spaceUsage = self.futuredCleaningSpaceUsage, spaceUsage != 0 {
			   let stringSpace = U.getSpaceFromInt(spaceUsage)
			   fullMessageBody = diskSpaceAfterCleanMessage + " " + stringSpace
		  }
		   
		  for (key, value) in self.deepCleanModel.objects {
			   switch key {
					case .similarPhotos, .duplicatedPhotos, .similarSelfies, .similarLivePhotos, .duplicatedVideos, .similarVideos:
						 let collectionIDS = value.selectedAssetsCollectionID
						 photosVideoID.append(contentsOf: collectionIDS)
					case .singleScreenShots, .singleLivePhotos, .singleScreenRecordings, .singleLargeVideos:
						 let collectionIDS = value.selectedAssetsCollectionID
						 photosVideoID.append(contentsOf: collectionIDS)
					case .emptyContacts:
						 let collectionIDS = value.selectedAssetsCollectionID
						 contactsIDS.append(contentsOf: collectionIDS)
					case .duplicatedContacts, .duplicatedPhoneNumbers, .duplicatedEmails:
						 let groups = self.deepCleanModel.objects[key]!.contactsFlowGroup
						 if !groups.isEmpty {
							  let collectionIDS = value.selectedAssetsCollectionID
							  
							  for id in collectionIDS {
								   if let group = groups.first(where: {$0.groupIdentifier == id}) {
										contactsIDS.append(contentsOf: group.contacts.map({$0.identifier}))
								   }
							  }
						 }
					default:
						 print("")
			   }
		  }
		  
		  let photoVideoCount: Int = Set(photosVideoID).count
		  let contactsSelectedCount: Int = Set(contactsIDS).count
		
		  if photoVideoCount != 0 {
			   fullMessageBody = fullMessageBody + "\n" + selectedPhotoVideoMessage + " " + "\(photoVideoCount)"
		  }
		  
		  if contactsSelectedCount != 0 {
			   fullMessageBody = fullMessageBody + "\n" + selectedContactsMessage + " " + "\(contactsSelectedCount)"
		  }

		  guard !fullMessageBody.isEmpty else { return }
	 
		  U.delay(0.5) {
			   self.showInfoPopUpMessage(with: deepCleanSelectedTitle, and: fullMessageBody)
		  }
	 }
	 
	 private func showInfoPopUpMessage(with title: String, and body: String) {
		  
		  let messageView = MessageView.viewFromNib(layout: .cardView)
		  var config = SwiftMessages.Config()
		  config.presentationStyle = .top
		  config.duration = .seconds(seconds: 3)
		  messageView.configureContent(title: title, body: body, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
		  messageView.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
		  messageView.titleLabel?.textColor = theme.titleTextColor
		  messageView.bodyLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
		  messageView.bodyLabel?.textColor = theme.subTitleTextColor
		  messageView.backgroundView.backgroundColor = theme.backgroundColor
		  messageView.configureDropShadow()
		  SwiftMessages.show(config: config, view: messageView)
	 }
	 
	 private func checkCleaningButtonState() {
		  
		  guard deepCleaningState == .willAvailibleDelete else { return }
		  
//		  updateCleaningItemPopUpinfo() .. remove pop up screen
		  handleButtonStateActive()
	 }
	 
	 private func showBottomButtonBar() {
		  bottomContainerHeightConstraint.constant = U.UIHelper.AppDimensions.bottomBarDefaultHeight
		  U.animate(0.35) {
			   self.tableView.contentInset.bottom =  U.UIHelper.AppDimensions.bottomBarDefaultHeight - 30
			   self.tableView.layoutIfNeeded()
			   self.view.layoutIfNeeded()
		  }
	 }
	 
	 private func hideBottomButtonBar() {
		  bottomContainerHeightConstraint.constant = 0
		  U.animate(0.35) {
			   self.tableView.contentInset.bottom = 0
			   self.tableView.layoutIfNeeded()
			   self.view.layoutIfNeeded()
		  }
	 }
	 
	 private func handleButtonStateActive() {
		  
		  let selectedAssetsCount = deepCleanModel.objects.values.flatMap({$0.selectedAssetsCollectionID}).count
		  bottomContainerHeightConstraint.constant = selectedAssetsCount > 0 ? U.UIHelper.AppDimensions.bottomBarDefaultHeight : 0
		  self.tableView.contentInset.bottom = selectedAssetsCount > 0 ? U.UIHelper.AppDimensions.bottomBarDefaultHeight - 20 : 0
		  
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
			   self.hideBottomButtonBar()
			   U.delay(1) {
					self.showProgressAlert()
					U.delay(1) {
						 self.startDeepCleanProcessing()
					}
			   }
		  }
     }
	 	 
	 private func startDeepCleanProcessing() {
		  
		  self.deepCleanManager.startingDeepCleaningProcessing(with: self.deepCleanModel) { errorsCount in
			   U.UI {
					self.progressAlert.closeForceController()
					self.cleanAndResetAllValues()
					U.delay(1) {
						 AlertHandler.deepCleanCompleteStateHandler(for: errorsCount == 0 ? .deepCleanCompleteSuxxessfull : .deepCleanCompleteWithErrors)
					}
			   }
		  } concelCompletionHandler: {
			   U.UI {
					self.progressAlert.closeForceController()
					self.cleanAndResetAllValues()
					U.delay(1) {
						 AlertHandler.deepCleanCompleteStateHandler(for: .deepCleanCanceled)
					}
			   }
		  }
	 }
	 
	 private func cleanAndResetAllValues() {
		  P.showIndicator()
		  U.delay(2) {
			   self.resetAllValues()
			   self.resetProgress()
			   self.mediaStoreModel.resetAllValues()
			   U.delay(1) {
					P.hideIndicator()
					self.tableView.reloadData()
					self.setProcessingActionButton(.redyForStartingCleaning)
					self.showBottomButtonBar()
					self.setupObservers()
			   }
		  }
		  U.notificationCenter.post(name: .addContactsStoreObserver, object: nil)
	 }
	 
	 private func setupLastCleanDate() {
		  
		  let date = Date()
		  S.lastSmartCleanDate = date
	 }
}

extension DeepCleaningViewController: ProgressAlertControllerDelegate {
	 
	 func didTapCancelOperation() {
		  deepCleanManager.stopDeepCleanOperation()
	 }
	 
	 func didAutoCloseController() {}
	 	 
	 private func showProgressAlert() {
		  self.progressAlert.showDeepCleanProgressAlert()
	 }
	 
	 @objc func handleDeepCleanProgressNotification(_ notification: Notification) {
		  
		  guard let userInfo = notification.userInfo else { return }
		  handleDeepCleanProgress(userInfo)
	 }

	 private func handleDeepCleanProgress(_ userInfo: [AnyHashable: Any]) {
		  if let progress = userInfo[C.key.notificationDictionary.progressAlert.deepCleanProgressValue] as? CGFloat,
			 let processingTitle = userInfo[C.key.notificationDictionary.progressAlert.deepCleanProcessingChangedTitle] as? String {
			   U.UI {
					self.progressAlert.updateChangedProgress(progress, processingTitle: processingTitle)
			   }
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
		  if handleSearchingResults {
			   A.showQuiteDeepCleanResults {
					self.updateMediaStoreDelegate?.didStartUpdatingMediaSpace(photo: S.phassetPhotoFilesSizes, video: S.phassetVideoFilesSizes)
					self.navigationController?.popViewController(animated: true)
			   }
		  } else {
			   self.updateMediaStoreDelegate?.didStartUpdatingMediaSpace(photo: S.phassetPhotoFilesSizes, video: S.phassetVideoFilesSizes)
			   self.navigationController?.popViewController(animated: true)
		  }
     }
     
     func didTapRightBarButton(_ sender: UIButton) {}
}
