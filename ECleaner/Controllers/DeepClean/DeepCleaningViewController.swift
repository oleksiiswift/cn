//
//  DeepCleaningViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.07.2021.
//

import UIKit
import Photos

class DeepCleaningViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomContainerHeightConstraint: NSLayoutConstraint!
    
    /// managers
    private var deepCleanManager = DeepCleanManager()
    
    /// properties
    public var scansOptions: [PhotoMediaType]?
    
    private var bottomMenuHeight: CGFloat = 80
    
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
    
    private var similarPhotosCount: Int = 0
    private var duplicatedPhotosCount: Int = 0
    private var similarLivePhotosCount: Int = 0
    private var similarVideoCount: Int = 0
    private var duplicatedVideosCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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
        switch indexPath.section {
            case 1:
                cell.cellConfig(contentType: .userPhoto, indexPath: indexPath, phasetCount: assetsCount, isDeepCleanController: true)
            case 2:
                cell.cellConfig(contentType: .userVideo, indexPath: indexPath, phasetCount: assetsCount, isDeepCleanController: true)
            case 3:
                cell.cellConfig(contentType: .userContacts, indexPath: indexPath, phasetCount: assetsCount, isDeepCleanController: true)
            default:
                return
        }
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
        
        U.UI {
            self.updateAssetsFieldCount(at: indexPath, assetsCount: assetsCount, mediaType: mediaType)
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
    
    @objc func calculateProgressPercentView(_ notification: Notification) {
        
        if notification.name.rawValue == C.key.notification.deepCleanSimilarPhotoPhassetScan {
            if let info = notification.userInfo {
                guard let totoalAssetsCount =  info[C.key.notificationDictionary.deepCleanSimilarPhotoTotalAsssetsCount] as? Int else { return }
                
                if let index = info[C.key.notificationDictionary.deepCleanSimilarPhotoPrecessingIndex] as? Int {
                    let totalPercent = Double(index) / Double(totoalAssetsCount)
                    debugPrint(totalPercent, "% processing simmilar")
                }
            }
        } else if notification.name.rawValue == C.key.notification.deepCleanDuplicatedPhotoPhassetScan {
            if let info = notification.userInfo {
                
                guard let totalAssetsCount = info[C.key.notificationDictionary.deepCleanDuplicatePhotoProcessingIndex] as? Int else { return }
                
                if let index = info[C.key.notificationDictionary.deepCleanDuplicatePhotoProcessingIndex] as? Int {
                    let totalPercent = Double(index) / Double(totalAssetsCount)
                    debugPrint(totalPercent, "% processing duplicates")
                }
            }
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
    }

    private func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath) {
        
        cell.setupCellSelected(at: indexPath, isSelected: false)
        
        switch indexPath.section {
            case 1:
                cell.cellConfig(contentType: MediaContentType.userPhoto, indexPath: indexPath, phasetCount: 0, isDeepCleanController: true)
            case 2:
                cell.cellConfig(contentType: MediaContentType.userVideo, indexPath: indexPath, phasetCount: 0, isDeepCleanController: true)
            default:
                cell.cellConfig(contentType: MediaContentType.userContacts, indexPath: indexPath, phasetCount: 0, isDeepCleanController: true)
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
        forceUpdateAssetsDeepCleanCells(at: indexPath)
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
    
    private func setupUI() {
        
    }
    
    private func setupObserversAndDelegate() {
     
        U.notificationCenter.addObserver(self, selector: #selector(calculateProgressPercentView(_:)), name: .deepCleanSimilarPhotoPhassetScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(calculateProgressPercentView(_:)), name: .deepCleanDuplicatedPhotoPhassetScan, object: nil)
    }
}

extension DeepCleaningViewController: Themeble {
    
    func updateColors() {
        
    }
}
