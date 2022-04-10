//
//  VideoCollectionCompressingViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 10.04.2022.
//

import UIKit
import Photos

class VideoCollectionCompressingViewController: UIViewController {

	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
	@IBOutlet weak var bottomMenuHeightConstraint: NSLayoutConstraint!
	
	var scrollView = UIScrollView()
	
	private let flowLayout = SimpleColumnFlowLayout(cellsPerRow: 2,
													minimumInterSpacing: 0,
													minimumLineSpacing: 0,
													inset: UIEdgeInsets(top: 10, left: 4, bottom: 0, right: 4))
	
	private var thumbnailSize: CGSize = .zero
	private var previousPreheatRect: CGRect = CGRect()
	private var bottomMenuHeight: CGFloat = 80
	
	
	
	private var photoManager = PhotoManager.shared
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
	public var mediaType: PhotoMediaType = .none
	public var contentType: MediaContentType = .none

	public var assetCollection: [PHAsset] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
		updateColors()
		setupNavigation()
		setupDelegate()
		setupCollectionView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateCachedAssets()
	}
}

extension VideoCollectionCompressingViewController {
	
	private func handleBottomButton() {
		
	}
	
	private func handleSelectPHAsset(at indexPath: IndexPath) {
		
		guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return }
		
		self.bottomMenuHeightConstraint.constant = selectedItems.count > 0 ? (bottomMenuHeight + U.bottomSafeAreaHeight - 5) : 0
		self.collectionView.contentInset.bottom = selectedItems.count > 0 ? 70 + U.bottomSafeAreaHeight : 5
		if let selectedItem = selectedItems.first {
			let phasset = self.assetCollection[selectedItem.row]
			
			let size = phasset.imageSize
			let stringSize = U.getSpaceFromInt(size)
			bottomButtonView.title("compress: \(stringSize)")
		}
		
		U.animate(0.5) {
			self.collectionView.layoutIfNeeded()
			self.view.layoutIfNeeded()
		}
	}
}

extension VideoCollectionCompressingViewController {
	
	private func setupCollectionView() {
		
		flowLayout.isSquare = true
		flowLayout.itemHieght = ((U.screenWidth - 30) / 3) / U.ratio
		
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
		
		self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
		
		self.collectionView.collectionViewLayout = flowLayout
		self.collectionView.allowsMultipleSelection = false
		self.collectionView.contentInset.top = 20
		self.collectionView.reloadData()
	}
	
	private func configure(cell: PhotoCollectionViewCell, at indexPath: IndexPath) {
		
		cell.selectButtonSetup(by: self.mediaType)
		cell.indexPath = indexPath
		cell.tag = indexPath.section * 1000 + indexPath.row
		cell.cellMediaType = self.mediaType
		cell.cellContentType = self.contentType
		
		let videoPHAsset = self.assetCollection[indexPath.row]
		
		if self.thumbnailSize.equalTo(CGSize.zero) {
			self.thumbnailSize = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)!.size.toPixel()
		}
		
		cell.loadCellThumbnail(videoPHAsset, imageManager: self.prefetchCacheImageManager, size: thumbnailSize)
		cell.setupUI()
		cell.updateColors()
	
		if let path = self.collectionView.indexPathsForSelectedItems, path.contains([indexPath]) {
			cell.isSelected = true
		} else {
			cell.isSelected = false
		}
		cell.checkIsSelected()
	}
	
	private func createCellContextMenu(for asset: PHAsset, at indexPath: IndexPath) -> UIMenu {
		return UIMenu()
	}
}

