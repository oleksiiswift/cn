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
	
	var selectedAssetsDelegate: DeepCleanSelectableAssetsDelegate?
	private var photoManager = PhotoManager.shared
	public var mediaType: PhotoMediaType = .none
	public var contentType: MediaContentType = .none
	
	private let flowLayout = SimpleColumnFlowLayout(cellsPerRow: 3,
													minimumInterSpacing: 0,
													minimumLineSpacing: 0,
													inset: UIEdgeInsets(top: 10, left: 4, bottom: 0, right: 4))
	
	public var assetCollection: [PHAsset] = []
	private var isSelectedAllPhassets: Bool {
		if let indexPaths = self.collectionView.indexPathsForSelectedItems {
			return indexPaths.count == self.assetCollection.count
		} else {
			return false
		}
	}
	public var changedPhassetCompletionHandler: ((_ changedPhasset: [PHAsset]) -> Void)?
	private var previouslySelectedIndexPaths: [IndexPath] = []
	public var isDeepCleaningSelectableFlow: Bool = false
	
    private var bottomMenuHeight: CGFloat = 80
	
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
        
        didSelectPreviouslyIndexPath()
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
        self.collectionView.reloadData()
		self.collectionView.contentInset.top = 20
    }
    
    private func configure(_ cell: PhotoCollectionViewCell, at indexPath: IndexPath) {
        
        cell.delegate = self
        cell.indexPath = indexPath
		cell.cellMediaType = self.mediaType
		cell.cellContentType = self.contentType
        
        if let paths = self.collectionView.indexPathsForSelectedItems, paths.contains([indexPath]) {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }

        cell.checkIsSelected()
        
        /// config thumbnail according screen type
        switch mediaType {
            case .singleScreenShots:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: ((U.screenWidth - 26) / 2),
                                                    height: ((U.screenHeight - 26) / 2) / U.ratio ))
            case .singleSelfies:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenHeight - 26) / 2) / U.ratio))
            case .singleLivePhotos:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
            case .singleLargeVideos:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
            case .similarVideos:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
            case .duplicatedVideos:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
            case .singleScreenRecordings:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
            default:
                cell.loadCellThumbnail(assetCollection[indexPath.row],
                                       size: CGSize(width: (U.screenWidth - 26) / 2,
                                                    height: ((U.screenWidth - 26) / 2) / U.ratio))
        }
		
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
        configure(cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        /// use delegate select cell
        /// on tap on cell opened full screen photo preivew
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
        
        guard isDeepCleaningSelectableFlow, !previouslySelectedIndexPaths.isEmpty else { return }
        
        for indexPath in previouslySelectedIndexPaths {
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: indexPath)
            
            if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                cell.checkIsSelected()
            }
        }
        
        handleSelectAllButtonState()
    }
}

extension SimpleAssetsListViewController {

	private func deepCleanFlowBackActionButton() {
			//    @objc func didTapBackButton() {
			//
			//        guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems, isDeepCleaningSelectableFlow else { return }
			//
			//        var selectedAssetsIDs: [String] = []
			//
			//        selectedIndexPath.forEach { indexPath in
			//            let assetInCollection = self.assetCollection[indexPath.row]
			//            selectedAssetsIDs.append(assetInCollection.localIdentifier)
			//        }
			//
			//        self.selectedAssetsDelegate?.didSelect(assetsListIds: selectedAssetsIDs, mediaType: self.mediaType)
			//        self.navigationController?.popViewController(animated: true)
			//    }
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
    
    private func showDeleteSelectedAssetsAlert() {
        
        AlertManager.showDeletePhotoAssetsAlert {
            self.deleteSelectedAssets()
        }
    }
    
//    MARK: - delete assets - 
    private func deleteSelectedAssets() {
        
        guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems else { return }
        
        var assetsToDelete: [PHAsset] = []
        
        selectedIndexPath.forEach { indexPath in
            let assetInCollection = self.assetCollection[indexPath.row]
                assetsToDelete.append(assetInCollection)
        }
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
						self.handleSelectAllButtonState()
						self.handleBottomButtonMenu()
					}
				}
			}
		}
			
		photoManager.serviceUtilsCalculatedOperationsQueuer.addOperation(deleteOperation)
	}
	
	private func recoverSeletedAssets() {
		guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems else { return }
		
		var receoveredAssets: [PHAsset] = []
		
		selectedIndexPath.forEach { indexPath in
			let asset = self.assetCollection[indexPath.row]
			receoveredAssets.append(asset)
		}
		
		let recoverOperation = photoManager.recoverSelectedOperation(assets: receoveredAssets) { suxxess in
			if suxxess {
				debugPrint(suxxess)
			} else {
				debugPrint()
			}
		}
		
		photoManager.serviceUtilsCalculatedOperationsQueuer.addOperation(recoverOperation)
	}
    
    private func createCellContextMenu(for asset: PHAsset, at indexPath: IndexPath) -> UIMenu {
        
        let fullScreenPreviewAction = UIAction(title: "full screen preview", image: I.cellElementsItems.fullScreen) { _ in
            if asset.mediaType == .video {
                self.showVideoPreviewController(asset)
            } else {
                self.showFullScreenAssetPreview(asset)
            }
        }
        
        let deleteAssetAction = UIAction(title: "delete", image: I.cellElementsItems.trashBin) { _ in
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
    
    private func showFullScreenAssetPreview(_ asset: PHAsset) {}
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
									  mediaType: contentType,
									  leftButtonTitle: nil,
									  rightButtonTitle: isSelectedAllPhassets ? "deselect all" : "select all")
	}
	
	private func setupDelegate() {
		navigationBar.delegate = self
		bottomButtonView.delegate = self
	}
	
	private func setupObservers() {
		UpdatingChangesInOpenedScreensMediator.instance.setListener(listener: self)
	}
}

extension SimpleAssetsListViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		if isDeepCleaningSelectableFlow {
			self.deepCleanFlowBackActionButton()
		} else {
			self.singleCleanFlowBackActionButton()
		}
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
    
    /// updating screenshots
    func getUpdatingScreenShots() {
        
        if mediaType == .singleScreenShots {
			
			let screenShotsOperation = photoManager.getScreenShotsOperation(from: S.lowerBoundSavedDate, to: S.upperBoundSavedDate) { screenShots in
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
    
    /// updating selfies
    func getUpdatingSelfies() {
        
        if mediaType == .singleSelfies {
			
			let selfiePhotosOperation = photoManager.getSelfiePhotosOperation(from: S.lowerBoundSavedDate, to: S.upperBoundSavedDate) { selfies in
				if self.assetCollection.count != selfies.count {
					self.assetCollection = selfies
					self.collectionView.reloadData()
				}
			}
			photoManager.phassetProcessingOperationQueuer.addOperation(selfiePhotosOperation)
        }
    }
}
