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
	public var isDeepCleaningSelectableFlow: Bool = false
	public var focusedIndexPath: IndexPath?
	public var previuousSelectedIndexPaths: [IndexPath]?
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
		
		handleFocusAndSelect()
	}
}

extension MediaViewController {
	
	private func handleFocusAndSelect() {
		
		if let indexPath = focusedIndexPath {
			self.startedScroll(indexPath: indexPath)
		}
		
		if let selectedIndexPaths = self.previuousSelectedIndexPaths {
			self.handleSelectedItems(previouslySelectedIndexPaths: selectedIndexPaths)
		}
	}
}

//		MARK: - select delegate -
extension MediaViewController: PhotoCollectionViewCellDelegate {
	
	func didShowFullScreenPHAsset(at indexPath: IndexPath) {}
	
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
		
		guard !previouslySelectedIndexPaths.isEmpty else { return }
		
		for previouslySelectedIndexPath in previouslySelectedIndexPaths {
			self.collectionView.selectItem(at: previouslySelectedIndexPath, animated: false, scrollPosition: [])
			self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: previouslySelectedIndexPath)
			if let cell = self.collectionView.cellForItem(at: previouslySelectedIndexPath) as? PhotoCollectionViewCell {
				cell.checkIsSelected()
			}
		}
	}
	
	private func didTapBackActionButtonWithSelectablePhaassets() {
		
		guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems else { return }
		
		switch self.collectionType {
			case .grouped:
				self.groupSelectionDelegate?.didSelect(slectedIndexPath: selectedIndexPath, phassetsGroups: self.assetGroups)
			case .single:
				self.singleSelectionDelegate?.didSelect(selectedIndexPath: selectedIndexPath, phasstsColledtion: self.assetCollection)
			default:
				return
		}
		self.navigationController?.popViewController(animated: true)
	}
}

extension MediaViewController {
	
	private func startedScroll(indexPath: IndexPath) {
		U.UI {
			self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: false)
			self.previewCollectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: false)
		}
	}
	
	private func createContextualMenu(for phasset: PHAsset, at indexPath: IndexPath) -> UIMenu {
		
		let setAsBestActionImage = I.systemItems.defaultItems.star.withTintColor(theme.titleTextColor).withRenderingMode(.alwaysTemplate)
		let deleteActionImage =    I.systemItems.defaultItems.trashBin.withTintColor(theme.actionTintColor).withRenderingMode(.alwaysTemplate)
		
		let setAsBestAction = UIAction(title: "set as best", image: setAsBestActionImage) { _ in
			self.setAsBest(phasset: phasset, at: indexPath)
		}
		
		let deletePHAssetAction = UIAction(title: "delete", image: deleteActionImage, attributes: .destructive) { _ in
			self.showConfirmDeletePHAsset(at: indexPath)
		}
		
		let deleteMenuCollection = UIMenu(title: "", children: [deletePHAssetAction])
		let setAsBestMenuCollection = UIMenu(title: "", children: [setAsBestAction])
		let deleteAndSetAsBestCollection = UIMenu(title: "", children: [setAsBestAction, deletePHAssetAction])
		
		switch collectionType {
			case .grouped:
				if !isDeepCleaningSelectableFlow {
					if indexPath.row == 0 {
						return deleteMenuCollection
					} else {
						return deleteAndSetAsBestCollection
					}
				} else {
					if indexPath.row != 0 {
						return setAsBestMenuCollection
					}
				}
			case .single:
				if !isDeepCleaningSelectableFlow {
					return deleteMenuCollection
				}
			case .none:
				return UIMenu()
		}
		return UIMenu()
	}
}

extension MediaViewController {
	
	private func setAsBest(phasset: PHAsset, at indexPath: IndexPath) {
		
		self.assetGroups[indexPath.section].assets.move(at: indexPath.row, to: 0)
		let zeroUpdatableIndexPath = IndexPath(row: 0, section: indexPath.section)
		
		self.collectionView.performBatchUpdates {
			self.collectionView.moveItem(at: indexPath, to: zeroUpdatableIndexPath)
			self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
		} completion: { _ in }
		self.previewCollectionView.performBatchUpdates {
			self.previewCollectionView.moveItem(at: indexPath, to: zeroUpdatableIndexPath)
		} completion: { _ in }
	}
}

