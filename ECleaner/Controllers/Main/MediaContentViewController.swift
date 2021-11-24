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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateSelectContainerView: UIView!
    @IBOutlet weak var dateSelectContainerHeigntConstraint: NSLayoutConstraint!
    
    var dateSelectableView = DateSelectebleView()
    
    public var mediaContentType: MediaContentType = .none
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
    public var allDuplicatedPhoneNumbers: [ContactsGroup] = []
    public var allDuplicatedEmailAdresses: [ContactsGroup] = []
    
    private var singleSearchContactsProgress: [CGFloat] = [0,0,0,0,0]
    private var totalSearchFindContactsCointIn: [Int] = [0,0,0,0,0]
    private var currentProgressForMediaType: [PhotoMediaType : CGFloat] = [:]
    
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
        tableView.contentInset.top = 20
    }
    
    func configure(_ cell: ContentTypeTableViewCell, at indexPath: IndexPath, isSearchingStarted: Bool = false) {
    
        let  photoMediaType: PhotoMediaType = MediaType.getSingleSearchMediaContentType(from: indexPath, type: mediaContentType)
        
        var assetContentCount: Int {
            switch photoMediaType {
                case .similarPhotos:
                    return 0
                case .duplicatedPhotos:
                    return 0
                case .singleScreenShots:
                    return self.allScreenShots.count
                case .singleLivePhotos:
                    return self.allLiveFotos.count
                case .similarLivePhotos:
                    return 0
                case .singleLargeVideos:
                    return self.allLargeVideos.count
                case .duplicatedVideos:
                    return self.allDuplicatesVideos.count
                case .similarVideos:
                    return self.allSimmilarVideos.count
                case .singleSelfies:
                    return self.allSelfies.count
                case .singleScreenRecordings:
                    return self.allScreenRecords.count
                case .singleRecentlyDeletedPhotos:
                    return self.allRecentlyDeletedPhotos.count
                case .singleRecentlyDeletedVideos:
                    return self.allRecentlyDeletedVideos.count
                case .compress:
                    return 0
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
                case .none:
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
    /// `2` - duplicated contacts
        
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
                        self.showDuplicatedNamesContacts()
                    case 3:
                        self.showDuplicatedPhoneNumbersContacts()
                    case 4:
                        self.showDuplicatedEmailsContacts()
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
        photoManager.getSimilarPhotosAssets(from: startingDate, to: endingDate) { similarGroup in
            if !similarGroup.isEmpty {
                self.showGropedContoller(assets: "similar photo", grouped: similarGroup, photoContent: .similarPhotos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noSimiliarPhoto) {}
            }
        }
    }
    
    private func showLivePhotos() {
        
        photoManager.getLivePhotos { asset in
            if !asset.isEmpty {
                self.showAssetViewController(assets: "live photos", collection: asset, photoContent: .singleLivePhotos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noLivePhoto) {}
            }
        }
    }
    
    private func showDuplicatePhotos() {
        photoManager.getDuplicatedPhotosAsset(from: startingDate, to: endingDate) { duplicateGroup in
            if !duplicateGroup.isEmpty {
                self.showGropedContoller(assets: "duplicate photo", grouped: duplicateGroup, photoContent: .duplicatedPhotos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noDuplicatesPhoto) {}
            }
        }
    }
    
    private func showSelfies() {
        photoManager.getSelfiePhotos(from: startingDate, to: endingDate) { selfies in
            if selfies.count != 0 {
                self.showAssetViewController(assets: "selfies", collection: selfies, photoContent: .singleSelfies)
            } else {
                AlertManager.showCantFindMediaContent(by: .noSelfie) {}
            }
        }
    }
    
    private func showScreenshots() {
        photoManager.getScreenShots(from: startingDate, to: endingDate) { screenshots in
            if screenshots.count != 0 {
                self.showAssetViewController(assets: "screenshots", collection: screenshots, photoContent: .singleScreenShots)
            } else {
                AlertManager.showCantFindMediaContent(by: .noScreenShots) {}
            }
        }
    }
    
    private func showRecentlyDeletedPhotos() {
        photoManager.getSortedRecentlyDeletedAssets { deletedPhotos, _ in
            if deletedPhotos.count != 0 {
                self.showAssetViewController(assets: "recently deleted photos", collection: deletedPhotos, photoContent: .singleRecentlyDeletedPhotos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noRecentlyDeletedPhotos) {}
            }
        }
    }
    
    private func showRecentlyDeletedVideos() {
        photoManager.getSortedRecentlyDeletedAssets { _, deletedVideos in
            if deletedVideos.count != 0 {
                self.showAssetViewController(assets: "resently deleted Videos", collection: deletedVideos, photoContent: .singleRecentlyDeletedVideos)
            } else {
                AlertManager.showCantFindMediaContent(by: .noRecentlyDeletedVideos) {}
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
                AlertManager.showCantFindMediaContent(by: .noLargeVideo) {}
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
                AlertManager.showCantFindMediaContent(by: .noDuplicatesVideo) {}
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
                AlertManager.showCantFindMediaContent(by: .noSimilarVideo) {}
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
                AlertManager.showCantFindMediaContent(by: .noScreenRecording) {}
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
        self.contactsManager.getEmptyContacts { contactsGroup in
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
                 
    private func showDuplicatedNamesContacts() {
        self.contactsManager.getDuplicatedContacts(of: .duplicatedContactName) { contactsGroup in
            U.delay(1) {
                
                SingleSearchNitificationManager.instance.sendSingleSearchProgressNotification(notificationtype: .duplicatesNames, totalProgressItems: 1, currentProgressItem: 1)
                
                U.delay(0.5) {
                    if contactsGroup.count != 0 {
                        let group = contactsGroup.sorted(by: {$0.name < $1.name})
                        self.showGroupedContactsViewController(contacts: group, group: .duplicatedContactName, content: .duplicatedContacts)
                    } else {
                        A.showEmptyContactsToPresent(of: .duplicatesNamesIsEmpty) {}
                    }
                }
            }
        }
    }
    
    private func showDuplicatedPhoneNumbersContacts() {
        P.showIndicator()
        self.contactsManager.getDuplicatedContacts(of: .duplicatedPhoneNumnber) { contactsGroup in
            U.UI {
                P.hideIndicator()
                if contactsGroup.count != 0 {
                    let group = contactsGroup.sorted(by: {$0.name < $1.name})
                    self.showGroupedContactsViewController(contacts: group, group: .duplicatedPhoneNumnber, content: .duplicatedPhoneNumbers)
                } else {
                    A.showEmptyContactsToPresent(of: .duplicatesNumbersIsEmpty) {}
                }
            }
        }
    }
    
    private func showDuplicatedEmailsContacts() {
        self.contactsManager.getDuplicatedContacts(of: .duplicatedEmail) { contactsGroup in
            U.delay(1) {
                if contactsGroup.count != 0 {
                    let group = contactsGroup.sorted(by: {$0.name < $1.name})
                    self.showGroupedContactsViewController(contacts: group, group: .duplicatedEmail, content: .duplicatedEmails)
                } else {
                    A.showEmptyContactsToPresent(of: .duplicatesEmailsIsEmpty) {}
                }
            }
        }
    }
}

//      MARK: - handle progressUpdating cell content

extension MediaContentViewController {
    
    @objc func handleContentProgressUpdateNotification(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        switch notification.name {
                
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
                self.progressUpdate(type, progrss: progress, title: optionalTitle)
            }
        }
    }
    
    private func handleSearchProgress(by type: SingleContentSearchNotificationType, files count: Int) {
        
        switch type {
                
                    /// `Contacts:
            case .allContacts:
                totalSearchFindContactsCointIn[0] = count
            case .emptyContacts:
                totalSearchFindContactsCointIn[1] = count
            case .duplicatesNames:
                totalSearchFindContactsCointIn[2] = count
            case .duplicatesNumbers:
                totalSearchFindContactsCointIn[3] = count
            case .duplicatesEmails:
                totalSearchFindContactsCointIn[4] = count
        }
    }
    
    private func calculateProgressPercentage(total: Int, current: Int, completionHandler: @escaping (String, CGFloat) -> Void) {
        
        let percentString: String = "%. f %%"
        let totalPercent = CGFloat(Double(current) / Double(total))
        let stringFormat = String(format: percentString, totalPercent)
        completionHandler(stringFormat, totalPercent)
    }
    
    private func progressUpdate(_ notificationType: SingleContentSearchNotificationType, progrss: CGFloat, title: String) {
        
        let indexPath = notificationType.mediaTypeRawValue.singleSearchIndexPath
        self.currentProgressForMediaType[notificationType.mediaTypeRawValue] = progrss
        
        switch notificationType {
            case .allContacts:
                self.singleSearchContactsProgress[0] = progrss
            case .emptyContacts:
                self.singleSearchContactsProgress[1] = progrss
            case .duplicatesNames:
                self.singleSearchContactsProgress[2] = progrss
            case .duplicatesNumbers:
                self.singleSearchContactsProgress[3] = progrss
            case .duplicatesEmails:
                self.singleSearchContactsProgress[4] = progrss
        }
        
        guard !indexPath.isEmpty else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? ContentTypeTableViewCell else { return }
        
        let isSearchStarted = progrss != 0 || progrss != 1.0
        
        self.configure(cell, at: indexPath, isSearchingStarted: isSearchStarted)
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


extension MediaContentViewController: Themeble {
    
    private func setupUI() {
        
        if mediaContentType == .userContacts {
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
        navigationBar.setupNavigation(title: mediaContentType.navigationTitle,
                                      leftBarButtonImage: I.navigationItems.back,
                                      rightBarButtonImage: nil,
                                      mediaType: mediaContentType,
                                      leftButtonTitle: nil,
                                      rightButtonTitle: nil)
    }
    
        
    private func setupObserversAndDelegate() {
        
        self.dateSelectableView.delegate = self
        self.navigationBar.delegate = self
        
            /// `contacts notification updates`
        U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchAllContactsScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchEmptyContactsScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchDuplicatesNamesContactsScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchDuplicatesNumbersContactsScan, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(handleContentProgressUpdateNotification(_:)), name: .singleSearchDupliatesEmailsContactsScan, object: nil)
    }
    
    private func setupDateInterval() {
        
        self.dateSelectableView.setupDisplaysDate(startingDate: self.startingDate, endingDate: self.endingDate)
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
            dateSelectorController.setPicker(self.isStartingDateSelected ? self.startingDate : self.endingDate)
            
            dateSelectorController.selectedDateCompletion = { selectedDate in
                self.isStartingDateSelected ? (self.startingDate = selectedDate) : (self.endingDate = selectedDate)
                self.dateSelectableView.setupDisplaysDate(startingDate: self.startingDate, endingDate: self.endingDate)
            }
        }
    }
}
