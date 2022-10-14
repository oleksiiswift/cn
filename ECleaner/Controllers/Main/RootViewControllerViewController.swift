//
//  RootViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 08.10.2022.
//

import UIKit
import Photos
import SwiftMessages
import Contacts

class RootViewController: UIViewController {

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var navigationBar: StartingNavigationBar!
	@IBOutlet weak var headerView: UIView!
	
	@IBOutlet weak var headerContainerView: UIView!
	
	@IBOutlet weak var headerContainerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var collectionContainerView: UIView!
	@IBOutlet weak var collectionContainerHeightConstraint: NSLayoutConstraint!
	
	var collectionContainerBottomHelperView = UIView()
	
	weak var coordinator: ApplicationCoordinator?
	
	private var rootViewModel: RootViewModel!
	private var rootDataSource: RootDataSource!
	private var singleCleanModel: SingleCleanModel!
	
	private var subscriptionManager = SubscriptionManager.instance
	private var permissionManager = PermissionManager.shared
	private var photoManager = PhotoManager.shared
	
	
	private var itemHeight: CGFloat?
	private var diskSpaceForStartingScreen: [MediaContentType : Int64] = [:]

	private var flowLayout = SimpleColumnFlowLayout(cellsPerRow: 2, minimumInterSpacing: 0, minimumLineSpacing: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
		
		initializeSingleCleanModel()
		setupObserversAndDelegates()
		setupViewModel()
		setupUI()
		setupCollectionSize()
		setupCollectionView()
		updateColors()
		setupNavigation()

//		setupCircleProgressView()
		
		subscriptionDidChange()
		addSubscriptionChangeObserver()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.coordinator = Utils.sceneDelegate.coordinator
		
		self.addSizeCalcuateObeserver()
		self.setupNavigation()
		self.updateContactsCount()
		self.updateInformation(.userPhoto)
		self.updateInformation(.userVideo)
		self.updateDeepCleanState()
		self.handleShortcutItem()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.removeSizeCalculateObserver()
		self.checkProgressStatus()
	}
	
	override func viewDidLayoutSubviews() {
		
		self.collectionContainerView.cornerSelectRadiusView(corners: [.topLeft, .topRight], radius: 12)
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
	
	private func setupViewModel() {
		
		let rootCells = RootSection(cells: [.userPhoto, .userVideo, .userContacts])
		
		var sections: [RootSection] {
			return [rootCells]
		}
		
		self.rootViewModel = RootViewModel(sections: sections)
		self.rootDataSource = RootDataSource(rootViewModel: self.rootViewModel)
		self.rootDataSource.didSelectModel = { model in
			
			switch model {
				case .userContacts:
					ContactsManager.shared.setProcess(.search, state: .disable)
					self.checkForAccessPermission(of: .userContacts)
				default:
					self.checkForAccessPermission(of: model)
			}
		}
	}
}

extension RootViewController {
	
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
	
	private func checkProgressStatus() {
		
		if diskSpaceForStartingScreen[.userPhoto] == nil {
			self.setProgressSize(for: .userPhoto, progress: 0)
		}
		
		if diskSpaceForStartingScreen[.userVideo] == nil {
			self.setProgressSize(for: .userVideo, progress: 0)
		}
	}
	
	private func updateInformation(_ contentType: MediaContentType) {
		
		Utils.UI {
			
			guard let indexPath = self.rootViewModel.indexPath(of: contentType), let cell = self.collectionView.cellForItem(at: indexPath) as? MediaTypeCollectionViewCell else { return }
			
			let contentCount = self.rootViewModel.getContentCount(of: contentType)
			let diskUsage = SettingsManager.getDiskSpaceFiles(of: contentType)
			
			cell.configureCell(mediaType: contentType, contentCount: contentCount, diskSpace: diskUsage)
			
		}
	}
	
	private func updateDeepCleanState() {
		DispatchQueue.main.async {
			let availible = PhotoLibraryPermissions().authorized && ContactsPermissions().authorized
			#warning("TODO refactor cell")
//			self.bottomButtonBarView.alpha = availible ? 1.0 : 0.5
		}
	}
	
	private func updateCircleProgress() {}
	
	@objc func updateFilesSizeObserver(_ notification: Notification) {
		
		switch notification.name {
			case .singleOperationPhotoFilesSizeScan:
				self.setupUpdateSizeValues(from: .photosSizeCheckerType, userInfo: notification.userInfo)
			case .singleOperationVideoFilesSizeScan:
				self.setupUpdateSizeValues(from: .videosSizeCheckerType, userInfo: notification.userInfo)
			default:
				return
		}
	}
	
