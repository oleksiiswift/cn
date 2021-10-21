//
//  MainViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 22.06.2021.
//

import UIKit
import Photos
import SwiftMessages

class MainViewController: UIViewController {
  
    @IBOutlet weak var customNavBar: CustomNavigationBar!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var circleTotlaSpaceView: CircleProgressView!
    @IBOutlet weak var circleProgressView: MMTGradientArcView!
//    @IBOutlet weak var mediaCollectionViewContainer: UIView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var deepCleaningButtonView: ShadowView!
    @IBOutlet weak var deepCleaningButtonTextLabel: UILabel!
//    @IBOutlet weak var circleProgressBarViewHeightConstraint: NSLayoutConstraint!
    
    lazy var premiumButton = UIBarButtonItem(image: I.navigationItems.premium, style: .plain, target: self, action: #selector(premiumButtonPressed))
    lazy var settingsButton = UIBarButtonItem(image: I.navigationItems.settings, style: .plain, target: self, action: #selector(settingsButtonPressed))
    
    private var photoMenager = PhotoManager()
    
    private let baseCarouselLayout = BaseCarouselFlowLayout()
    
    private var allPhotoCount: Int?
    private var allVideosCount: Int?
    private var allContactsCount: Int?
    private var totalFilesOnDevice: Int?
    
    private var photoDiskSpaceCount: Int64? {
        get {
            return S.phassetPhotoFilesSizes
        }
    }
    
    private var videoDiskSpaceCount: Int64? {
        get {
            return S.phassetPhotoVideoSizes
        }
    }
    
    private var allScreenShots: [PHAsset] = []
    private var allSelfies: [PHAsset] = []
    private var allLiveFotos: [PHAsset] = []
    
    private var allLargeVidoes: [PHAsset] = []
    private var allScreenRecordsVideos: [PHAsset] = []
    private var allSimilarRecordingsVideos: [PhassetGroup] = []
    
    private var allRecentlyDeletedPhotos: [PHAsset] = []
    private var allRecentlyDeletedVideos: [PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObserversAndDelegates()
        setupNavigation()
        setupUI()
        setupProgressAndCollectionSize()
        setupCollectionView()
        setupCircleProgressView()
        updateColors()
      
//      let progress = GradientCircularProgress()
//      var style = MyStyle()
//      style.progressSize = circleProgressView.frame.size.height
//      let progressView = progress.showAtRatio(frame: circleProgressView.bounds, display: true, style: style)
//      circleProgressView.addSubview(progressView!)
//      let calculatePercentage: Double = Double(Device.usedDiskSpaceInBytes) / Double(Device.totalDiskSpaceInBytes)
//      progress.updateRatio(CGFloat(calculatePercentage))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    @IBAction func didTapStartDeepCleaningActionButton(_ sender: Any) {
         
        openDeepCleanController()
    }
}

extension MainViewController {
    
    private func getMediaContent() {}
    @objc func settingsButtonPressed() {}
    @objc func premiumButtonPressed() {}
    
    @objc func updatePhotoSpaceDiskUsage(_ notification: Notification) {
        
        if notification.name == Notification.Name(rawValue: C.key.notification.photoSpaceNotificationName) {
            U.UI {
                let indexPath = IndexPath(row: 0, section: 0)
                if let cell = self.mediaCollectionView.cellForItem(at: indexPath) as? MediaTypeCollectionViewCell {
                    cell.configureCell(mediaType: .userPhoto, contentCount: self.allPhotoCount, diskSpace: S.phassetPhotoFilesSizes)
                    self.mediaCollectionView.reloadItems(at: [indexPath])
                }
            }
        } else if notification.name == Notification.Name(rawValue: C.key.notification.videoSpaceNotificationName) {
            U.UI {
                let indexPath = IndexPath(row: 1, section: 0)
                if let cell = self.mediaCollectionView.cellForItem(at: indexPath) as? MediaTypeCollectionViewCell {
                    cell.configureCell(mediaType: .userVideo, contentCount: self.allVideosCount, diskSpace: S.phassetVideoFilesSizes)
                    self.mediaCollectionView.reloadItems(at: [indexPath])
                }
            }
        } else if  notification.name == Notification.Name(rawValue: C.key.notification.mediaSpaceNotificationName) {
            U.UI {
                if let info = notification.userInfo {
                    if let space = info[C.key.settings.allMediaSpace] as? Int64{
                        debugPrint(space)
                    }
                }
            }
        }
    }
}

//      MARK: - updating elements -
extension MainViewController: UpdateContentDataBaseListener {
 
    func getScreenAssets(_ assets: [PHAsset]) {
        self.allScreenShots = assets
    }
    
    func getLivePhotosAssets(_ assets: [PHAsset]) {
        self.allLiveFotos = assets
    }
    
    func getFrontCameraAssets(_ assets: [PHAsset]) {
        self.allSelfies = assets
    }
            
    func getPhotoLibraryCount(count: Int, calculatedSpace: Int64) {
        U.UI {
            self.allPhotoCount = count
            if let cell = self.mediaCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? MediaTypeCollectionViewCell {
                cell.configureCell(mediaType: .userPhoto, contentCount: count, diskSpace: calculatedSpace)
            }
        }
    }
    
    func getVideoCount(count: Int, calculatedSpace: Int64) {
        
        self.allVideosCount = count
            if let cell = self.mediaCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? MediaTypeCollectionViewCell {
            cell.configureCell(mediaType: .userVideo, contentCount: count, diskSpace: calculatedSpace)
        }
    }
    
    func getLargeVideosAssets(_ assets: [PHAsset]) {
        self.allLargeVidoes = assets
    }
    
    func getSimmilarVideosAssets(_ assets: [PhassetGroup]) {
        self.allSimilarRecordingsVideos = assets
    }
    
    func getDuplicateVideosAssets(_ assets: [PhassetGroup]) {
        debugPrint(assets.count)
    }
    
    func getScreenRecordsVideosAssets(_ assets: [PHAsset]) {
        self.allScreenRecordsVideos = assets
    }
    
    func getContactsCount(count: Int) {
        
        self.allContactsCount = count
        if let cell = mediaCollectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? MediaTypeCollectionViewCell {
            cell.configureCell(mediaType: .userContacts, contentCount: count, diskSpace: 0)
        }
    }
    
    func getRecentlyDeletedPhotoAsssets(_ assets: [PHAsset]) {
        self.allRecentlyDeletedPhotos = assets
    }
    
    func getRecentlyDeletedVideoAssets(_ assts: [PHAsset]) {
        self.allRecentlyDeletedVideos = assts
    }
}

extension MainViewController {
    
    private func openMediaController(type: MediaContentType) {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.content) as! MediaContentViewController
  
        switch type {
            case .userPhoto:
                viewController.allScreenShots = self.allScreenShots
                viewController.allSelfies = self.allSelfies
                viewController.allLiveFotos = self.allLiveFotos
                viewController.allRecentlyDeletedPhotos = self.allRecentlyDeletedPhotos
            case .userVideo:
                viewController.allLargeVideos = self.allLargeVidoes
                viewController.allScreenRecords = self.allScreenRecordsVideos
                viewController.allRecentlyDeletedVideos = self.allRecentlyDeletedVideos
            default:
                return
        }
        
        viewController.contentType = type
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func openDeepCleanController() {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.deep, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.deepClean) as! DeepCleaningViewController
    
        viewController.scansOptions = [.similarPhotos,
                                       .similarVideos,
                                       .duplicatedPhotos,
                                       .duplicatedVideos,
                                       .similarLivePhotos,
                                       .singleScreenShots,
                                       .singleScreenRecordings]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

//
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
        
        switch indexPath.item {
            case 0:
                cell.mediaTypeCell = .userPhoto
                cell.configureCell(mediaType: .userPhoto, contentCount: self.allPhotoCount, diskSpace: photoDiskSpaceCount)
            case 1:
                cell.mediaTypeCell = .userVideo
                cell.configureCell(mediaType: .userVideo, contentCount: self.allVideosCount, diskSpace: videoDiskSpaceCount)
            case 2:
                cell.mediaTypeCell = .userContacts
                cell.configureCell(mediaType: .userContacts, contentCount: self.allContactsCount, diskSpace: 0)
            default:
                debugPrint("")
        }
    }
}

extension MainViewController: UpdateColorsDelegate {
    
