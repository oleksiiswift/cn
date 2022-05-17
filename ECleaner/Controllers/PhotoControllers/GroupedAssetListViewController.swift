//
//  GroupedAssetListViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 28.06.2021.
//

import UIKit
import Photos
import AVKit

protocol ContentGroupedDataProviderDelegate: AnyObject {
    func scrollToPreviewPage(at index: Int)
}

class GroupedAssetListViewController: UIViewController {

		/// `outlets`
	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var bottomButtonBarView: BottomButtonBarView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var bottomMenuHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var photoContentContainerView: UIView!
		
	@IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
	private var collectionType: CollectionType = .grouped
	var scrollView = UIScrollView()
	let collectionViewFlowLayout = SNCollectionViewLayout()
	
		/// - delegates -
	private weak var delegate: ContentGroupedDataProviderDelegate?
	var selectedAssetsDelegate: DeepCleanSelectableAssetsDelegate?
		/// - managers -
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
	private var photoManager = PhotoManager.shared
	private var progressAlertController = ProgressAlertController.shared
		/// `assets`
	public var assetGroups: [PhassetGroup] = []
	public var mediaType: PhotoMediaType = .none
	public var contentType: MediaContentType = .none
	
		/// `properties`
	private var isSelectAllAssetsMode: Bool {
		return self.selectedSection.count == self.collectionView.numberOfSections
	}
	public var isDeepCleaningSelectableFlow: Bool = false
	public var changedPhassetGroupCompletionHandler: ((_ phassetGroup: [PhassetGroup]) -> Void)?
	public let phassetsTechnicalUseOperation = OperationProcessingQueuer(name: Constants.key.operation.queue.techUseQueue, maxConcurrentOperationCount: 2, qualityOfService: .userInteractive)
	
	private var selectedAssets: [PHAsset] = []
	private var selectedSection: Set<Int> = []
	private var previouslySelectedIndexPaths: [IndexPath] = []
	public var previousSelectedIDs: [String] = []
	private var thumbnailSize: CGSize!

    private var previousPreheatRect: CGRect = CGRect()

    private var bottomMenuHeight: CGFloat = 80
    private var defaultContainerHeight: CGFloat = 0
	    
    override func viewDidLoad() {
        super.viewDidLoad()

		setupNavigation()
		setupUI()
		setupCollectionView()
		setupDelegate()
		setupObservers()
		updateColors()
		handleDeleteAssetsButton()
    }
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
		updateCachedAssets()
        self.defaultContainerHeight = self.photoContentContainerView.frame.height
		handleDeepCleanStartSelectablePHAssetsGroup()
    }
}

extension GroupedAssetListViewController {
	
	private func didTapBackSingleCleanActionButton() {
		changedPhassetGroupCompletionHandler?(assetGroups)
		self.navigationController?.popViewController(animated: true)
	}
	
	private func didTapBackDeepCleanActionButton() {
		let selectedAssetsIDs: [String] = selectedAssets.compactMap({ $0.localIdentifier})
		self.selectedAssetsDelegate?.didSelect(assetsListIds: selectedAssetsIDs, contentType: self.mediaType, updatableGroup: assetGroups, updatableAssets: [], updatableContactsGroup: [])
		self.navigationController?.popViewController(animated: true)
	}
}

	//      MARK: - Popup viewController drop down menu setup -
extension GroupedAssetListViewController {
	
	func openBurgerMenu() {

		let deleteButtonIsSelected: Bool = !self.selectedAssets.isEmpty
		
		let selectAllOptionItem = DropDownOptionsMenuItem(titleMenu: "select all", itemThumbnail: I.systemElementsItems.circleCheckBox!, isSelected: true, menuItem: .selectAll)
		let deselectAllOptionItem = DropDownOptionsMenuItem(titleMenu: "deselect all", itemThumbnail: I.systemElementsItems.circleBox!, isSelected: true, menuItem: .deselectAll)
		let deleteOptionItem = DropDownOptionsMenuItem(titleMenu: "delete", itemThumbnail: I.systemItems.defaultItems.trashBin, isSelected: deleteButtonIsSelected, menuItem: .delete)
		let firstRowMenuItem = isSelectAllAssetsMode ? deselectAllOptionItem : selectAllOptionItem
		presentDropDonwMenu(with: [firstRowMenuItem, deleteOptionItem], from:  navigationBar.rightBarButtonItem)
	}
	
	private func presentDropDonwMenu(with items: [DropDownOptionsMenuItem], from navigationButton: UIButton) {
		let dropDownViewController = DropDownMenuViewController()
		dropDownViewController.menuSectionItems = items
		dropDownViewController.delegate = self
		
		guard let popoverPresentationController = dropDownViewController.popoverPresentationController else { return }
		
		popoverPresentationController.delegate = self
		popoverPresentationController.sourceView = navigationButton
		popoverPresentationController.sourceRect = CGRect(x: navigationButton.bounds.midX, y: navigationButton.bounds.maxY - 13, width: 0, height: 0)
		popoverPresentationController.permittedArrowDirections = .up
		self.present(dropDownViewController, animated: true, completion: nil)
	}
}