	private func setupUpdateSizeValues(from type: SingleContentSearchNotificationType, userInfo: [AnyHashable: Any]?) {
		
		DispatchQueue.main.async {
			
			guard let userInfo = userInfo,
				  let totalProcessing = userInfo[type.dictionaryCountName] as? Int,
				  let currentProcessingIndex = userInfo[type.dictioanartyIndexName] as? Int else { return }
			
			let progress = CGFloat(currentProcessingIndex) / CGFloat(totalProcessing)
			
			switch type {
				case .photosSizeCheckerType:
					self.setProgressSize(for: .userPhoto, progress: progress)
				case .videosSizeCheckerType:
					self.setProgressSize(for: .userVideo, progress: progress)
				default:
					return
			}
		}
	}
	
	private func setProgressSize(for type: MediaContentType, progress: CGFloat) {
		
		guard let indexPath = self.rootViewModel.indexPath(of: type) else { return }
		
		Utils.UI {
			
			guard let cell = self.collectionView.cellForItem(at: indexPath) as? MediaTypeCollectionViewCell else { return }
			
			cell.setProgress(progress)
		}
	}
}

extension RootViewController: UpdateContentDataBaseListener {
	
	func updateContentStoreCount(mediaType: MediaContentType, itemsCount: Int, calculatedSpace: Int64?) {
		U.delay(1) {
			
			self.rootViewModel.setContentCount(model: mediaType, itemsCount: itemsCount)
			
			if let calculatedSpace = calculatedSpace {
				self.diskSpaceForStartingScreen[mediaType] = calculatedSpace
			}
			
			guard let indexPath = self.rootViewModel.indexPath(of: mediaType), let cell = self.collectionView.cellForItem(at: indexPath) as? MediaTypeCollectionViewCell else { return }
			
				cell.configureCell(mediaType: mediaType, contentCount: itemsCount, diskSpace: calculatedSpace)
			
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

extension RootViewController {
	
	private func checkForAccessPermission(of type: MediaContentType, animated: Bool = true, cleanType: RemoteCleanType = .none) {
		
		switch type {
			case .userPhoto, .userVideo:
				permissionManager.photolibraryPermissionAccess { status in
					status == .authorized ? self.openMediaController(type: type, animated: animated, cleanType: cleanType) : ()
				}
			case .userContacts:
				permissionManager.contactsPermissionAccess { status in
					status == .authorized ? self.openMediaController(type: type, animated: animated, cleanType: cleanType) : ()
				}
			default:
				return
		}
	}
	
	private func prepareDeepCleanController(animated: Bool = true) {
		
		guard PhotoLibraryPermissions().authorized && ContactsPermissions().authorized else {
			AlertManager.showPermissionAlert(of: .deniedDeepClean, at: self)
			return
		}
		
		self.subscriptionManager.purchasePremiumHandler { status in
			switch status {
				case .lifetime, .purchasedPremium:
					self.photoManager.stopEstimatedSizeProcessingOperations()
					self.openDeepCleanController(animated: animated)
				case .nonPurchased:
					self.subscriptionManager.limitVersionActionHandler(of: .deepClean, at: self)
			}
		}
	}
	
	private func openMediaController(type: MediaContentType, animated: Bool = true, cleanType: RemoteCleanType) {
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.content) as! MediaContentViewController
		viewController.singleCleanModel = self.singleCleanModel
		ContactsManager.shared.contactsProcessingOperationQueuer.cancelAll()
		viewController.mediaContentType = type
		self.navigationController?.pushViewController(viewController: viewController, animated: true, completion: {
			U.delay(0.5) {
				viewController.handleShortcutProcessing(of: cleanType)
			}
		})
	}
	
	private func openDeepCleanController(animated: Bool = true) {
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.deep, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.deepClean) as! DeepCleaningViewController
		viewController.updateMediaStoreDelegate = self
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
		self.navigationController?.pushViewController(viewController, animated: animated)
	}
	
	private func openSettingsController() {
		coordinator?.showSettingsViewController(from: self.navigationController)
	}
	
	private func openSubscriptionController() {
		UIPresenter.showViewController(of: .subscription)
	}
	
	@objc func shortCutItemStartCleanProcess(_ notification: Notification) {}
	
	private func popTopMainViewController() {
		if self != getTheMostTopController() {
			self.navigationController?.popToRootViewController(animated: false)
		}
	}
}


extension RootViewController {
	
	@objc func contactsStoreDidChange() {}
	
	private func updateContactsCount() {
		ContactsManager.shared.getAllContacts { contacts in
			self.getAllCNContacts(contacts)
			self.rootViewModel.setContentCount(model: .userContacts, itemsCount: contacts.count)
			self.updateInformation(.userContacts)
		}
	}
	