extension MediaViewController {
	
	private func showConfirmDeletePHAsset(at indexPath: IndexPath) {
		
		A.deletePHAssets(of: self.contentType, of: .one) {
			self.deletePHAsset(at: indexPath)
		}
	}
	
	private func deletePHAsset(at indexPath: IndexPath) {
		
		var selectedPHAsset: PHAsset {
			switch collectionType {
				case .grouped:
					return self.assetGroups[indexPath.section].assets[indexPath.row]
				case .single:
					return self.assetCollection[indexPath.row]
				default:
					return PHAsset()
			}
		}
			
		let deletePHAssetOperation = self.photoManager.deleteSelectedOperation(assets: [selectedPHAsset], completion: { deleted in
			if deleted {
				U.UI {
					self.updateCollection(with: selectedPHAsset, at: indexPath)
				}
			} else {
				ErrorHandler.shared.showDeleteAlertError(selectedPHAsset.mediaType == .video ? .errorDeleteVideo : .errorDeletePhoto)
			}
		})
		self.photoManager.serviceUtilsCalculatedOperationsQueuer.addOperation(deletePHAssetOperation)
	}
	
	private func updateCollection(with removablePHAsset: PHAsset, at indexPath: IndexPath) {
	
		switch collectionType {
			case .single:
				self.assetCollection.remove(at: indexPath.row)
				self.collectionView.performBatchUpdates {
					self.collectionView.deleteItems(at: [indexPath])
				} completion: { _ in }
				self.previewCollectionView.performBatchUpdates {
					self.previewCollectionView.deleteItems(at: [indexPath])
				} completion: { _ in
					self.checkForEmptyCollection()
				}
			case .grouped:
				if self.assetGroups[indexPath.section].assets.count == 2 {
					self.assetGroups.remove(at: indexPath.section)
					self.collectionView.performBatchUpdates {
						self.collectionView.deleteSections(IndexSet(integer: indexPath.section))
					} completion: { _ in }
					self.previewCollectionView.performBatchUpdates {
						self.previewCollectionView.deleteSections(IndexSet(integer: indexPath.section))
					} completion: { _ in
						self.checkForEmptyCollection()
					}
				} else {
					self.assetGroups[indexPath.section].assets.remove(at: indexPath.item)
					self.collectionView.performBatchUpdates {
						self.collectionView.deleteItems(at: [indexPath])
					} completion: { _ in }
					self.previewCollectionView.performBatchUpdates {
						self.previewCollectionView.deleteItems(at: [indexPath])
					} completion: { _ in
						self.checkForEmptyCollection()
					}
				}
			default:
				return
		}
	}
	
	private func checkForEmptyCollection() {
		
		switch collectionType {
			case .single:
				if self.assetCollection.isEmpty {
					singleSelectionDelegate?.didSelect(selectedIndexPath: [], phasstsColledtion: [])
					self.navigationController?.popViewController(animated: true)
				}
			case .grouped:
				if self.assetGroups.isEmpty {
					groupSelectionDelegate?.didSelect(slectedIndexPath: [], phassetsGroups: [])
					self.navigationController?.popViewController(animated: true)
				}
			case .none:
				return
		}
	}
}

//		MARK: - collection view setup - and configure -
extension MediaViewController  {
	
	private func setupCollectionView() {
		
		self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell,
										   bundle: nil),
									 forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
	
		self.previewCollectionView.register(UINib(nibName: C.identifiers.xibs.photoPreviewCell, bundle: nil),
											forCellWithReuseIdentifier: C.identifiers.cells.photoPreviewCell)
		
