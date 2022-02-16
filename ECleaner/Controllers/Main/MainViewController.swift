//
//  MainViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit
import Photos
import SwiftMessages
import Contacts

class MainViewController: UIViewController {
  
    @IBOutlet weak var navigationBar: StartingNavigationBar!
    @IBOutlet weak var bottomButtonBarView: BottomButtonBarView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var circleTotlaSpaceView: CircleProgressView!
    @IBOutlet weak var circleProgressView: MMTGradientArcView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var sectionHeaderTextLabel: UILabel!
	
    private let baseCarouselLayout = BaseCarouselFlowLayout()
        
	private var photoMenager = PhotoManager.shared
	private var singleCleanModel: SingleCleanModel!
    
    private var contentCount: [MediaContentType : Int] = [:]
    private var diskSpaceForStartingScreen: [MediaContentType : Int64] = [:]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		initializeSingleCleanModel()
        setupObserversAndDelegates()
        setupNavigation()
        setupUI()
        setupProgressAndCollectionSize()
        setupCollectionView()
        setupCircleProgressView()
        updateColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigation()
        updateContactsCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
	
	private func initializeSingleCleanModel() {
		 
		var objects: [PhotoMediaType : SingleCleanStateModel] = [:]
		objects[.similarPhotos] = SingleCleanStateModel(type: .similarPhotos)
		objects[.duplicatedPhotos] = SingleCleanStateModel(type: .duplicatedPhotos)
		objects[.singleScreenShots] = SingleCleanStateModel(type: .singleScreenShots)
		objects[.similarSelfies] = SingleCleanStateModel(type: .similarSelfies)
		objects[.singleLivePhotos] = SingleCleanStateModel(type: .singleLivePhotos)
		
		objects[.singleLargeVideos] = SingleCleanStateModel(type: .singleLargeVideos)
		objects[.duplicatedVideos] = SingleCleanStateModel(type: .duplicatedVideos)
		objects[.similarVideos] = SingleCleanStateModel(type: .similarVideos)
		objects[.singleScreenRecordings] = SingleCleanStateModel(type: .singleScreenRecordings)
		
		objects[.allContacts] = SingleCleanStateModel(type: .allContacts)
		objects[.emptyContacts] = SingleCleanStateModel(type: .emptyContacts)
		objects[.duplicatedContacts] = SingleCleanStateModel(type: .duplicatedContacts)
		objects[.duplicatedPhoneNumbers] = SingleCleanStateModel(type: .duplicatedPhoneNumbers)
		objects[.duplicatedEmails] = SingleCleanStateModel(type: .duplicatedEmails)
		self.singleCleanModel = SingleCleanModel(objects: objects)
	}
}

extension MainViewController {
    
    @objc func updatingContentDisplayInformation(_ notification: Notification) {
        
        switch notification.name {
            case .mediaSpaceDidChange:
                self.updateCircleProgress()
            case .photoSpaceDidChange:
                self.updateInformation(.userPhoto)
            case .videoSpaceDidChange:
                self.updateInformation(.userVideo)
            case .contactsCountDidChange:
                self.updateInformation(.userContacts)
            default:
                return
        }
    }
    
    private func updateInformation(_ contentType: MediaContentType) {
		U.UI {
			let contentCount = self.contentCount[contentType]
			let diskUsage = SettingsManager.getDiskSpaceFiles(of: contentType)
			self.diskSpaceForStartingScreen[contentType] = diskUsage
			if let cell = self.mediaCollectionView.cellForItem(at: contentType.mainScreenIndexPath) as? MediaTypeCollectionViewCell {
				cell.configureCell(mediaType: contentType, contentCount: contentCount, diskSpace: diskUsage)
			}
		}
    }
    
    private func updateCircleProgress() {}
}

//      MARK: - updating elements -
extension MainViewController: UpdateContentDataBaseListener {
    