extension VideoCollectionCompressingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return assetCollection.count
	}
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.photoSimpleCell, for: indexPath) as! PhotoCollectionViewCell
		self.configure(cell: cell, at: indexPath)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		if let cell = collectionView.cellForItem(at: indexPath) {
			if cell.isSelected {
				self.collectionView.deselectItem(at: indexPath, animated: true)
				self.collectionView.delegate?.collectionView?(self.collectionView, didDeselectItemAt: indexPath)
				return false
			}
		}
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.handleSelectPHAsset(at: indexPath)
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		self.handleSelectPHAsset(at: indexPath)
	}
	
	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let asset = self.assetCollection[indexPath.row]
		let identifier = IndexPath(item: indexPath.item, section: indexPath.section) as NSCopying
		
		return UIContextMenuConfiguration(identifier: identifier) {
			return PreviewAVController(asset: asset)
		} actionProvider: { _ in
			return self.createCellContextMenu(for: asset, at: indexPath)
		}
	}

	func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		
		guard let indexPath = configuration.identifier as? IndexPath,  let cell = collectionView.cellForItem(at: indexPath) else { return nil}
		
		let targetPreview = UITargetedPreview(view: cell)
		targetPreview.parameters.backgroundColor = .clear
		
		return targetPreview
	}
	
	func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		guard let indexPath = configuration.identifier as? IndexPath, let cell = collectionView.cellForItem(at: indexPath) else { return nil}
		
		let targetPreview = UITargetedPreview(view: cell)
		targetPreview.parameters.backgroundColor = .clear
		return targetPreview
	}
}

extension VideoCollectionCompressingViewController {
	
	private func updateCachedAssets() {
		
		guard isViewLoaded && view.window != nil else { return }
		
		let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
		let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
		
		let delta = abs(preheatRect.midY - previousPreheatRect.midY)
		guard delta > view.bounds.height / 3 else { return }
		
		let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
		let addedAssets = addedRects
			.flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
			.compactMap { indexPath in self.assetCollection[indexPath.row] }
		let _ = removedRects
			.flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
			.compactMap { indexPath in self.assetCollection[indexPath.row] }
		
		prefetchCacheImageManager.startCachingImages(for: addedAssets, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil)
//		prefetchCacheImageManager.stopCachingImages(for: removedAssets, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil)
		previousPreheatRect = preheatRect
	}
	
	private func resetCachedAssets() {
		prefetchCacheImageManager.stopCachingImagesForAllAssets()
		previousPreheatRect = .zero
	}
	
	 private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
		if old.intersects(new) {
			var added = [CGRect]()
			if new.maxY > old.maxY {
				added += [CGRect(x: new.origin.x, y: old.maxY,
								 width: new.width, height: new.maxY - old.maxY)]
			}
			if old.minY > new.minY {
				added += [CGRect(x: new.origin.x, y: new.minY,
								 width: new.width, height: old.minY - new.minY)]
			}
			var removed = [CGRect]()
			if new.maxY < old.maxY {
				removed += [CGRect(x: new.origin.x, y: new.maxY,
								   width: new.width, height: old.maxY - new.maxY)]
			}
			if old.minY < new.minY {
				removed += [CGRect(x: new.origin.x, y: old.minY,
								   width: new.width, height: new.minY - old.minY)]
			}
			return (added, removed)
		} else {
			return ([new], [old])
		}
	}
}

extension VideoCollectionCompressingViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func didTapRightBarButton(_ sender: UIButton) {}
}

extension VideoCollectionCompressingViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		
		guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else { return }
		let phasset = self.assetCollection[selectedIndexPath.row]
		
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.videoProcessing, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.videoCompressing) as! VideoCompressingViewController
		
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}

extension VideoCollectionCompressingViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateCachedAssets()
	}
}

extension VideoCollectionCompressingViewController {
	
	private func setupUI() {
		
		self.bottomMenuHeightConstraint.constant = 0
		self.bottomButtonView.setImage(I.systemItems.defaultItems.compress, with: CGSize(width: 24, height: 22))
	}
	
	private func setupNavigation() {
		
		self.navigationBar.setupNavigation(title: self.mediaType.mediaTypeName,
										   leftBarButtonImage: I.systemItems.navigationBarItems.back,
										   rightBarButtonImage: nil,
										   contentType: self.contentType,
										   leftButtonTitle: nil,
										   rightButtonTitle: nil)
	}
	
	private func setupDelegate() {
		
		self.navigationBar.delegate = self
		self.bottomButtonView.delegate = self
		self.scrollView.delegate = self
	}
}

extension VideoCollectionCompressingViewController: Themeble {
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
		self.collectionView.backgroundColor = .clear
		
		bottomButtonView.buttonColor = contentType.screenAcentTintColor
		bottomButtonView.buttonTintColor = theme.activeTitleTextColor
		bottomButtonView.buttonTitleColor = theme.activeTitleTextColor
		bottomButtonView.activityIndicatorColor = theme.backgroundColor
		bottomButtonView.updateColorsSettings()
	}
}
