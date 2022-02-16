//
//  SimpleAssetsListViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2021.
//

import UIKit
import Photos
import AVKit

class SimpleAssetsListViewController: UIViewController {

	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var bottomButtonView: BottomButtonBarView!
	@IBOutlet weak var bottomMenuHeightConstraint: NSLayoutConstraint!
	
	var scrollView = UIScrollView()
	var selectedAssetsDelegate: DeepCleanSelectableAssetsDelegate?
	private var photoManager = PhotoManager.shared
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
	public var mediaType: PhotoMediaType = .none
	public var contentType: MediaContentType = .none
	
	private var thumbnailSize: CGSize = .zero
	private var previousPreheatRect: CGRect = CGRect()
	private var bottomMenuHeight: CGFloat = 80
	private let flowLayout = SimpleColumnFlowLayout(cellsPerRow: 3,
													minimumInterSpacing: 0,
													minimumLineSpacing: 0,
													inset: UIEdgeInsets(top: 10, left: 4, bottom: 0, right: 4))
	
	private var isSelectedAllPhassets: Bool {
		if let indexPaths = self.collectionView.indexPathsForSelectedItems {
			return indexPaths.count == self.assetCollection.count
		} else {
			return false
		}
	}
	
	public var assetCollection: [PHAsset] = []
	public var changedPhassetCompletionHandler: ((_ changedPhasset: [PHAsset]) -> Void)?
	public var selectedPhassetCompletionHandler: ((_ selectedPhassets: [PHAsset]) -> Void)?
	
	private var previouslySelectedIndexPaths: [IndexPath] = []
	public var isDeepCleaningSelectableFlow: Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setupUI()
		setupNavigation()
		setupDelegate()
		setupObservers()
        updateColors()
        setupCollectionView()
    }
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
		!previouslySelectedIndexPaths.isEmpty ? didSelectPreviouslyIndexPath() : ()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		updateCachedAssets()
		previouslySelectedIndexPaths.isEmpty ? didSelectAll() : ()
	}
}

//  MARK: - collection view setup -
extension SimpleAssetsListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func setupCollectionView() {
        
        switch mediaType {
            case .singleLargeVideos:
                flowLayout.isSquare = true
            default:
                flowLayout.itemHieght = ((U.screenWidth - 30) / 3) / U.ratio
        }
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.allowsMultipleSelection = true
		self.collectionView.contentInset.top = 20
		self.collectionView.reloadData()
    }
    
    private func configure(_ cell: PhotoCollectionViewCell, at indexPath: IndexPath) {

        cell.delegate = self
        cell.indexPath = indexPath
		cell.tag = indexPath.section * 1000 + indexPath.row
		cell.cellMediaType = self.mediaType
		cell.cellContentType = self.contentType
			/// config thumbnail according screen type
		let asset = assetCollection[indexPath.row]
		
		if self.thumbnailSize.equalTo(CGSize.zero) {
			self.thumbnailSize = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)!.size.toPixel()
		}

		cell.loadCellThumbnail(asset, imageManager: self.prefetchCacheImageManager, size: thumbnailSize)
		cell.setBestView(availible: false)
		cell.setupUI()
		cell.updateColors()
        
        if let paths = self.collectionView.indexPathsForSelectedItems, paths.contains([indexPath]) {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }

        cell.checkIsSelected()
		cell.updateColors()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.photoSimpleCell, for: indexPath) as! PhotoCollectionViewCell
		cell.photoThumbnailImageView.image = nil
        configure(cell, at: indexPath)
        return cell
    }
	
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        /// use delegate select cell
        /// on tap on cell opened full screen photo preivew
		self.showFullScreenAssetPreview(focus: indexPath)
        return false
    }
        
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let asset = self.assetCollection[indexPath.row]
		let identifier = IndexPath(item: indexPath.item, section: indexPath.section) as NSCopying
        if asset.mediaType == .video {
            return UIContextMenuConfiguration(identifier: identifier) {
                return PreviewAVController(asset: asset)
            } actionProvider: { _ in
                return self.createCellContextMenu(for: asset, at: indexPath)
            }
        } else {
            return UIContextMenuConfiguration(identifier: identifier) {
                return AssetContextPreviewViewController(asset: asset)
            } actionProvider: { _ in
                return self.createCellContextMenu(for: asset, at: indexPath)
            }
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

extension SimpleAssetsListViewController {
	
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


extension SimpleAssetsListViewController: PhotoCollectionViewCellDelegate {
    
    /// custom select deselect button for selected cells
    /// did select item need for preview photo
    /// need handle select button state and check cell.isSelected for checkmark image
    /// for selected cell use cell delegate and indexPath
    
    func didSelectCell(at indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) {
            if cell.isSelected {
                self.collectionView.deselectItem(at: indexPath, animated: true)
                cell.isSelected = false
            } else {
                self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                cell.isSelected = true
            }
        }
        handleSelectAllButtonState()
        handleBottomButtonMenu()
		handleSelectAssetsNavigationCount()
    }
    
    /// handle previously selected indexPath if back from deep clean screen
    public func handleAssetsPreviousSelected(selectedAssetsIDs: [String], assetCollection: [PHAsset]) {
        
        for selectedAssetsID in selectedAssetsIDs {
        
            let indexPath = assetCollection.firstIndex(where: {
                $0.localIdentifier == selectedAssetsID
            }).flatMap({
                IndexPath(row: $0, section: 0)
            })
            
            if let existingIndexPath = indexPath {
                self.previouslySelectedIndexPaths.append(existingIndexPath)
            }
        }
    }
    
    private func didSelectPreviouslyIndexPath() {
        
        guard isDeepCleaningSelectableFlow else { return }
        
        for indexPath in previouslySelectedIndexPaths {
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: indexPath)
            
            if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                cell.checkIsSelected()
            }
        }
        handleSelectAllButtonState()
    }
	
	private func didSelectAll() {
		
		guard isDeepCleaningSelectableFlow else { return }
		
		A.showSelectAllStarterAlert(for: mediaType) {
			self.setCollection(selected: true)
		}
	}
}

