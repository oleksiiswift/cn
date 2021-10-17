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

protocol DeepCleanSelectableAssetsDelegate: AnyObject {
     
     func didSelect(assetsListIds: [String], mediaType: PhotoMediaType)
}

class DeepCleaningViewController: UIViewController {
     
     @IBOutlet weak var dateSelectContainerView: UIView!
     @IBOutlet weak var tableView: UITableView!
     @IBOutlet weak var bottomMenuView: UIView!
     @IBOutlet weak var processingButtonView: UIView!
     @IBOutlet weak var processingButtonTextLabel: UILabel!
     @IBOutlet weak var dateSelectContainerHeigntConstraint: NSLayoutConstraint!
     @IBOutlet weak var bottomContainerHeightConstraint: NSLayoutConstraint!
     
     var dateSelectableView = DateSelectebleView()
     
     lazy var backBarButtonItem = UIBarButtonItem(image: I.navigationItems.leftShevronBack, style: .plain, target: self, action: #selector(didTapBackButton))
     lazy var processingButtonActivityIndicator = UIActivityIndicatorView(style: .medium)
     
     /// managers∂
     private var deepCleanManager = DeepCleanManager()
     private var photoManager = PhotoManager()
     
     /// protocols and delegates
     weak var selectableAssetsDelegate: DeepCleanSelectableAssetsDelegate?
     
     /// properties
     public var scansOptions: [PhotoMediaType]?
     
     private var bottomMenuHeight: CGFloat = 80
     private var processing: Bool = false
     private var isStartingDateSelected: Bool = false
     private var deepCleanFirstRunProcessingIsStart: Bool = false
     
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
     private var totalDeepCleanProgress: [CGFloat] = [0,0,0,0,0,0,0,0]
     private var totalDeepCleanFilesCountIn: [Int] = [0,0,0,0,0,0,0,0]
     private var handleSelectedAssetsForRowMediatype: [PhotoMediaType: Bool] = [:]
     private var doneProcessingDeepCleanForMedia: [PhotoMediaType : Bool] = [:]
     private var currentProgressForRawMediatype: [PhotoMediaType: CGFloat] = [:]
     
     /// `finding duplicates and assets`
     private var similarPhoto: [PhassetGroup] = []
     private var duplicatedPhoto: [PhassetGroup] = []
     private var screenShots: [PHAsset] = []
     private var similarLivePhotos: [PhassetGroup] = []
     
     private var largeVideos: [PHAsset] = []
     private var duplicatedVideo: [PhassetGroup] = []
     private var similarVideo: [PhassetGroup] = []
     private var screenRecordings: [PHAsset] = []
     
     /// `part use for calculate assets in phasset groups`
     private var similarPhotosCount: Int = 0
     private var duplicatedPhotosCount: Int = 0
     private var similarLivePhotosCount: Int = 0
     private var similarVideoCount: Int = 0
     private var duplicatedVideosCount: Int = 0
     
     private var allContacts: [Int] = []
     private var emptyContacts: [Int] = []
     private var duplicatedContacts: [Int] = []
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          setupUI()
          setupProcessingActionButton()
          setupNavigation()
          setupTableView()
          setupDateInterval()
          updateTotalFilesTitleChecked(0)
          setupObserversAndDelegate()
          updateColors()
          setupProcessingButtonActivityIndicator()
     }
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          switch segue.identifier {
               case C.identifiers.segue.showDatePicker:
                    self.setupShowDatePickerSelectorController(segue: segue)
               default:
                    break
          }
     }
     
     @IBAction func didTapProcessingActionButton(_ sender: Any) {
          
          if !deepCleanFirstRunProcessingIsStart {
               deepCleanFirstRunProcessingIsStart = !deepCleanFirstRunProcessingIsStart
               prepareButtonsStateStartingProcessing(activate: true)
               prepareStartDeepCleanProcessing()
          } else {
               debugPrint("try delete assets -> ")
          }
     }
}

//      MARK: deep cleaning algorithm
extension DeepCleaningViewController {
     
     private func prepareStartDeepCleanProcessing() {
          
          self.photoManager.getPhotoAssetsCount(from: self.startingDate, to: self.endingDate) { allAssetsCount in
               self.totalFilesOnDevice = allAssetsCount
               
               self.photoManager.getPartitionalMediaAssetsCount(from: self.startingDate, to: self.endingDate) { assetGroupPartitionCount in
                    self.totalPartitinAssetsCount = assetGroupPartitionCount
                    self.checkStartCleaningButtonState(true)
                    self.startDeepCleanScan()
               }
          }
     }
     