extension GroupedAssetListViewController {
	
	private func showFullScreenAssetPreviewAndFocus(at indexPath: IndexPath) {
		
		guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems else { return }
		
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.preview, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.media) as! MediaViewController
		viewController.isDeepCleaningSelectableFlow = self.isDeepCleaningSelectableFlow
		viewController.previuousSelectedIndexPaths = selectedIndexPath
		viewController.collectionType = self.collectionType
		viewController.focusedIndexPath = indexPath
		viewController.assetGroups = self.assetGroups
		viewController.contentType = self.contentType
		viewController.mediaType = self.mediaType
		viewController.groupSelectionDelegate = self
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}

//		MARK: - handle selected previous index path and phassets ids -
extension GroupedAssetListViewController {
	
	private func handlePreviousSelected(selectedAssetsIDs: [String], assetGroupCollection: [PhassetGroup],_ completionHandler: @escaping (_ indexPaths: [IndexPath]) -> Void) -> ConcurrentProcessOperation {

		let findSelectedIndexPathsOperation = ConcurrentProcessOperation { operation in
			
			var previousSelected: [IndexPath] = []
			let dispatchGroup = DispatchGroup()
			let dispatchQueue = DispatchQueue(label: C.key.dispatch.selectedPhassetsQueue)
			let dispatchSemaphore = DispatchSemaphore(value: 0)
			
			let start = Date()
			var endstart = Date()
			for selectedAssetsID in selectedAssetsIDs {
				autoreleasepool {
					dispatchGroup.enter()
					let sectionIndex = assetGroupCollection.firstIndex(where: {
						$0.assets.contains(where: {$0.localIdentifier == selectedAssetsID})
					}).flatMap({
						$0
					})
					debugPrint(selectedAssetsID)
					if let section = sectionIndex {
						let index: Int = Int(section)
						let indexPath = assetGroupCollection[index].assets.firstIndex(where: {
							$0.localIdentifier == selectedAssetsID
						}).flatMap({
							IndexPath(row: $0, section: index)
						})
						
						if let existingIndexPath = indexPath {
							previousSelected.append(existingIndexPath)
						}
					}
					dispatchSemaphore.signal()
					dispatchGroup.leave()
					endstart = Date()
				}
			}

			dispatchGroup.notify(queue: dispatchQueue) {
				U.UI {
					let time = endstart.timeIntervalSince1970 - start.timeIntervalSince1970
					debugPrint(time)
					completionHandler(previousSelected)
				}
			}
		}
			
		return findSelectedIndexPathsOperation
	}