	@objc func permissionDidChange(_ notification: Notification) {
		
		guard let userInfo = notification.userInfo  else { return }
		
		DispatchQueue.main.async {
			if let rawValue = userInfo[C.key.notificationDictionary.permission.photoPermission] as? String, rawValue == PhotoLibraryPermissions().permissionRawValue {
				
				guard let photoIndexPath = self.rootViewModel.indexPath(of: .userPhoto), let videoIndexPath = self.rootViewModel.indexPath(of: .userVideo) else { return }
			
				defer {
					self.tryStartPhotoAccessProcess()
				}
				self.collectionView.reloadItems(at: [photoIndexPath, videoIndexPath])
			} else if let rawValue = userInfo[C.key.notificationDictionary.permission.contactsPermission] as? String, rawValue == ContactsPermissions().permissionRawValue {
				
				guard let contactIndexPath = self.rootViewModel.indexPath(of: .userContacts) else { return }
				
				defer {
					self.tryStartContactsAccessProcess()
				}
				
				self.collectionView.reloadItems(at: [contactIndexPath])
			}
		}
		self.updateDeepCleanState()
	}
	
	private func tryStartContactsAccessProcess() {
		
		guard ContactsPermissions().authorized  else { return }
		ContactsManager.shared.contactsProcessingStore()
	}
	
	private func tryStartPhotoAccessProcess() {
		
		guard PhotoLibraryPermissions().authorized else { return }
		 PhotoManager.shared.getPhotoLibraryContentAndCalculateSpace()
	}
}

extension RootViewController: UpdateMediaStoreSizeDelegate {
	
	func didStartUpdatingMediaSpace(photo: Int64?, video: Int64?) {
		
		photo == nil ? self.photoManager.startPhotosizeCher() : ()
		video == nil ? self.photoManager.startVideSizeCher() : ()
	}
}

extension RootViewController: RemoteLaunchServiceListener {
	
	private func handleShortcutItem() {
		
		guard let shortcutItem = U.sceneDelegate.shortCutItem else { return }
		U.delay(0.33) {
			let _ = RemoteLaunchServiceMediator.sharedInstance.handleShortCutItem(shortcutItem: shortcutItem)
		}
		U.sceneDelegate.shortCutItem = nil
	}
	
	func remoteProcessingClean(by cleanType: RemoteCleanType) {
		
		self.popTopMainViewController()
		
		switch cleanType {
			case .deepClean:
				self.prepareDeepCleanController(animated: false)
			default:
				self.checkForAccessPermission(of: cleanType.mediaType, animated: false, cleanType: cleanType)
		}
	}
}

extension RootViewController: StartingNavigationBarDelegate {
	
	func didTapLeftBarButton(_sender: UIButton) {
		self.openSubscriptionController()
	}
	
	func didTapRightBarButton(_sender: UIButton) {
		self.openSettingsController()
	}
}

extension RootViewController {
	
	private func setupCollectionView() {
		
		self.collectionView.delegate = self.rootDataSource
		self.collectionView.dataSource = self.rootDataSource
		
		self.collectionView.collectionViewLayout = flowLayout
		self.collectionView.register(UINib(nibName: Constants.identifiers.xibs.mediaTypeCell, bundle: nil), forCellWithReuseIdentifier: Constants.identifiers.cells.mediaTypeCell)
		self.collectionView.isScrollEnabled = false
	}
}


extension RootViewController: SubscriptionObserver {
	
	func subscriptionDidChange() {
		
		Utils.UI {
			self.subscriptionManager.purchasePremiumHandler { status in
				switch status {
					case .lifetime, .purchasedPremium:
						self.navigationBar.setUpNavigation(title: nil, leftImage: nil, rightImage: I.systemItems.navigationBarItems.settings, imageTintColor: self.theme.subTitleTextColor)
					case .nonPurchased:
						self.navigationBar.setUpNavigation(title: nil, leftImage: I.systemItems.navigationBarItems.premium, rightImage: I.systemItems.navigationBarItems.settings, imageTintColor: self.theme.subTitleTextColor)
				}
			}
		}
	}
	
	@objc func advertisementDidChange() {
		
		
		#warning("TODO")
//		UIView.animate(withDuration: 0.5) {
//			self.circleTotalSpaceView.isHidden = true
//			UIView.animate(withDuration: 0.5) {
//				self.setupProgressAndCollectionSize()
//				self.setupCircleProgressView()
//			} completion: { _ in
//				UIView.animate(withDuration: 0.5) {
//					self.circleTotalSpaceView.isHidden = false
//				}
//			}
//		}
	}
}


extension RootViewController: UpdateColorsDelegate {
	