     private func startDeepCleanScan() {
          
          guard let options = scansOptions else { return }
          
          backBarButtonItem.isEnabled = false
          
          deepCleanManager.startDeepCleaningFetch(options, startingFetchingDate: startingDate, endingFetchingDate: endingDate) { mediaType in
               self.scansOptions = mediaType
          } screenShots: { assets in
               
               debugPrint(assets.count, "screenShots")
               
               self.screenShots = assets
               self.doneProcessingDeepCleanForMedia[.singleScreenShots] = true
               self.updateCellInfoCount(by: .userPhoto, mediaType: .singleScreenShots, assetsCount: assets.count)
               
          } similarPhoto: { assetsGroup in
               
               debugPrint(assetsGroup.count, "similarPhoto")
               
               self.similarPhoto = assetsGroup
               self.doneProcessingDeepCleanForMedia[.similarPhotos] = true
               self.similarPhotosCount = self.getAssetsCount(for: assetsGroup)
               self.updateCellInfoCount(by: .userPhoto, mediaType: .similarPhotos, assetsCount: self.similarPhotosCount)
               
          } duplicatedPhoto: { assetsGroup in
               
               debugPrint(assetsGroup.count, "duplicatedPhoto")
               
               self.doneProcessingDeepCleanForMedia[.duplicatedPhotos] = true
               self.duplicatedPhoto = assetsGroup
               self.duplicatedPhotosCount = self.getAssetsCount(for: assetsGroup)
               self.updateCellInfoCount(by: .userPhoto, mediaType: .duplicatedPhotos, assetsCount: self.duplicatedPhotosCount)
               
          } similarLivePhotos: { assetsGroup in
               
               debugPrint(assetsGroup.count, "similarLivePhotos")
               
               self.doneProcessingDeepCleanForMedia[.similarLivePhotos] = true
               self.similarLivePhotos = assetsGroup
               self.similarLivePhotosCount = self.getAssetsCount(for: assetsGroup)
               self.updateCellInfoCount(by: .userPhoto, mediaType: .similarLivePhotos, assetsCount: self.similarLivePhotosCount)
               
          } largeVideo: { assets in
               
               debugPrint(assets.count, "large videos")
               
               self.doneProcessingDeepCleanForMedia[.singleLargeVideos] = true
               self.largeVideos = assets
               self.updateCellInfoCount(by: .userVideo, mediaType: .singleLargeVideos, assetsCount: self.largeVideos.count)
               
          } similarVideo: { assetsGroup in
               
               debugPrint(assetsGroup.count, "similarVideo")
               
               self.doneProcessingDeepCleanForMedia[.similarVideos] = true
               self.similarVideo = assetsGroup
               self.similarVideoCount = self.getAssetsCount(for: assetsGroup)
               self.updateCellInfoCount(by: .userVideo, mediaType: .similarVideos, assetsCount: self.similarVideoCount)
               
          } duplicatedVideo: { assetsGroup in
               
               debugPrint(assetsGroup.count, "duplicatedVideo")
               
               self.doneProcessingDeepCleanForMedia[.duplicatedVideos] = true
               self.duplicatedVideo = assetsGroup
               self.duplicatedVideosCount = self.getAssetsCount(for: assetsGroup)
               self.updateCellInfoCount(by: .userVideo, mediaType: .duplicatedVideos, assetsCount: self.duplicatedVideosCount)
               
          } screenRecordings: { assets in
               
               debugPrint(assets.count, "screenRecordings")
               
               self.doneProcessingDeepCleanForMedia[.singleScreenRecordings] = true
               self.screenRecordings = assets
               self.updateCellInfoCount(by: .userVideo, mediaType: .singleScreenRecordings, assetsCount: self.screenRecordings.count)
          } completionHandler: {
               
               self.processing = false
               
               U.UI {
                    self.backBarButtonItem.isEnabled = true
               }
               
               debugPrint("done")
               debugPrint(self.screenShots.count, "screenshots")
               debugPrint(self.similarPhoto.count, "similarPhoto")
               debugPrint(self.duplicatedPhoto.count, "duplicatedPhoto")
               debugPrint(self.similarLivePhotos.count, "similarLivePhotos")
               debugPrint(self.largeVideos.count, "laege videos")
               debugPrint(self.similarVideo.count, "similarVideo")
               debugPrint(self.duplicatedVideo.count, "duplicatedVideo")
               debugPrint(self.screenRecordings.count, "screenRecordings")
               P.hideIndicator()
          }
          
          U.delay(1) {
               self.processing = true
          }
     }
     