extension SimpleAssetsListViewController {

	private func deepCleanFlowBackActionButton() {
		
		guard let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems, isDeepCleaningSelectableFlow else { return }
		
		var selectedAsstsIDs: [String] = []
		
		selectedIndexPaths.forEach { indexPath in
			let assetInCollection = self.assetCollection[indexPath.row]
			selectedAsstsIDs.append(assetInCollection.localIdentifier)
		}
		self.selectedAssetsDelegate?.didSelect(assetsListIds: selectedAsstsIDs, contentType: self.mediaType, updatableGroup: [], updatableAssets: assetCollection, updatableContactsGroup: [])
		self.navigationController?.popViewController(animated: true)
	}
	
	private func singleCleanFlowBackActionButton() {
		self.changedPhassetCompletionHandler?(assetCollection)
		self.navigationController?.popViewController(animated: true)
	}
}

extension SimpleAssetsListViewController {

    private func setCollection(selected: Bool) {
        
        if !selected {
            self.collectionView.deselectAllItems(in: 0, animated: true)
        } else {
            self.collectionView.selectAllItems(in: 0, animated: true)
        }
        
        let numbersOfItemsInSection = collectionView.numberOfItems(inSection: 0)
        
        for indexPath in (0..<numbersOfItemsInSection).map({IndexPath(item: $0, section: 0)}) {
            
            if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                cell.isSelected = selected
                cell.checkIsSelected()
            }
        }
		handleBottomButtonMenu()
		handleSelectAllButtonState()
		handleSelectAssetsNavigationCount()
    }
    
    private func handleSelectAllButtonState() {
		let rightButtonTitle = isSelectedAllPhassets ? "deselect all" : "select all"
		self.navigationBar.changeHotRightTitle(newTitle: rightButtonTitle)
    }
    
    private func handleBottomButtonMenu() {
        
        guard !isDeepCleaningSelectableFlow else { return }
        
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            bottomMenuHeightConstraint.constant = selectedItems.count > 0 ? (bottomMenuHeight + U.bottomSafeAreaHeight - 5) : 0
			
			switch mediaType {
				case .singleRecentlyDeletedPhotos, .singleRecentlyDeletedVideos:
					bottomButtonView.title("recover selected (\(selectedItems.count)")
				default:
					bottomButtonView.title("delete selected (\(selectedItems.count))")
			}
			
			self.collectionView.contentInset.bottom = selectedItems.count > 0 ? 70 + U.bottomSafeAreaHeight : 5
            U.animate(0.5) {
                self.collectionView.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
    }
	
	private func handleSelectAssetsNavigationCount() {
		
		guard isDeepCleaningSelectableFlow else { return }
	
		if let selectedItems = self.collectionView.indexPathsForSelectedItems {
			if selectedItems.count > 0 {
				self.navigationBar.changeHotLeftTitleWithImage(newTitle: String(" (\(selectedItems.count))"), image: I.systemItems.navigationBarItems.back)
			} else {
				self.navigationBar.changeHotLeftTitleWithImage(newTitle: "", image: I.systemItems.navigationBarItems.back)
			}
		} else {
			self.navigationBar.changeHotLeftTitleWithImage(newTitle: "", image: I.systemItems.navigationBarItems.back)
		}
	}
    
    private func showDeleteSelectedAssetsAlert() {
        
        AlertManager.showDeletePhotoAssetsAlert {
            self.deleteSelectedAssets()
        }
    }
    
//    MARK: - delete assets - 
    private func deleteSelectedAssets() {
        
        guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems else { return }
		let assetsToDelete: [PHAsset] = selectedIndexPath.compactMap({self.assetCollection[$0.row]})
		self.deleteOperationWith(selectedPHAassets: assetsToDelete, at: selectedIndexPath)
    }
	
	private func deleteSinglePhasset(at indexPath: IndexPath) {
		
		self.deleteOperationWith(selectedPHAassets: [self.assetCollection[indexPath.row]], at: [indexPath])
	}
	
	private func deleteOperationWith(selectedPHAassets: [PHAsset], at indexPath: [IndexPath]) {
		let deleteOperation = photoManager.deleteSelectedOperation(assets: selectedPHAassets) { success in
			if success {
				let assetIdentifiers = selectedPHAassets.map({ $0.localIdentifier})
				self.assetCollection = self.assetCollection.filter({!assetIdentifiers.contains($0.localIdentifier)})
				U.UI {
					self.collectionView.performBatchUpdates {
						self.collectionView.deleteItems(at: indexPath)
					} completion: { _ in
						self.smoothReloadData()
					}
				}
			}
		}
			
		photoManager.serviceUtilsCalculatedOperationsQueuer.addOperation(deleteOperation)
	}
	
	private func smoothReloadData() {
		UIView.transition(with: self.collectionView, duration: 0.35, options: .transitionCrossDissolve) {
			self.collectionView.reloadData()
		} completion: { _ in
			self.handleSelectAssetsNavigationCount()
			self.handleSelectAllButtonState()
			self.handleBottomButtonMenu()
		}
	}
	
	private func recoverSeletedAssets() {
		guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems else { return }
		
		var receoveredAssets: [PHAsset] = []
		
		selectedIndexPath.forEach { indexPath in
			let asset = self.assetCollection[indexPath.row]
			receoveredAssets.append(asset)
		}
		
//		let recoverOperation = photoManager.recoverSelectedOperation(assets: receoveredAssets) { suxxess in
//			if suxxess {
//				debugPrint(suxxess)
//			} else {
//				debugPrint()
//			}
//		}
//		
//		photoManager.serviceUtilsCalculatedOperationsQueuer.addOperation(recoverOperation)
	}
    
    private func createCellContextMenu(for asset: PHAsset, at indexPath: IndexPath) -> UIMenu {
        
        let fullScreenPreviewAction = UIAction(title: "full screen preview", image: I.systemItems.defaultItems.arrowUP) { _ in
			self.showFullScreenAssetPreview(focus: indexPath)
        }
        
		let deleteAssetAction = UIAction(title: "delete", image: I.systemItems.defaultItems.trashBin, attributes: .destructive) { _ in
			self.deleteSinglePhasset(at: indexPath)
        }
        
        return UIMenu(title: "", children: [fullScreenPreviewAction, deleteAssetAction])
    }
    
    
    private func showVideoPreviewController(_ asset: PHAsset) {
        
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
            U.UI {
                if avAsset != nil {
                    let playerController = AVPlayerViewController()
                    let player = AVPlayer(playerItem: AVPlayerItem(asset: avAsset!))
                    playerController.player = player
                    self.present(playerController, animated: true) {
                        playerController.player!.play()
                    }
                } else {
                    return
                }
            }
        }
    }
    
	private func showFullScreenAssetPreview(focus indexPath: IndexPath ) {
		
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.preview, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.media) as! MediaViewController
		viewController.collectionType = .single
		viewController.focusedIndexPath = indexPath
		viewController.assetCollection = self.assetCollection
		self.navigationController?.pushViewController(viewController, animated: false)
	}
	
