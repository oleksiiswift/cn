////
////  celBlock51area.swift
////  ECleaner
////
////  Created by alekseii sorochan on 20.07.2021.
////
//
//import UIKit
//import Photos
//
//
//
////      MARK: - ui setup -
////extension PhotoPreviewViewControllerOLDVers {
////
////    private func setupUI() {
////    }
////
////    private func setupCollectionView() {
////
////        let cellPadding: CGFloat = 0
////        let carouselLayout = UICollectionViewFlowLayout()
////        carouselLayout.scrollDirection = .horizontal
////        carouselLayout.itemSize = .init(width: self.view.frame.width, height: self.view.frame.height)
////        carouselLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
////        carouselLayout.minimumLineSpacing = cellPadding
////        collectionView.isPagingEnabled = true
////        collectionView.collectionViewLayout = carouselLayout
////
////
////        collectionView.dataSource = self
////        collectionView.delegate = self
////        collectionView.prefetchDataSource = self
////        collectionView.showsVerticalScrollIndicator = false
////        collectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: C.identifiers.cells.carouselCell)
////    }
////
//
////
////    private func configure(_ cell: CarouselCollectionViewCell, at indexPath: IndexPath) {
////
////        let targetSize = CGSize(width: U.screenWidth, height: U.screenHeight)
////
////        switch collectionType {
////            case .single:
////                chacheManager.requestImage(for: singleAssetsCollection[indexPath.row], targetSize: targetSize, contentMode: .aspectFit, options: nil) { image, _ in
////                    U.UI {
////                        if let image = image {
////                            cell.configureCell(image: image)
////                            debugPrint("cell config")
////                        }
////                    }
////                }
////            case .grouped:
//////                chacheManager.requestImage(for: groupAssetsCollection[indexPath.section].assets[indexPath.row], targetSize: targetSize, contentMode: .aspectFit, options: nil) { image, _ in
//////                    U.UI {
//////                        if let image = image {
//////                            cell.configureCell(image: image)
//////                            debugPrint("group cell configured")
//////                        }
//////                    }
//////                }
////                if let image = groupAssetsCollection[indexPath.section].assets[indexPath.row].thumbnail {
////                    cell.configureCell(image: image)
////                }
////
////            default:
////                debugPrint("no collection error")
////        }
////    }
////
////    public func reloadCollectionView() {
////        collectionView.reloadData()
////    }
////
////    public func scrollToImageView(at indexPath: IndexPath) {
////        debugPrint(indexPath)
////        U.UI {
////            self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
////        }
////    }
////}
//
//
//
////extension PhotoPreviewViewControllerOLDVers: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
////
////    func numberOfSections(in collectionView: UICollectionView) -> Int {
////        return collectionType == .single ? 1 : groupAssetsCollection.count
////    }
////
////    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        return collectionType == .single ? singleAssetsCollection.count : groupAssetsCollection[section].assets.count
////    }
////
////    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.carouselCell, for: indexPath) as! CarouselCollectionViewCell
////        configure(cell, at: indexPath)
////        return cell
////    }
////
////    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
////        U.UI {
//////            switch self.collectionType {
//////                case .single:
//////                    let scale = max(U.mainScreen.scale, 2)
//////                    let targetSize = CGSize(width: U.screenWidth * scale, height: U.screenHeight * scale)
//////                    self.chacheManager.startCachingImages(for: self.singleAssetsCollection, targetSize: targetSize, contentMode: .aspectFit, options: nil)
//////                case .grouped:
//////                    let scale = max(U.mainScreen.scale, 2)
//////                    let targetSize = CGSize(width: U.screenWidth * scale, height: U.screenHeight * scale)
//////                    var assets: [PHAsset] = []
//////                    for group in self.groupAssetsCollection {
//////                        assets.append(contentsOf: group.assets)
//////                    }
//////                    self.chacheManager.startCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFit, options: nil)
//////                default:
//////                    return
//////            }
////        }
////    }
////}
//
////class CarouselViewRemove: UIView {
////
//////    MARK: - properties -
////
////    struct CarouselDataAssets {
////        let image: UIImage?
////        let isSelected: Bool
////    }
////}
//
//
//
//
////// MARK: - UICollectionView Delegate
////extension CarouselView: UICollectionViewDelegate {
////    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
////        currentPage = getCurrentPage()
////    }
////
////    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
////        currentPage = getCurrentPage()
////    }
////
////    func scrollViewDidScroll(_ scrollView: UIScrollView) {
////        currentPage = getCurrentPage()
////    }
////}
////// MARKK: - Helpers
////private extension CarouselView {
////    func getCurrentPage() -> Int {
////
////        let visibleRect = CGRect(origin: carouselCollectionView.contentOffset, size: carouselCollectionView.bounds.size)
////        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
////        if let visibleIndexPath = carouselCollectionView.indexPathForItem(at: visiblePoint) {
////            return visibleIndexPath.row
////        }
////
////        return currentPage
////    }
////}
//
////
////import UIKit
////import Photos
//
////extension PHCachingImageManager {
////    
//
////    
//
////    func fetchPreviewFor(video asset: PHAsset, callback: @escaping (UIImage) -> Void) {
////        let options = PHImageRequestOptions()
////        options.isNetworkAccessAllowed = true
////        options.isSynchronous = true
////        let screenWidth = YPImagePickerConfiguration.screenWidth
////        let ts = CGSize(width: screenWidth, height: screenWidth)
////        requestImage(for: asset, targetSize: ts, contentMode: .aspectFill, options: options) { image, _ in
////            if let image = image {
////                DispatchQueue.main.async {
////                    callback(image)
////                }
////            }
////        }
////    }
////    
////    func fetchPlayerItem(for video: PHAsset, callback: @escaping (AVPlayerItem) -> Void) {
////        let videosOptions = PHVideoRequestOptions()
////        videosOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.automatic
////        videosOptions.isNetworkAccessAllowed = true
////        requestPlayerItem(forVideo: video, options: videosOptions, resultHandler: { playerItem, _ in
////            DispatchQueue.main.async {
////                if let playerItem = playerItem {
////                    callback(playerItem)
////                }
////            }
////        })
////    }
////    
////    /// This method return two images in the callback. First is with low resolution, second with high.
////    /// So the callback fires twice.
////    func fetch(photo asset: PHAsset, callback: @escaping (UIImage, Bool) -> Void) {
////        let options = PHImageRequestOptions()
////        // Enables gettings iCloud photos over the network, this means PHImageResultIsInCloudKey will never be true.
////        options.isNetworkAccessAllowed = true
////        // Get 2 results, one low res quickly and the high res one later.
////        options.deliveryMode = .opportunistic
////        requestImage(for: asset, targetSize: PHImageManagerMaximumSize,
////                     contentMode: .aspectFill, options: options) { result, info in
////            guard let image = result else {
////                print("No Result 🛑")
////                return
////            }
////            DispatchQueue.main.async {
////                let isLowRes = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
////                callback(image, isLowRes)
////            }
////        }
////    }
////}
//
//
//
////extension PhotoPreviewViewControllerOLDVers: UIPageViewControllerDataSource {
////
////    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
////        guard let viewControllerIndex = loadedViewControllers.firstIndex(of: viewController) else { return nil}
////
////        let previousIndex = viewControllerIndex - 1
////
////        guard previousIndex >= 0 else {
////            return loadedViewControllers.last
////        }
////
////        guard loadedViewControllers.count > previousIndex else { return nil}
////        return loadedViewControllers[previousIndex]
////    }
////
////    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
////        guard let viewControllerIndex = loadedViewControllers.firstIndex(of: viewController) else { return nil }
////
////        let nextIndex = viewControllerIndex + 1
////
////        guard loadedViewControllers.count != nextIndex else {
////            return loadedViewControllers.first
////        }
////
////        guard loadedViewControllers.count > nextIndex else {
////            return nil
////        }
////
////        return loadedViewControllers[nextIndex]
////    }
////
////    func presentationCount(for _: UIPageViewController) -> Int {
////        return loadedViewControllers.count
////    }
////
////    func presentationIndex(for _: UIPageViewController) -> Int {
////        guard let firstViewController = viewControllers?.first,
////              let firstViewControllerIndex = loadedViewControllers.firstIndex(of: firstViewController) else {
////            return 0
////        }
////        return firstViewControllerIndex
////    }
////}
//
//
////public protocol ImageControllerDelegate: class {
////
////    func imageControllerDidAppear(_ controller: ImageVC)
////    func imageControllerWillDisappear(_ controller: ImageVC)
////    func imageWasPanned(_ recognizer: UIPanGestureRecognizer, imageView: UIImageView)
////    func imageWasZoomed()
////}
////
//
//
//
//
//
////
////open class ImageVC: UIViewController, GalleryPageProtocol {
////
////    public weak var delegate: GalleryPageDelegate?
//
////    public var index: Int
////    public var isInitialController = false
////    public let itemCount: Int
////    public let imageId: String?
////
////    public var loadingQueue: ImageOperation?
////
////    private let scrollView = UIScrollView()
////    private var isAnimating = false
////
////    private let minimumZoomScale: CGFloat = 1
////    private let maximumZoomScale: CGFloat = 2.5
////
////    private var previewLoaded: Bool = false
////    private var imageLoaded: Bool = false
////    private var fullSizeImageLoaded: Bool = false // image for zooming
////    private var imageFrame: CGRect = CGRect()
////
////    /// INTERACTIONS
////    private let doubleTapRecognizer = UITapGestureRecognizer()
////    private let swipeToDismissRecognizer = UIPanGestureRecognizer()
////
////    public init(index: Int, itemCount: Int, imageId: String?, loadingQueue: ImageOperation, isInitialController: Bool = false) {
////
////        self.isInitialController = isInitialController
////        self.imageId = imageId
//
////
////        super.init(nibName: nil, bundle: nil)
////
////        self.modalPresentationStyle = .custom
////        self.view.backgroundColor = .clear
////    }
////
////    open override func viewDidLoad() {
////        super.viewDidLoad()
////
////        configureScrollView()
////        configureGestureRecognizers()
////        createViewHierarchy()
////    }
////
////    override open func viewDidLayoutSubviews() {
////        super.viewDidLayoutSubviews()
////
////        scrollView.frame = self.view.bounds
////
////        if let size = imageView.image?.size , size != CGSize.zero {
////
////            let aspectFitItemSize = aspectFitSize(forContentOfSize: size, inBounds: self.scrollView.bounds.size)
////
////            imageView.bounds.size = aspectFitItemSize
////            scrollView.contentSize = imageView.bounds.size
////
////            imageView.center = scrollView.boundsCenter
////        }
////    }
////    open override func viewDidDisappear(_ animated: Bool) {
////        super.viewDidDisappear(animated)
////
////        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
////    }
////}
////
////
////extension ImageVC {
////
////    // MARK: - Helpers
////    private func setImage() {
////
////        let fileManager = PFileManager()
////
////        guard let imageId = imageId else {
////            return
////        }
////
////        let image = fileManager.getDownsampledImageBy(id: imageId, pointSize: CGSize(width: U.screen.size.width, height: U.screen.size.height), scale: U.mainScreen.scale)
////
////        self.imageView.isAccessibilityElement = image.isAccessibilityElement
////        self.imageView.accessibilityLabel = image.accessibilityLabel
////        self.imageView.accessibilityTraits = image.accessibilityTraits
////
////        U.UI {
////
////            self.imageView.image = image
////            self.imageLoaded = true
////            self.view.setNeedsLayout()
////            self.view.layoutIfNeeded()
////        }
////    }
////
////    private func configureImageViewWithPreview() {
////
////        guard let imageId = imageId else {
////            return
////        }
////
////        let photosManager = PhotoDatabaseManager()
////
////        guard let image = photosManager.getPreviewForPhoto(by: imageId) else {
////            return
////        }
////
////        self.imageView.isAccessibilityElement = image.isAccessibilityElement
////        self.imageView.accessibilityLabel = image.accessibilityLabel
////        self.imageView.accessibilityTraits = image.accessibilityTraits
////
////        U.UI {
////
////            self.imageView.image = image
////            self.view.setNeedsLayout()
////            self.view.layoutIfNeeded()
////            self.previewLoaded = true
////            self.imageFrame = self.imageView.frame
////        }
////    }
////
////    // MARK: - Configuration
////    fileprivate func configureScrollView() {
////
////        scrollView.showsHorizontalScrollIndicator = false
////        scrollView.showsVerticalScrollIndicator = false
////        scrollView.backgroundColor = .clear
////        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
////        scrollView.contentInset = UIEdgeInsets.zero
////        scrollView.contentOffset = CGPoint.zero
////        scrollView.minimumZoomScale = minimumZoomScale
////        scrollView.maximumZoomScale = max(maximumZoomScale, aspectFillZoomScale(forBoundingSize: self.view.bounds.size, contentSize: imageView.bounds.size))
////        print(aspectFillZoomScale(forBoundingSize: self.view.bounds.size, contentSize: imageView.bounds.size))
////        scrollView.delegate = self
////    }
////
////    private func configureGestureRecognizers() {
////
////        doubleTapRecognizer.addTarget(self, action: #selector(scrollViewDidDoubleTap(_:)))
////        doubleTapRecognizer.numberOfTapsRequired = 2
////        U.UI { self.scrollView.addGestureRecognizer(self.doubleTapRecognizer) }
////
////        swipeToDismissRecognizer.delegate = self
////        swipeToDismissRecognizer.cancelsTouchesInView = false
////        swipeToDismissRecognizer.addTarget(self, action: #selector(imageViewPanned(_:)))
////        U.UI { self.imageView.addGestureRecognizer(self.swipeToDismissRecognizer) }
////    }
////
////    fileprivate func createViewHierarchy() {
////
////        self.view.addSubview(scrollView)
////        scrollView.addSubview(imageView)
////    }
//
////
////    private func operationsWereFinished() -> Bool {
////
////        return previewLoaded && imageLoaded
////    }
////
////    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
////        return imageView
////    }
////
////    @objc func scrollViewDidDoubleTap(_ recognizer: UITapGestureRecognizer) {
////
////        let touchPoint = recognizer.location(ofTouch: 0, in: imageView)
////        var zoomRectangle = CGRect()
////        let zoomScale: CGFloat = maximumZoomScale
////
////        if scrollView.zoomScale > scrollView.minimumZoomScale {
////            zoomRectangle = zoomRect(ForScrollView: scrollView, scale: scrollView.minimumZoomScale, center: touchPoint)
////
////        } else {
////            zoomRectangle = zoomRect(ForScrollView: scrollView, scale: zoomScale, center: touchPoint)
////        }
////
////        scrollView.zoom(to: zoomRectangle, animated: true)
////    }
////
////    @objc func imageViewPanned(_ recognizer: UIPanGestureRecognizer) {
////        delegate?.imageWasPanned(recognizer, view: imageView)
////    }
////}
////
////// MARK: - ScrollView delegate
////extension ImageVC: UIScrollViewDelegate {
////
////    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
//////        delegate?.imageWasZoomed()
////
////        // When user zooming, if scale bigger than screen scale, download full size image
////        if scrollView.zoomScale > U.mainScreen.scale, !fullSizeImageLoaded {
////
////            self.fullSizeImageLoaded = true
////
////            U.BG {
////
////                let fileM = PFileManager()
////
////                if let imageId = self.imageId {
////
////                    let image = fileM.getDownsampledImageBy(id: imageId, pointSize: CGSize(width: self.imageFrame.size.width, height: self.imageFrame.size.height), scale: self.maximumZoomScale)
////
////                    U.UI {
////                        self.imageView.image = image
////                    }
////                }
////            }
////        }
////
////        imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
////    }
////}
////
////// MARK: Gesture delegate
////extension ImageVC: UIGestureRecognizerDelegate {
////
////    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
////
////        guard gestureRecognizer == swipeToDismissRecognizer, scrollView.zoomScale == 1 else { return false }
////
////        let velocity = swipeToDismissRecognizer.velocity(in: swipeToDismissRecognizer.view)
////
////        guard velocity.orientation != .none else { return false }
////
////        /// We continue if the swipe is horizontal, otherwise it's Vertical and it is swipe to dismiss.
////        guard velocity.orientation == .horizontal else { return true }
////
////        return false
////    }
////}
//
//
//
////final class GalleryPagingDataSource: NSObject, UIPageViewControllerDataSource {
//
////
////    func createItemController(_ itemIndex: Int, isInitial: Bool = false) -> UIViewController {
////        guard let itemsDataSource = itemsDataSource else { return UIViewController() }
////
////        let item = itemsDataSource.item(for: itemIndex).0
////        var vc: UIViewController!
////
////        if item.contentType == .video, let video = item as? VideoModel {
////          let player = VideoPlayerVC(video: video, index: itemIndex, isItem: true)
////          vc = player
////        } else if item.contentType == .photo {
////          vc = ImageVC(index: itemIndex, itemCount: itemsDataSource.itemCount(), imageId: item.id, loadingQueue: imageLoadingQueue, isInitialController: isInitial)
////        }
////
////        (vc as! GalleryPageProtocol).delegate = pageControllerDelegate
////
////        return vc
////    }
////}
////
//
//    
////    private let cacheManager = PHCachingImageManager.
//
////
////
////class PhotoLoader {
////
////    private let cacheManager = PCacheManager.shared
////    private let fManager = PFileManager()
////    private let imageFinalSize = CGSize(width: 70, height: 70).toPixel()
////
////    func photoFor(id: String, completion: @escaping ((UIImage?) -> Void)) {
////
////        U.BG { [ weak self ] in
////            guard let self = self else { return }
////            if let image = self.cacheManager.getImageFromCache(id: id) {
////                completion(image)
////
////            } else {
////                let image = self.fManager.getImage(imageId: id)
////                completion(image)
////            }
////        }
////    }
////
////    func removePhotoFor(id: String) {
////        U.BG { [ weak self ] in
////            self?.fManager.deleteImage(imageId: id)
////        }
////    }
////
//////    MARK: - PSI-135 UNUSED
////    func showPhotoSelection(for id: String, completion: @escaping (UIImage?) -> ()) {
////
//////        MARK: - PSI-135 changes if need
////
//////        dkImagePickerController.didSelectAssets = { (assets: [DKAsset]) in
//////
//////            U.BG { [weak self] in
//////                guard let self = self else { return }
//////
//////                assets.first?.fetchImage(with: self.imageFinalSize, completeBlock: { (image, _) in
//////                    if let data = image?.pngData() {
//////                        self.fManager.f(id: id, data: data)
//////                        completion(UIImage(data: data))
//////                    }
//////                })
//////            }
//////        }
//////        topController()?.present(dkImagePickerController, animated: true)
////    }
////}
//
//
//
//
//
//#warning("WORK IN PROGRESS")
////extension PhotoManager {
////	
////	public func recoverSelectedOperation(assets: [PHAsset], completion: @escaping ((Bool) -> Void)) -> ConcurrentProcessOperation {
////		
////		let recoverPhassetsOperation = ConcurrentProcessOperation { operation in
////			
////			self.fetchManager.fetchRecentlyDeletedCollection { recentlyDeletedCollection in
////				PHPhotoLibrary.shared().performChanges {
////					if let recentlyDeletedAlbum = recentlyDeletedCollection {
////						let assetsIdentifiers = assets.map({$0.localIdentifier})
////						
////						
//////						PHPhotoLibrary.shared().performChanges({
////								guard let request = PHAssetCollectionChangeRequest(for: recentlyDeletedAlbum) else {
////									return
////								}
//////								request.removeAssets([asset] as NSArray)
//////						request.removeAssets([assets] as NSArray)
////						
//////						let albumPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumRecentlyAdded, options: nil)
//////
//////						albumPhoto.enumerateObjects { collection, index, object in
//////							let result = PHAsset.fetchAssets(in: collection, options: nil)
//////
//////
//////
//////							var a = PHAsset.fetchAssets(in: collection, options: nil)
//////
//////							var z: [PHAsset] = []
//////							a.enumerateObjects { asset, index, object in
//////								z.append(asset)
//////							}
//////
//////							let id = z.map({$0.localIdentifier})
//////
//////
//////
//////							let s = PHAsset.fetchAssets(withLocalIdentifiers: id, options: nil)
//////
//////							let albumChangeR = PHAssetCollectionChangeRequest(for: collection, assets: s)
//////
//////							s.enumerateObjects { assets, index, object in
//////								debugPrint(assets.localIdentifier)
//////							}
//////						}
////						
//////						let recent = PHAsset.fetchAssets(in: recentlyDeletedAlbum, options: .none)
////						
////					
////						
////						
////						
//////						fetchOptions.sortDescriptors = [NSSortDescriptor(key: SortingDesriptionKey.creationDate.value, ascending: false)]
//////						fetchOptions.predicate = NSPredicate(
//////							format: "\(SDKey.mediaType.value) = %d AND (\(SDKey.creationDate.value) >= %@) AND (\(SDKey.creationDate.value) <= %@)",
//////							type,
//////							lowerDate as NSDate,
//////							upperDate as NSDate
//////						)
//////						albumPhoto.enumerateObjects({(collection, index, object) in
//////							completionHandler(PHAsset.fetchAssets(in: collection, options: fetchOptions))
//////
////						
//////						let options = PHFetchOptions()
////						
////						
////						
////						
////						
//////						let results = PHAsset.fetchAssets(withLocalIdentifiers: assetsIdentifiers, options: options)
//////						debugPrint(results.count)
//////						results.enumerateObjects { asset, index, object in
//////							debugPrint(asset.localIdentifier)
//////						}
//////
//////
//////
////						
//////						NSPredicate(format: "localIdentifier = %@", assetsIdentifiers)
////						
////						
//////						let albumChangeRequest = PHAssetCollectionChangeRequest(for: recentlyDeletedAlbum, assets: recent)
//////
////						let fastEnumeration = NSArray(array: assets)
//////						albumChangeRequest?.removeAssets(fastEnumeration)
//////
//////						request.removeAssets(fastEnumeration)
////				
//////						PHPhotoLibrary.shared()
////						
//////
//////						let assetIdentifiers = assetsToDeleteFromDevice.map({ $0.localIdentifier })
//////						let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
////					
////						
////						
////			
////					}
////				} completionHandler: { suxxess, error in
////					completion(false)
////				}
////			}
////			
////			
////			
//////			var albumPlaceholder: PHObjectPlaceholder?
//////			   PHPhotoLibrary.shared().performChanges({
//////				   // Request creating an album with parameter name
//////				   let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
//////				   // Get a placeholder for the new album
//////				   albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
//////			   }, completionHandler: { success, error in
//////				   if success {
//////					   guard let placeholder = albumPlaceholder else {
//////						   fatalError("Album placeholder is nil")
//////					   }
//////
//////					   let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
//////					   guard let album: PHAssetCollection = fetchResult.firstObject else {
//////						   // FetchResult has no PHAssetCollection
//////						   return
//////					   }
//////
//////					   // Saved successfully!
//////					   print(album.assetCollectionType)
//////				   }
//////				   else if let e = error {
//////					   // Save album failed with error
//////				   }
//////
////
//////
//////
////			
//////			PHPhotoLibrary.shared().performChanges({
//////				   let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//////				   let placeholder = assetRequest.placeholderForCreatedAsset
//////				   guard let _placeholder = placeholder else { completion(nil); return }
//////
//////				   let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
//////				   albumChangeRequest?.addAssets([_placeholder] as NSFastEnumeration)
//////			   }) { success, error in
//////				   completion(nil)
//////			   }
////			
////			
////		}
////		
////		recoverPhassetsOperation.name = C.key.operation.name.recoverPhassetsOperation
////		return recoverPhassetsOperation
////	}
////}
//
//class PreviewLayout: UICollectionViewFlowLayout {
//
//	let offsetBetweenCells: CGFloat = 44
//	var layoutHandler: LayoutChangeHandler?
//
//	override init() {
//		super.init()
//		commonInit()
//	}
//
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//
//	func commonInit() {
//		scrollDirection = .horizontal
//		minimumLineSpacing = 0
//		minimumInteritemSpacing = 0
//	}
//}
//
//// MARK: - UICollectionViewFlowLayout overrides
//extension PreviewLayout {
//
//	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//		return true
//	}
//
//	override class var layoutAttributesClass: AnyClass {
//		return ParallaxLayoutAttributes.self
//	}
//
//	override func prepare() {
//		super.prepare()
//		if let collectionView = collectionView, let layoutHandler = layoutHandler {
//			let size = collectionView.bounds.size
//			if size != itemSize {
//				itemSize = size
//				invalidateLayout()
//			}
//			if layoutHandler.needsUpdateOffset {
//				let offset = collectionView.contentOffset
//				collectionView.contentOffset = targetContentOffset(forProposedContentOffset: offset)
//			}
//		}
//	}
//
//	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//		return super.layoutAttributesForElements(in: rect)?
//			.compactMap { $0.copy() as? ParallaxLayoutAttributes }
//			.compactMap(prepareAttributes)
//	}
//
//	private func prepareAttributes(attributes: ParallaxLayoutAttributes) -> ParallaxLayoutAttributes {
//		guard let collectionView = self.collectionView else { return attributes }
//
//		let width = itemSize.width
//		let centerX = width / 2
//		let distanceToCenter = attributes.center.x - collectionView.contentOffset.x
//		let relativeDistanceToCenter = (distanceToCenter - centerX) / width
//
//		if abs(relativeDistanceToCenter) >= 1 {
//			attributes.parallaxValue = .none
//			attributes.transform = .identity
//		} else {
//			attributes.parallaxValue = relativeDistanceToCenter
//			attributes.transform = CGAffineTransform(translationX: relativeDistanceToCenter * offsetBetweenCells, y: 0)
//		}
//		return attributes
//	}
//
//	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
//		let targetOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
//		guard let layoutHandler = layoutHandler, layoutHandler.needsUpdateOffset else {
//			return targetOffset
//		}
//		return CGPoint(
//			x: CGFloat(layoutHandler.targetIndex) * itemSize.width,
//			y: targetOffset.y)
//	}
//}
//
//
//
//class ParallaxLayoutAttributes: UICollectionViewLayoutAttributes {
//	var parallaxValue: CGFloat?
//}
//
//
//extension ParallaxLayoutAttributes {
//
//	override func copy(with zone: NSZone? = nil) -> Any {
//		let copy = super.copy(with: zone) as? ParallaxLayoutAttributes
//		copy?.parallaxValue = self.parallaxValue
//		return copy.require(hint: "Unexpected copy type.")
//	}
//
//	override func isEqual(_ object: Any?) -> Bool {
//		let attrs = object as? ParallaxLayoutAttributes
//		if attrs?.parallaxValue != parallaxValue {
//			return false
//		}
//		return super.isEqual(object)
//	}
//}
//
//public extension Optional {
//	/**
//	 *  Require this optional to contain a non-nil value
//	 *
//	 *  This method will either return the value that this optional contains, or trigger
//	 *  a `preconditionFailure` with an error message containing debug information.
//	 *
//	 *  - parameter hint: Optionally pass a hint that will get included in any error
//	 *                    message generated in case nil was found.
//	 *
//	 *  - return: The value this optional contains.
//	 */
//	func require(hint hintExpression: @autoclosure () -> String? = nil,
//				 file: StaticString = #file,
//				 line: UInt = #line) -> Wrapped {
//		guard let unwrapped = self else {
//			var message = "Required value was nil in \(file), at line \(line)"
//
//			if let hint = hintExpression() {
//				message.append(". Debugging hint: \(hint)")
//			}
//
//			#if !os(Linux)
//			let exception = NSException(
//				name: .invalidArgumentException,
//				reason: message,
//				userInfo: nil
//			)
//
//			exception.raise()
//			#endif
//
//			preconditionFailure(message)
//		}
//
//		return unwrapped
//	}
//}
//
//enum InteractionState {
//	case enabled
//	case disabled
//}
//
//enum LayoutState {
//	case ready
//	case configuring
//}
//
//protocol LayoutChangeHandler {
//	var needsUpdateOffset: Bool { get }
//	var targetIndex: Int { get }
//	var layoutState: LayoutState { get set }
//}
//
//class ScrollSynchronizer: NSObject {
//	let preview: PreviewLayout
//	let thumbnails: ThumbnailLayout
//
//	var activeIndex = 0
//	var layoutStateInternal: LayoutState = .configuring
//	var interactionState: InteractionState = .enabled
//
//	init(preview: PreviewLayout, thumbnails: ThumbnailLayout) {
//		self.preview = preview
//		self.thumbnails = thumbnails
//		super.init()
//		self.thumbnails.layoutHandler = self
//		self.preview.layoutHandler = self
//		bind()
//	}
//
//	func reload() {
//		preview.collectionView?.reloadData()
//		thumbnails.collectionView?.reloadData()
//	}
//}
//
//	// MARK: - UICollectionViewDelegate
//	extension ScrollSynchronizer: UICollectionViewDelegate {
//
//		func scrollViewDidScroll(_ scrollView: UIScrollView) {
//			guard let collection = scrollView as? UICollectionView else { return }
//			unbind()
//			if collection == preview.collectionView {
//				let offset = scrollView.contentOffset.x
//				let relativeOffset = offset / preview.itemSize.width / CGFloat(collection.numberOfItems(inSection: 0))
//				thumbnails.changeOffset(relative: relativeOffset)
//				activeIndex = thumbnails.nearestIndex
//			}
//			if scrollView == thumbnails.collectionView {
//				print(thumbnails.relativeOffset)
//				let index = thumbnails.nearestIndex
//				if index != activeIndex {
//					activeIndex = index
//					let indexPath = IndexPath(row: activeIndex, section: 0)
//					preview.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//				}
//			}
//			bind()
//		}
//
//		func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//			if activeIndex != indexPath.row {
//				activeIndex = indexPath.row
//				handle(event: .move(index: indexPath, completion: .none))
//			}
//		}
//
//		func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//			if scrollView == thumbnails.collectionView {
//				handle(event: .beginScrolling)
//			}
//		}
//
//		func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//			if scrollView == thumbnails.collectionView && !decelerate {
//				thumbnailEndScrolling()
//			}
//		}
//
//		func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//			if scrollView == thumbnails.collectionView {
//				thumbnailEndScrolling()
//			}
//		}
//
//		func thumbnailEndScrolling() {
//			handle(event: .endScrolling)
//		}
//	}
//
//
//	// MARK: - event handling
//	extension ScrollSynchronizer {
//		enum Event {
//			case remove(index: IndexPath, dataSourceUpdate: () -> Void, completion: (() -> Void)?)
//			case move(index: IndexPath, completion: (() -> Void)?)
//			case beginScrolling
//			case endScrolling
//		}
//
//		func handle(event: Event) {
//			switch event {
//			case .remove(let index, let update, let completion):
//				delete(at: index, dataSourceUpdate: update, completion: completion)
//			case .move(let index, let completion):
//				move(to: index, completion: completion)
//			case .endScrolling:
//				endScrolling()
//			case .beginScrolling:
//				beginScrolling()
//			}
//		}
//	}
//
//	// MARK: - event handling impl
//	private extension ScrollSynchronizer {
//
//		func delete(
//			at indexPath: IndexPath,
//			dataSourceUpdate: @escaping () -> Void,
//			completion: (() -> Void)?) {
//
//			unbind()
//			interactionState = .disabled
//			DeleteAnimation(thumbnails: thumbnails, preview: preview, index: indexPath).run {
//				let previousCount = self.thumbnails.itemsCount
//				if previousCount == indexPath.row + 1 {
//					self.activeIndex = previousCount - 1
//				}
//				dataSourceUpdate()
//				self.thumbnails.collectionView?.deleteItems(at: [indexPath])
//				self.preview.collectionView?.deleteItems(at: [indexPath])
//				print("removed \(indexPath)")
//				self.bind()
//				self.interactionState = .enabled
//				completion?()
//			}
//		}
//
//		func move(to indexPath: IndexPath, completion: (() -> Void)?) {
//
//			unbind()
//			interactionState = .disabled
//			MoveAnimation(thumbnails: thumbnails, preview: preview, index: indexPath).run {
//				self.interactionState = .enabled
//				self.bind()
//			}
//		}
//
//		func beginScrolling() {
//			interactionState = .disabled
//			ScrollAnimation(thumbnails: thumbnails, preview: preview, type: .beign).run {
//
//			}
//		}
//
//		func endScrolling() {
//			ScrollAnimation(thumbnails: thumbnails, preview: preview, type: .end).run {
//				self.interactionState = .enabled
//			}
//		}
//	}
//
//	// MARK: - layout changes
//	extension ScrollSynchronizer: LayoutChangeHandler {
//		var layoutState: LayoutState {
//			get {
//				layoutStateInternal
//			}
//			set(value) {
//				switch value {
//				case .ready:
//					bind()
//				case .configuring:
//					unbind()
//				}
//				layoutStateInternal = value
//			}
//		}
//
//		var needsUpdateOffset: Bool {
//			layoutState == .configuring
//		}
//
//		var targetIndex: Int {
//			activeIndex
//		}
//	}
//
//	// MARK: - private
//	extension ScrollSynchronizer {
//		private func bind() {
//			preview.collectionView?.delegate = self
//			thumbnails.collectionView?.delegate = self
//		}
//
//		private func unbind() {
//			preview.collectionView?.delegate = .none
//			thumbnails.collectionView?.delegate = .none
//		}
//	}
//
//
//
//class PhotosView: UIView & SnapView {
//
//	let previewCollection: UICollectionView
//	let thumbnailCollection: UICollectionView
//	let synchronizer: ScrollSynchronizer
//
//	let debugCenterLine: UIView
//
//	init(sizeForIndex: ((Int) -> CGSize)?) {
//		let previewLayout = PreviewLayout()
//		let thumbnailLayout = ThumbnailLayout(dataSource: sizeForIndex)
//		previewCollection = UICollectionView(frame: .zero, collectionViewLayout: previewLayout)
//		thumbnailCollection = UICollectionView(frame: .zero, collectionViewLayout: thumbnailLayout)
//		thumbnailCollection.decelerationRate = .fast
//		synchronizer = ScrollSynchronizer(
//			preview: previewLayout,
//			thumbnails: thumbnailLayout)
//		debugCenterLine = UIView()
//		super.init(frame: .zero)
//		setupUI()
//		createConstraints()
//	}
//
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//
//	func setupUI() {
//		addSubview(previewCollection)
//		addSubview(thumbnailCollection)
//		addSubview(debugCenterLine)
//
//		let backgroundColor = UIColor(named: "SinglePhotoBackground")
//
//		debugCenterLine.backgroundColor = .red
//
//		previewCollection.isPagingEnabled = true
//		previewCollection.showsVerticalScrollIndicator = false
//		previewCollection.showsHorizontalScrollIndicator = false
//		previewCollection.backgroundColor = backgroundColor
//
//		thumbnailCollection.showsVerticalScrollIndicator = false
//		thumbnailCollection.showsHorizontalScrollIndicator = false
//		thumbnailCollection.backgroundColor = backgroundColor
//	}
//
//	func createConstraints() {
//		debugCenterLine.snp.makeConstraints {
//			$0.width.equalTo(1)
//			$0.height.equalToSuperview()
//			$0.centerX.equalToSuperview()
//			$0.centerY.equalToSuperview()
//		}
//		thumbnailCollection.snp.makeConstraints {
//			$0.bottom.equalTo(safeAreaLayoutGuide.snp.bottomMargin)
//			$0.leading.equalToSuperview()
//			$0.trailing.equalToSuperview()
//			$0.height.equalTo(66)
//		}
//		previewCollection.snp.makeConstraints {
//			$0.top.equalToSuperview()
//			$0.leading.equalToSuperview()
//			$0.trailing.equalToSuperview()
//			$0.bottom.equalTo(thumbnailCollection.snp.top)
//		}
//	}
//
//	var indexInFocus: Int {
//		return synchronizer.activeIndex
//	}
//}
//
//class PhotosViewController: UIViewController {
//	var dataSource: PhotosDataSource?
//
//	var contentView: PhotosView {
//		return (view as? PhotosView).require()
//	}
//	
//	
//	public var assetCollection: [PHAsset] = []
//	public var assetGroups: [PhassetGroup] = []
//	public var mediaType: PhotoMediaType = .none
//	public var contentType: MediaContentType = .none
//	public var collectionType: CollectionType = .none
//
//	override func loadView() {
//		
//		view = PhotosView(sizeForIndex: {
//			if let images = self.dataSource?.assetCollection {
//				return images.count > $0 ? images[$0].thumbnail!.size : CGSize(width: 1, height: 1)
//
//			}
//			return CGSize(width: 1, height: 1)
//			
//		})
//		
//		dataSource = PhotosDataSource(preview: contentView.previewCollection, thumbnails: contentView.thumbnailCollection, assetCollection: self.assetCollection, assetGroups: self.assetGroups, collectionType: self.collectionType)
//		
//
//		toolbarItems = [
//			UIBarButtonItem(barButtonSystemItem: .action, target: .none, action: .none),
//			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: .none, action: .none),
//			UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAdd(sender:))),
//			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: .none, action: .none),
//			UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(onDelete(sender:)))
//		]
//	}
//
//	override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//		contentView.synchronizer.layoutState = .ready
//	}
//
//	override func viewDidDisappear(_ animated: Bool) {
//		super.viewDidDisappear(animated)
//		contentView.synchronizer.layoutState = .configuring
//	}
//
//	@objc func onDelete(sender: UIBarButtonItem) {
////		guard contentView.synchronizer.interactionState == .enabled else { return }
////		guard let count = dataSource?.images.count, count > 2 else {
////			let alert = UIAlertController(
////				title: "Sorry",
////				message: "This sample does not handle corner cases, however, as one or zero cells",
////				preferredStyle: .alert)
////			alert.addAction(UIAlertAction(title: "OK", style: .cancel))
////			present(alert, animated: true)
////			return
////		}
////		let index = contentView.indexInFocus
////		let event: ScrollSynchronizer.Event = .remove(
////			index: IndexPath(item: index, section: 0),
////			dataSourceUpdate: { self.dataSource?.images.remove(at: index) },
////			completion: nil)
////		contentView.synchronizer.handle(event: event)
//	}
//
//	@objc func onAdd(sender: UIBarButtonItem) {
////		if let dataSource = dataSource {
////			dataSource.images.append(dataSource.randomImage())
////			contentView.synchronizer.reload()
////		}
//	}
//}
//
//// MARK: orientation changes
//extension PhotosViewController {
//	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//		contentView.synchronizer.layoutState = .configuring
//		super.viewWillTransition(to: size, with: coordinator)
//		coordinator.animate(alongsideTransition: nil) { [weak self] _ in
//			self?.contentView.synchronizer.layoutState = .ready
//		}
//	}
//}
//
//
//
//class PhotosDataSource: NSObject {
//	
//	private var photoManager = PhotoManager.shared
//	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
//	
//	public var focusedIndexPath: IndexPath?
//	
//	public var assetCollection: [PHAsset]
//	public var assetGroups: [PhassetGroup]
//	public var mediaType: PhotoMediaType = .none
//	public var contentType: MediaContentType = .none
//	public var collectionType: CollectionType
//	
//
////	lazy var images = loadImages()
//
//	let preview: UICollectionView
//	let thumbnails: UICollectionView
//
//	init(preview: UICollectionView, thumbnails: UICollectionView, assetCollection: [PHAsset], assetGroups: [PhassetGroup], collectionType: CollectionType) {
//		self.preview = preview
//		self.thumbnails = thumbnails
//		self.assetCollection = assetCollection
//		self.assetGroups = assetGroups
//		self.collectionType = collectionType
//
//		super.init()
//		
//		preview.prefetchDataSource = self
//		thumbnails.prefetchDataSource = self
//		preview.dataSource = self
//		preview.register(
//			PreviewCollectionViewCell.self,
//			forCellWithReuseIdentifier: PreviewCollectionViewCell.reuseId)
//
//		thumbnails.dataSource = self
//		thumbnails.register(
//			ThumbnailCollectionViewCell.self,
//			forCellWithReuseIdentifier: ThumbnailCollectionViewCell.reuseId)
//	}
//
//	var urls: [URL] {
//		Bundle.main.urls(
//			forResourcesWithExtension: .none,
//			subdirectory: "Data").require(hint: "No test data found.")
//	}
//
//	func loadImages() -> [UIImage] {
//		return urls
//			.compactMap { try? Data(contentsOf: $0) }
//			.compactMap(UIImage.init(data:))
//	}
//
//	func randomImage() -> UIImage {
//		return Set(loadImages()).randomElement().require(hint: "No test data found.")
//	}
//}
//
//extension PhotosDataSource: UICollectionViewDataSource {
//	
//	func numberOfSections(in collectionView: UICollectionView) -> Int {
//		switch collectionType {
//			case .grouped:
//				return assetGroups.count
//			case .single:
//				return 1
//			case .none:
//				return 1
//		}
//	}
//	
//	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////		return images.count
//		switch collectionType {
//			case .grouped:
//				return assetGroups[section].assets.count
//			case .single:
//				return assetCollection.count
//			case .none:
//				return 0
//		}
//	}
//
//	func collectionView(_ collectionView: UICollectionView,
//						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		
//		
//		var asset: PHAsset {
//			switch collectionType {
//				case .grouped:
//					return assetGroups[indexPath.section].assets[indexPath.row]
//				case .single:
//					return assetCollection[indexPath.row]
//				case .none:
//					return assetCollection[indexPath.row]
//			}
//		}
//		
//
//		var reuseId: String?
//		if collectionView == preview {
//			reuseId = PreviewCollectionViewCell.reuseId
//		}
//		if collectionView == thumbnails {
//			reuseId = ThumbnailCollectionViewCell.reuseId
//		}
//		let cell = reuseId.flatMap {
//			collectionView.dequeueReusableCell(
//				withReuseIdentifier: $0,
//				for: indexPath) as? ImageCell
//		}
//		
//		let options = PhotoManager.shared.requestOptions
//		
//		
//		self.prefetchCacheImageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options, resultHandler: { image, info in
//			if let loadedImage = image {
////				self.photoThumbnailImageView.image = loadedImage
//
//				debugPrint("prefetch image")
//				cell?.imageView.image = loadedImage
//		
//			}
//		})
//	
//	
//		return cell.require(hint: "Unexpected cell type.")
//	}
//
//}
//
//extension PhotosDataSource: UICollectionViewDataSourcePrefetching {
//	
//	
//	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//		let phassets = requestPhassets(for: indexPaths)
//		let thumbnailSize = CGSize(width: 300, height: 300)
//		let options = PHImageRequestOptions()
//		options.isNetworkAccessAllowed = true
//		prefetchCacheImageManager.startCachingImages(for: phassets, targetSize: thumbnailSize, contentMode: .aspectFit, options: options)
//		
//	}
//	
//	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//		
//		
//		let phassets = requestPhassets(for: indexPaths)
////		let thumbnailSize = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPaths.first!)!.size.toPixel()
//		let thumbnailSize = CGSize(width: 300, height: 300)
//		let options = PHImageRequestOptions()
//		options.isNetworkAccessAllowed = true
//		prefetchCacheImageManager.stopCachingImages(for: phassets, targetSize: thumbnailSize, contentMode: .aspectFit, options: options)
//	}
//	
//	
//	private func requestPhassets(for indexPaths: [IndexPath]) -> [PHAsset] {
//		switch collectionType {
//			case .grouped:
//				return indexPaths.compactMap({ self.assetGroups[$0.section].assets[$0.item]})
//			default:
//				return indexPaths.compactMap({ self.assetCollection[$0.row]})
//		}
//	}
//	
//}