		self.previewCollectionView.dataSource = self
		self.previewCollectionView.delegate = self
		self.previewCollectionView.prefetchDataSource = self
		self.previewCollectionView.showsVerticalScrollIndicator = false
		self.previewCollectionView.showsHorizontalScrollIndicator = false
		self.previewCollectionView.contentInset = .zero
		
		self.previewColletionFlowLayput.itemSize = CGSize(width: U.screenWidth, height: self.previewCollectionView.frame.height - 100)
		self.previewColletionFlowLayput.scrollDirection = .horizontal
		self.previewColletionFlowLayput.minimumInteritemSpacing = 40
		self.previewColletionFlowLayput.minimumLineSpacing = 150
		self.previewColletionFlowLayput.headerReferenceSize = .zero
		
		self.previewCollectionView.collectionViewLayout = previewColletionFlowLayput

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
	
	private func configurePreview(_ cell: PhotoPreviewCollectionViewCell, at indexPath: IndexPath) {
		
		var asset: PHAsset {
			switch collectionType {
				case .grouped:
					return assetGroups[indexPath.section].assets[indexPath.row]
				case .single:
					return assetCollection[indexPath.row]
				default:
					return PHAsset()
			}
		}
		cell.indexPath = indexPath
		cell.tag = indexPath.section * 1000 + indexPath.row
		cell.cellMediaType = self.mediaType
		cell.configureLayout(with: self.contentType)
		let previewSize = self.previewCollectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)!.size.toPixel()
		cell.configurePreview(from: asset, imageManager: self.prefetchCacheImageManager, size: previewSize, of: self.contentType)
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
		
		if collectionView == self.collectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.photoSimpleCell, for: indexPath) as! PhotoCollectionViewCell
			configure(cell, at: indexPath)
			return cell
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.photoPreviewCell, for: indexPath) as! PhotoPreviewCollectionViewCell
			configurePreview(cell, at: indexPath)
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionat section: Int) -> CGFloat {
		if collectionView == self.previewCollectionView {
			return 0
		} else {
			return 20
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
	
		guard collectionView == self.collectionView else { return nil }
				
		if isDeepCleaningSelectableFlow {
			switch collectionType {
				case .single:
					return nil
				case .grouped:
					if indexPath.row == 0 {
						return nil
					}
				case .none:
					return nil
			}
		}
		
		let phasset = collectionType == .single ? self.assetCollection[indexPath.row] : self.assetGroups[indexPath.section].assets[indexPath.row]
		let identifier = IndexPath(item: indexPath.item, section: indexPath.section) as NSCopying
		
		switch phasset.mediaType {
			case .video:
				return UIContextMenuConfiguration(identifier: identifier) {
					return nil
				} actionProvider: { _ in
					self.createContextualMenu(for: phasset, at: indexPath)
				}
			case .image:
				return UIContextMenuConfiguration(identifier: identifier) {
					return nil
				} actionProvider: { _ in
					self.createContextualMenu(for: phasset, at: indexPath)
				}
			default:
				return nil
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		
		guard let indexPath = configuration.identifier as? IndexPath, let cell = self.collectionView.cellForItem(at: indexPath) else { return nil}
		
		let targetPreview = UITargetedPreview(view: cell)
		targetPreview.parameters.backgroundColor = theme.backgroundColor
		targetPreview.view.backgroundColor = theme.backgroundColor
		return targetPreview
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

//		MARK: - handle track carousel -
extension MediaViewController {
	
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
	
	private func handleDecelerateScrollCollection(at indexPath: IndexPath) {
		collectionView.reloadSelectedItems(at: [indexPath])
		if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell{
			cell.checkIsSelected()
		}
	}
}

//		MARK: - scroll view carousel delegate -
extension MediaViewController: UIScrollViewDelegate {

	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//		if let indexPath = visibleCellIndex, !decelerate {
//			handleDecelerateScrollCollection(at: indexPath)
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

	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

	}

	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		shouldTrackScrolling = true
	}

	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//		if let indexPath = visibleCellIndex {
//			handleDecelerateScrollCollection(at: indexPath)
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
