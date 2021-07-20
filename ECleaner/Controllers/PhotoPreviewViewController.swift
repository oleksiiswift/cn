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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

//extension PhotoPreviewViewController: UIPageViewControllerDataSource {
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        guard let viewControllerIndex = loadedViewControllers.firstIndex(of: viewController) else { return nil}
//
//        let previousIndex = viewControllerIndex - 1
//
//        guard previousIndex >= 0 else {
//            return loadedViewControllers.last
//        }
//
//        guard loadedViewControllers.count > previousIndex else { return nil}
//        return loadedViewControllers[previousIndex]
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        guard let viewControllerIndex = loadedViewControllers.firstIndex(of: viewController) else { return nil }
//
//        let nextIndex = viewControllerIndex + 1
//
//        guard loadedViewControllers.count != nextIndex else {
//            return loadedViewControllers.first
//        }
//
//        guard loadedViewControllers.count > nextIndex else {
//            return nil
//        }
//
//        return loadedViewControllers[nextIndex]
//    }
//
//    func presentationCount(for _: UIPageViewController) -> Int {
//        return loadedViewControllers.count
//    }
//
//    func presentationIndex(for _: UIPageViewController) -> Int {
//        guard let firstViewController = viewControllers?.first,
//              let firstViewControllerIndex = loadedViewControllers.firstIndex(of: firstViewController) else {
//            return 0
//        }
//        return firstViewControllerIndex
//    }
//}


//public protocol ImageControllerDelegate: class {
//
//    func imageControllerDidAppear(_ controller: ImageVC)
//    func imageControllerWillDisappear(_ controller: ImageVC)
//    func imageWasPanned(_ recognizer: UIPanGestureRecognizer, imageView: UIImageView)
//    func imageWasZoomed()
//}
//





//
//open class ImageVC: UIViewController, GalleryPageProtocol {
//
//    public weak var delegate: GalleryPageDelegate?

//    public var index: Int
//    public var isInitialController = false
//    public let itemCount: Int
//    public let imageId: String?
//
//    public var loadingQueue: ImageOperation?
//
//    private let scrollView = UIScrollView()
//    private var isAnimating = false
//
//    private let minimumZoomScale: CGFloat = 1
//    private let maximumZoomScale: CGFloat = 2.5
//
//    private var previewLoaded: Bool = false
//    private var imageLoaded: Bool = false
//    private var fullSizeImageLoaded: Bool = false // image for zooming
//    private var imageFrame: CGRect = CGRect()
//
//    /// INTERACTIONS
//    private let doubleTapRecognizer = UITapGestureRecognizer()
//    private let swipeToDismissRecognizer = UIPanGestureRecognizer()
//
//    public init(index: Int, itemCount: Int, imageId: String?, loadingQueue: ImageOperation, isInitialController: Bool = false) {
//
//        self.isInitialController = isInitialController
//        self.imageId = imageId