	private func handleSelected(for indexPaths: [IndexPath], completionHandler: @escaping () -> Void) {
	
			self.selectedAssets = []
			for indexPath in indexPaths {
				self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
				self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: indexPath)
				let phasset = self.assetGroups[indexPath.section].assets[indexPath.row]
				self.selectedAssets.append(phasset)
				
				if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
					cell.isSelected = true
					cell.checkIsSelected()
					self.handleSelectAllButtonSection(IndexPath(item: 0, section: indexPath.section))
				}
			}
			self.handleActionButtons()
			completionHandler()
	}
	
	private func didSelectAllAssets(at indexPath: IndexPath, in sectionHeader: GroupedAssetsReusableHeaderView) {
		
		var addingSection: Bool = false
		
			/// work with assets
		if selectedSection.contains(indexPath.section) {
			for asset in self.assetGroups[indexPath.section].assets {
				self.selectedAssets.removeAll(asset)
			}
		} else {
			for asset in self.assetGroups[indexPath.section].assets {
				let index = self.assetGroups[indexPath.section].assets.indexes(of: asset)
				if index != [0] {
					self.selectedAssets.append(asset)
					addingSection = true
				}
			}
		}
		
			/// work with indexes paths
		if addingSection {
			selectedSection.insert(indexPath.section)
			self.collectionView.selectAllItems(in: indexPath.section, first: 1, animated: true)
		} else {
			selectedSection.remove(indexPath.section)
			self.collectionView.deselectAllItems(in: indexPath.section, first: 0, animated: true)
		}
		
		let indexesOfSection = self.collectionView.getAllIndexPathsInSection(section: indexPath.section)
		indexesOfSection.forEach { indexPath in
			if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
				cell.checkIsSelected()
			}
		}
		
		sectionHeader.handleSelectableAsstes(to: addingSection)
		sectionHeader.handleDeleteAssets(to: addingSection)
		self.handleDeleteAssetsButton()
		self.handleSelectAssetsNavigationCount()
	}
	
	private func shouldSelectAllAssetsInSections(_ isSelect: Bool) {
		
		for section in 0..<collectionView.numberOfSections {
			if isSelect {
				self.collectionView.deselectAllItems(in: section, animated: true)
			} else {
				self.collectionView.selectAllItems(in: section, first: 1, animated: true)
			}
			
			for item in 1..<self.collectionView.numberOfItems(inSection: section) {
				if let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? PhotoCollectionViewCell{
					cell.isSelected = !isSelect
					cell.checkIsSelected()
				}
				
				if isSelect {
					self.selectedAssets.removeAll()
				} else {
					if !self.selectedAssets.contains(self.assetGroups[section].assets[item]) {
						self.selectedAssets.append(self.assetGroups[section].assets[item])
					}
				}
			}
			
			/// check header button state availible
			self.handleSelectAllButtonSection(IndexPath(item: 0, section: section))
			
			if !self.selectedSection.contains(section) {
				self.selectedSection.insert(section)
			}
		}
		
		if isSelect {
			selectedSection.removeAll()
		}
		self.handleDeleteAssetsButton()
		self.handleSelectAssetsNavigationCount()
	}
	
	private func handleDeepCleanStartSelectablePHAssetsGroup() {
		
		guard isDeepCleaningSelectableFlow else { return }
		
		if !previousSelectedIDs.isEmpty {
			
			let progress: ProgressAlertType = self.contentType == .userPhoto ? .selectingPhotos : .selectingVideos
			self.progressAlertController.showSimpleProgressAlerControllerBar(of: progress, from: self)
			
			let selectedOperation = self.handlePreviousSelected(selectedAssetsIDs: self.previousSelectedIDs,
																assetGroupCollection: self.assetGroups) { indexPaths in
				self.handleSelected(for: indexPaths) {
					U.delay(1) {
						self.progressAlertController.closeProgressAnimatedController()
					}
				}
			}
			phassetsTechnicalUseOperation.addOperation(selectedOperation)
	
		} else {
			self.handleDeleteAssetsButton()
		}
	}
}

//		  MARK: - flow with select deselect cell
extension GroupedAssetListViewController: PhotoCollectionViewCellDelegate {
	
	func didShowFullScreenPHasset(at cell: PhotoCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		self.showFullScreenAssetPreviewAndFocus(at: indexPath)
	}
	
	func didSelect(cell: PhotoCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		
		let phasset = self.assetGroups[indexPath.section].assets[indexPath.row]
		
		if cell.isSelected {
			self.collectionView.deselectItem(at: indexPath, animated: true)
			self.collectionView.delegate?.collectionView?(self.collectionView, didDeselectItemAt: indexPath)
			if self.selectedAssets.contains(phasset) {
				self.selectedAssets = self.selectedAssets.filter({$0 != phasset})
			}
		} else {
			self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
			self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: indexPath)
			if !self.selectedAssets.contains(phasset) {
				self.selectedAssets.append(phasset)
			}
		}
		self.handleActionButtons(indexPath: indexPath)
	}
}

extension GroupedAssetListViewController: GroupSelectableAssetsDelegate {
	
	func didSelect(selectedIndexPath: [IndexPath], phassetsGroups: [PhassetGroup]) {
		
		self.assetGroups = phassetsGroups
		
		if self.assetGroups.isEmpty {
			didTapBackSingleCleanActionButton()
		} else {
			self.collectionView.reloadDataWitoutAnimation()
				self.handleSelected(for: selectedIndexPath) {}
		}
	}
}

//		MARK: - handle check and did select cells -
extension GroupedAssetListViewController {
	
