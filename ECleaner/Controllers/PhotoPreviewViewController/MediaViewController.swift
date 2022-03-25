//
//  MediaViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.01.2022.
//

import UIKit
import Photos

enum CollectionType {
	case grouped
	case single
	case none
}

class MediaViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var previewCollectionView: UICollectionView!
	
	private let carouselCollectionFlowLayout = CarouselFlowLayout()
	private let previewColletionFlowLayput = PreviewCarouselFlowLayout()
	
	weak var singleSelectionDelegate: SimpleSelectableAssetsDelegate?
	weak var groupSelectionDelegate: GroupSelectableAssetsDelegate?
	
		/// `transition`
	private lazy var transitionController = ZoomTransitionController()
	private var currentImage = UIImageView()

	var scrollView = UIScrollView()
	private var shouldTrackScrolling = true
	
	private var visibleCell: PhotoCollectionViewCell? {
		return previewCollectionView.visibleCells.first as? PhotoCollectionViewCell
	}
	private var visibleCellIndex: IndexPath? {
		guard let visibleCell = visibleCell else {
			return nil
		}
		return previewCollectionView.indexPath(for: visibleCell)
	}
	public var focusedIndexPath: IndexPath?
	
	private var previousPreheatRect: CGRect = CGRect()
	
	private var photoManager = PhotoManager.shared
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
	
	public var collectionType: CollectionType = .none
	public var assetCollection: [PHAsset] = []
	public var assetGroups: [PhassetGroup] = []
	public var mediaType: PhotoMediaType = .none
	public var contentType: MediaContentType = .none
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupUI()
		setupCollectionView()
		updateColors()
		setupNavigationBar()
		setupDelegate()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let indexPath = focusedIndexPath {
			self.startedScroll(indexPath: indexPath)
		}
	}
}

//		MARK: - previously select phassets and handle select
extension MediaViewController {
	
	private func getSelectedPhassetsIDs(_ completionHandler: @escaping (_ ids: [String]) -> Void) {
		
		guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems else {
			completionHandler([])
			return
		}
		
		var selectedPHAssetsIDs: [String] = []
		let dispatchGroup = DispatchGroup()
		let dispatchQueue = DispatchQueue(label: C.key.dispatch.selectedPhassetsQueue)
		let dispatchSemaphore = DispatchSemaphore(value: 0)
		
		for indexPath in selectedIndexPath {
			dispatchGroup.enter()
			
			switch collectionType {
				case .single:
					let phassetInCollection = self.assetCollection[indexPath.row]
					selectedPHAssetsIDs.append(phassetInCollection.localIdentifier)
				case .grouped:
					let phassetInCollection = self.assetGroups[indexPath.section].assets[indexPath.row]
					selectedPHAssetsIDs.append(phassetInCollection.localIdentifier)
				default:
					return
			}
			
			dispatchSemaphore.signal()
			dispatchGroup.leave()
		}
		
		dispatchGroup.notify(queue: dispatchQueue) {
			U.UI {
				completionHandler(selectedPHAssetsIDs)				
			}
		}
	}
	
	public func handlePreviouslySelectedPHAssets(from previouslySelectedIDS: [String], assetsCollection: [PHAsset]) {
		
		var previouslySelectedIndexPaths: [IndexPath] = []
		let dispatchGroup = DispatchGroup()
		let dispatchQueue = DispatchQueue(label: C.key.dispatch.selectedPhassetsQueue)
		let dispatchSemaphore = DispatchSemaphore(value: 0)
		
		for selectedPHAssetID in previouslySelectedIDS {
			dispatchGroup.enter()
			let indexPath = assetsCollection.firstIndex(where: {
				$0.localIdentifier == selectedPHAssetID
			}).flatMap({
				IndexPath(row: $0, section: 0)
			})
			
			if let existingIndexPath = indexPath {
				previouslySelectedIndexPaths.append(existingIndexPath)
			}
			dispatchSemaphore.signal()
			dispatchGroup.leave()
		}
		
		dispatchGroup.notify(queue: dispatchQueue) {
			U.UI {
				self.handleSelectedItems(previouslySelectedIndexPaths: previouslySelectedIndexPaths)
			}
		}
	}