//	let storyboard = UIStoryboard(name: C.identifiers.storyboards.preview, bundle: nil)
//	let viewController = storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
//	viewController.collectionType = .single
//	viewController.assetCollection = self.assetCollection
//	
//	
////		viewController.collectionType = .single
////		viewController.focusedIndexPath = indexPath
////		viewController.assetCollection = self.assetCollection
//	self.navigationController?.pushViewController(viewController, animated: false)
	
	
	
}

//      MARK: - setup UI -
extension SimpleAssetsListViewController: Themeble {
    
    func setupUI() {
        
        bottomMenuHeightConstraint.constant = 0
		
		switch mediaType {
			case .singleRecentlyDeletedPhotos, .singleRecentlyDeletedVideos:
				self.bottomButtonView.setImage(I.systemItems.defaultItems.recover, with: CGSize(width: 18, height: 24))
			default:
				self.bottomButtonView.setImage(I.systemItems.defaultItems.delete, with: CGSize(width: 18, height: 24))
		}
    }
    
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

//		MARK: - SETUP -
extension SimpleAssetsListViewController {
	
	private func setupNavigation() {
		
		navigationBar.setupNavigation(title: mediaType.mediaTypeName,
									  leftBarButtonImage: I.systemItems.navigationBarItems.back,
									  rightBarButtonImage: nil,
									  contentType: contentType,
									  leftButtonTitle: nil,
									  rightButtonTitle: isSelectedAllPhassets ? "deselect all" : "select all")
	}
	
