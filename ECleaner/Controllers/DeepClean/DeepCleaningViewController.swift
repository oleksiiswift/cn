//
//  DeepCleaningViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.07.2021.
//

import UIKit
import Photos
import PhotosUI

class DeepCleaningViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomContainerHeightConstraint: NSLayoutConstraint!
    
    lazy var backBarButtonItem = UIBarButtonItem(image: I.navigationItems.leftShevronBack, style: .plain, target: self, action: #selector(didTapBackButton))
    /// managers
    private var deepCleanManager = DeepCleanManager()
    private var photoManager = PhotoManager()
    
    /// properties
    public var scansOptions: [PhotoMediaType]?
    
    private var bottomMenuHeight: CGFloat = 80
    private var processing: Bool = false
    
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
    
//    TODO: list of selected Assets or list of selected ids'
    public var cleaningAssetsList: [String] = []
    
    private var screenShots: [PHAsset] = []
    private var similarPhoto: [PhassetGroup] = []
    private var duplicatedPhoto: [PhassetGroup] = []
    private var similarLivePhotos: [PhassetGroup] = []
    private var largeVideos: [PHAsset] = []
    private var similarVideo: [PhassetGroup] = []
    private var duplicatedVideo: [PhassetGroup] = []
    private var screenRecordings: [PHAsset] = []
    
    private var allContacts: [Int] = []
    private var emptyContacts: [Int] = []
    private var duplicatedContacts: [Int] = []

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
        checkStartCleaningButtonState(false)
        setupObserversAndDelegate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.startDeepCleanScan()
    }
}

extension DeepCleaningViewController {
    