	public func handlePReviouslySelectedPhassetsGroup(from previouslySelectedIDS: [String], assetsCollectionGroups: [PhassetGroup]) {
		var previouslySelectedIndexPaths: [IndexPath] = []
		let dispatchGroup = DispatchGroup()
		let dispatchQueue = DispatchQueue(label: C.key.dispatch.selectedPhassetsQueue)
		let dispatchSemaphore = DispatchSemaphore(value: 0)
	
		for seletedPHAssetID in previouslySelectedIDS {
			dispatchGroup.enter()
			
			let sectionIndex = assetsCollectionGroups.firstIndex(where: {
				$0.assets.contains(where: {$0.localIdentifier == seletedPHAssetID})
			}).flatMap({
				$0
			})
			
			if let section = sectionIndex {
				let index = Int(section)
				let indexPath = assetsCollectionGroups[index].assets.firstIndex(where: {
					$0.localIdentifier == seletedPHAssetID
				}).flatMap({
					IndexPath(row: $0, section: index)
				})
				
				if let existingIndexPath = indexPath {
					previouslySelectedIndexPaths.append(existingIndexPath)
				}
			}
			
			dispatchSemaphore.signal()
			dispatchGroup.leave()
		}
		
		dispatchGroup.notify(queue: dispatchQueue) {
			self.handleSelectedItems(previouslySelectedIndexPaths: previouslySelectedIndexPaths)
		}
	}
}

//		MARK: - select delegate -
extension MediaViewController: PhotoCollectionViewCellDelegate {
	
	func didSelectCell(at indexPath: IndexPath) {
		if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
			if cell.isSelected {
				self.collectionView.deselectItem(at: indexPath, animated: true)
				self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: indexPath)
			} else {
				self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
				self.collectionView.delegate?.collectionView?(self.collectionView, didDeselectItemAt: indexPath)
			}
			cell.checkIsSelected()
		}
	}
}

extension MediaViewController {
	
	private func handleSelectedItems(previouslySelectedIndexPaths: [IndexPath]) {
		
		for previouslySelectedIndexPath in previouslySelectedIndexPaths {
			self.collectionView.selectItem(at: previouslySelectedIndexPath, animated: false, scrollPosition: [])
			self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: previouslySelectedIndexPath)
			
			if let cell = self.collectionView.cellForItem(at: previouslySelectedIndexPath) as? PhotoCollectionViewCell {
				U.delay(1) {
					cell.checkIsSelected()
					
				}
			}
		}
	}
	
	private func didTapBackActionButtonWithSelectablePhaassets() {
		
		self.getSelectedPhassetsIDs { ids in
			switch self.collectionType {
				case .grouped:
					self.groupSelectionDelegate?.didSelect(assetListsIDs: ids)
				case .single:
					self.singleSelectionDelegate?.didSelect(assetListsIDs: ids)
				default:
					return
			}
			self.navigationController?.popViewController(animated: true)
		}
	}
}

extension MediaViewController {
	
	private func startedScroll(indexPath: IndexPath) {
		U.UI {
			self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: false)
			self.previewCollectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: false)
		}
	}
}

//		MARK: - collection view setup - and configure -
extension MediaViewController  {
	
	private func setupCollectionView() {
		
		self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell,
										   bundle: nil),
									 forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
		
