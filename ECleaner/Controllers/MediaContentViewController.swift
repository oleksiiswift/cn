//
//  MediaContentViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 25.06.2021.
//

import UIKit
import Photos
import SwiftMessages

class MediaContentViewController: UIViewController {

    @IBOutlet weak var startingDateTitileTextLabel: UILabel!
    @IBOutlet weak var endingDateTitleTextLabel: UILabel!
    @IBOutlet weak var startingDateTextLabel: UILabel!
    @IBOutlet weak var endingDateTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startingDateButtonView: UIView!
    @IBOutlet weak var endingDateButtonView: UIView!
    
    @IBOutlet weak var dateSelectContainerView: UIView!
    @IBOutlet weak var dateSelectContainerHeigntConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startingDateStackView: UIStackView!
    @IBOutlet weak var endingDateStackView: UIStackView!
    
    public var contentType: MediaContentType = .none
    private var photoManager = PhotoManager()
    
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
    
    private var isStartingDateSelected: Bool = false
    
    public var allScreenShots: [PHAsset] = []
    public var allSelfies: [PHAsset] = []
    public var allLiveFotos: [PHAsset] = []
    
    public var allLargeVideos: [PHAsset] = []
    public var allSimmilarVideos: [PHAsset] = []
    public var allDuplicatesVideos: [PHAsset] = []
    public var allScreenRecords: [PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForAssetsCount()
        setupUI()
        updateColors()
        setupNavigation()
        setupTableView()
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

    @IBAction func didTapSelectStartDateActionButton(_ sender: Any) {
        self.isStartingDateSelected = true
        performSegue(withIdentifier: C.identifiers.segue.showDatePicker, sender: self)
    }
    
    @IBAction func didTapSelectEndDateActionButton(_ sender: Any) {
        self.isStartingDateSelected = false
        performSegue(withIdentifier: C.identifiers.segue.showDatePicker, sender: self)
    }
}

extension MediaContentViewController: UITableViewDelegate, UITableViewDataSource {

    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: C.identifiers.xibs.contentTypeCell, bundle: nil), forCellReuseIdentifier: C.identifiers.cells.contentTypeCell)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath) {
        
        var assetContentCount: Int = 0
    
        switch self.contentType {
            case .userPhoto:
                switch indexPath.row {
                    case 2:
                        assetContentCount = self.allScreenShots.count
                    case 3:
                        assetContentCount = self.allSelfies.count
                    case 4:
                        assetContentCount = self.allLiveFotos.count
                    default:
                        debugPrint("")
                }
            case .userVideo:
                switch indexPath.row {
                    case 0:
                        assetContentCount = self.allLargeVideos.count
                    case 1:
                        assetContentCount = self.allDuplicatesVideos.count
                    case 2:
                        assetContentCount = self.allSimmilarVideos.count
                    case 3:
                        assetContentCount = self.allScreenRecords.count
                    default:
                        debugPrint("")
                }
            case .userContacts:
                debugPrint("")
            default:
                return
        }
        
        cell.cellConfig(contentType: contentType, indexPath: indexPath, phasetCount: assetContentCount)
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return contentType.numberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.contentTypeCell, for: indexPath) as! ContentTypeTableViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentType.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showMediaContent(by: contentType, selected: indexPath.row)
    }
}

//      MARK: - show content controller -
extension MediaContentViewController {
    
    /// `0` - simmilar photos
    /// `1` -duplicates
    /// `2` - screenshots
    /// `3` - selfies
    /// `4` - detecting face???
    /// `5` -live photos
    /// `6` -location
    