     private func checkStartCleaningButtonState(_ animate: Bool) {
          
          let selectedAssetsCount = selectedAssetsCollectionID.values.compactMap({$0}).flatMap({$0}).count
          bottomContainerHeightConstraint.constant = selectedAssetsCount > 0 ? (bottomMenuHeight + U.bottomSafeAreaHeight - 5) : 0
          self.tableView.contentInset.bottom = selectedAssetsCount > 0 ? 10 : 5
          
          if animate {
               U.animate(0.5) {
                    self.tableView.layoutIfNeeded()
                    self.view.layoutIfNeeded()
               }
          } else {
               U.UI {
                    self.tableView.layoutIfNeeded()
                    self.view.layoutIfNeeded()
               }
          }
     }
     
     private func updateAssetsFieldCount(at indexPath: IndexPath, assetsCount: Int, mediaType: PhotoMediaType) {
          
          guard !indexPath.isEmpty, let cell = self.tableView.cellForRow(at: indexPath) as? ContentTypeTableViewCell else { return }
          
          self.configure(cell, at: indexPath)
     }
     
     private func updateCellInfoCount(by type: MediaContentType, mediaType: PhotoMediaType, assetsCount: Int) {
          
          if Thread.isMainThread {
               self.updateAssetsFieldCount(at: mediaType.indexPath, assetsCount: assetsCount, mediaType: mediaType)
          } else {
               U.UI {
                    self.updateAssetsFieldCount(at: mediaType.indexPath, assetsCount: assetsCount, mediaType: mediaType)
               }
          }
     }
     
     private func getAssetsCount(for groups: [PhassetGroup]) -> Int {
          
          var assetsCount: Int = 0
          
          for group in groups {
               assetsCount += group.assets.count
          }
          return assetsCount
     }
}


extension DeepCleaningViewController: DateSelectebleViewDelegate {
     
     @objc func didTapBackButton() {
          self.navigationController?.popViewController(animated: true)
     }
     
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
          
          if let cell = self.tableView.cellForRow(at: mediaType.indexPath) as? ContentTypeTableViewCell {
               let isSelected = !assetsListIds.isEmpty
               self.handleSelectedAssetsForRowMediatype[mediaType] = isSelected
               self.selectedAssetsCollectionID[mediaType] = assetsListIds
               
               U.UI {
                    cell.setupCellSelected(at: mediaType.indexPath, isSelected: isSelected)
                    self.checkStartCleaningButtonState(true)
               }
          }
     }
}

//      MARK: - updating progress notification roating -
extension DeepCleaningViewController {
     
     @objc func flowRoatingHandleNotification(_ notification: Notification) {
          
          switch notification.name.rawValue {
               case C.key.notification.deepCleanSimilarPhotoPhassetScan:
                    self.recieveNotification(by: .similarPhoto, info: notification.userInfo)
               case C.key.notification.deepCleanDuplicatedPhotoPhassetScan:
                    self.recieveNotification(by: .duplicatePhoto, info: notification.userInfo)
               case C.key.notification.deepCleanScreenShotsPhotoPhassetScan:
                    self.recieveNotification(by: .screenshots, info: notification.userInfo)
               case C.key.notification.deepCleanSimilarLivePhotosPhassetScan:
                    self.recieveNotification(by: .similarLivePhoto, info: notification.userInfo)
               case C.key.notification.deepCleanLargeVideoPhassetScan:
                    self.recieveNotification(by: .largeVideo, info: notification.userInfo)
               case C.key.notification.deepCleanDuplicateVideoPhassetScan:
                    self.recieveNotification(by: .duplicateVideo, info: notification.userInfo)
               case C.key.notification.deepCleanSimilarVideoPhassetScan:
                    self.recieveNotification(by: .similarVideo, info: notification.userInfo)
               case C.key.notification.deepCleanScreenRecordingsPhassetScan:
                    self.recieveNotification(by: .screenRecordings, info: notification.userInfo)
               case C.key.notification.deepCleanAllContactsScan:
                    self.recieveNotification(by: .allContacts, info: notification.userInfo)
               case C.key.notification.deepCleanEmptyContactsScan:
                    self.recieveNotification(by: .emptyContacts, info: notification.userInfo)
               case C.key.notification.deepCleanDuplicateContacts:
                    self.recieveNotification(by: .duplicateContacts, info: notification.userInfo)
               default:
                    return
          }
     }
     