	private func setupUI() {
	
		let bannerStatus = Advertisement.manager.advertisementBannerStatus
		
		var itemHeight: CGFloat {
			switch Screen.size {
				case .small:
					switch bannerStatus {
						case .active:
							return 180
						case .hiden:
							return 190
					}
				case .medium:
					switch bannerStatus {
						case .active:
							return 230
						case .hiden:
							return 235
					}
				case .plus:
					switch bannerStatus {
						case .active:
							return 240
						case .hiden:
							return 250
					}
				case .large:
					switch bannerStatus {
						case .active:
							return 250
						case .hiden:
							return 260
					}
				case .modern:
					return 270
				case .max:
					return 280
				case .madMax:
					return 280
			}
		}
		
		self.itemHeight = itemHeight
		flowLayout.cellsPerRow = 2
		flowLayout.itemHieght = itemHeight
		
		scrollView.showsVerticalScrollIndicator = false
		scrollView.delegate = self
		
		self.view.insertSubview(collectionContainerBottomHelperView, at: 0)
		
		collectionContainerBottomHelperView.translatesAutoresizingMaskIntoConstraints = false
		
		collectionContainerBottomHelperView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		collectionContainerBottomHelperView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		collectionContainerBottomHelperView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		collectionContainerBottomHelperView.heightAnchor.constraint(equalToConstant: 150).isActive = true
		
		headerContainerView.backgroundColor = .red
	}
	
	private func setupCollectionSize() {
		
		guard let itemHeight = self.itemHeight else { return }
		
		var collectionSize: CGFloat {
			
			let numberOfSections = self.rootViewModel.numberOfSections()
			
			var numberOfRows: Int {
				var numberOfItems = 0
				
				for section in 0...numberOfSections - 1 {
					let items = self.rootViewModel.numberOfRows(in: section)
					numberOfItems += items
				}
				
				if numberOfItems % 2 == 0 {
					return numberOfItems / 2
				} else {
					return numberOfItems / 2 + 1
				}
			}
			return CGFloat(numberOfRows) * itemHeight + 40
		}
		
		let headerContainerHeight = Utils.screenHeight / 2
		
		scrollView.contentSize = CGSize(width: Utils.screenWidth, height: headerContainerHeight + collectionSize)
		self.collectionContainerHeightConstraint.constant = collectionSize
		
		self.headerContainerHeightConstraint.constant = headerContainerHeight
	
		self.headerView.layoutIfNeeded()
		self.collectionContainerView.layoutIfNeeded()

		self.view.layoutIfNeeded()
	}
	
	private func setupNavigation() {
		
		self.navigationController?.navigationBar.isHidden = true
	}
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
		self.collectionView.backgroundColor = .clear
		self.collectionContainerView.backgroundColor = theme.primaryButtonBackgroundColor
		self.collectionContainerBottomHelperView.backgroundColor = theme.primaryButtonBackgroundColor
	}
}

extension RootViewController {
	
	private func setupObserversAndDelegates() {
		UpdateContentDataBaseMediator.instance.setListener(listener: self)
		RemoteLaunchServiceMediator.sharedInstance.setListener(listener: self)
		
		navigationBar.delegate = self
		
		U.notificationCenter.addObserver(self, selector: #selector(updatingContentDisplayInformation(_:)), name: .photoSpaceDidChange, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(updatingContentDisplayInformation(_:)), name: .videoSpaceDidChange, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(updatingContentDisplayInformation(_:)), name: .mediaSpaceDidChange, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(updatingContentDisplayInformation(_:)), name: .contactsCountDidChange, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(contactsStoreDidChange), name: .CNContactStoreDidChange, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(removeStoreObserver), name: .removeContactsStoreObserver, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(addStoreObserver), name: .addContactsStoreObserver, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(permissionDidChange(_:)), name: .permisionDidChange, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(advertisementDidChange), name: .bannerStatusDidChanged, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(shortCutItemStartCleanProcess(_:)), name: .shortCutsItemsNavigationItemsNotification, object: nil)
	}
	
	@objc func addStoreObserver() {
		U.notificationCenter.addObserver(self, selector: #selector(contactsStoreDidChange), name: .CNContactStoreDidChange, object: nil)
	}
	
	@objc func removeStoreObserver() {
		U.notificationCenter.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
	}
	
	private func addSizeCalcuateObeserver() {
		U.notificationCenter.addObserver(self, selector: #selector(updateFilesSizeObserver(_:)), name: .singleOperationPhotoFilesSizeScan, object: nil)
		U.notificationCenter.addObserver(self, selector: #selector(updateFilesSizeObserver(_:)), name: .singleOperationVideoFilesSizeScan, object: nil)
	}
	
	private func removeSizeCalculateObserver() {
		U.notificationCenter.removeObserver(self, name: .singleOperationPhotoFilesSizeScan, object: nil)
		U.notificationCenter.removeObserver(self, name: .singleOperationVideoFilesSizeScan, object: nil)
	}
}


extension RootViewController: UIScrollViewDelegate {

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		debugPrint(scrollView.contentOffset.y)
		
		
		if let constraint = self.collectionContainerBottomHelperView.constraints.filter({$0.firstAttribute == .height}).first {
			constraint.constant = 150 + scrollView.contentOffset.y
		}

	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		
	}
}