		self.previewCollectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell,
										   bundle: nil),
									 forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
		
		self.previewCollectionView.dataSource = self
		self.previewCollectionView.delegate = self
		self.previewCollectionView.prefetchDataSource = self
		self.previewCollectionView.showsVerticalScrollIndicator = false
		self.previewCollectionView.showsHorizontalScrollIndicator = false
		self.previewCollectionView.contentInset = .zero
		

		self.previewColletionFlowLayput.itemSize = CGSize(width: U.screenWidth - 20, height: U.screenHeight / 2)
		self.previewColletionFlowLayput.scrollDirection = .horizontal
		self.previewColletionFlowLayput.minimumInteritemSpacing = 20
		self.previewColletionFlowLayput.minimumLineSpacing = 150
		self.previewColletionFlowLayput.headerReferenceSize = .zero
		
		previewCollectionView.collectionViewLayout = previewColletionFlowLayput

		self.collectionView.dataSource = self
		self.collectionView.delegate = self
		self.collectionView.prefetchDataSource = self
		self.collectionView.showsVerticalScrollIndicator = false
		self.collectionView.showsHorizontalScrollIndicator = false
		self.collectionView.contentInset = .zero
		
		self.carouselCollectionFlowLayout.itemSize = CGSize(width: 100, height: 100)
		self.carouselCollectionFlowLayout.scrollDirection = .horizontal
		self.carouselCollectionFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		self.carouselCollectionFlowLayout.minimumInteritemSpacing = 10
		self.carouselCollectionFlowLayout.minimumLineSpacing = 10
		self.carouselCollectionFlowLayout.headerReferenceSize = .zero
		self.collectionView.collectionViewLayout = carouselCollectionFlowLayout
		self.collectionView.allowsMultipleSelection = true
		self.collectionView.reloadData()
	}
	
	private func configure(_ cell: PhotoCollectionViewCell, at indexPath: IndexPath) {

		var asset: PHAsset {
			switch collectionType {
				case .grouped:
					return assetGroups[indexPath.section].assets[indexPath.row]
				case .single:
					return assetCollection[indexPath.row]
				case .none:
					return assetCollection[indexPath.row]
			}
		}
		
		cell.delegate = self
		cell.indexPath = indexPath
		cell.tag = indexPath.section * 1000 + indexPath.row
		cell.cellMediaType = self.mediaType
		cell.cellContentType = self.contentType
		let thumbnailSize = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)!.size.toPixel()
		cell.loadCellThumbnail(asset, imageManager: self.prefetchCacheImageManager, size: thumbnailSize)
		cell.setupUI()
		cell.updateColors()
		cell.selectButtonSetup(by: self.mediaType)
		self.currentImage = cell.photoThumbnailImageView
		
		if let path = self.collectionView.indexPathsForSelectedItems, path.contains(indexPath) {
			cell.isSelected = true
		} else {
			cell.isSelected = false
		}
		
		cell.checkIsSelected()
	}
}

//		MARK: - collection view delegate -
extension MediaViewController: UICollectionViewDelegate, UICollectionViewDataSource {

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		switch collectionType {
			case .grouped:
				return assetGroups.count
			default:
				return 1
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch collectionType {
			case .grouped:
				return assetGroups[section].assets.count
			case .single:
				return assetCollection.count
			case .none:
				return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.photoSimpleCell, for: indexPath) as! PhotoCollectionViewCell
		configure(cell, at: indexPath)
		return cell
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionat section: Int) -> CGFloat {
		if collectionView == self.previewCollectionView {
			return 0
		} else {
			return 20
		}
	}
}

//		MARK: - prefetch collection view -
extension MediaViewController: UICollectionViewDataSourcePrefetching {
	
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		let phassets = requestPhassets(for: indexPaths)
		let thumbnailSize = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPaths.first!)!.size.toPixel()
		let options = PHImageRequestOptions()
		options.isNetworkAccessAllowed = true
		prefetchCacheImageManager.startCachingImages(for: phassets, targetSize: thumbnailSize, contentMode: .aspectFit, options: options)
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		let phassets = requestPhassets(for: indexPaths)
		let thumbnailSize = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPaths.first!)!.size.toPixel()
		let options = PHImageRequestOptions()
		options.isNetworkAccessAllowed = true
		prefetchCacheImageManager.stopCachingImages(for: phassets, targetSize: thumbnailSize, contentMode: .aspectFit, options: options)
	}
	
	private func requestPhassets(for indexPaths: [IndexPath]) -> [PHAsset] {
		switch collectionType {
			case .grouped:
				return indexPaths.compactMap({ self.assetGroups[$0.section].assets[$0.item]})
			default:
				return indexPaths.compactMap({ self.assetCollection[$0.row]})
		}
	}
}