    func updateContentStoreCount(mediaType: MediaContentType, itemsCount: Int, calculatedSpace: Int64?) {
		U.delay(1) {
			self.contentCount[mediaType] = itemsCount
			if let calculatedSpace = calculatedSpace {
				self.diskSpaceForStartingScreen[mediaType] = calculatedSpace
			}
			if let cell = self.mediaCollectionView.cellForItem(at: mediaType.mainScreenIndexPath) as? MediaTypeCollectionViewCell {
				cell.configureCell(mediaType: mediaType, contentCount: itemsCount, diskSpace: calculatedSpace)
			}
		}
    }

    func getScreenAssets(_ assets: [PHAsset]) {
		self.singleCleanModel.objects[.singleScreenShots]?.phassets = assets
    }
    
    func getLivePhotosAssets(_ assets: [PHAsset]) {
		self.singleCleanModel.objects[.singleLivePhotos]?.phassets = assets
    }
    
    func getLargeVideosAssets(_ assets: [PHAsset]) {
		self.singleCleanModel.objects[.singleLargeVideos]?.phassets = assets
    }
    
    func getSimmilarVideosAssets(_ assets: [PhassetGroup]) {
		self.singleCleanModel.objects[.similarVideos]?.phassetGroup = assets
    }
    
    func getDuplicateVideosAssets(_ assets: [PhassetGroup]) {
		self.singleCleanModel.objects[.duplicatedVideos]?.phassetGroup = assets
    }
    
    func getScreenRecordsVideosAssets(_ assets: [PHAsset]) {
		self.singleCleanModel.objects[.singleScreenRecordings]?.phassets = assets
    }
    
    func getRecentlyDeletedPhotoAsssets(_ assets: [PHAsset]) {
		self.singleCleanModel.objects[.singleRecentlyDeletedPhotos]?.phassets = assets
    }
    
    func getRecentlyDeletedVideoAssets(_ assts: [PHAsset]) {
		self.singleCleanModel.objects[.singleRecentlyDeletedVideos]?.phassets = assts
    }
    
    func getAllCNContacts(_ contacts: [CNContact]) {
		self.singleCleanModel.objects[.allContacts]?.contacts = contacts
    }
    
    func getAllDuplicatedContacts(_ contacts: [ContactsGroup]) {
		self.singleCleanModel.objects[.duplicatedContacts]?.contactsGroup = contacts
    }
    
    func getAllEmptyContacts(_ contacts: [ContactsGroup]) {
		self.singleCleanModel.objects[.emptyContacts]?.contactsGroup = contacts
    }
    
    func getAllDuplicatedContactsGroup(_ contctsGroup: [ContactsGroup]) {
		self.singleCleanModel.objects[.duplicatedContacts]?.contactsGroup = contctsGroup
    }
    
    func getAllDuplicatedNumbersContactsGroup(_ contctsGroup: [ContactsGroup]) {
		self.singleCleanModel.objects[.duplicatedPhoneNumbers]?.contactsGroup = contctsGroup
    }
    
    func getAllDuplicatedEmailsContactsGroup(_ contctsGroup: [ContactsGroup]) {
		self.singleCleanModel.objects[.duplicatedEmails]?.contactsGroup = contctsGroup
    }
}

extension MainViewController {
    
    private func openMediaController(type: MediaContentType) {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.content) as! MediaContentViewController
		viewController.singleCleanModel = self.singleCleanModel
		ContactsManager.shared.contactsProcessingOperationQueuer.cancelAll()
        viewController.mediaContentType = type
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func openDeepCleanController() {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.deep, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.deepClean) as! DeepCleaningViewController
    
        viewController.scansOptions = [.similarPhotos,
									   .duplicatedPhotos,
									   .singleScreenShots,
									   .similarSelfies,
									   .similarLivePhotos,
									   .singleLargeVideos,
									   .duplicatedVideos,
									   .similarVideos,
									   .singleScreenRecordings,
									   .emptyContacts,
									   .duplicatedContacts,
									   .duplicatedPhoneNumbers,
									   .duplicatedEmails
		]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func openSettingsController() {
		
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.settings, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.settings) as! SettingsViewController
		self.navigationController?.pushViewController(viewController, animated: true)
	}
    
    private func openSubscriptionController() {}
}

extension MainViewController {
    
    @objc func contactsStoreDidChange() {
		U.delay(5) {
			self.updateContactsCount()			
		}
    }
    