	private func checkForSelectedSection() {
		
		for section in 0..<self.collectionView.numberOfSections {
			let allSectionIndexPaths = self.getIndexPathInSectionWithoutFirst(section: section)
			var selectedIndexPathInSection: [IndexPath] = []
			
			if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
				allSectionIndexPaths.forEach { indexPath in
					if let path = selectedIndexPaths.first(where: {$0 == indexPath}) {
						selectedIndexPathInSection.append(path)
					}
				}
				if allSectionIndexPaths.count == selectedIndexPathInSection.count {
					if !selectedSection.contains(section) {
						selectedSection.insert(section)
					}
				}
			}
		}
	}
	
	private func checkSelectedHeaderView(for indexPath: IndexPath, headerView: GroupedAssetsReusableHeaderView) {
		
		if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems {
			if !selectedIndexPaths.isEmpty {
				let sectionSelectedPathFiltered = selectedIndexPaths.filter({$0.section == indexPath.section})
				if sectionSelectedPathFiltered.contains(where: {$0.section == indexPath.section}) {
					headerView.handleDeleteAssets(to: true)
					if self.collectionView.numberOfItems(inSection: indexPath.section) - 1 == sectionSelectedPathFiltered.count {
						headerView.handleSelectableAsstes(to: true)
					} else {
						headerView.handleSelectableAsstes(to: false)
					}
				} else {
					headerView.handleSelectableAsstes(to: false)
					headerView.handleDeleteAssets(to: false)
				}
			} else {
				headerView.handleDeleteAssets(to: false)
				headerView.handleSelectableAsstes(to: false)
			}
		}
		collectionViewFlowLayout.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
	}
	
	private func isSelectedSection(_ indexPaths: [IndexPath]) -> Bool {
		var isCellsSelectedCount: Int = 0
		indexPaths.forEach { indexPath in
			
			if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
				if cell.isSelected {
					isCellsSelectedCount += 1
				}
			}
		}
		return indexPaths.count == isCellsSelectedCount
	}
	
	private func onSelectAllSectionButtonTapped(for sectionHeader: GroupedAssetsReusableHeaderView, at indexPath: IndexPath) {
		
		let indexPaths = self.getIndexPathInSectionWithoutFirst(section: indexPath.section)
		let sectionsCells = self.getSectionsCells(at: indexPaths)
		
		if !sectionsCells.isEmpty {
			
				/// check if section contains selected cells
			let selectedCell = sectionsCells.filter({ $0.isSelected })
			if !selectedCell.isEmpty {
				
				let cells = sectionsCells.filter({ !$0.isSelected })
					/// check if section contains selected and not selected cells
				if !cells.isEmpty {
					cells.forEach { cell in
						if let cellIndexPath = self.collectionView.indexPath(for: cell) {//}, cellIndexPath != IndexPath(row: 0, section: indexPath.section) {
							if !self.selectedAssets.contains(self.assetGroups[cellIndexPath.section].assets[cellIndexPath.row]) {
								self.selectedAssets.append(self.assetGroups[cellIndexPath.section].assets[cellIndexPath.row])
								collectionView.selectItem(at: cellIndexPath, animated: true, scrollPosition: .centeredHorizontally)
								cell.checkIsSelected()
							}
						}
					}
					
					if !self.selectedSection.contains(indexPath.section) {
						self.selectedSection.insert(indexPath.section)
					}
					sectionHeader.handleSelectableAsstes(to: true)
					sectionHeader.handleDeleteAssets(to: true)
					
				} else {
						/// select - deselect all section withoit first cell
						/// section are full selected or deselected
					self.didSelectAllAssets(at: indexPath, in: sectionHeader)
				}
			} else {
				self.didSelectAllAssets(at: indexPath, in: sectionHeader)
			}
		}
	}
	
	private func checkForEmptyCollection() {
		
		if assetGroups.isEmpty {
			isDeepCleaningSelectableFlow ? didTapBackDeepCleanActionButton() : didTapBackSingleCleanActionButton()
		}
	}
}

extension GroupedAssetListViewController {
	
	private func getIndexPathInSectionWithoutFirst(section: Int) -> [IndexPath] {
		let cellsCountInSection = self.collectionView.numberOfItems(inSection: section)
		return (1..<cellsCountInSection).map({IndexPath(item: $0, section: section)})
	}
	
	private func getSectionsCells(at indexPaths: [IndexPath]) -> [PhotoCollectionViewCell] {
		var cells: [PhotoCollectionViewCell] = []
		
		indexPaths.forEach { indexPath in
			if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
				cells.append(cell)
			}
		}
		return cells
	}
}

//		MARK: - handle select buttons state -
extension GroupedAssetListViewController {
	
	private func handleSelectAllButtonSection(_ indexPath: IndexPath) {
		
		if let view = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader,
															at: IndexPath(row: 0, section: indexPath.section)) {
			
			guard let headerView = view as? GroupedAssetsReusableHeaderView else { return }
			
			if let selectedIndexPath = self.collectionView.indexPathsForSelectedItems {
				let sectionFilters = selectedIndexPath.filter({ $0.section == indexPath.section})
				if sectionFilters.contains(where: {$0.section == indexPath .section}) {
					let numbersOfItems = self.collectionView.numberOfItems(inSection: indexPath.section) - 1
					if numbersOfItems == sectionFilters.count || numbersOfItems == sectionFilters.count{
						if !selectedSection.contains(indexPath.section) {
							selectedSection.insert(indexPath.section)
						}
					} else {
						if selectedSection.contains(indexPath.section) {
							selectedSection.remove(indexPath.section)
						}
					}
				} else {
				}
			}
			checkSelectedHeaderView(for: indexPath, headerView: headerView)
			collectionViewFlowLayout.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
		}
	}
	
	private func handleSelectAssetsNavigationCount() {
		
		guard isDeepCleaningSelectableFlow else { return }
	
		if !selectedAssets.isEmpty {
			self.navigationBar.changeHotLeftTitleWithImage(newTitle: String(" (\(selectedAssets.count))"), image: I.systemItems.navigationBarItems.back)
		} else {
			self.navigationBar.changeHotLeftTitleWithImage(newTitle: "", image: I.systemItems.navigationBarItems.back)
		}
	}
}