//		MARK: - navigation delegate -
extension MediaViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		self.didTapBackActionButtonWithSelectablePhaassets()
	}
	
	func didTapRightBarButton(_ sender: UIButton) {}
}

//		MARK: - scroll view carousel delegate -
extension MediaViewController: UIScrollViewDelegate {

	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//		if let indexPath = visibleCellIndex, !decelerate {
//			collectionView.reloadSelectedItems(at: [indexPath])
//			if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell{
//				cell.checkIsSelected()
//			}
//		}
	}

	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

	}

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView === previewCollectionView {
			handleTrackCollection(from: previewCollectionView, to: collectionView)
		}

		if scrollView === collectionView {
			handleTrackCollection(from: collectionView, to: previewCollectionView)
		}
	}
	
	private func handleTrackCollection(from: UICollectionView, to: UICollectionView) {
		let centerPoint = CGPoint(x: from.contentOffset.x + (from.frame.width / 2), y: from.frame.height / 2)
		
		if shouldTrackScrolling {
			if let indexPath = from.indexPathForItem(at: centerPoint) {
				shouldTrackScrolling = false
				UIView.animate(withDuration: 0.0) {
					U.UI {
						to.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
					}
				} completion: { finished in
					self.shouldTrackScrolling = finished
				}
			}
		}
	}

	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

	}

	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		shouldTrackScrolling = true
	}

	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

//		if let indexPath = visibleCellIndex {
//			collectionView.reloadSelectedItems(at: [indexPath])
//			if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
//				cell.checkIsSelected()
//			}
//		}
	}
}

//		MARK: - setup ui -
extension MediaViewController {
	
	private func setupUI() {}
	
	private func setupNavigationBar() {
		
		navigationBar.setupNavigation(title: mediaType.mediaTypeName,
									  leftBarButtonImage: I.systemItems.navigationBarItems.back,
									  rightBarButtonImage: nil,
									  contentType: contentType,
									  leftButtonTitle: nil,
									  rightButtonTitle: nil)
	}
	
	private func setupDelegate() {
		
		navigationBar.delegate = self
		scrollView.delegate = self
	}

	/// hide transition setup 
	public func setupTransitionConfiguration(from controller: UIViewController, referenceImageView: @escaping ReferenceImageView, referenceImageViewFrameInTransitioningView: @escaping ReferenceImageViewFrame) {
		
		controller.navigationController?.delegate = transitionController
		let destinationController = ZoomAnimatorRreferences(referenceImageView: { [weak self] () -> UIImageView in
			return self!.currentImage
		}) { [weak self] () -> CGRect in
			guard let self = self, let imageView = self.visibleCell?.photoThumbnailImageView else {
				return CGRect(x: 0, y: 0, width: 350, height: 350)
			}
			return self.collectionView.convert(imageView.frame, to: self.collectionView)
		}
		transitionController.to = destinationController
		
		let fromDestinationController = ZoomAnimatorRreferences(referenceImageView: referenceImageView, referenceImageViewFrameInTransitioningView: referenceImageViewFrameInTransitioningView)
		transitionController.to = destinationController
		transitionController.from = fromDestinationController
	}
}

extension MediaViewController: Themeble {
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
		self.collectionView.backgroundColor = theme.backgroundColor
		self.previewCollectionView.backgroundColor = theme.backgroundColor
	}
}


extension UICollectionView {
		
	func reloadSelectedItems(at indexPaths: [IndexPath]) {
		
		let selectedItems = indexPathsForSelectedItems
		reloadItems(at: indexPaths)
		if let selectedItems = selectedItems {
			for selectedItem in selectedItems {
				if indexPaths.contains(selectedItem) {
					selectItem(at: selectedItem, animated: false, scrollPosition: [])
				}
			}
		}
	}
}