//
//        super.init(nibName: nil, bundle: nil)
//
//        self.modalPresentationStyle = .custom
//        self.view.backgroundColor = .clear
//    }
//
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//
//        configureScrollView()
//        configureGestureRecognizers()
//        createViewHierarchy()
//    }
//
//    override open func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        scrollView.frame = self.view.bounds
//
//        if let size = imageView.image?.size , size != CGSize.zero {
//
//            let aspectFitItemSize = aspectFitSize(forContentOfSize: size, inBounds: self.scrollView.bounds.size)
//
//            imageView.bounds.size = aspectFitItemSize
//            scrollView.contentSize = imageView.bounds.size
//
//            imageView.center = scrollView.boundsCenter
//        }
//    }
//    open override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
//    }
//}
//
//
//extension ImageVC {
//
//    // MARK: - Helpers
//    private func setImage() {
//
//        let fileManager = PFileManager()
//
//        guard let imageId = imageId else {
//            return
//        }
//
//        let image = fileManager.getDownsampledImageBy(id: imageId, pointSize: CGSize(width: U.screen.size.width, height: U.screen.size.height), scale: U.mainScreen.scale)
//
//        self.imageView.isAccessibilityElement = image.isAccessibilityElement
//        self.imageView.accessibilityLabel = image.accessibilityLabel
//        self.imageView.accessibilityTraits = image.accessibilityTraits
//
//        U.UI {
//
//            self.imageView.image = image
//            self.imageLoaded = true
//            self.view.setNeedsLayout()
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    private func configureImageViewWithPreview() {
//
//        guard let imageId = imageId else {
//            return
//        }
//
//        let photosManager = PhotoDatabaseManager()
//
//        guard let image = photosManager.getPreviewForPhoto(by: imageId) else {
//            return
//        }
//
//        self.imageView.isAccessibilityElement = image.isAccessibilityElement
//        self.imageView.accessibilityLabel = image.accessibilityLabel
//        self.imageView.accessibilityTraits = image.accessibilityTraits
//
//        U.UI {
//
//            self.imageView.image = image
//            self.view.setNeedsLayout()
//            self.view.layoutIfNeeded()
//            self.previewLoaded = true
//            self.imageFrame = self.imageView.frame
//        }
//    }
//
//    // MARK: - Configuration
//    fileprivate func configureScrollView() {
//
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.backgroundColor = .clear
//        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
//        scrollView.contentInset = UIEdgeInsets.zero
//        scrollView.contentOffset = CGPoint.zero
//        scrollView.minimumZoomScale = minimumZoomScale
//        scrollView.maximumZoomScale = max(maximumZoomScale, aspectFillZoomScale(forBoundingSize: self.view.bounds.size, contentSize: imageView.bounds.size))
//        print(aspectFillZoomScale(forBoundingSize: self.view.bounds.size, contentSize: imageView.bounds.size))
//        scrollView.delegate = self
//    }
//
//    private func configureGestureRecognizers() {
//
//        doubleTapRecognizer.addTarget(self, action: #selector(scrollViewDidDoubleTap(_:)))
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        U.UI { self.scrollView.addGestureRecognizer(self.doubleTapRecognizer) }
//
//        swipeToDismissRecognizer.delegate = self
//        swipeToDismissRecognizer.cancelsTouchesInView = false
//        swipeToDismissRecognizer.addTarget(self, action: #selector(imageViewPanned(_:)))
//        U.UI { self.imageView.addGestureRecognizer(self.swipeToDismissRecognizer) }
//    }
//
//    fileprivate func createViewHierarchy() {
//
//        self.view.addSubview(scrollView)
//        scrollView.addSubview(imageView)
//    }

//
//    private func operationsWereFinished() -> Bool {
//
//        return previewLoaded && imageLoaded
//    }
//
//    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return imageView
//    }
//
//    @objc func scrollViewDidDoubleTap(_ recognizer: UITapGestureRecognizer) {
//
//        let touchPoint = recognizer.location(ofTouch: 0, in: imageView)
//        var zoomRectangle = CGRect()
//        let zoomScale: CGFloat = maximumZoomScale
//
//        if scrollView.zoomScale > scrollView.minimumZoomScale {
//            zoomRectangle = zoomRect(ForScrollView: scrollView, scale: scrollView.minimumZoomScale, center: touchPoint)
//
//        } else {
//            zoomRectangle = zoomRect(ForScrollView: scrollView, scale: zoomScale, center: touchPoint)
//        }
//
//        scrollView.zoom(to: zoomRectangle, animated: true)
//    }
//
//    @objc func imageViewPanned(_ recognizer: UIPanGestureRecognizer) {
//        delegate?.imageWasPanned(recognizer, view: imageView)
//    }
//}
//
//// MARK: - ScrollView delegate
//extension ImageVC: UIScrollViewDelegate {
//
//    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
////        delegate?.imageWasZoomed()
//
//        // When user zooming, if scale bigger than screen scale, download full size image
//        if scrollView.zoomScale > U.mainScreen.scale, !fullSizeImageLoaded {
//
//            self.fullSizeImageLoaded = true
//
//            U.BG {
//
//                let fileM = PFileManager()
//
//                if let imageId = self.imageId {
//
//                    let image = fileM.getDownsampledImageBy(id: imageId, pointSize: CGSize(width: self.imageFrame.size.width, height: self.imageFrame.size.height), scale: self.maximumZoomScale)
//
//                    U.UI {
//                        self.imageView.image = image
//                    }
//                }
//            }
//        }
//
//        imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
//    }
//}
//
//// MARK: Gesture delegate
//extension ImageVC: UIGestureRecognizerDelegate {
//
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        guard gestureRecognizer == swipeToDismissRecognizer, scrollView.zoomScale == 1 else { return false }
//
//        let velocity = swipeToDismissRecognizer.velocity(in: swipeToDismissRecognizer.view)
//
//        guard velocity.orientation != .none else { return false }
//
//        /// We continue if the swipe is horizontal, otherwise it's Vertical and it is swipe to dismiss.
//        guard velocity.orientation == .horizontal else { return true }
//
//        return false
//    }
//}



//final class GalleryPagingDataSource: NSObject, UIPageViewControllerDataSource {

//
//    func createItemController(_ itemIndex: Int, isInitial: Bool = false) -> UIViewController {
//        guard let itemsDataSource = itemsDataSource else { return UIViewController() }
//
//        let item = itemsDataSource.item(for: itemIndex).0
//        var vc: UIViewController!
//
//        if item.contentType == .video, let video = item as? VideoModel {
//          let player = VideoPlayerVC(video: video, index: itemIndex, isItem: true)
//          vc = player
//        } else if item.contentType == .photo {
//          vc = ImageVC(index: itemIndex, itemCount: itemsDataSource.itemCount(), imageId: item.id, loadingQueue: imageLoadingQueue, isInitialController: isInitial)
//        }
//
//        (vc as! GalleryPageProtocol).delegate = pageControllerDelegate
//
//        return vc
//    }
//}
//

    
//    private let cacheManager = PHCachingImageManager.

//
//
//class PhotoLoader {
//
//    private let cacheManager = PCacheManager.shared
//    private let fManager = PFileManager()
//    private let imageFinalSize = CGSize(width: 70, height: 70).toPixel()
//
//    func photoFor(id: String, completion: @escaping ((UIImage?) -> Void)) {
//
//        U.BG { [ weak self ] in
//            guard let self = self else { return }
//            if let image = self.cacheManager.getImageFromCache(id: id) {
//                completion(image)
//
//            } else {
//                let image = self.fManager.getImage(imageId: id)
//                completion(image)
//            }
//        }
//    }
//
//    func removePhotoFor(id: String) {
//        U.BG { [ weak self ] in
//            self?.fManager.deleteImage(imageId: id)
//        }
//    }
//
////    MARK: - PSI-135 UNUSED
//    func showPhotoSelection(for id: String, completion: @escaping (UIImage?) -> ()) {
//
////        MARK: - PSI-135 changes if need
//
////        dkImagePickerController.didSelectAssets = { (assets: [DKAsset]) in
////
////            U.BG { [weak self] in
////                guard let self = self else { return }
////
////                assets.first?.fetchImage(with: self.imageFinalSize, completeBlock: { (image, _) in
////                    if let data = image?.pngData() {
////                        self.fManager.f(id: id, data: data)
////                        completion(UIImage(data: data))
////                    }
////                })
////            }
////        }
////        topController()?.present(dkImagePickerController, animated: true)
//    }
//}

//
//extension CGSize {
//    
//    func toPixel() -> CGSize {
//        let scale = UIScreen.main.scale
//        return CGSize(width: self.width * scale, height: self.height * scale)
//    }
//}


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
