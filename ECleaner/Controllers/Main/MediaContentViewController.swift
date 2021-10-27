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
  
    @IBOutlet weak var customNavBar: CustomNavigationBar!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateSelectContainerView: UIView!
    @IBOutlet weak var dateSelectContainerHeigntConstraint: NSLayoutConstraint!
    
    var dateSelectableView = DateSelectebleView()
    
    public var contentType: MediaContentType = .none
    private var photoManager = PhotoManager()
    private var contactsManager = ContactsManager.shared
    
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
    public var allRecentlyDeletedPhotos: [PHAsset] = []
    
    public var allLargeVideos: [PHAsset] = []
    public var allSimmilarVideos: [PHAsset] = []
    public var allDuplicatesVideos: [PHAsset] = []
    public var allScreenRecords: [PHAsset] = []
    public var allRecentlyDeletedVideos: [PHAsset] = []
    
    public var allContacts: [CNContact] = []
    public var allEmptyContacts: [ContactsGroup] = []
    public var allDuplicatedContacts: [ContactsGroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForAssetsCount()
        setupUI()
        setupDateInterval()
        updateColors()
        setupNavigation()
        setupTableView()
        setupObserversAndDelegate()
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
        var photoMediaType: PhotoMediaType = .none
    
        switch self.contentType {
            case .userPhoto:
                switch indexPath.row {
                    case 0:
                        photoMediaType = .similarPhotos
                    case 1:
                        photoMediaType = .duplicatedPhotos
                    case 2:
                        photoMediaType = .singleScreenShots
                        assetContentCount = self.allScreenShots.count
                    case 3:
                        photoMediaType = .singleSelfies
                        assetContentCount = self.allSelfies.count
                    case 4:
                        photoMediaType = .singleLivePhotos
                        assetContentCount = self.allLiveFotos.count
                    case 5:
                        photoMediaType = .singleRecentlyDeletedPhotos
                        assetContentCount = self.allRecentlyDeletedPhotos.count
                    default:
                        debugPrint("")
                }
            case .userVideo:
                switch indexPath.row {
                    case 0:
                        photoMediaType = .singleLargeVideos
                        assetContentCount = self.allLargeVideos.count
                    case 1:
                        photoMediaType = .duplicatedVideos
                        assetContentCount = self.allDuplicatesVideos.count
                    case 2:
                        photoMediaType = .similarVideos
                        assetContentCount = self.allSimmilarVideos.count
                    case 3:
                        photoMediaType = .singleScreenRecordings
                        assetContentCount = self.allScreenRecords.count
                    case 4:
                        photoMediaType = .compress
                    case 5:
                        photoMediaType = .singleRecentlyDeletedVideos
                        assetContentCount = self.allRecentlyDeletedVideos.count
                    default:
                        debugPrint("")
                }
            case .userContacts:
                switch indexPath.row {
                    case 0:
                        photoMediaType = .allContacts
                        assetContentCount = self.allContacts.count
                    case 1:
                        photoMediaType = .emptyContacts
                        assetContentCount = self.allEmptyContacts.count
                    case 2:
                        photoMediaType = .duplicatedContacts
                        assetContentCount = self.allDuplicatedContacts.count
                    default:
                        return                        
                }
            default:
                return
        }
        
        cell.cellConfig(contentType: self.contentType, photoMediaType: photoMediaType, indexPath: indexPath, phasetCount: assetContentCount, progress: 0)
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
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showMediaContent(by: contentType, selected: indexPath.row)
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
                        self.showDuplicatedContacts()
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
                self.showAssetViewController(assets: "live photos", collection: asset, photoContent: .singleLivePhotos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noLivePhoto)
            }
        }
    }
    
    private func showDuplicatePhotos() {
        photoManager.getDuplicatedPhotosAsset(from: startingDate, to: endingDate) { duplicateGroup in
            if !duplicateGroup.isEmpty {
                self.showGropedContoller(assets: "duplicate photo", grouped: duplicateGroup, photoContent: .duplicatedPhotos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noDuplicatesPhoto)
            }
        }
    }
    
    private func showSelfies() {
        photoManager.getSelfiePhotos(from: startingDate, to: endingDate) { selfies in
            if selfies.count != 0 {
                self.showAssetViewController(assets: "selfies", collection: selfies, photoContent: .singleSelfies)
            } else {
                AlertManager.showCantFindMediaContent(by: .noSelfie)
            }
        }
    }
    
    private func showScreenshots() {
        photoManager.getScreenShots(from: startingDate, to: endingDate) { screenshots in
            if screenshots.count != 0 {
                self.showAssetViewController(assets: "screenshots", collection: screenshots, photoContent: .singleScreenShots)
            } else {
                AlertManager.showCantFindMediaContent(by: .noScreenShots)
            }
        }
    }
    
    private func showRecentlyDeletedPhotos() {
        photoManager.getSortedRecentlyDeletedAssets { deletedPhotos, _ in
            if deletedPhotos.count != 0 {
                self.showAssetViewController(assets: "recently deleted photos", collection: deletedPhotos, photoContent: .singleRecentlyDeletedPhotos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noRecentlyDeletedPhotos)
            }
        }
    }
    
    private func showRecentlyDeletedVideos() {
        photoManager.getSortedRecentlyDeletedAssets { _, deletedVideos in
            if deletedVideos.count != 0 {
                self.showAssetViewController(assets: "resently deleted Videos", collection: deletedVideos, photoContent: .singleRecentlyDeletedVideos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noRecentlyDeletedVideos)
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
                self.showAssetViewController(assets: "large videos", collection: videos, photoContent: .singleLargeVideos)
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
                self.showGropedContoller(assets: "duplicated video", grouped: videoGrouped, photoContent: .duplicatedVideos)
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
                self.showGropedContoller(assets: "similar videos", grouped: videos, photoContent: .similarVideos)
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
                self.showAssetViewController(assets: "screen records", collection: videos, photoContent: .singleScreenRecordings)
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
                self.showGropedContoller(assets: "similar by time stam", grouped: videos, photoContent: .similarVideos)
            }
        }
    }
}