extension GroupedAssetListViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		isDeepCleaningSelectableFlow ? didTapBackDeepCleanActionButton() : didTapBackSingleCleanActionButton()
	}
	
	func didTapRightBarButton(_ sender: UIButton) {
		openBurgerMenu()
	}
}

extension GroupedAssetListViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		showDeleteConfirmAlert()
	}
}

//		MARK: - configure collection view -
extension GroupedAssetListViewController {
	
	private func setupCollectionView() {
		
			/// `delegates` subscribe
		self.collectionViewFlowLayout.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
	
			/// `register xib`
		self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell,
										   bundle: nil),
									 forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
		
		self.collectionView.register(UINib(nibName: C.identifiers.xibs.groupHeader,
										   bundle: nil),
									 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
									 withReuseIdentifier: C.identifiers.views.groupHeaderView)
		
			/// collection view `setup`
		self.collectionView.contentInset = UIEdgeInsets(top: 15, left: 10, bottom: 5, right: 10)
		self.collectionViewFlowLayout.fixedDivisionCount = 4
		self.collectionViewFlowLayout.itemSpacing = 0
		self.collectionView.collectionViewLayout = collectionViewFlowLayout
		self.collectionView.allowsMultipleSelection = true
		self.collectionView.reloadData()
	}
	
	private func configure(_ cell: PhotoCollectionViewCell, at indexPath: IndexPath) {
		
		let asset = assetGroups[indexPath.section].assets[indexPath.row]
		cell.collectionType = self.collectionType
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
		
		if let path = self.collectionView.indexPathsForSelectedItems, path.contains(indexPath) {
			cell.isSelected = true
		} else {
			cell.isSelected = false
		}
		cell.checkIsSelected()
	}
	
	public func hederConfigure(_ view: GroupedAssetsReusableHeaderView, at indexPath: IndexPath) {
//		view.deleteSelectedButton.isHidden = isDeepCleaningSelectableFlow
		view.mediaContentType = self.contentType
		view.deleteSelectedButton.contentType = self.contentType
		view.setupUI()
		view.setGroupDate(self.assetGroups[indexPath.section].creationDate)
	}
}

	//      MARK: - setup collection view with flow layout -
extension GroupedAssetListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return assetGroups.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return assetGroups[section].assets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.photoSimpleCell, for: indexPath) as! PhotoCollectionViewCell
		configure(cell, at: indexPath)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		self.showFullScreenAssetPreviewAndFocus(at: indexPath)
		return false
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
		self.showFullScreenAssetPreviewAndFocus(at: indexPath)
		return false
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		switch kind {
				
			case UICollectionView.elementKindSectionHeader:
				
				let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: C.identifiers.views.groupHeaderView, for: indexPath)
				
				guard let sectionHeader = headerView as? GroupedAssetsReusableHeaderView else { return headerView }
				
				self.hederConfigure(sectionHeader, at: indexPath)
				
				handleSelectAllButtonSection(indexPath)
				checkSelectedHeaderView(for: indexPath, headerView: sectionHeader)
				
				sectionHeader.onSelectAll = {
					self.onSelectAllSectionButtonTapped(for: sectionHeader, at: indexPath)
				}
				
				sectionHeader.onDeleteSelected = {
					self.onDeleteAllSelectedInSectionButtonTapped(for: sectionHeader, at: indexPath)
				}
				
				return sectionHeader
				
			default:
				assert(false, "Invalid element type")
		}
		return UICollectionReusableView()
	}
			
	func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		
		guard let headerview = view as? GroupedAssetsReusableHeaderView else { return }
		
		checkSelectedHeaderView(for: indexPath, headerView: headerview)
	}
	
	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let asset = self.assetGroups[indexPath.section].assets[indexPath.row]
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
		targetPreview.parameters.backgroundColor = theme.backgroundColor
		targetPreview.view.backgroundColor = theme.backgroundColor
		
		return targetPreview
	}
	
	private func smoothReloadData() {
		UIView.transition(with: self.collectionView, duration: 0.35, options: .transitionCrossDissolve) {
			self.collectionView.reloadData()
		} completion: { _ in
			self.handleDeleteAssetsButton()
			self.handleSelectAssetsNavigationCount()
		}
	}
	
	private func reloadDataAfterRefactor() {
		self.collectionView.reloadDataWitoutAnimation()
		self.selectedAssets = []
		self.selectedSection = []
		self.handleDeleteAssetsButton()
		self.handleSelectAssetsNavigationCount()
		self.checkForEmptyCollection()
	}
	
	private func handleActionButtons(indexPath: IndexPath? = nil) {
		self.handleDeleteAssetsButton()
		self.handleSelectAssetsNavigationCount()
		if let indexPath = indexPath {
			self.handleSelectAllButtonSection(indexPath)
		}
		self.checkForEmptyCollection()
	}
}

