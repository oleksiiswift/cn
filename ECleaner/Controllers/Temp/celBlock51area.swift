//
//  celBlock51area.swift
//  ECleaner
//
//  Created by alekseii sorochan on 20.07.2021.
//

import UIKit



//      MARK: - ui setup -
//extension PhotoPreviewViewController {
//
//    private func setupUI() {
//    }
//
//    private func setupCollectionView() {
//
//        let cellPadding: CGFloat = 0
//        let carouselLayout = UICollectionViewFlowLayout()
//        carouselLayout.scrollDirection = .horizontal
//        carouselLayout.itemSize = .init(width: self.view.frame.width, height: self.view.frame.height)
//        carouselLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
//        carouselLayout.minimumLineSpacing = cellPadding
//        collectionView.isPagingEnabled = true
//        collectionView.collectionViewLayout = carouselLayout
//
//
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.prefetchDataSource = self
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: C.identifiers.cells.carouselCell)
//    }
//

//
//    private func configure(_ cell: CarouselCollectionViewCell, at indexPath: IndexPath) {
//
//        let targetSize = CGSize(width: U.screenWidth, height: U.screenHeight)
//
//        switch collectionType {
//            case .single:
//                chacheManager.requestImage(for: singleAssetsCollection[indexPath.row], targetSize: targetSize, contentMode: .aspectFit, options: nil) { image, _ in
//                    U.UI {
//                        if let image = image {
//                            cell.configureCell(image: image)
//                            debugPrint("cell config")
//                        }
//                    }
//                }
//            case .grouped:
////                chacheManager.requestImage(for: groupAssetsCollection[indexPath.section].assets[indexPath.row], targetSize: targetSize, contentMode: .aspectFit, options: nil) { image, _ in
////                    U.UI {
////                        if let image = image {
////                            cell.configureCell(image: image)
////                            debugPrint("group cell configured")
////                        }
////                    }
////                }
//                if let image = groupAssetsCollection[indexPath.section].assets[indexPath.row].thumbnail {
//                    cell.configureCell(image: image)
//                }
//
//            default:
//                debugPrint("no collection error")
//        }
//    }
//
//    public func reloadCollectionView() {
//        collectionView.reloadData()
//    }
//
//    public func scrollToImageView(at indexPath: IndexPath) {
//        debugPrint(indexPath)
//        U.UI {
//            self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
//        }
//    }
//}



//extension PhotoPreviewViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return collectionType == .single ? 1 : groupAssetsCollection.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return collectionType == .single ? singleAssetsCollection.count : groupAssetsCollection[section].assets.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.carouselCell, for: indexPath) as! CarouselCollectionViewCell
//        configure(cell, at: indexPath)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        U.UI {
////            switch self.collectionType {
////                case .single:
////                    let scale = max(U.mainScreen.scale, 2)
////                    let targetSize = CGSize(width: U.screenWidth * scale, height: U.screenHeight * scale)
////                    self.chacheManager.startCachingImages(for: self.singleAssetsCollection, targetSize: targetSize, contentMode: .aspectFit, options: nil)
////                case .grouped:
////                    let scale = max(U.mainScreen.scale, 2)
////                    let targetSize = CGSize(width: U.screenWidth * scale, height: U.screenHeight * scale)
////                    var assets: [PHAsset] = []
////                    for group in self.groupAssetsCollection {
////                        assets.append(contentsOf: group.assets)
////                    }
////                    self.chacheManager.startCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFit, options: nil)
////                default:
////                    return
////            }
//        }
//    }
//}

//class CarouselViewRemove: UIView {
//
////    MARK: - properties -
//
//    struct CarouselDataAssets {
//        let image: UIImage?
//        let isSelected: Bool
//    }
//}




//// MARK: - UICollectionView Delegate
//extension CarouselView: UICollectionViewDelegate {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        currentPage = getCurrentPage()
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        currentPage = getCurrentPage()
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        currentPage = getCurrentPage()
//    }
//}
//// MARKK: - Helpers
//private extension CarouselView {
//    func getCurrentPage() -> Int {
//
//        let visibleRect = CGRect(origin: carouselCollectionView.contentOffset, size: carouselCollectionView.bounds.size)
//        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//        if let visibleIndexPath = carouselCollectionView.indexPathForItem(at: visiblePoint) {
//            return visibleIndexPath.row
//        }
//
//        return currentPage
//    }
//}

//
//import UIKit
//import Photos

//extension PHCachingImageManager {
//    

//    

//    func fetchPreviewFor(video asset: PHAsset, callback: @escaping (UIImage) -> Void) {
//        let options = PHImageRequestOptions()
//        options.isNetworkAccessAllowed = true
//        options.isSynchronous = true
//        let screenWidth = YPImagePickerConfiguration.screenWidth
//        let ts = CGSize(width: screenWidth, height: screenWidth)
//        requestImage(for: asset, targetSize: ts, contentMode: .aspectFill, options: options) { image, _ in
//            if let image = image {
//                DispatchQueue.main.async {
//                    callback(image)
//                }
//            }
//        }
//    }
//    
//    func fetchPlayerItem(for video: PHAsset, callback: @escaping (AVPlayerItem) -> Void) {
//        let videosOptions = PHVideoRequestOptions()
//        videosOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.automatic
//        videosOptions.isNetworkAccessAllowed = true
//        requestPlayerItem(forVideo: video, options: videosOptions, resultHandler: { playerItem, _ in
//            DispatchQueue.main.async {
//                if let playerItem = playerItem {
//                    callback(playerItem)
//                }
//            }
//        })
//    }
//    
//    /// This method return two images in the callback. First is with low resolution, second with high.
//    /// So the callback fires twice.
//    func fetch(photo asset: PHAsset, callback: @escaping (UIImage, Bool) -> Void) {
//        let options = PHImageRequestOptions()
//        // Enables gettings iCloud photos over the network, this means PHImageResultIsInCloudKey will never be true.
//        options.isNetworkAccessAllowed = true
//        // Get 2 results, one low res quickly and the high res one later.
//        options.deliveryMode = .opportunistic
//        requestImage(for: asset, targetSize: PHImageManagerMaximumSize,
//                     contentMode: .aspectFill, options: options) { result, info in
//            guard let image = result else {
//                print("No Result 🛑")
//                return
//            }
//            DispatchQueue.main.async {
//                let isLowRes = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
//                callback(image, isLowRes)
//            }
//        }
//    }
//}



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