//      MARK: - contacts content -
extension MediaContentViewController {
    
    private func showAllContacts() {
        
    }
    
    private func showEmptyGroupsContacts() {
        
        
    }
    
    private func showDuplicatedContacts() {
        P.showIndicator()
        contactsManager.getDuplicatedAllContacts(self.allContacts) { groupedContacts in
            #warning("WORK in PROGRESS")
            for group in groupedContacts {
                
                debugPrint("group ->")
                for contac in group.contacts {
                    debugPrint(contac)
                }
            }
            
            debugPrint(groupedContacts.count)
            P.hideIndicator()
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

extension MediaContentViewController: CustomNavigationBarDelegate {
    
    func didTapLeftBarButton(_sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapRightBarButton(_sender: UIButton) {}  
}

extension MediaContentViewController: Themeble {
    
    private func setupUI() {
        
        if contentType == .userContacts {
            
            dateSelectContainerHeigntConstraint.constant = 0
            dateSelectContainerView.isHidden = true
        }
        
        dateSelectableView.frame = dateSelectContainerView.bounds
        dateSelectContainerView.addSubview(dateSelectableView)
        
        dateSelectableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateSelectableView.leadingAnchor.constraint(equalTo: dateSelectContainerView.leadingAnchor),
            dateSelectableView.trailingAnchor.constraint(equalTo: dateSelectContainerView.trailingAnchor),
            dateSelectableView.bottomAnchor.constraint(equalTo: dateSelectContainerView.bottomAnchor),
            dateSelectableView.topAnchor.constraint(equalTo: dateSelectContainerView.topAnchor)])
    }
    
    private func setupNavigation() {
        
        self.navigationController?.navigationBar.isHidden = true
        customNavBar.setUpNavigation(title: contentType.navTitle, leftImage: I.navigationItems.back, rightImage: nil)
    }
    
    private func setupObserversAndDelegate() {
        
        self.dateSelectableView.delegate = self
        self.customNavBar.delegate = self
    }
    
    private func setupDateInterval() {
        
        self.dateSelectableView.setupDisplaysDate(startingDate: self.startingDate, endingDate: self.endingDate)
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor
//        dateSelectContainerView.addBottomBorder(with: theme.contentBackgroundColor, andWidth: 1)
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