extension GroupedAssetListViewController {
	
	private func showDeleteConfirmAlert() {
		
		A.deletePHAssets(of: self.contentType, of: selectedAssets.count > 1 ? .many : .one) {
			self.deleteSelectedAssets()
		}
	}
	
	private func showDelecteConfirmAlert(for assets: [PHAsset], completionHandler: @escaping (Bool) -> Void) {
		
		let deletePhassetOperation = photoManager.deleteSelectedOperation(assets: assets) { suxxess in
			if !suxxess {
				U.delay(1) {
					self.progressAlertController.closeProgressAnimatedController()
					U.delay(1) {
						ErrorHandler.shared.showDeleteAlertError(self.contentType == .userVideo ? .errorDeleteVideo : .errorDeletePhoto)
					}
				}
			}
			completionHandler(suxxess)
		}
		
		A.deletePHAssets(of: self.contentType, of: assets.count > 1 ? .many : .one) {
			let type: ProgressAlertType = self.contentType == .userPhoto ? .deletePhotos : .deleteVideos
			self.progressAlertController.showSimpleProgressAlerControllerBar(of: type, from: self)
			U.delay(1) {
				self.photoManager.phassetProcessingOperationQueuer.addOperation(deletePhassetOperation)
			}
		}
	}
	
	/// `delete selected phassets from bottom action`
	private func deleteSelectedAssets() {
		
		guard let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems else { return }
		
		let selectedPhassets: [PHAsset] = selectedIndexPaths.map({self.assetGroups[$0.section].assets[$0.row]})
		
		guard !selectedPhassets.isEmpty else { return }
		
		var sectionsOperation = self.assetGroups.enumerated().filter({
			$0.element.assets.intersects(with: selectedPhassets)
		}).map({$0.offset})
		
		let progress: ProgressAlertType = self.contentType == .userPhoto ? .deletePhotos : .deleteVideos
		progressAlertController.showSimpleProgressAlerControllerBar(of: progress, from: self)
		
		let deletePhassetOperation = photoManager.deleteSelectedOperation(assets: selectedPhassets) { success in
			U.UI {
				if success {
					
					var removableSections: [Int] = []
					var updatedAssetsGroups: [PhassetGroup] = self.assetGroups
					
					let _: [PhassetGroup] = sectionsOperation.map({
						let assets = self.assetGroups[$0].assets.subtracting(selectedPhassets)
						assets.count == 1 ? removableSections.append($0) : ()
						updatedAssetsGroups[$0].assets = assets.count == 1 ? [] : assets
						return updatedAssetsGroups[$0]
					})
					
					sectionsOperation = sectionsOperation.subtracting(removableSections)
					let _ = updatedAssetsGroups.remove(elementsAtIndices: removableSections)
					
					self.collectionView.performBatchUpdates {
						self.collectionView.deleteItems(at: selectedIndexPaths)
						self.collectionView.deleteSections(IndexSet(removableSections))
						self.assetGroups = updatedAssetsGroups
					} completion: { _ in
						U.delay(1) {
						self.reloadDataAfterRefactor()
							self.progressAlertController.closeProgressAnimatedController()
						}
					}
				} else {
					U.delay(1) {
						self.progressAlertController.closeProgressAnimatedController()
					}
				}
			}
		}
		
		U.delay(1) {
			self.photoManager.phassetProcessingOperationQueuer.addOperation(deletePhassetOperation)
		}
	}
	
	private func deleteAsset(at indexPath: IndexPath) {
		
		let phasset = self.assetGroups[indexPath.section].assets[indexPath.row]
		
		self.showDelecteConfirmAlert(for: [phasset]) { suxxess in
			U.UI {
				if suxxess {
					self.selectedAssets.removeAll(phasset)
				
					self.assetGroups[indexPath.section].assets.remove(at: indexPath.item)
				
					let oldGropsValue = self.assetGroups.count
					let newGroupsValue = self.assetGroups.filter({$0.assets.count != 1})
					if oldGropsValue != newGroupsValue.count {
						self.collectionView.performBatchUpdates {
							self.collectionView.deleteSections(IndexSet(integer: indexPath.section))
							self.assetGroups.remove(at: indexPath.section)
							self.assetGroups = newGroupsValue
						} completion: { _ in
							U.delay(1) {
								self.handleActionButtons()
								self.progressAlertController.closeProgressAnimatedController()
							}
						}
					} else {
						self.collectionView.performBatchUpdates {
							self.collectionView.deleteItems(at: [indexPath])
							self.assetGroups = newGroupsValue
						} completion: { _ in
							U.delay(1) {
								self.handleActionButtons(indexPath: indexPath)
								self.progressAlertController.closeProgressAnimatedController()
							}
						}
					}
				}
			}
		}
	}
}