	private func setupDelegate() {
		navigationBar.delegate = self
		bottomButtonView.delegate = self
		scrollView.delegate = self
	}
	
	private func setupObservers() {
		UpdatingChangesInOpenedScreensMediator.instance.setListener(listener: self)
	}
}

extension SimpleAssetsListViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateCachedAssets()
	}
}

extension SimpleAssetsListViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		isDeepCleaningSelectableFlow ? self.deepCleanFlowBackActionButton() : self.singleCleanFlowBackActionButton()
	}

	func didTapRightBarButton(_ sender: UIButton) {
		self.setCollection(selected: !isSelectedAllPhassets)
	}
}

extension SimpleAssetsListViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		
		if mediaType == .singleRecentlyDeletedVideos || mediaType == .singleRecentlyDeletedPhotos {
			recoverSeletedAssets()
		} else {
			showDeleteSelectedAssetsAlert()
		}
	}
}

extension SimpleAssetsListViewController: UIPopoverPresentationControllerDelegate {
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
}

//      MARK: - updating screen if photolibrary did change it content -
extension SimpleAssetsListViewController: UpdatingChangesInOpenedScreensListeners {
	
	func getUpdatingSelfies() {}
	
    /// updating screenshots
    func getUpdatingScreenShots() {
        
        if mediaType == .singleScreenShots {
			
			let screenShotsOperation = photoManager.getScreenShotsOperation(from: S.lowerBoundSavedDate, to: S.upperBoundSavedDate, cleanProcessingType: .singleSearch) { screenShots in
				if self.assetCollection.count != screenShots.count {
					U.UI {
						self.assetCollection = screenShots
						self.setCollection(selected: false)
						self.collectionView.reloadData()
					}
				}
			}
			photoManager.phassetProcessingOperationQueuer.addOperation(screenShotsOperation)
        }
    }
}
