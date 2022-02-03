//
//  PhotoPreviewViewControllerOLDVers.swift
//  ECleaner
//
//  Created by alekseii sorochan on 19.07.2021.
//

import UIKit
import Photos


class PhotoPreviewViewControllerOLDVers: UIPageViewController {
    
    /// managers
    private var chacheManager = PHCachingImageManager()
    
    /// controllers
    private var loadedViewControllers: [UIViewController] = []
    
    /// delegates
    private var initialViewController: PhassetPreviewPageProtocolOLD?
    public var pagingDataSource: PhotoPreviewPagingDataSourceOLD?
    public var photosDataSource: PhotoPreviewDataSourceOLD?
    
    /// assets
    private var collectionType: CollectionType = .none
    public var photoMediaContentType: PhotoMediaType = .none
    public var groupAssetsCollection: [PhassetGroup] = []
    public var singleAssetsCollection: [PHAsset] = []
    
    /// pageControll
    public var currentIndex: Int = 0
    public var photoCount: Int = 0
    
    /// properties
    private var spineDividerWidth: Float = 10
    private let assetsCollectionSizeMaximumSize = PHImageManagerMaximumSize
    private let aspectSize: CGSize = CGSize(width: U.screenWidth, height: U.screenHeight)
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupDataSource()
        setupUI()
        setupNavigateControll()
    }
}

extension PhotoPreviewViewControllerOLDVers {
    
    private func setupDelegate() {
        
        pagingDataSource?.pageContollerDelegate = self
    }
    
    private func setupDataSource() {
        
        /// before baging need to check if collection is single or groped
        if let dataSource = photosDataSource {
            self.pagingDataSource = PhotoPreviewPagingDataSourceOLD(dataSource: dataSource, isGroupedAssets: self.collectionType == .grouped)
        }
        
        let initialViewController = pagingDataSource?.createViewController(at: currentIndex)
        self.setViewControllers([initialViewController!], direction: .forward, animated: false, completion: nil)
        self.initialViewController = initialViewController as? PhassetPreviewPageProtocolOLD
        self.dataSource = pagingDataSource
    }
    
    public func mediaContentTypeSetup() {
        
        switch photoMediaContentType {
            case .singleLivePhotos, .singleLargeVideos, .singleScreenShots, .singleScreenRecordings:
                self.collectionType = .single
			case .duplicatedPhotos, .duplicatedVideos, .similarPhotos, .similarVideos, .similarLivePhotos, .similarSelfies:
                self.collectionType = .grouped
            default:
                self.collectionType = .none
        }
    }
    
    public func loadAssetsCollection(_ assetsCollection: [PHAsset]) {
 
        let options = chacheManager.photoImageRequestOptions()
        chacheManager.startCachingImages(for: assetsCollection, targetSize: aspectSize, contentMode: .aspectFit, options: options)
    }
    
    private func setupNavigateControll() {
        
        if let firstViewController = loadedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    public func slideToPage(index: Int, completion: (() -> Void)?) {
        let tempIndex = currentIndex
        if currentIndex < index {
            var i = tempIndex
            while i <= index {
                i += 1
                
                    
                self.pageForward(animated: false, comletionHandler: nil)
                
                
                self.currentIndex = i + 1
//                self.setViewControllers([loadedViewControllers[i]], direction: .forward, animated: false, completion: {[weak self] (complete: Bool) -> Void in
//                    if (complete) {
//                        self?.currentIndex = i - 1
//                        completion?()
//                    }
//                })
            }
        } else if currentIndex > index {
            var i = tempIndex
            while i >= index {
                i -= 1
                self.pageBackward(animated: false, completionHandler: nil)
                self.currentIndex = i - 1
//                self.setViewControllers([loadedViewControllers[i]], direction: .reverse, animated: false, completion: {[weak self] (complete: Bool) -> Void in
//                    if complete {
//                        self?.currentIndex = i + 1
//                        completion?()
//                    }
//                })
            }
        }
    }
}

extension PhotoPreviewViewControllerOLDVers: Themeble {
    
    private func setupUI() {}
    func updateColors() {}
}

extension PhotoPreviewViewControllerOLDVers: PhassetPreviewPageDelegateOLD {

    func photoPreviewControllerDidAppear(_ controller: PhassetPreviewPageProtocolOLD) {
        debugPrint("photoPreviewControllerDidAppear")
    }

    func photoPreviewControllerWillDisapper(_ controller: PhassetPreviewPageProtocolOLD) {
        debugPrint("photoPreviewControllerWillDisapper")
    }

    func photoPrevireDidPanned(_ recognizer: UIPanGestureRecognizer, view: UIView) {
        debugPrint("photoPrevireDidPanned")
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalUIPageViewControllerOptionsKeyDictionary(_ input: [String: Any]?) -> [UIPageViewController.OptionsKey: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIPageViewController.OptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIPageViewControllerOptionsKey(_ input: UIPageViewController.OptionsKey) -> String {
    return input.rawValue
}
