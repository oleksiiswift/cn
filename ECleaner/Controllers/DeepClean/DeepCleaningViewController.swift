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

class DeepCleaningViewController: UIViewController {
    
    @IBOutlet weak var dateSelectContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dateSelectContainerHeigntConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContainerHeightConstraint: NSLayoutConstraint!
 
    var dateSelectableView = DateSelectebleView()
    
    lazy var backBarButtonItem = UIBarButtonItem(image: I.navigationItems.leftShevronBack, style: .plain, target: self, action: #selector(didTapBackButton))
    
    /// managers
    private var deepCleanManager = DeepCleanManager()
    private var photoManager = PhotoManager()
    
    /// properties
    public var scansOptions: [PhotoMediaType]?
    
    private var bottomMenuHeight: CGFloat = 80
    private var processing: Bool = false
    private var isStartingDateSelected: Bool = false
    
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
    
    private var totalFilesChecked: Int = 0
    public var totalFilesOnDevice: Int = 0
    private var totalPercentageCalculated: CGFloat = 0
    
//    TODO: list of selected Assets or list of selected ids'
    public var cleaningAssetsList: [String] = []
    
    private var similarPhoto: [PhassetGroup] = []
    private var duplicatedPhoto: [PhassetGroup] = []
    private var screenShots: [PHAsset] = []
    private var similarLivePhotos: [PhassetGroup] = []
    
    private var largeVideos: [PHAsset] = []
    private var duplicatedVideo: [PhassetGroup] = []
    private var similarVideo: [PhassetGroup] = []
    private var screenRecordings: [PHAsset] = []
    
    private var allContacts: [Int] = []
    private var emptyContacts: [Int] = []
    private var duplicatedContacts: [Int] = []
    
    private var totalDeepCleanProgress: [CGFloat] = [0,0,0,0,0,0,0,0]
    private var totalDeepCleanFilesCountIn: [Int] = [0,0,0,0,0,0,0,0]
    private var doneProcessingDeepCleanForMedia: [PhotoMediaType : Bool] = [:]

    private var currentProgressScreenShots: CGFloat = 0
    private var currentProgressSimilarPhoto: CGFloat = 0
    private var currentProgressDuplicatedPhoto: CGFloat = 0
    private var currentProgressSimilarLivePhoto: CGFloat = 0
    private var currentProgressLargeVideos: CGFloat = 0
    private var currentProgressSimilarVideo: CGFloat = 0
    private var currentProgressDuplicatedVideo: CGFloat = 0
    private var currentProgressScreenRecordings: CGFloat = 0
    private var currentProgressAllContacts: CGFloat = 0
    private var currentProgressEmptyContacts: CGFloat = 0
    private var currentProgressDuplicateContacts: CGFloat = 0
    
    private var similarPhotosCount: Int = 0
    private var duplicatedPhotosCount: Int = 0
    private var similarLivePhotosCount: Int = 0
    private var similarVideoCount: Int = 0
    private var duplicatedVideosCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigation()
        setupTableView()
        setupDateInterval()
        checkStartCleaningButtonState(false)
        updateTotalFilesTitleChecked(0)
        setupObserversAndDelegate()
        updateColors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.startDeepCleanScan()
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
        }
        
