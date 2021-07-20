//
//  PhotoPreviewViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 19.07.2021.
//

import UIKit
import Photos

enum CollectionType {
    case grouped
    case single
    case none
}

class PhotoPreviewViewController: UIPageViewController {
    
    private var collectionType: CollectionType = .none
    private var assetPhotoCollection: [UIImage] = []
    public var photoMediaContentType: PhotoMediaType = .none
    public var groupAssetsCollection: [PhassetGroup] = []
    public var singleAssetsCollection: [PHAsset] = []
    
    private var loadedViewControllers: [UIViewController] = []
    
    private var chacheManager = PHCachingImageManager()
    
    private var initialViewController: PhassetPreviewPageProtocol?
    private var pagingDataSource: PhotoPreviewPagingDataSource?
    
    public var currentIndex: Int = 0
    public var photoCount: Int = 0
    public var photosDataSource: PhotoPreviewDataSource?
    
    private var spineDividerWidth: Float = 10
    
    //    init(startIndex: Int, photoCount: Int, itemDataSource: PhotoPreviewDataSource) {
    //
    //        self.currentIndex = startIndex
    //        self.photoCount = photoCount
    //        self.photosDataSource = itemDataSource
    //        self.pagingDataSource = PhotoPreviewPagingDataSource(dataSource: itemDataSource)
    //
    //        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: convertToOptionalUIPageViewControllerOptionsKeyDictionary([convertFromUIPageViewControllerOptionsKey(UIPageViewController.OptionsKey.interPageSpacing) : NSNumber(value: spineDividerWidth as Float)]))
    //
    //  pagingDataSource.pageContollerDelegate = self
    //    let initialViewController = pagingDataSource.createViewController(at: currentIndex)
    //    self.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
    //    self.initialViewController = initialViewController as? PhassetPreviewPageProtocol
    //    self.dataSource = pagingDataSource
    //    }
    //
    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pagingDataSource = PhotoPreviewPagingDataSource(dataSource: photosDataSource!)
        
        pagingDataSource?.pageContollerDelegate = self
        let initialViewController = pagingDataSource?.createViewController(at: currentIndex)
        self.setViewControllers([initialViewController!], direction: .forward, animated: false, completion: nil)
        self.initialViewController = initialViewController as? PhassetPreviewPageProtocol
        self.dataSource = pagingDataSource
        
        setupUI()
        setupNavigateControll()
        setupDelegate()
    }
}

extension PhotoPreviewViewController: Themeble {
    
    private func setupUI() {}
    
    private func setupDelegate() {}

    func updateColors() {}
    
    public func mediaContentTypeSetup() {
        
        switch photoMediaContentType {
            case .singleSelfies, .singleLivePhotos, .singleLargeVideos, .singleScreenShots, .singleScreenRecordings:
                self.collectionType = .single
            case .duplicatedPhotos, .duplicatedVideos, .similarPhotos, .similarVideos, .similarLivePhotos:
                self.collectionType = .grouped
            default:
                self.collectionType = .none
        }
    }
    
    public func loadAssetsCollection() {
        
        var assetCollection: [PHAsset] = []
        
        for groupAsset in groupAssetsCollection {
            assetCollection.append(contentsOf: groupAsset.assets)
        }
        
//        PHImageManagerMaximumSize
        let options = chacheManager.photoImageRequestOptions()
        chacheManager.startCachingImages(for: assetCollection, targetSize: CGSize(width: U.screenWidth, height: U.screenHeight), contentMode: .aspectFit, options: options)
    }
    
    private func setupNavigateControll() {
        
        if let firstViewController = loadedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
//    private func createCarouselController(with image: UIImage) -> UIViewController {
//
//        let viewController = UIViewController()
//        viewController.view = CarouselItemView(image: image)
//        return viewController
//    }
}

extension PhotoPreviewViewController: PhassetPreviewPageDelegate {

    func photoPreviewControllerDidAppear(_ controller: PhassetPreviewPageProtocol) {
        debugPrint("photoPreviewControllerDidAppear")
    }

    func photoPreviewControllerWillDisapper(_ controller: PhassetPreviewPageProtocol) {
        debugPrint("photoPreviewControllerWillDisapper")
    }

    func photoPrevireDidPanned(_ recognizer: UIPanGestureRecognizer, view: UIView) {
        debugPrint("photoPrevireDidPanned")
    }

}



class CarouselItemView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeWithNib()
    }

    convenience init(image: UIImage) {
        self.init()
        
        imageView.image = image
    }
    
    private func initializeWithNib() {
        
        Bundle.main.loadNibNamed(C.identifiers.xibs.carouselView, owner: self, options: nil)
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