    private func showMediaContent(by selectedType: MediaContentType, selected index: Int) {
        
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
                        return
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
//                        self.showSimmilarVideoFilesByTimeStamp()
                        self.showSimilarVideoFiles()
                    case 3:
                        self.showScreenRecordsVideoFiles()
                    default:
                        return
                }
            case .userContacts:
                debugPrint("show contacts")
            case .none:
                return
        }
    }
    
    private func showGropedContoller(assets title: String, grouped collection: [PhassetGroup], photoContent type: GropedAsset) {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
        let viewController  = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.groupedList) as! GroupedAssetListViewController
        viewController.assetGroups = collection
        viewController.title = title
        viewController.grouped = type
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showAssetViewController(assets title: String, collection: [PHAsset], photoContent type: PhotoMediaType) {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.assetsList) as! SimpleAssetsListViewController
        viewController.title = title
        viewController.assetCollection = collection
        viewController.photoMediaType = type
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
        photoManager.getSimilarPhotosAssets(from: startingDate, to: endingDate) { similarGroup in
            if !similarGroup.isEmpty {
                self.showGropedContoller(assets: "similar photo", grouped: similarGroup, photoContent: .similarPhotos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noSimiliarPhoto)
            }
        }
    }
    
    private func showLivePhotos() {
        
        photoManager.getLivePhotos { asset in
            if !asset.isEmpty {
                self.showAssetViewController(assets: "live photos", collection: asset, photoContent: .livephotos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noLivePhoto)
            }
        }
    }
    
    private func showDuplicatePhotos() {
        photoManager.getDuplicatedPhotosAsset(from: startingDate, to: endingDate) { duplicateGroup in
            if !duplicateGroup.isEmpty {
                self.showGropedContoller(assets: "duplicate photo", grouped: duplicateGroup, photoContent: .duplicatePhotos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noDuplicatesPhoto)
            }
        }
    }
    
    private func showSelfies() {
        photoManager.getSelfiePhotos(from: startingDate, to: endingDate) { selfies in
            if selfies.count != 0 {
                self.showAssetViewController(assets: "selfies", collection: selfies, photoContent: .selfies)
            } else {
                AlertManager.showCantFindMediaContent(by: .noSelfie)
            }
        }
    }
    
    private func showScreenshots() {
        photoManager.getScreenShots(from: startingDate, to: endingDate) { screenshots in
            if screenshots.count != 0 {
                self.showAssetViewController(assets: "screenshots", collection: screenshots, photoContent: .screenshots)
            } else {
                AlertManager.showCantFindMediaContent(by: .noScreenShots)
            }
        }
    }
    
    private func checkForAssetsCount() {
        
        if self.allScreenRecords.isEmpty {
            photoManager.getScreenRecordsVideos(from: S.startingSavedDate, to: S.endingSavedDate) { videoAssets in
                if videoAssets.count != 0 {
                    self.allScreenRecords = videoAssets
                } else {
                    return
                }
            }
        }
        
        if self.allLargeVideos.isEmpty {
            photoManager.getLargevideoContent(from: S.startingSavedDate, to: S.endingSavedDate) { videoAssets in
                if videoAssets.count != 0 {
                    self.allLargeVideos = videoAssets
                } else {
                    return
                }
            }
        }
    }
}

//      MARK: - video content -
extension MediaContentViewController {
    
    private func showLargeVideoFiles() {
        P.showIndicator()
        photoManager.getLargevideoContent(from: startingDate, to: endingDate) { videos in
            P.hideIndicator()
            if videos.count != 0 {
                self.showAssetViewController(assets: "large videos", collection: videos, photoContent: .largeVideos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noLargeVideo)
            }
        }
    }
    
    private func showDuplicateVideoFiles() {
        P.showIndicator()
        photoManager.getDuplicatedVideoAsset(from: startingDate, to: endingDate) { videoGrouped in
            P.hideIndicator()
            if videoGrouped.count != 0 {
                self.showGropedContoller(assets: "duplicated video", grouped: videoGrouped, photoContent: .duplicatedVideo)
            } else {
                AlertManager.showCantFindMediaContent(by: .noDuplicatesVideo)
            }
        }
    }
    
    private func showSimilarVideoFiles() {
        P.showIndicator()
        photoManager.getSimilarVideoAssets(from: startingDate, to: endingDate) { videos in
            P.hideIndicator()
            if videos.count != 0 {
                self.showGropedContoller(assets: "similar videos", grouped: videos, photoContent: .similarVideo)
            } else {
                AlertManager.showCantFindMediaContent(by: .noSimilarVideo)
            }
        }
    }
    