        U.delay(1) {
            self.processing = true
        }
    }

    private func checkStartCleaningButtonState(_ animate: Bool) {
        
        bottomContainerHeightConstraint.constant = cleaningAssetsList.count > 0 ? (bottomMenuHeight + U.bottomSafeAreaHeight - 5) : 0
        self.tableView.contentInset.bottom = cleaningAssetsList.count > 0 ? 10 : 5
        
        if animate {
            U.animate(0.5) {
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
        
        var indexPath = IndexPath()
        
        switch type {
            case .userPhoto:
                indexPath = MediaContentType.userPhoto.getIndexPath(for: mediaType)
            case .userVideo:
                indexPath = MediaContentType.userVideo.getIndexPath(for: mediaType)
            case .userContacts:
                indexPath = MediaContentType.userContacts.getIndexPath(for: mediaType)
            case .none:
                debugPrint("no media content type")
        }
        
        if Thread.isMainThread {
            self.updateAssetsFieldCount(at: indexPath, assetsCount: assetsCount, mediaType: mediaType)
        } else {
            U.UI {
                self.updateAssetsFieldCount(at: indexPath, assetsCount: assetsCount, mediaType: mediaType)
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
                self.recieveNotification(by: .livePhoto, info: notification.userInfo)
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
            case .duplicateVideo:
                self.totalDeepCleanFilesCountIn[5] = count
            case .similarVideo:
                self.totalDeepCleanFilesCountIn[6] = count
            default:
                return
        }
    }
    
    private func updateTotalFilesTitleChecked(_ totalFiles: Int) {
        
        /// processing `duplicate video and similiar videos`
        let totalVideoProcessing = (totalDeepCleanFilesCountIn[5] + totalDeepCleanFilesCountIn[6]) / 2
        
        /// pricessing `duplicate photos and similar videos`
        let countAllProcessing = totalDeepCleanFilesCountIn.sum() / 2
                
        totalFilesChecked = countAllProcessing + totalVideoProcessing
        
        totalPercentageCalculated = CGFloat((totalFilesChecked * 100) / self.totalFilesOnDevice)
    
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DeepCleanInfoTableViewCell {
            cell.setProgress(files: totalFilesChecked)
            cell.setRoundedProgress(value: totalPercentageCalculated)
        }
    }

    private func progressUpdate(_ type: DeepCleanNotificationType, progress: CGFloat, title: String) {
        
        var indexPath = IndexPath()
        
        switch type {
            case .similarPhoto:
                indexPath = MediaContentType.userPhoto.getIndexPath(for: .similarPhotos)
                self.currentProgressSimilarPhoto = progress
                self.totalDeepCleanProgress[0] = progress
            case .duplicatePhoto:
                indexPath = MediaContentType.userPhoto.getIndexPath(for: .duplicatedPhotos)
                self.currentProgressDuplicatedPhoto = progress
                self.totalDeepCleanProgress[1] = progress
            case .screenshots:
                indexPath = MediaContentType.userPhoto.getIndexPath(for: .singleScreenShots)
                self.currentProgressScreenShots = progress
                self.totalDeepCleanProgress[2] = progress
            case .livePhoto:
                indexPath = MediaContentType.userPhoto.getIndexPath(for: .similarLivePhotos)
                self.currentProgressSimilarLivePhoto = progress
                self.totalDeepCleanProgress[3] = progress
            case .largeVideo:
                indexPath = MediaContentType.userVideo.getIndexPath(for: .singleLargeVideos)
                self.currentProgressLargeVideos = progress
                self.totalDeepCleanProgress[4] = progress
            case .duplicateVideo:
                indexPath = MediaContentType.userVideo.getIndexPath(for: .duplicatedVideos)
                self.currentProgressDuplicatedVideo = progress
                self.totalDeepCleanProgress[5] = progress
            case .similarVideo:
                indexPath = MediaContentType.userVideo.getIndexPath(for: .similarVideos)
                self.currentProgressSimilarVideo = progress
                self.totalDeepCleanProgress[6] = progress
            case .screenRecordings:
                indexPath = MediaContentType.userVideo.getIndexPath(for: .singleScreenRecordings)
                self.currentProgressScreenRecordings = progress
                self.totalDeepCleanProgress[7] = progress
            case .allContacts:
                indexPath = MediaContentType.userVideo.getIndexPath(for: .allContacts)
            case .emptyContacts:
                indexPath = MediaContentType.userContacts.getIndexPath(for: .emptyContacts)
            case .duplicateContacts:
                indexPath = MediaContentType.userContacts.getIndexPath(for: .duplicatedContacts)
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
                    self.showGropedContoller(assets: type.mediaTypeName(), grouped: similarPhoto, photoContent: type)
                }
            case .duplicatedPhotos:
                if !duplicatedPhoto.isEmpty {
                    self.showGropedContoller(assets: type.mediaTypeName(), grouped: duplicatedPhoto, photoContent: type)
                }
            case .singleScreenShots:
                if !screenShots.isEmpty {
                    self.showAssetViewController(assets: type.mediaTypeName(), collection: screenShots, photoContent: type)
                }
            case .similarLivePhotos:
                if !similarLivePhotos.isEmpty {
                    self.showGropedContoller(assets: type.mediaTypeName(), grouped: similarLivePhotos, photoContent: type)
                }
            case .singleLargeVideos:
                if !largeVideos.isEmpty {
                    self.showAssetViewController(assets: type.mediaTypeName(), collection: largeVideos, photoContent: type)
                }
            case .duplicatedVideos:
                if !duplicatedVideo.isEmpty {
                    self.showGropedContoller(assets: type.mediaTypeName(), grouped: duplicatedVideo, photoContent: type)
                }
            case .similarVideos:
                if !similarVideo.isEmpty {
                    self.showGropedContoller(assets: type.mediaTypeName(), grouped: similarVideo, photoContent: type)
                }
            case .singleScreenRecordings:
                if !screenRecordings.isEmpty {
                    self.showAssetViewController(assets: type.mediaTypeName(), collection: screenRecordings, photoContent: type)
                }
            default:
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
        
        cell.setupCellSelected(at: indexPath, isSelected: false)
        
        switch indexPath.section {
            case 1:
                switch indexPath.row {
                    case 0:
                        cell.cellConfig(contentType: .userPhoto,
                                        indexPath: indexPath,
                                        phasetCount: self.similarPhotosCount,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressSimilarPhoto,
                                        isProcessingComplete: doneProcessingDeepCleanForMedia[.similarPhotos] ?? false)
                    case 1:
                        cell.cellConfig(contentType: .userPhoto,
                                        indexPath: indexPath,
                                        phasetCount: self.duplicatedPhotosCount,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressDuplicatedPhoto,
                                        isProcessingComplete: doneProcessingDeepCleanForMedia[.duplicatedPhotos] ?? false)
                                        
                    case 2:
                        cell.cellConfig(contentType: .userPhoto,
                                        indexPath: indexPath,
                                        phasetCount: self.screenShots.count,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressScreenShots,
                                        isProcessingComplete: doneProcessingDeepCleanForMedia[.singleScreenShots] ?? false)
                    case 3:
                    
                        cell.cellConfig(contentType: .userPhoto,
                                        indexPath: indexPath,
                                        phasetCount: self.similarLivePhotosCount,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressSimilarLivePhoto,
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
                                        progress: self.currentProgressLargeVideos,
                                        isProcessingComplete: doneProcessingDeepCleanForMedia[.singleLargeVideos] ?? false)
                                        
                    case 1:
                        cell.cellConfig(contentType: .userVideo,
                                        indexPath: indexPath,
                                        phasetCount: self.duplicatedVideosCount,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressDuplicatedVideo,
                                        isProcessingComplete: doneProcessingDeepCleanForMedia[.duplicatedVideos] ?? false)
                    case 2:
                        cell.cellConfig(contentType: .userVideo,
                                        indexPath: indexPath,
                                        phasetCount: self.similarVideoCount,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressSimilarVideo,
                                        isProcessingComplete: doneProcessingDeepCleanForMedia[.similarVideos] ?? false)
                                        
                    case 3:
                        cell.cellConfig(contentType: .userVideo,
                                        indexPath: indexPath,
                                        phasetCount: self.screenRecordings.count,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressScreenRecordings,
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
                                        progress: self.currentProgressAllContacts)
                    case 1:
                        cell.cellConfig(contentType: .userContacts,
                                        indexPath: indexPath,
                                        phasetCount: self.emptyContacts.count,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressEmptyContacts)
                    case 2:
                        cell.cellConfig(contentType: .userContacts,
                                        indexPath: indexPath,
                                        phasetCount: self.duplicatedContacts.count,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressDuplicateContacts)
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
}

extension DeepCleaningViewController: Themeble {
    
    func updateColors() {
        

    }
}