     private func recieveNotification(by type: DeepCleanNotificationType, info: [AnyHashable: Any]?) {
          
          guard let userInfo = info,
                let totalProcessingAssetsCount = userInfo[type.dictionaryCountName] as? Int,
                let index = userInfo[type.dictionaryIndexName] as? Int else { return }
          
          handleTotalFilesChecked(by: type, files: index)
          
          calculateProgressPercentage(total: totalProcessingAssetsCount, current: index) { title, progress in
               U.UI {
                    self.progressUpdate(type, progress: progress, title: title)
               }
          }
     }
     
     private func handleTotalFilesChecked(by type: DeepCleanNotificationType, files count: Int) {
          
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
               default:
                    return
          }
     }
     
     private func updateTotalFilesTitleChecked(_ totalFiles: Int) {
                    
          let totalVideoProcessing = (totalDeepCleanFilesCountIn[5] + totalDeepCleanFilesCountIn[6]) / 2
          let totalPhotoProcessing = (totalDeepCleanFilesCountIn[0] + totalDeepCleanFilesCountIn[1]) / 2
          
          totalFilesChecked = (totalPhotoProcessing + totalVideoProcessing)
   
          if self.totalFilesOnDevice == 0 {
               totalPercentageCalculated = 0
          } else {
               totalPercentageCalculated = self.totalDeepCleanProgress.sum() / 8
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
          
          let indexPath = notificationType.mediaTypeRawValue.indexPath
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
               case .allContacts:
                    debugPrint("todo")
               case .emptyContacts:
                    debugPrint("todo")
               case .duplicateContacts:
                    debugPrint("todo")
          }
          
          guard !indexPath.isEmpty else { return }
          
          guard let cell = tableView.cellForRow(at: indexPath) as? ContentTypeTableViewCell else { return }
          self.configure(cell, at: indexPath)
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
          
          switch indexPath.section {
               case 1:
                    switch indexPath.row {
                         case 0:
                              self.showCleaningListViewControler(by: .similarPhotos)
                         case 1:
                              self.showCleaningListViewControler(by: .duplicatedPhotos)
                         case 2:
                              self.showCleaningListViewControler(by: .singleScreenShots)
                         case 3:
                              self.showCleaningListViewControler(by: .similarLivePhotos)
                         default:
                              return
                    }
               case 2:
                    switch indexPath.row {
                         case 0:
                              self.showCleaningListViewControler(by: .singleLargeVideos)
                         case 1:
                              self.showCleaningListViewControler(by: .duplicatedVideos)
                         case 2:
                              self.showCleaningListViewControler(by: .similarVideos)
                         case 3:
                              self.showCleaningListViewControler(by: .singleScreenRecordings)
                         default:
                              return
                    }
               case 3:
                    switch indexPath.row {
                         case 0:
                              self.showCleaningListViewControler(by: .allContacts)
                         case 1:
                              self.showCleaningListViewControler(by: .emptyContacts)
                         case 2:
                              self.showCleaningListViewControler(by: .duplicatedContacts)
                         default:
                              return
                    }
               default:
                    return
          }
     }
     
     private func showCleaningListViewControler(by type: PhotoMediaType) {
          
          switch type {
               case .similarPhotos:
                    if !similarPhoto.isEmpty {
                         self.showGropedContoller(assets: type.mediaTypeName,
                                                  grouped: similarPhoto,
                                                  photoContent: type)
                    }
               case .duplicatedPhotos:
                    if !duplicatedPhoto.isEmpty {
                         self.showGropedContoller(assets: type.mediaTypeName,
                                                  grouped: duplicatedPhoto,
                                                  photoContent: type)
                    }
               case .singleScreenShots:
                    if !screenShots.isEmpty {
                         self.showAssetViewController(assets: type.mediaTypeName,
                                                      collection: screenShots,
                                                      photoContent: type)
                    }
               case .similarLivePhotos:
                    if !similarLivePhotos.isEmpty {
                         self.showGropedContoller(assets: type.mediaTypeName,
                                                  grouped: similarLivePhotos,
                                                  photoContent: type)
                    }
               case .singleLargeVideos:
                    if !largeVideos.isEmpty {
                         self.showAssetViewController(assets: type.mediaTypeName,
                                                      collection: largeVideos,
                                                      photoContent: type)
                    }
               case .duplicatedVideos:
                    if !duplicatedVideo.isEmpty {
                         self.showGropedContoller(assets: type.mediaTypeName,
                                                  grouped: duplicatedVideo,
                                                  photoContent: type)
                    }
               case .similarVideos:
                    if !similarVideo.isEmpty {
                         self.showGropedContoller(assets: type.mediaTypeName,
                                                  grouped: similarVideo,
                                                  photoContent: type)
                    }
               case .singleScreenRecordings:
                    if !screenRecordings.isEmpty {
                         self.showAssetViewController(assets: type.mediaTypeName,
                                                      collection: screenRecordings,
                                                      photoContent: type)
                    }
               default:
                    return
          }
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
     }
     
     private func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath) {
          
          let contentType = MediaType.getMediaContentType(from: indexPath)
          let isSelected = self.handleSelectedAssetsForRowMediatype[contentType] ?? false
          cell.setupCellSelected(at: indexPath, isSelected: isSelected)
          
          switch indexPath.section {
               case 1:
                    switch indexPath.row {
                         case 0:
                              cell.cellConfig(contentType: .userPhoto,
                                              indexPath: indexPath,
                                              phasetCount: self.similarPhotosCount,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.similarPhotos] ?? 0,
                                              isProcessingComplete: doneProcessingDeepCleanForMedia[.similarPhotos] ?? false)
                         case 1:
                              cell.cellConfig(contentType: .userPhoto,
                                              indexPath: indexPath,
                                              phasetCount: self.duplicatedPhotosCount,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.duplicatedPhotos] ?? 0,
                                              isProcessingComplete: doneProcessingDeepCleanForMedia[.duplicatedPhotos] ?? false)
                              
                         case 2:
                              cell.cellConfig(contentType: .userPhoto,
                                              indexPath: indexPath,
                                              phasetCount: self.screenShots.count,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.singleScreenShots] ?? 0,
                                              isProcessingComplete: doneProcessingDeepCleanForMedia[.singleScreenShots] ?? false)
                         case 3:
                              
                              cell.cellConfig(contentType: .userPhoto,
                                              indexPath: indexPath,
                                              phasetCount: self.similarLivePhotosCount,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.similarLivePhotos] ?? 0,
                                              isProcessingComplete: doneProcessingDeepCleanForMedia[.similarLivePhotos] ?? false)
                         default:
                              return
                    }
               case 2:
                    switch indexPath.row {
                         case 0:
                              cell.cellConfig(contentType: .userVideo,
                                              indexPath: indexPath,
                                              phasetCount: self.largeVideos.count,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.singleLargeVideos] ?? 0,
                                              isProcessingComplete: doneProcessingDeepCleanForMedia[.singleLargeVideos] ?? false)
                              
                         case 1:
                              cell.cellConfig(contentType: .userVideo,
                                              indexPath: indexPath,
                                              phasetCount: self.duplicatedVideosCount,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.duplicatedVideos] ?? 0,
                                              isProcessingComplete: doneProcessingDeepCleanForMedia[.duplicatedVideos] ?? false)
                         case 2:
                              cell.cellConfig(contentType: .userVideo,
                                              indexPath: indexPath,
                                              phasetCount: self.similarVideoCount,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.similarVideos] ?? 0,
                                              isProcessingComplete: doneProcessingDeepCleanForMedia[.similarVideos] ?? false)
                              
                         case 3:
                              cell.cellConfig(contentType: .userVideo,
                                              indexPath: indexPath,
                                              phasetCount: self.screenRecordings.count,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.singleScreenRecordings] ?? 0,
                                              isProcessingComplete: doneProcessingDeepCleanForMedia[.singleScreenRecordings] ?? false)
                         default:
                              return
                    }
               case 3:
                    switch indexPath.row {
                         case 0:
                              cell.cellConfig(contentType: .userContacts,
                                              indexPath: indexPath,
                                              phasetCount: self.allContacts.count,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.allContacts] ?? 0)
                         case 1:
                              cell.cellConfig(contentType: .userContacts,
                                              indexPath: indexPath,
                                              phasetCount: self.emptyContacts.count,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.emptyContacts] ?? 0)
                         case 2:
                              cell.cellConfig(contentType: .userContacts,
                                              indexPath: indexPath,
                                              phasetCount: self.duplicatedContacts.count,
                                              isDeepCleanController: true,
                                              progress: self.currentProgressForRawMediatype[.duplicatedContacts] ?? 0)
                         default:
                              return
                    }
               default:
                    return
          }
     }
     
     private func configureInfoCell(_ cell: DeepCleanInfoTableViewCell, at indexPath: IndexPath) {
          
          cell.setProgress(files: self.totalFilesChecked)
          cell.setRoundedProgress(value: totalPercentageCalculated)
     }
     
     func numberOfSections(in tableView: UITableView) -> Int {
          return 4
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          
          switch section {
               case 0:
                    return 1
               case 1:
                    return MediaContentType.userPhoto.deepCleanNumbersOfRows
               case 2:
                    return MediaContentType.userVideo.deepCleanNumbersOfRows
               default:
                    return MediaContentType.userContacts.deepCleanNumbersOfRows
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
          return indexPath.section == 0 ? 125 : UITableView.automaticDimension
     }
     
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          
          let view = UIView(frame: CGRect(x: 0, y: 0, width: U.screenWidth, height: 30))
          let sectionTitleTextLabel = UILabel()
          
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
                    sectionTitleTextLabel.text = "photo"
               case 2:
                    sectionTitleTextLabel.text = "video"
               default:
                    sectionTitleTextLabel.text = "contacts"
          }
          return view
     }
}