    private func showScreenRecordsVideoFiles() {
        P.showIndicator()
        photoManager.getScreenRecordsVideos(from: startingDate, to: endingDate) { videos in
            P.hideIndicator()
            if videos.count != 0 {
                self.showAssetViewController(assets: "screen records", collection: videos, photoContent: .screenRecording)
            } else {
                AlertManager.showCantFindMediaContent(by: .noScreenRecording)
            }
        }
    }
    
    private func showSimmilarVideoFilesByTimeStamp() {
        P.showIndicator()
        photoManager.getSimilarVideosByTimeStamp(from: startingDate, to: endingDate) { videos in
            P.hideIndicator()
            if videos.count != 0 {
                self.showGropedContoller(assets: "similar by time stam", grouped: videos, photoContent: .similarVideo)
            }
        }
    }
}

extension MediaContentViewController: Themeble {
    
    private func setupUI() {
        
        switch contentType {
            case .userPhoto:
                title = "title photo"
            case .userVideo:
                title = "title video"
            case .userContacts:
                title = "title contact"
                dateSelectContainerHeigntConstraint.constant = 0
                dateSelectContainerView.isHidden = true
            case .none:
                debugPrint("")
        }
        
        startingDateStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        startingDateStackView.isLayoutMarginsRelativeArrangement = true
        endingDateStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        endingDateStackView.isLayoutMarginsRelativeArrangement = true
    
        startingDateButtonView.setCorner(12)
        endingDateButtonView.setCorner(12)
        
        startingDateTitileTextLabel.text = "from"
        endingDateTitleTextLabel.text = "to"
        
        startingDateTextLabel.text = U.displayDate(from: startingDate)
        endingDateTextLabel.text = U.displayDate(from: endingDate)
        
        startingDateTextLabel.font = .systemFont(ofSize: 15, weight: .regular)
        endingDateTextLabel.font = .systemFont(ofSize: 15, weight: .regular)
        startingDateTitileTextLabel.font = .systemFont(ofSize: 15, weight: .medium)
        endingDateTextLabel.font = .systemFont(ofSize: 15, weight: .medium)
    }
    
    private func setupNavigation() {
        self.navigationController?.updateNavigationColors()
        self.navigationItem.backButtonTitle = ""
    }
    
    func updateColors() {
        dateSelectContainerView.addBottomBorder(with: currentTheme.contentBackgroundColor, andWidth: 1)
        startingDateButtonView.backgroundColor = currentTheme.contentBackgroundColor
        endingDateButtonView.backgroundColor = currentTheme.contentBackgroundColor
        
        startingDateTitileTextLabel.textColor = currentTheme.titleTextColor
        endingDateTextLabel.textColor = currentTheme.titleTextColor
        
        startingDateTitileTextLabel.textColor = currentTheme.subTitleTextColor
        endingDateTitleTextLabel.textColor = currentTheme.subTitleTextColor
    }
    
    private func setupShowDatePickerSelectorController(segue: UIStoryboardSegue) {
        
        if let segue = segue as? SwiftMessagesSegue {
            segue.configure(layout: .bottomMessage)
            segue.dimMode = .gray(interactive: false)
            segue.interactiveHide = false
            segue.messageView.configureNoDropShadow()
            segue.messageView.backgroundHeight = Device.isSafeAreaiPhone ? 458 : 438
            
            if let dateSelectorController = segue.destination as? DateSelectorViewController {
                dateSelectorController.isStartingDateSelected = self.isStartingDateSelected
                dateSelectorController.setPicker(self.isStartingDateSelected ? self.startingDate : self.endingDate)
                
                dateSelectorController.selectedDateCompletion = { selectedDate in
                    if self.isStartingDateSelected {
                        self.startingDate = selectedDate
                        self.startingDateTextLabel.text = U.displayDate(from: selectedDate)
                    } else {
                        self.endingDate = selectedDate
                        self.endingDateTextLabel.text = U.displayDate(from: selectedDate)
                    }
                }
            }
        }
    }
}