extension GroupedAssetListViewController {
	
	private func onDeleteAllSelectedInSectionButtonTapped(for sectionHeader: GroupedAssetsReusableHeaderView, at indexPath: IndexPath) {
		
		guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems else { return }
		
		let indexPathOfSection = self.getIndexPathInSectionWithoutFirst(section: indexPath.section)
		
		let selectedIndexPathsInSection = selectedIndexPath.intersection(with: indexPathOfSection)
		let selectedIndixes = selectedIndexPathsInSection.map({$0.row})
	
		if !selectedIndexPathsInSection.isEmpty {
			let changedGroupsPHAssets = assetGroups[indexPath.section].assets
			let phassets = selectedIndixes.map({changedGroupsPHAssets[$0]})
			
			if !phassets.isEmpty {
				self.showDelecteConfirmAlert(for: phassets) { suxxess in
					
					guard suxxess else {return }
					
					self.selectedAssets = self.selectedAssets.filter({!phassets.contains($0)})
					
					U.UI {
						if phassets.count == indexPathOfSection.count {
							self.assetGroups.remove(at: indexPath.section)
							self.collectionView.performBatchUpdates {
								self.collectionView.deleteSections(IndexSet(integer: indexPath.section))
							} completion: { _ in
								U.delay(1) {
									
								
								self.handleSelectAllButtonSection(indexPath)
								self.checkForSelectedSection()
								self.handleActionButtons()
								
									self.progressAlertController.closeProgressAnimatedController()
								}
							}
						} else {
							self.assetGroups[indexPath.section].assets = self.assetGroups[indexPath.section].assets.filter({!phassets.contains($0)})
							self.collectionView.performBatchUpdates {
								self.collectionView.deleteItems(at: selectedIndexPathsInSection)
							} completion: { _ in
								U.delay(1) {
								self.handleSelectAllButtonSection(indexPath)
								self.checkForSelectedSection()
								self.handleActionButtons()
									self.progressAlertController.closeProgressAnimatedController()
								}
							}
						}
					}
				}
			}
		}
	}
}

extension GroupedAssetListViewController {
	
	private func createCellContextMenu(for asset: PHAsset, at indexPath: IndexPath) -> UIMenu {
		
		let fullScreenPreviewActionImage = I.systemItems.defaultItems.arrowUP.withTintColor(theme.titleTextColor).withRenderingMode(.alwaysTemplate)
		let setAsBestActionImage =         I.systemItems.defaultItems.star.withTintColor(theme.titleTextColor).withRenderingMode(.alwaysTemplate)
		let deleteActionImage =            I.systemItems.defaultItems.trashBin.withTintColor(theme.actionTintColor).withRenderingMode(.alwaysTemplate)
		
		let fullScreenPreviewAction = UIAction(title: "full screen preview", image: fullScreenPreviewActionImage) { _ in
			self.showFullScreenAssetPreviewAndFocus(at: indexPath)
		}
		
		let setAsBestAction = UIAction(title: "set as best", image: setAsBestActionImage) { _ in
			self.setAsBest(asset: asset, at: indexPath)
		}
		
		let deleteAssetAction = UIAction(title: "delete", image: deleteActionImage, attributes: .destructive) { _ in
			self.deleteAsset(at: indexPath)
		}
		
		if indexPath.row == 0 {
			return UIMenu(title: "", children: [fullScreenPreviewAction])
		} else {
			return UIMenu(title: "", children: [fullScreenPreviewAction, setAsBestAction, deleteAssetAction])
		}
	}
}

extension GroupedAssetListViewController {
	
	private func handleDeleteAssetsButton() {
		
		U.UI { [self] in
			guard !isDeepCleaningSelectableFlow else {
				bottomMenuHeightConstraint.constant = 0
				return
			}
			
				/// `bottom menu`
			bottomMenuHeightConstraint.constant = !selectedAssets.isEmpty ? U.UIHelper.AppDimensions.bottomBarDefaultHeight  : 0
			
			bottomButtonBarView.title("delete selected (\(selectedAssets.count))")
			
			U.animate(0.5) {
				self.collectionView.contentInset.bottom = !self.selectedAssets.isEmpty ? U.UIHelper.AppDimensions.bottomBarDefaultHeight + 10 + U.bottomSafeAreaHeight : 5
			
				self.photoContentContainerView.layoutIfNeeded()
				self.view.layoutIfNeeded()
			}
		}
	}
}

extension GroupedAssetListViewController {
	