    private func updateContactsCount() {
        ContactsManager.shared.getAllContacts { contacts in
            self.getAllCNContacts(contacts)
            self.contentCount[.userContacts] = contacts.count
            self.updateInformation(.userContacts)
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.mediaTypeCell, for: indexPath) as! MediaTypeCollectionViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
            case 0:
                self.openMediaController(type: .userPhoto)
            case 1:
                self.openMediaController(type: .userVideo)
            case 2:
				ContactsManager.shared.setProcess(.search, state: .disable)
                self.openMediaController(type: .userContacts)
            default:
                return
        }
    }
}

extension MainViewController {
    
    private func setupCollectionView() {
        
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.collectionViewLayout = baseCarouselLayout
        mediaCollectionView.register(UINib(nibName: C.identifiers.xibs.mediaTypeCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.mediaTypeCell)
        mediaCollectionView.showsVerticalScrollIndicator = false
        mediaCollectionView.showsHorizontalScrollIndicator = false
    }

    private func configure(_ cell: MediaTypeCollectionViewCell, at indexPath: IndexPath) {
        
        let mediaContentType = getMainScreenCellType(by: indexPath)
        let diskInUse = diskSpaceForStartingScreen[getMainScreenCellType(by: indexPath)]
        cell.configureCell(mediaType: mediaContentType, contentCount: contentCount[mediaContentType], diskSpace: diskInUse)
    }
    
    private func getMainScreenCellType(by indexPath: IndexPath) -> MediaContentType {
        switch indexPath {
            case IndexPath(row: 0, section: 0):
                return .userPhoto
            case IndexPath(row: 1, section: 0):
                return .userVideo
            case IndexPath(row: 2, section: 0):
                return .userContacts
            default:
                return .none
        }
    }
}

extension MainViewController: BottomActionButtonDelegate, StartingNavigationBarDelegate {
    
    func didTapLeftBarButton(_sender: UIButton) {
        self.openSubscriptionController()
    }
    
    func didTapRightBarButton(_sender: UIButton) {
        self.openSettingsController()
    }
    
    func didTapActionButton() {
        self.openDeepCleanController()
    }
}

extension MainViewController: UpdateColorsDelegate {
    