//    func item(at index: Int, section: Int) -> (PHAsset, UIImageView) {
//
//        var imageView = UIImageView()
//
//        let indexPath = IndexPath(item: index, section: section)
//
//        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
//            imageView = cell.photoThumbnailImageView
//        }
//        return (assetGroups[section].assets[index], imageView)
//    }


enum PartialCardImageDrawMode: String {
    case all
    case top
    case center
    case bottom
}

struct PartialCardImage {
    
    var drawMode: PartialCardImageDrawMode
    var edgeInsets: UIEdgeInsets
    var backgroundColor: UIColor
    var cornerRadius: CGFloat
    var shadowColor: UIColor
    var shadowOffset: CGSize
    var shadowOpacity: CGFloat
    var shadowRadius: CGFloat
    
    init(drawMode: PartialCardImageDrawMode = .all,
         edgeInsets: UIEdgeInsets = .zero,
         backgroundColor: UIColor = .white,
         cornerRadius: CGFloat = 0.0,
         shadowColor: UIColor = .black,
         shadowOffset: CGSize = CGSize(width: 0, height: 0),
         shadowOpacity: CGFloat = 0.0,
         shadowRadius: CGFloat = 0.0) {
        self.drawMode = drawMode
        self.edgeInsets = edgeInsets
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
    }
    
    private var shadowInsets: UIEdgeInsets {
        var insets = self.edgeInsets
        
        switch drawMode {
        case .top:
            insets.bottom = 0
        case .center:
            insets.top = 0
            insets.bottom = 0
        case .bottom:
            insets.top = 0
        default:
            break
        }
        
        return insets
    }
    
    private var imageSize: CGSize {
        let width = shadowInsets.left + shadowWidth + 1 + shadowWidth + shadowInsets.right
        let shadowTop = shadowInsets.top + shadowHeight
        let shadowBottom = shadowInsets.bottom + shadowHeight
        
        switch drawMode {
        case .top:
            return CGSize(width: width,
                          height: 1 + shadowTop)
        case .center:
            return CGSize(width: width,
                          height: 1)
        case .bottom:
            return CGSize(width: width,
                          height: 1 + shadowBottom)
        default:
            return CGSize(width: width,
                          height: 1 + shadowTop + shadowBottom)
        }
    }
    
    private var shadowRect: CGRect {
        let x = shadowInsets.left
        let width = shadowWidth + 1 + shadowWidth
        let height = shadowHeight + 1 + shadowHeight

        switch drawMode {
        case .top:
            return CGRect(x: x,
                          y: shadowInsets.top,
                          width: width,
                          height: height)
        case .center:
            return CGRect(x: x,
                          y: -shadowHeight,
                          width: width,
                          height: height)
        case .bottom:
            return CGRect(x: x,
                          y: height - shadowInsets.bottom,
                          width: width,
                          height: height)
        default:
            return CGRect(x: x,
                          y: shadowInsets.top,
                          width: width,
                          height: height)
        }
    }
    
    private var resizableImageCapInsets: UIEdgeInsets {
        var insets = UIEdgeInsets(top: shadowInsets.top + shadowHeight,
                                  left: shadowInsets.left + shadowWidth,
                                  bottom: shadowInsets.bottom + shadowHeight,
                                  right: shadowInsets.right + shadowWidth)
        
        switch drawMode {
        case .top:
            insets.bottom = 1
        case .center:
            insets.top = 1
            insets.bottom = 1
        case .bottom:
            insets.top = 1
        default:
            break
        }
        
        return insets
    }
    
    func draw() -> UIImage? {
        let size = imageSize
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: cornerRadius)
        
        context.setShadow(offset: shadowOffset,
                          blur: shadowRadius,
                          color: shadowColor.withAlphaComponent(shadowOpacity).cgColor)
        
        context.setFillColor(backgroundColor.cgColor)
        
        shadowPath.fill()
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        return image.resizableImage(withCapInsets: resizableImageCapInsets,
                                    resizingMode: .stretch)
    }

    private var shadowHeight: CGFloat {
        return shadowRadius + shadowOffset.height
    }
    
    private var shadowWidth: CGFloat {
        return shadowRadius + shadowOffset.width
    }

}


class CardBackgroundImageView: UIView {
    
    let cardImage: PartialCardImage
    
    let imageView = UIImageView()

    init(cardImage: PartialCardImage) {
        self.cardImage = cardImage
        
        super.init(frame: .zero)
        
        imageView.image = cardImage.draw()
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var edgeInsets = UIEdgeInsets.zero
        
        switch cardImage.drawMode {
        case .top:
            edgeInsets.top = -cardImage.edgeInsets.top
        case .bottom:
            edgeInsets.bottom = -cardImage.edgeInsets.bottom
        case .all:
            edgeInsets.top = -cardImage.edgeInsets.top
            edgeInsets.bottom = -cardImage.edgeInsets.bottom
        default:
            break
        }
        
        imageView.frame = bounds.inset(by: edgeInsets)
        
        clipsToBounds = false
    }
    
}