	private func setAsBest(asset: PHAsset, at indexPath: IndexPath) {
		
		guard let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { return }
		
		let bestPHAssetIndexPath = IndexPath(row: 0, section: indexPath.section)
		
		cell.isSelected ? cell.delegate?.didSelect(cell: cell) : ()
			
		assetGroups[indexPath.section].assets.move(at: indexPath.row, to: 0)
		collectionView.performBatchUpdates {
			collectionView.moveItem(at: indexPath, to: bestPHAssetIndexPath)
		} completion: { _ in
			self.collectionView.reloadDataWithotAnimationKeepSelect(at: [bestPHAssetIndexPath, IndexPath(row: 1, section: indexPath.section)])
			self.handleActionButtons(indexPath: indexPath)
		}
	}
 }

extension GroupedAssetListViewController: SelectDropDownMenuDelegate {
	
	func selectedItemListViewController(_ controller: DropDownMenuViewController, didSelectItem: DropDownMenuItems) {
		
		switch didSelectItem {
			case .deselectAll:
				self.shouldSelectAllAssetsInSections(true)
			case .selectAll:
				self.shouldSelectAllAssetsInSections(false)
			case .delete:
				self.deleteSelectedAssets()
			default:
				return
		}
	}
}

extension GroupedAssetListViewController {
	
	private func updateCachedAssets() {
		
		guard isViewLoaded && view.window != nil else { return }
		
		let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
		let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
		
		let delta = abs(preheatRect.midY - previousPreheatRect.midY)
		guard delta > view.bounds.height / 3 else { return }
		
		let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
		let addedAssets = addedRects
			.flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
			.compactMap { indexPath in self.assetGroups[indexPath.section].assets[indexPath.item] }
		let _ = removedRects
			.flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
			.compactMap { indexPath in self.assetGroups[indexPath.section].assets[indexPath.item] }
		
		let options = PHImageRequestOptions()
		options.isNetworkAccessAllowed = true
		let size = CGSize(width: 300, height: 300)
		
		prefetchCacheImageManager.startCachingImages(for: addedAssets, targetSize: size, contentMode: .aspectFill, options: options)
//		prefetchCacheImageManager.stopCachingImages(for: [removedAssets], targetSize: size, contentMode: .aspectFill, options: options)
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

//      MARK: - delegates flow -
extension GroupedAssetListViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension GroupedAssetListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateCachedAssets()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		debugPrint("scrollViewDidEndDecelerating")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		debugPrint("scrollViewDidEndScrollingAnimation")
	}
    
    private func computeDifferenceBetweenRect(oldRect: CGRect, andRect newRect: CGRect, removedHandler: (CGRect)->Void, addedHandler: (CGRect)->Void) {
        if newRect.intersects(oldRect) {
            let oldMaxY = oldRect.maxY
            let oldMinY = oldRect.minY
            let newMaxY = newRect.maxY
            let newMinY = newRect.minY
            
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
}

//      MARK: - setup UI -
extension GroupedAssetListViewController {
		
	private func setupUI() {
		
		let bottomButtonImageSize = CGSize(width: 18, height: 24)
		switch mediaType {
			case .singleRecentlyDeletedPhotos, .singleRecentlyDeletedVideos:
				self.bottomButtonBarView.setImage(I.systemItems.defaultItems.recover, with: bottomButtonImageSize)
			default:
				self.bottomButtonBarView.setImage(I.systemItems.defaultItems.delete, with: bottomButtonImageSize)
		}
	}
	
	private func setupNavigation() {
		
		navigationBarHeightConstraint.constant = U.UIHelper.AppDimensions.NavigationBar.navigationBarHeight
		
		navigationBar.setupNavigation(title: self.mediaType.mediaTypeName,
									  leftBarButtonImage: I.systemItems.navigationBarItems.back,
									  rightBarButtonImage: I.systemItems.navigationBarItems.burgerDots,
									  contentType: self.contentType,
									  leftButtonTitle: nil,
									  rightButtonTitle: nil)
	}
	
	private func setupObservers() {}
	
	private func setupDelegate() {
		
		scrollView.delegate = self
		navigationBar.delegate = self
		bottomButtonBarView.delegate = self
	}
}

extension GroupedAssetListViewController: SNCollectionViewLayoutDelegate {
	
	func scaleForItem(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, atIndexPath indexPath: IndexPath) -> UInt {

		return indexPath.row == 0 ? 2 : 1
	}
	
	func headerFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
		return 55
	}
}

extension GroupedAssetListViewController: Themeble {
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
		self.collectionView.backgroundColor = theme.backgroundColor
		
		bottomButtonBarView.buttonColor = contentType.screenAcentTintColor
		bottomButtonBarView.buttonTintColor = theme.activeTitleTextColor
		bottomButtonBarView.buttonTitleColor = theme.activeTitleTextColor
		bottomButtonBarView.activityIndicatorColor = theme.backgroundColor
		bottomButtonBarView.updateColorsSettings()
	}
}