    private func setupObserversAndDelegates() {
        UpdateContentDataBaseMediator.instance.setListener(listener: self)
    
        U.notificationCenter.addObserver(self, selector: #selector(updatePhotoSpaceDiskUsage(_:)), name: .photoSpaceDidChange, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(updatePhotoSpaceDiskUsage(_:)), name: .videoSpaceDidChange, object: nil)
        U.notificationCenter.addObserver(self, selector: #selector(updatePhotoSpaceDiskUsage(_:)), name: .mediaSpaceDidChange, object: nil)
    }
    
    private func setupNavigation() {
            
        self.navigationController?.navigationBar.isHidden = true
        customNavBar.setUpNavigation(title: "DASHBOARD_TITLE".localized(), leftImage: I.navigationItems.premium, rightImage: I.navigationItems.settings)
      
//        self.navigationController?.updateNavigationColors()
//        self.navigationItem.leftBarButtonItem = premiumButton
//        self.navigationItem.rightBarButtonItem = settingsButton
//        self.navigationItem.backButtonTitle = ""
    }
    
    #warning("LOCO add loco")
    private func setupUI() {
                
        scrollView.alwaysBounceVertical = true
        deepCleaningButtonView.setCorner(12)
        deepCleaningButtonTextLabel.font = UIFont(font: FontManager.robotoBlack, size: 16.0)//.systemFont(ofSize: 17, weight: .bold)
        deepCleaningButtonTextLabel.text = "DEEP_CLEANING_BUTTON_TITLE".localized()
      
        deepCleaningButtonView.clipsToBounds = true
        deepCleaningButtonView.layer.cornerRadius = 14
    }
    
    func updateColors() {
        
        self.view.backgroundColor = theme.backgroundColor//.clear
//        deepCleaningButtonView.backgroundColor = theme.accentBackgroundColor
        deepCleaningButtonTextLabel.textColor = theme.blueTextColor
    }
    
    private func setupProgressAndCollectionSize() {
        
      circleTotlaSpaceView.font = UIFont(font: FontManager.robotoBlack, size: 61.0)!
      circleTotlaSpaceView.percentLabel.font = UIFont(font: FontManager.robotoBlack, size: 61.0)
      circleTotlaSpaceView.percentLabelCenterInset = 45
    }
    
    private func setupCircleProgressView() {
        
        let calculatePercentage: Double = Double(Device.usedDiskSpaceInBytes) / Double(Device.totalDiskSpaceInBytes)

        circleTotlaSpaceView.setProgress(progress: CGFloat(calculatePercentage), animated: true)
        circleTotlaSpaceView.progressShapeColor = theme.tintColor
        circleTotlaSpaceView.backgroundShapeColor = .clear
        circleTotlaSpaceView.titleColor = theme.subTitleTextColor
        circleTotlaSpaceView.percentColor = theme.titleTextColor

        circleTotlaSpaceView.orientation = .bottom
        circleTotlaSpaceView.lineCap = .round
        circleTotlaSpaceView.clockwise = true

        circleTotlaSpaceView.title = "\(Device.usedDiskSpaceInGB.removeWhitespace()) FROM \(Device.totalDiskSpaceInGB.removeWhitespace()) USED"
        circleTotlaSpaceView.percentLabelFormat = "%.f%%"
    }
}

public struct MyStyle : StyleProperty {

    // Progress Size
  public var progressSize: CGFloat = 200

    // Gradient Circular
  public var arcLineWidth: CGFloat = 47.0
  public var startArcColor: UIColor = UIColor().colorFromHexString("3677FF")
  public var endArcColor: UIColor = UIColor().colorFromHexString("66CDFF")


    // Base Circular
  public var baseLineWidth: CGFloat? = 47.0
  public var baseArcColor: UIColor? = UIColor.clear//darkGray()

    // Ratio
  public var ratioLabelFont: UIFont? = UIFont(name: "Verdana-Bold", size: 16.0)
  public var ratioLabelFontColor: UIColor? = UIColor.white//()

    // Message
  public var messageLabelFont: UIFont? = UIFont.systemFont(ofSize: 16.0)
  public var messageLabelFontColor: UIColor? = UIColor.white//()

    // Background
  public var backgroundStyle: BackgroundStyles = .none

    // Dismiss
  public var dismissTimeInterval: Double? = 0.0 // 'nil' for default setting.

  public init() {}
}