    private func startDeepCleanScan() {
        
        guard let options = scansOptions else { return }
    
        backBarButtonItem.isEnabled = false
    
        deepCleanManager.startDeepCleaningFetch(options, startingFetchingDate: startingDate, endingFetchingDate: endingDate) { mediaType in
            self.scansOptions = mediaType
        } screenShots: { assets in
            debugPrint(assets.count, "screenShots")
            if assets.count != 0 {
                self.screenShots = assets
                self.updateCellInfoCount(by: .userPhoto, mediaType: .singleScreenShots, assetsCount: assets.count)
            }
        } similarPhoto: { assetsGroup in
            debugPrint(assetsGroup.count, "similarPhoto")
            if assetsGroup.count != 0 {
                self.similarPhoto = assetsGroup
                self.similarPhotosCount = self.getAssetsCount(for: assetsGroup)
                self.updateCellInfoCount(by: .userPhoto, mediaType: .similarPhotos, assetsCount: self.similarPhotosCount)
            }
        } duplicatedPhoto: { assetsGroup in
            debugPrint(assetsGroup.count, "duplicatedPhoto")
            if assetsGroup.count != 0 {
                self.duplicatedPhoto = assetsGroup
                self.duplicatedPhotosCount = self.getAssetsCount(for: assetsGroup)
                self.updateCellInfoCount(by: .userPhoto, mediaType: .duplicatedPhotos, assetsCount: self.duplicatedPhotosCount)
            }
        } similarLivePhotos: { assetsGroup in
            debugPrint(assetsGroup.count, "similarLivePhotos")
            if assetsGroup.count != 0 {
                self.similarLivePhotos = assetsGroup
                self.similarLivePhotosCount = self.getAssetsCount(for: assetsGroup)
                self.updateCellInfoCount(by: .userPhoto, mediaType: .similarLivePhotos, assetsCount: self.similarLivePhotosCount)
            }
        } largeVideo: { assets in
            if assets.count != 0 {
                self.largeVideos = assets
                self.updateCellInfoCount(by: .userVideo, mediaType: .singleLargeVideos, assetsCount: self.largeVideos.count)
            }
        } similarVideo: { assetsGroup in
            debugPrint(assetsGroup.count, "similarVideo")
            if assetsGroup.count != 0 {
                self.similarVideo = assetsGroup
                self.similarVideoCount = self.getAssetsCount(for: assetsGroup)
                self.updateCellInfoCount(by: .userVideo, mediaType: .similarVideos, assetsCount: self.similarVideoCount)
            }
        } duplicatedVideo: { assetsGroup in
            debugPrint(assetsGroup.count, "duplicatedVideo")
            if assetsGroup.count != 0 {
                self.duplicatedVideo = assetsGroup
                self.duplicatedVideosCount = self.getAssetsCount(for: assetsGroup)
                self.updateCellInfoCount(by: .userVideo, mediaType: .duplicatedVideos, assetsCount: self.duplicatedVideosCount)
            }
        } screenRecordings: { assets in
            debugPrint(assets.count, "screenRecordings")
            if assets.count != 0  {
                self.screenRecordings = assets
                self.updateCellInfoCount(by: .userVideo, mediaType: .singleScreenRecordings, assetsCount: self.screenRecordings.count)
            }
        } completionHandler: {
            
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
    
    private func forceUpdateAssetsDeepCleanCells(at indexPath: IndexPath) {
        
        switch indexPath.section {
            case 1:
                switch indexPath.row {
                    case 0:
                        self.updateCellInfoCount(by: .userPhoto, mediaType: .similarPhotos, assetsCount: self.similarPhoto.count)
                    case 1:
                        self.updateCellInfoCount(by: .userPhoto, mediaType: .duplicatedPhotos, assetsCount: self.duplicatedPhotosCount)
                    case 2:
                        self.updateCellInfoCount(by: .userPhoto, mediaType: .singleScreenShots, assetsCount: self.screenShots.count)
                    case 3:
                        self.updateCellInfoCount(by: .userPhoto, mediaType: .similarLivePhotos, assetsCount: self.similarLivePhotosCount)
                    default:
                        return
                }
            case 2:
                switch indexPath.row {
                    case 0:
                        self.updateCellInfoCount(by: .userVideo, mediaType: .singleLargeVideos, assetsCount: self.largeVideos.count)
                    case 1:
                        self.updateCellInfoCount(by: .userVideo, mediaType: .duplicatedVideos, assetsCount: self.duplicatedVideosCount)
                    case 2:
                        self.updateCellInfoCount(by: .userVideo, mediaType: .similarVideos, assetsCount: self.similarVideoCount)
                    case 3:
                        self.updateCellInfoCount(by: .userVideo, mediaType: .singleScreenRecordings, assetsCount: self.screenRecordings.count)
                    default:
                        return
                }
            case 3:
                switch indexPath.row {
                    case 0:
                        self.updateCellInfoCount(by: .userContacts, mediaType: .allContacts, assetsCount: 0)
                    case 1:
                        self.updateCellInfoCount(by: .userContacts, mediaType: .emptyContacts, assetsCount: 0)
                    case 2:
                        self.updateCellInfoCount(by: .userContacts, mediaType: .duplicatedContacts, assetsCount: 0)
                    default:
                        return
                }
            default:
                debugPrint("view for title")
        }
    }
}

extension DeepCleaningViewController {
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
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
            
        calculateProgressPercentage(total: totalProcessingAssetsCount, current: index) { title, progress in
            U.UI {
                self.progressUpdate(type, progress: progress, title: title)
            }
        }
    }

    private func progressUpdate(_ type: DeepCleanNotificationType, progress: CGFloat, title: String) {
        
        var indexPath = IndexPath()
        
        switch type {
            case .similarPhoto:
                indexPath = MediaContentType.userPhoto.getIndexPath(for: .similarPhotos)
                self.currentProgressSimilarPhoto = progress
            case .duplicatePhoto:
                indexPath = MediaContentType.userPhoto.getIndexPath(for: .duplicatedPhotos)
                self.currentProgressDuplicatedPhoto = progress
            case .screenshots:
                indexPath = MediaContentType.userPhoto.getIndexPath(for: .singleScreenShots)
                self.currentProgressScreenShots = progress
            case .livePhoto:
                indexPath = MediaContentType.userPhoto.getIndexPath(for: .similarLivePhotos)
                self.currentProgressSimilarLivePhoto = progress
            case .largeVideo:
                indexPath = MediaContentType.userVideo.getIndexPath(for: .singleLargeVideos)
                self.currentProgressLargeVideos = progress
            case .duplicateVideo:
                indexPath = MediaContentType.userVideo.getIndexPath(for: .duplicatedVideos)
                self.currentProgressDuplicatedVideo = progress
            case .similarVideo:
                indexPath = MediaContentType.userVideo.getIndexPath(for: .similarVideos)
                self.currentProgressSimilarVideo = progress
            case .screenRecordings:
                indexPath = MediaContentType.userVideo.getIndexPath(for: .singleScreenRecordings)
                self.currentProgressScreenRecordings = progress
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
    }
    
    private func calculateProgressPercentage(total: Int, current: Int, completion: @escaping (String, CGFloat) -> Void) {
        
        let percentLabelFormat: String = "%.f %%"
        let totalPercent = CGFloat(Double(current) / Double(total)) * 100
        let stingFormat = String(format: percentLabelFormat, totalPercent)
        completion(stingFormat, totalPercent)
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
                                        progress: self.currentProgressSimilarPhoto)
                    case 1:
                        cell.cellConfig(contentType: .userPhoto,
                                        indexPath: indexPath,
                                        phasetCount: self.duplicatedPhotosCount,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressDuplicatedPhoto)
                    case 2:
                        cell.cellConfig(contentType: .userPhoto,
                                        indexPath: indexPath,
                                        phasetCount: self.screenShots.count,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressScreenShots)
                    case 3:
                        cell.cellConfig(contentType: .userPhoto,
                                        indexPath: indexPath,
                                        phasetCount: self.similarLivePhotosCount,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressSimilarLivePhoto)
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
                                        progress: self.currentProgressLargeVideos)
                    case 1:
                        cell.cellConfig(contentType: .userVideo,
                                        indexPath: indexPath,
                                        phasetCount: self.duplicatedVideosCount,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressDuplicatedVideo)
                    case 2:
                        cell.cellConfig(contentType: .userVideo,
                                        indexPath: indexPath,
                                        phasetCount: self.similarVideoCount,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressSimilarVideo)
                    case 3:
                        cell.cellConfig(contentType: .userVideo,
                                        indexPath: indexPath,
                                        phasetCount: self.screenRecordings.count,
                                        isDeepCleanController: true,
                                        progress: self.currentProgressScreenRecordings)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        forceUpdateAssetsDeepCleanCells(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 150 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: U.screenWidth, height: 30))
        let sectionTitleTextLabel = UILabel()
        
        view.addSubview(sectionTitleTextLabel)
        sectionTitleTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        sectionTitleTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        sectionTitleTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        sectionTitleTextLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sectionTitleTextLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
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
    
    private func setupUI() {}
    
    private func setupObserversAndDelegate() {
     
        U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanSimilarPhotoPhassetScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDuplicatedPhotoPhassetScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanScreenShotsPhassetScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanSimilarLivePhotosPhaassetScan, object: nil)
        
        U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanLargeVideoPhassetScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanDuplicateVideoPhassetScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanSimilarVideoPhassetScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(flowRoatingHandleNotification(_:)), name: .deepCleanScreenRecordingsPhassetScan, object: nil)
    }
    
    private func setupNavigation() {
        
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        
    }
}

extension DeepCleaningViewController: Themeble {
    
    func updateColors() {
        
    }
}
