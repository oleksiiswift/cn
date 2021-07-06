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
    
    @IBOutlet weak var circleTotlaSpaceView: CircleProgressView!
    @IBOutlet weak var mediaCollectionViewContainer: UIView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var deepCleaningButtonView: UIView!
    @IBOutlet weak var deepCleaningButtonTextLabel: UILabel!
    @IBOutlet weak var circleProgressBarViewHeightConstraint: NSLayoutConstraint!
    
    lazy var premiumButton = UIBarButtonItem(image: I.navigationItems.premium, style: .plain, target: self, action: #selector(premiumButtonPressed))
    lazy var settingsButton = UIBarButtonItem(image: I.navigationItems.settings, style: .plain, target: self, action: #selector(settingsButtonPressed))
    
    private var photoMenager = PhotoManager()
    
    private let baseCarouselLayout = BaseCarouselFlowLayout()
    
    private var allPhotoCount: Int?
    private var allVideosCount: Int?
    private var allContactsCount: Int?
    
    private var allScreenShots: [PHAsset] = []
    private var allSelfies: [PHAsset] = []
    private var allLiveFotos: [PHAsset] = []
    private var allLargeVidoes: [PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}

extension MainViewController {
    
    private func getMediaContent() {}
    @objc func settingsButtonPressed() {}
    @objc func premiumButtonPressed() {}
}

//      MARK: - updating elements -
extension MainViewController: UpdateContentDataBaseListener {
    
    func getScreenAsset(_ assets: [PHAsset]) {
        self.allScreenShots = assets
    }
    
    func getFrontCameraAsset(_ assets: [PHAsset]) {
        self.allSelfies = assets
    }
    
    func getLivePhotosAsset(_ assets: [PHAsset]) {
        self.allLiveFotos = assets
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
    
    func getLargeVideosAsset(_ assets: [PHAsset]) {
        self.allLargeVidoes = assets
    }
    
    
    func getContactsCount(count: Int) {
        
        self.allContactsCount = count
        if let cell = mediaCollectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? MediaTypeCollectionViewCell {
            cell.configureCell(mediaType: .userContacts, contentCount: count, diskSpace: 0)
        }
    }

    private func openMediaController(type: MediaContentType) {
        let storyboard = UIStoryboard(name: C.identifiers.storyboards.media, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.content) as! MediaContentViewController
  
        switch type {
            case .userPhoto:
                viewController.allScreenShots = self.allScreenShots
                viewController.allSelfies = self.allSelfies
                viewController.allLiveFotos = self.allLiveFotos
            case .userVideo:
                viewController.allLargeVideos = self.allLargeVidoes
            default:
                return
        }
        
        viewController.contentType = type
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
                cell.configureCell(mediaType: .userPhoto, contentCount: self.allPhotoCount, diskSpace: 0)
            case 1:
                cell.mediaTypeCell = .userVideo
                cell.configureCell(mediaType: .userVideo, contentCount: self.allVideosCount, diskSpace: 0)
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
    }
    
    private func setupNavigation() {
            
        self.navigationController?.updateNavigationColors()
        self.navigationItem.leftBarButtonItem = premiumButton
        self.navigationItem.rightBarButtonItem = settingsButton
        self.navigationItem.backButtonTitle = ""
    }
    
    #warning("LOCO add loco")
    private func setupUI() {
                
        deepCleaningButtonView.setCorner(12)
        deepCleaningButtonTextLabel.font = .systemFont(ofSize: 17, weight: .bold)
        deepCleaningButtonTextLabel.text = "Deep Cleaning"
    }
    
    func updateColors() {
        self.view.backgroundColor = currentTheme.backgroundColor
        deepCleaningButtonView.backgroundColor = currentTheme.accentBackgroundColor
        deepCleaningButtonTextLabel.textColor = currentTheme.activeTitleTextColor
    }
    
    private func setupProgressAndCollectionSize() {
        
        /// `default size` of collection CGSize(width: 163, height: 290)
        /// `default size` of progress bar is 190
        /// `height` item size must be is equel to collection view height
        
        switch Screen.size {
            case .small:
                
                circleProgressBarViewHeightConstraint.constant = 140
                circleTotlaSpaceView.lineWidth = 10
                circleTotlaSpaceView.titleLabelBottomInset = (circleTotlaSpaceView.frame.height / 2) - 10
                circleTotlaSpaceView.percentLabelCenterInset = 25
                circleTotlaSpaceView.titleLabel.font = .systemFont(ofSize: 11, weight: .regular)
                circleTotlaSpaceView.percentLabel.font = .systemFont(ofSize: 18, weight: .bold)
                
                circleTotlaSpaceView.layoutIfNeeded()
                self.view.layoutIfNeeded()
                
                baseCarouselLayout.itemSize = CGSize(width: 138, height: mediaCollectionView.frame.height)
    
            case .medium:
                debugPrint("")
            case .plus:
                debugPrint("")
                circleTotlaSpaceView.lineWidth = 20
                circleTotlaSpaceView.titleLabelBottomInset = (circleTotlaSpaceView.frame.height / 2) + 10
                circleTotlaSpaceView.titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
                circleTotlaSpaceView.percentLabel.font = .systemFont(ofSize: 25, weight: .black)
                circleTotlaSpaceView.percentLabelCenterInset = 25
            case .large:
                debugPrint("")
            case .modern:
                debugPrint("")
            case .max:
                debugPrint("")
            case .madMax:
                debugPrint("")
        }
    }
    
    private func setupCircleProgressView() {
        
        let calculatePercentage: Double = Double(Device.usedDiskSpaceInBytes) / Double(Device.totalDiskSpaceInBytes)
  
        circleTotlaSpaceView.setProgress(progress: CGFloat(calculatePercentage), animated: true)
        circleTotlaSpaceView.progressShapeColor = currentTheme.tintColor
        circleTotlaSpaceView.backgroundShapeColor = currentTheme.contentBackgroundColor
        circleTotlaSpaceView.titleColor = currentTheme.subTitleTextColor
        circleTotlaSpaceView.percentColor = currentTheme.tintColor
        
        circleTotlaSpaceView.orientation = .bottom
        circleTotlaSpaceView.lineCap = .round
        circleTotlaSpaceView.clockwise = true

        circleTotlaSpaceView.title = "\(Device.usedDiskSpaceInGB.removeWhitespace()) out of \(Device.totalDiskSpaceInGB.removeWhitespace())"
        circleTotlaSpaceView.percentLabelFormat = "%.f%%"
    }
}