extension DeepCleaningViewController {
     
     private func setupUI() {
          
          dateSelectableView.frame = dateSelectContainerView.bounds
          dateSelectContainerView.addSubview(dateSelectableView)
          
          dateSelectableView.translatesAutoresizingMaskIntoConstraints = false
          
          dateSelectableView.leadingAnchor.constraint(equalTo: dateSelectContainerView.leadingAnchor).isActive = true
          dateSelectableView.trailingAnchor.constraint(equalTo: dateSelectContainerView.trailingAnchor).isActive = true
          dateSelectableView.bottomAnchor.constraint(equalTo: dateSelectContainerView.bottomAnchor).isActive = true
          dateSelectableView.topAnchor.constraint(equalTo: dateSelectContainerView.topAnchor).isActive = true
          
          
          processingButtonView.setCorner(12)
          processingButtonTextLabel.font = .systemFont(ofSize: 17, weight: .bold)
     }
     
     private func setupDateInterval() {
          
          dateSelectableView.setupDisplaysDate(startingDate: self.startingDate, endingDate: self.endingDate)
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
          
          dateSelectableView.delegate = self
          selectableAssetsDelegate = self
     }
     
     private func setupNavigation() {
          
          self.navigationItem.leftBarButtonItem = backBarButtonItem
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
                    self.dateSelectableView.setupDisplaysDate(startingDate: self.startingDate, endingDate: self.endingDate)
               }
          }
     }
     
     private func setupProcessingButtonActivityIndicator() {
          
          processingButtonActivityIndicator.isHidden = true
          
          processingButtonView.addSubview(processingButtonActivityIndicator)
          processingButtonActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
          
          NSLayoutConstraint.activate([
               processingButtonActivityIndicator.centerXAnchor.constraint(equalTo: processingButtonView.centerXAnchor),
               processingButtonActivityIndicator.centerYAnchor.constraint(equalTo: processingButtonView.centerYAnchor),
               processingButtonActivityIndicator.widthAnchor.constraint(equalToConstant: 20),
               processingButtonActivityIndicator.heightAnchor.constraint(equalToConstant: 20)
          ])
     }
     
     private func setupProcessingActionButton(_ isStartingDeepCleanProcess: Bool = true) {
                    
          if !deepCleanFirstRunProcessingIsStart {
               bottomContainerHeightConstraint.constant = (bottomMenuHeight + U.bottomSafeAreaHeight - 5)
               self.tableView.contentInset.bottom = 10
          } else {
               checkStartCleaningButtonState(false)
          }
          
          if isStartingDeepCleanProcess {
               
               processingButtonTextLabel.text = deepCleanFirstRunProcessingIsStart ? "re start deep clean" : "start deep clean"
               
          } else {
               
               processingButtonTextLabel.text = "delete"
          }
     }
     
     private func prepareButtonsStateStartingProcessing(activate: Bool) {
          
          processingButtonTextLabel.isHidden = activate
          activate ? processingButtonActivityIndicator.startAnimating() : processingButtonActivityIndicator.stopAnimating()
          processingButtonActivityIndicator.isHidden = !activate
     }
}



extension DeepCleaningViewController: Themeble {
     
     func updateColors() {
          
          bottomMenuView.backgroundColor = .clear
          processingButtonView.backgroundColor = theme.accentBackgroundColor
          processingButtonTextLabel.textColor = theme.activeTitleTextColor
          processingButtonActivityIndicator.color = theme.backgroundColor
     }
}