    private func setupObserversAndDelegates() {
        UpdateContentDataBaseMediator.instance.setListener(listener: self)
        bottomButtonBarView.delegate = self
        navigationBar.delegate = self
        
        U.notificationCenter.addObserver(self, selector: #selector(updatingContentDisplayInformation(_:)), name: .photoSpaceDidChange, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(updatingContentDisplayInformation(_:)), name: .videoSpaceDidChange, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(updatingContentDisplayInformation(_:)), name: .mediaSpaceDidChange, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(updatingContentDisplayInformation(_:)), name: .contactsCountDidChange, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(contactsStoreDidChange), name: .CNContactStoreDidChange, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(removeStoreObserver), name: .removeContactsStoreObserver, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(addStoreObserver), name: .addContactsStoreObserver, object: nil)
    }
	
	@objc func removeStoreObserver() {
		U.notificationCenter.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
	}
	
	@objc func addStoreObserver() {
		U.notificationCenter.addObserver(self, selector: #selector(contactsStoreDidChange), name: .CNContactStoreDidChange, object: nil)
	}
    
    private func setupNavigation() {
            
        self.navigationController?.navigationBar.isHidden = true
        navigationBar.setUpNavigation(title: nil, leftImage: I.systemItems.navigationBarItems.premium, rightImage: I.systemItems.navigationBarItems.settings)
    }
    
    private func setupUI() {
                
        scrollView.alwaysBounceVertical = true
        bottomButtonBarView.title("START DEEP CLEAN")
        bottomButtonBarView.actionButton.imageSize = CGSize(width: 25, height: 25)
        bottomButtonBarView.setImage(I.mainStaticItems.clean)
		
		sectionHeaderTextLabel.text = "Select Category"
		sectionHeaderTextLabel.font = .systemFont(ofSize: 14, weight: .heavy)
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor
		sectionHeaderTextLabel.textColor = theme.subTitleTextColor
        bottomButtonBarView.buttonColor = theme.cellBackGroundColor
        bottomButtonBarView.buttonTintColor = theme.secondaryTintColor
        bottomButtonBarView.buttonTitleColor = theme.activeLinkTitleTextColor
        bottomButtonBarView.configureShadow = true
        bottomButtonBarView.addButtonShadow()
        bottomButtonBarView.updateColorsSettings()
    }
    
    private func setupProgressAndCollectionSize() {
        
		circleTotlaSpaceView.font = .systemFont(ofSize: 50, weight: .black)
		circleTotlaSpaceView.percentLabel.font = .systemFont(ofSize: 50, weight: .black)
      circleTotlaSpaceView.percentLabelCenterInset = 45
      
      switch Screen.size {
        case .small:
          debugPrint("")
            //                circleProgressBarViewHeightConstraint.constant = 140
//          circleTotlaSpaceView.lineWidth = 10
//          circleTotlaSpaceView.titleLabelBottomInset = (circleTotlaSpaceView.frame.height / 2) - 10
//          circleTotlaSpaceView.percentLabelCenterInset = 25
//          circleTotlaSpaceView.titleLabel.font = .systemFont(ofSize: 11, weight: .regular)
//          circleTotlaSpaceView.percentLabel.font = .systemFont(ofSize: 18, weight: .bold)
//
//          circleTotlaSpaceView.layoutIfNeeded()
//          self.view.layoutIfNeeded()
//
//          baseCarouselLayout.itemSize = CGSize(width: 138, height: mediaCollectionView.frame.height)
          
        case .medium:
          debugPrint("")
//          circleTotlaSpaceView.lineWidth = 20
//          circleTotlaSpaceView.titleLabelBottomInset = (circleTotlaSpaceView.frame.height / 2) + 10
//          circleTotlaSpaceView.titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
//          circleTotlaSpaceView.percentLabel.font = .systemFont(ofSize: 25, weight: .black)
//          circleTotlaSpaceView.percentLabelCenterInset = 25
        case .plus:
          debugPrint("")
          collectionViewHeightConstraint.constant = 260
          
          circleTotlaSpaceView.font = UIFont(font: FontManager.robotoBlack, size: 20.0)!
          circleTotlaSpaceView.percentLabel.font = UIFont(font: FontManager.robotoBlack, size: 20.0)
        case .large:
          debugPrint("")
          collectionViewHeightConstraint.constant = 260
          
          circleTotlaSpaceView.font = UIFont(font: FontManager.robotoBlack, size: 45.0)!
          circleTotlaSpaceView.percentLabel.font = UIFont(font: FontManager.robotoBlack, size: 45.0)
        case .modern:
          debugPrint("")
          
          collectionViewHeightConstraint.constant = 260
          
          circleTotlaSpaceView.font = UIFont(font: FontManager.robotoBlack, size: 50.0)!
          circleTotlaSpaceView.percentLabel.font = UIFont(font: FontManager.robotoBlack, size: 50.0)
        case .max:
          debugPrint("")
        case .madMax:
          debugPrint("")
      }
    }
    
    private func setupCircleProgressView() {
        
        let calculatePercentage: Double = Double(Device.usedDiskSpaceInBytes) / Double(Device.totalDiskSpaceInBytes)

        circleTotlaSpaceView.setProgress(progress: CGFloat(calculatePercentage), animated: true)
        circleTotlaSpaceView.progressShapeColor = theme.tintColor
        circleTotlaSpaceView.backgroundShapeColor = theme.topShadowColor.withAlphaComponent(0.2)
        circleTotlaSpaceView.titleColor = theme.subTitleTextColor
        circleTotlaSpaceView.percentColor = theme.titleTextColor

        circleTotlaSpaceView.orientation = .bottom
        circleTotlaSpaceView.lineCap = .round
        circleTotlaSpaceView.clockwise = true

        circleTotlaSpaceView.title = "\(Device.usedDiskSpaceInGB.removeWhitespace()) FROM \(Device.totalDiskSpaceInGB.removeWhitespace()) USED"
        circleTotlaSpaceView.percentLabelFormat = "%.f%%"
    }
}
