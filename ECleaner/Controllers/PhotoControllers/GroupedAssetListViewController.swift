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

class GroupedAssetListViewController: UIViewController, UIPageViewControllerDelegate {

		/// `outlets`
	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var bottomButtonBarView: BottomButtonBarView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var bottomMenuHeightConstraint: NSLayoutConstraint!
	
	var scrollView = UIScrollView()
	let collectionViewFlowLayout = SNCollectionViewLayout()
		/// - delegates -
	private weak var delegate: ContentGroupedDataProviderDelegate?
	var selectedAssetsDelegate: DeepCleanSelectableAssetsDelegate?
	
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
	
	private var selectedAssets: [PHAsset] = []
	private var selectedSection: Set<Int> = []
	private var previouslySelectedIndexPaths: [IndexPath] = []

    @IBOutlet weak var photoPreviewContainerView: UIView!
    @IBOutlet weak var photoContentContainerView: UIView!
    @IBOutlet weak var optionalViewerHeightConstraint: NSLayoutConstraint!
    
    /// - controllers -
    #warning("hide photopreviewLogic for TODO later")
//    private var photoPreviewController = PhotoPreviewViewController(
//    private weak var delegate: ContentDataProviderDelegate?

    private var splitAssetsNumberOfItems: Int = 0
    private var splitAssets: [PHAsset] = []
    
    /// - managers -
    private var cacheImageManager = PHCachingImageManager()
	private var photoManager = PhotoManager.shared

    let carouselCollectionFlowLayout = ZoomAndSnapFlowLayout()
	
    private var isSliderFlowLayout: Bool = false
    private var isCarouselViewMode: Bool = false
    private var focusedIndexPath: IndexPath?
    private var previousPreheatRect: CGRect = CGRect()

    private var bottomMenuHeight: CGFloat = 80
    private var defaultContainerHeight: CGFloat = 0
    private var carouselPreviewCollectionHeight: CGFloat = 150 + U.bottomSafeAreaHeight

    override func viewDidLoad() {
        super.viewDidLoad()

		setupNavigation()
		setupUI()
		setupCollectionView()
		setupDelegate()
		setupObservers()
		updateColors()
		handleDeleteAssetsButton()
		
//        splitAllAssetsForPreview() /// hide temporary for future
//        setupPhotoPreviewController() /// hide
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
		!previouslySelectedIndexPaths.isEmpty ? didSelectPreviouslyIndexPath() : ()

//        updateCachedAssets()
//        setupPhotoPreviewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
		previouslySelectedIndexPaths.isEmpty ? handleStartingSelectableAssets() : ()
        self.defaultContainerHeight = self.photoContentContainerView.frame.height
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
	
	private func preSelectCleaningPhassetAccordingControllerType() {
		
		guard isDeepCleaningSelectableFlow else { return }
	}
}

	//      MARK: - Popup viewController drop down menu setup -
extension GroupedAssetListViewController {
	
	func openBurgerMenu() {
		
//		let sliderMenuOptionItem = DropDownOptionsMenuItem(titleMenu: "slider", itemThumbnail: I.systemElementsItems.sliderView, isSelected: false, menuItem: .changeLayout)
//		let tileMenuOptionItem = DropDownOptionsMenuItem(titleMenu: "tile", itemThumbnail: I.systemElementsItems.tileView, isSelected: false, menuItem: .changeLayout)
		let selectAllOptionItem = DropDownOptionsMenuItem(titleMenu: "select all", itemThumbnail: I.systemElementsItems.circleCheckBox!, isSelected: true, menuItem: .selectAll)
		let deselectAllOptionItem = DropDownOptionsMenuItem(titleMenu: "deselect all", itemThumbnail: I.systemElementsItems.circleBox!, isSelected: true, menuItem: .deselectAll)
		let deleteOptionItem = DropDownOptionsMenuItem(titleMenu: "delete", itemThumbnail: I.systemItems.defaultItems.trashBin, isSelected: true, menuItem: .delete)
//
		let firstRowMenuItem = isSelectAllAssetsMode ? deselectAllOptionItem : selectAllOptionItem
//		let secondRowMenuItem = isSliderFlowLayout ? tileMenuOptionItem : sliderMenuOptionItem
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
	
	public func handlePreviousSelected(selectedAssetsIDs: [String], assetGroupCollection: [PhassetGroup]) {
		
		for selectedAssetsID in selectedAssetsIDs {
			
			let sectionIndex = assetGroupCollection.firstIndex(where: {
				$0.assets.contains(where: {$0.localIdentifier == selectedAssetsID})
			}).flatMap({
				$0
			})
			
			if let section = sectionIndex {
				let index: Int = Int(section)
				let indexPath = assetGroupCollection[index].assets.firstIndex(where: {
					$0.localIdentifier == selectedAssetsID
				}).flatMap({
					IndexPath(row: $0, section: index)
				})
				
				if let existingIndexPath = indexPath {
					self.previouslySelectedIndexPaths.append(existingIndexPath)
				}
			}
		}
	}
	
	private func didSelectPreviouslyIndexPath() {
		
		guard isDeepCleaningSelectableFlow, !previouslySelectedIndexPaths.isEmpty else { return }
		
		for indexPath in previouslySelectedIndexPaths {
			self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
			self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: indexPath)
			
			if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
				cell.isSelected = true
				cell.checkIsSelected()
			}
			self.selectedAssets.append(self.assetGroups[indexPath.section].assets[indexPath.item])
		}
		checkForCelectedSection()
		handleSelectAssetsNavigationCount()
	}
	
	private func checkForCelectedSection() {
		
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
		collectionViewFlowLayout.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
		self.collectionView.prefetchDataSource = self
		
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
		collectionViewFlowLayout.fixedDivisionCount = 4
		collectionViewFlowLayout.itemSpacing = 0

		
		carouselCollectionFlowLayout.itemSize = CGSize(width: 80, height: 80)
		carouselCollectionFlowLayout.minimumLineSpacing = 0
		carouselCollectionFlowLayout.minimumInteritemSpacing = 0
		carouselCollectionFlowLayout.headerReferenceSize = CGSize.zero
		
		self.collectionView.collectionViewLayout = collectionViewFlowLayout
		self.collectionView.allowsMultipleSelection = true
		self.collectionView.reloadData()
	}
	
	private func configure(_ cell: PhotoCollectionViewCell, at indexPath: IndexPath) {
		
		cell.delegate = self
		cell.indexPath = indexPath
		cell.cellMediaType = self.mediaType
		cell.cellContentType = self.contentType
		cell.setupUI()
		cell.updateColors()
		cell.selectButtonSetup(by: self.mediaType)
		
		if let path = self.collectionView.indexPathsForSelectedItems, path.contains(indexPath) {
			cell.isSelected = true
		} else {
			cell.isSelected = false
		}
		
		cell.checkIsSelected()
		
        let asset = assetGroups[indexPath.section].assets[indexPath.row]
		self.photoManager.requestChacheImageForPhasset(asset) { image in
			cell.loadCellThumbnail(asset, image: image)
		}
	}
	
	public func hederConfigure(_ view: GroupedAssetsReusableHeaderView, at indexPath: IndexPath) {
		
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
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		guard !isCarouselViewMode else {
			return UICollectionReusableView()
		}
		
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
	
		/// if need select cell from custom cell-button and tap on cell need - return `false`
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
			//        #warning("TODO: hide temporary")
			//        self.changeFlowLayoutAndFocus(at: indexPath)
		return false
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
			//        self.lazyHardcoreCheckForSelectedItemsAndAssets()
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
}

	//  MARK: - flow with select deselect cell
extension GroupedAssetListViewController: PhotoCollectionViewCellDelegate {
	
	func didSelectCell(at indexPath: IndexPath) {
		if let cell = self.collectionView.cellForItem(at: indexPath) {
			if cell.isSelected {
				self.collectionView.deselectItem(at: indexPath, animated: true)
				cell.isSelected = false
				if self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
					self.selectedAssets = self.selectedAssets.filter({ $0 != self.assetGroups[indexPath.section].assets[indexPath.row]})
				}
			} else {
				self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
				cell.isSelected = true
				if !self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
					self.selectedAssets.append(self.assetGroups[indexPath.section].assets[indexPath.row])
				}
			}
			self.handleSelectAllButtonSection(indexPath)
			self.handleDeleteAssetsButton()
			self.handleSelectAssetsNavigationCount()
		}
	}
}

	//      MARK: - check selected index path cell
extension GroupedAssetListViewController {
	
		/// `didSelectAllAssets` select deselect all assets in section
		/// `getIndexPathInSectionWithoutFirst` - get all index path in section without first index
		/// `checkSelectedHeaderView` - check header for selected items when load and reuse
		/// `isSelectedSection` check if contains selected cell and current section
		/// `getSectionsCells` get all cell and current section
		/// `lazyHardcoreCheckForSelectedItemsAndAssets` hardcore check for lost index pathes and elements of array if they lost
		/// `handleSelected` set selected cells in section
	
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
	
	private func getIndexPathInSectionWithoutFirst(section: Int) -> [IndexPath] {
		let cellsCountInSection = self.collectionView.numberOfItems(inSection: section)
		return (1..<cellsCountInSection).map({IndexPath(item: $0, section: section)})
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
	
	private func onDeleteAllSelectedInSectionButtonTapped(for sectionHeader: GroupedAssetsReusableHeaderView, at indexPath: IndexPath) {
		
		let indexPathsOfSection = self.getIndexPathInSectionWithoutFirst(section: indexPath.section)
		let sectionCells = self.getSectionsCells(at: indexPathsOfSection)
		
		if !sectionCells.isEmpty {
			let selectedCells = sectionCells.filter({$0.isSelected})
			if !selectedCells.isEmpty {
		
				let changedGroup = assetGroups[indexPath.section]
				var phassets: [PHAsset] = []
				
				selectedCells.forEach { cell in
					if let index = collectionView.indexPath(for: cell) {
						phassets.append(changedGroup.assets[index.item])
					}
				}
				
				if !phassets.isEmpty {
					self.showDelecteConfirmAlert(for: phassets) { suxxess in
						
						phassets.forEach { asset in
							self.selectedAssets.removeAll(asset)
						}
						
						U.UI {
							if indexPathsOfSection.count == phassets.count {
						
								self.assetGroups.remove(at: indexPath.section)
								
								self.collectionView.performBatchUpdates {
									self.collectionView.deleteSections(IndexSet(integer: indexPath.section))
								} completion: { _ in
									UIView.performWithoutAnimation {
										self.collectionView.reloadData()
									}
									self.handleDeleteAssetsButton()
									self.handleSelectAssetsNavigationCount()
								}
							} else {
								var indexPathsSelectedSections: [IndexPath] = []
								
								selectedCells.forEach { cell in
									if let indexPath = self.collectionView.indexPath(for: cell) {
										indexPathsSelectedSections.append(indexPath)
									}
								}
								
								phassets.forEach { asset in
									self.assetGroups[indexPath.section].assets.removeAll(asset)
								}
								
								self.collectionView.performBatchUpdates {
									self.collectionView.deleteItems(at: indexPathsSelectedSections)
								} completion: { _ in
									UIView.performWithoutAnimation {
										self.collectionView.reloadData()
									}
									self.handleDeleteAssetsButton()
									self.handleSelectAssetsNavigationCount()
								}
							}
						}
					}
				}
			}
		}
	}
	
	private func lazyHardcoreCheckForSelectedItemsAndAssets() {
		
		guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return }
		
		if selectedItems.isEmpty, !self.selectedAssets.isEmpty {
			self.selectedAssets.removeAll()
		} else if !selectedItems.isEmpty, self.selectedAssets.isEmpty {
			selectedItems.forEach { indexPath in
				if !self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
					self.selectedAssets.append(self.assetGroups[indexPath.section].assets[indexPath.row])
				}
			}
		} else if !selectedItems.isEmpty, !self.selectedAssets.isEmpty {
			self.selectedAssets.removeAll()
			
			selectedItems.forEach { indexPath in
				if !self.selectedAssets.contains(self.assetGroups[indexPath.section].assets[indexPath.row]) {
					self.selectedAssets.append(self.assetGroups[indexPath.section].assets[indexPath.row])
				}
			}
		}
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
	
	private func handleStartingSelectableAssets() {
		guard isDeepCleaningSelectableFlow else { return }
		
		A.showSelectAllStarterAlert(for: mediaType) {
			self.shouldSelectAllAssetsInSections(false)
			self.bottomMenuHeightConstraint.constant = 0
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
			
			let calculatedBottomMenuHeight: CGFloat = bottomMenuHeight + U.bottomSafeAreaHeight - 5
			
				/// `collection`
			if isCarouselViewMode {
				optionalViewerHeightConstraint.constant = defaultContainerHeight - (carouselPreviewCollectionHeight + (!selectedAssets.isEmpty ?  calculatedBottomMenuHeight : 0))
			} else {
				optionalViewerHeightConstraint.constant = 0
			}
			
				/// `bottom menu`
			bottomMenuHeightConstraint.constant = !selectedAssets.isEmpty ? (calculatedBottomMenuHeight) : 0
			
			bottomButtonBarView.title("delete selected (\(selectedAssets.count))")
			
			self.collectionView.contentInset.bottom = !selectedAssets.isEmpty ? 20 : 10
			U.animate(0.5) {
				self.photoContentContainerView.layoutIfNeeded()
				self.view.layoutIfNeeded()
			}
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

extension GroupedAssetListViewController: SNCollectionViewLayoutDelegate {
//    MARK: TODO: set if 3 asset
    func scaleForItem(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, atIndexPath indexPath: IndexPath) -> UInt {
        if indexPath.row == 0 {
            return 2
        }
        return 1
    }
    
    func headerFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        return 55
    }
}


// MARK: -> refacotor after this line
#warning("check after line->")


//      MARK: - prefetching data source -
extension GroupedAssetListViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
		var fetchassets: [PHAsset] = []
		indexPaths.forEach { indexPath in
			fetchassets.append(assetGroups[indexPath.section].assets[indexPath.row])
		}
		self.photoManager.prefetchImagesForAsset(fetchassets)
        
//        U.UI { [weak self] in
//
//            guard let `self` = self, let _ = self.collectionView else { return }
//            guard self.splitAssetsNumberOfItems > 0 else { return }
//
//            if indexPaths.count <= self.splitAssetsNumberOfItems {
//
//                let scale = max(UIScreen.main.scale,2)
//                let targetSize = CGSize(width: U.screenWidth * scale, height: U.screenHeight * scale)
//
//                self.cacheImageManager.startCachingImages(for: self.splitAssets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
//            }
//        }
    }
}

//      MARK: - assets processing -
extension GroupedAssetListViewController {
	
    private func showDeleteConfirmAlert() {
        
        AlertManager.showDeletePhotoAssetsAlert {
            self.deleteSelectedAssets()
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

					self.assetGroups = self.assetGroups.filter({$0.assets.count != 1})
					
					if oldGropsValue != self.assetGroups.count {
						self.collectionView.deleteSections(IndexSet(integer: indexPath.section))
						self.assetGroups.remove(at: indexPath.section)
						self.smoothReloadData()
					} else {
						self.collectionView.performBatchUpdates {
							self.collectionView.deleteItems(at: [indexPath])
						} completion: { _ in
							UIView.performWithoutAnimation {
								self.collectionView.reloadData()
							}
							self.handleDeleteAssetsButton()
							self.handleSelectAssetsNavigationCount()
						}
					}
				}
			}
		}
	}
		
	private func showDelecteConfirmAlert(for assets: [PHAsset], completionHandler: @escaping (Bool) -> Void) {
		
		let deletePhassetOperation = photoManager.deleteSelectedOperation(assets: assets) { suxxess in
			if !suxxess {
				U.UI {
					ErrorHandler.shared.showDeleteAlertError(.errorDeletePhasset)
				}
			}
			completionHandler(suxxess)
		}
		AlertManager.showDeletePhotoAssetsAlert {
			self.photoManager.phassetProcessingOperationQueuer.addOperation(deletePhassetOperation)
		}
	}
	
    private func deleteSelectedAssets() {
        
        let identifiers = selectedAssets.map({$0.localIdentifier})
        
		let deletePhassetOperation = photoManager.deleteSelectedOperation(assets: selectedAssets) { success in
			U.UI {
				if success {
					for group in self.assetGroups {
						group.assets = group.assets.filter({!identifiers.contains($0.localIdentifier)})
					}
					self.assetGroups = self.assetGroups.filter({$0.assets.count != 1})
				}
				self.selectedAssets = []
				self.selectedSection = []
				self.smoothReloadData()
			}
		}
		
		photoManager.phassetProcessingOperationQueuer.addOperation(deletePhassetOperation)
    }

    private func createCellContextMenu(for asset: PHAsset, at indexPath: IndexPath) -> UIMenu {
        
        let fullScreenPreviewActionImage = I.systemItems.defaultItems.arrowUP.withTintColor(theme.titleTextColor).withRenderingMode(.alwaysTemplate)
        let setAsBestActionImage =         I.systemItems.defaultItems.star.withTintColor(theme.titleTextColor).withRenderingMode(.alwaysTemplate)
        let deleteActionImage =            I.systemItems.defaultItems.trashBin.withTintColor(theme.actionTintColor).withRenderingMode(.alwaysTemplate)
		
        let fullScreenPreviewAction = UIAction(title: "full screen preview", image: fullScreenPreviewActionImage) { _ in
            if asset.mediaType == .video {
                self.showVideoPreviewController(asset)
            } else {
//                self.showFullScreenAssetPreviewAndFocus(at: indexPath)
            }
        }
		
		let setAsBestAction = UIAction(title: "set as best", image: setAsBestActionImage) { _ in
			self.setAsBest(asset: asset, at: indexPath)
		}
        
		let deleteAssetAction = UIAction(title: "delete", image: deleteActionImage, attributes: .destructive) { _ in
			self.deleteAsset(at: indexPath)
        }
		
        if indexPath.row == 0 {
            return UIMenu(title: "", children: [fullScreenPreviewAction, deleteAssetAction])
        } else {
            return UIMenu(title: "", children: [fullScreenPreviewAction, setAsBestAction, deleteAssetAction])
        }
    }
	
	private func setAsBest(asset: PHAsset, at indexPath: IndexPath) {
        
		assetGroups[indexPath.section].assets.move(at: indexPath.row, to: 0)
		collectionView.performBatchUpdates {
			collectionView.moveItem(at: indexPath, to: IndexPath(row: 0, section: indexPath.section))
		} completion: { _ in
			UIView.performWithoutAnimation {
				self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
			}
		}
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
    
    private func showFullScreenAssetPreviewAndFocus(at indexPath: IndexPath) {
        self.changeFlowLayoutAndFocus(at: indexPath)
    }
    
    private func changeFlowLayoutAndFocus(at indexPath: IndexPath) {
        
        isCarouselViewMode = !isCarouselViewMode
        optionalViewerHeightConstraint.constant = isCarouselViewMode ? defaultContainerHeight - carouselPreviewCollectionHeight : 0
        photoPreviewContainerView.isHidden = !isCarouselViewMode
        
        self.collectionView.collectionViewLayout = isCarouselViewMode ? carouselCollectionFlowLayout : collectionViewFlowLayout
        
        let carouselEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: self.collectionView.frame.width / 2 - 30, bottom: 0, right: self.collectionView.frame.width / 2 - 30)
        let collectionEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        collectionView.contentInset = isCarouselViewMode ? carouselEdgeInsets : collectionEdgeInsets
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        if isCarouselViewMode {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//            let index = getSplitIndex(from: indexPath)
//            TODO: hide temporary preview
//            photoPreviewController.slideToPage(index: index) {
//                debugPrint("done")
//            }

        } else {
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: indexPath.section == 0 ? 0 : indexPath.section - 1), at: [.centeredVertically, .centeredHorizontally], animated: false)
        }
        
        if isCarouselViewMode {
//            if let image = assetGroups[indexPath.section].assets[indexPath.row].getImage {
//                #warning("TODO")
////                self.imageView.image = image
//            } else {
//                self.changeFlowLayoutAndFocus(at: indexPath)
//            }
            
        }
    }
    
    @objc func didBackActionChangeLayout() {
        
        if isCarouselViewMode {
            if let indexPath = focusedIndexPath {
                changeFlowLayoutAndFocus(at: indexPath)
            } else {
                changeFlowLayoutAndFocus(at: IndexPath(item: 0, section: 8))
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func splitAllAssetsForPreview() {
        
        for group in assetGroups {
            splitAssetsNumberOfItems += group.assets.count
            splitAssets.append(contentsOf: group.assets)
        }
    }
    
    private func getSplitIndex(from indexPath: IndexPath) -> Int {
        
        let asset = assetGroups[indexPath.section].assets[indexPath.row]
        if let index = splitAssets.firstIndex(where: {$0 == asset}) {
            return index
        }
        
        return 0
    }
 }

extension GroupedAssetListViewController: SelectDropDownMenuDelegate {
    
    func selectedItemListViewController(_ controller: DropDownMenuViewController, didSelectItem: DropDownMenuItems) {
        
        switch didSelectItem {
            case .changeLayout:
                self.changeFlowLayoutAndFocus(at: IndexPath(row: 0, section: 0))
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



//      MARK: - delegates flow - 

extension GroupedAssetListViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension GroupedAssetListViewController: PhotoPreviewDataSource {

    
    func item(at index: Int, isGroupedAssets: Bool) -> (PHAsset, UIImageView) {
        /// in grouped view controller isGrouped always true
    
        let assetFromSplitCollection = splitAssets[index]
        
        if let section = assetGroups.firstIndex(where: {$0.assets.contains(assetFromSplitCollection)}) {
            let group = assetGroups[section]
            
            if let index = group.assets.firstIndex(where: {$0 == assetFromSplitCollection}) {
                var imageView = UIImageView()
                let asset = group.assets[index]
                
                let indexPath = IndexPath(item: index, section: section)
                
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                    imageView = cell.photoThumbnailImageView
                }
                
                return (asset, imageView)
            }
        }
        return (PHAsset(), UIImageView())
    }

    func itemsCount() -> Int {
        return splitAssetsNumberOfItems
    }
}

extension GroupedAssetListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadPreviewImageThumb(isScrolling: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadPreviewImageThumb(isScrolling: false)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}
    
    func loadPreviewImageThumb(isScrolling: Bool) {
        
        guard isCarouselViewMode else { return }
//        let point = view.convert(self.collectionView.center, to: collectionView)
        
//        guard let indexPath = self.collectionView.indexPathForItem(at: point) else {return }
        
//        let asset = self.assetGroups[indexPath.section].assets[indexPath.row]
    
        if !isScrolling {
//            let index = self.getSplitIndex(from: indexPath)
//            TODO: hide temporary
//            photoPreviewController.slideToPage(index: index, completion: nil)
            
//            _ = photoPreviewController.pagingDataSource?.createViewController(at: index)
//            photoPreviewController.scrollToPage(at: index)
//            self.imageView.image = asset.getImage
//            photoPreviewController.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
//            photoPreviewController.scrollToImageView(at: indexPath)
        } else {
//            let index = self.getSplitIndex(from: indexPath)
//            photoPreviewController.slideToPage(index: index, completion: nil)
//            photoPreviewController.pageForward()
            
            //            self.imageView.image = asset.getImage
//            photoPreviewController.scrollToImageView(at: indexPath)
//            photoPreviewController.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
//            self.imageView.image = asset.getImage
//            self.imageManager?.requestImage(for: asset, targetSize: CGSize(width: U.screenWidth, height: U.screenHeight), contentMode: .aspectFill, options: nil) {result, info in
//                
//                debugPrint(result?.accessibilityIdentifier)
//                self.imageView.image = result
//                
//            }
        }
    }
    
    
//    private func updateCachedAssets() {
//
//        // The preheat window is twice the height of the visible rect.
//        var preheatRect = self.collectionView!.bounds
//        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
//
//        /*
//         Check if the collection view is showing an area that is significantly
//         different to the last preheated area.
//         */
////        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
////        if delta > self.collectionView!.bounds.height / 3.0 {
////
////            // Compute the assets to start caching and to stop caching.
////            var addedIndexPaths: [IndexPath] = []
////            var removedIndexPaths: [IndexPath] = []
////
////            self.computeDifferenceBetweenRect(oldRect: self.previousPreheatRect, andRect: preheatRect, removedHandler: {removedRect in
////                //                let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(removedRect)
////                let indexPath = self.collectionView.indexPathsForVisibleItems
////
////                removedIndexPaths += indexPaths
////            }, addedHandler: {addedRect in
////                let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(addedRect)
////                addedIndexPaths += indexPaths
////            })
////
//
//
////        for group in assetGroups {
////            all.append(contentsOf: group.assets)
////
////        }
//
//        self.imageManager?.allowsCachingHighQualityImages = true
//
//
////            let assetsToStartCaching = self.assetsAtIndexPaths(indexPaths: addedIndexPaths)
////            let assetsToStopCaching = self.assetsAtIndexPaths(indexPaths: removedIndexPaths)
//
//            // Update the assets the PHCachingImageManager is caching.
//        self.imageManager?.startCachingImages(for: all, targetSize: CGSize(width: U.screenWidth, height: U.screenHeight), contentMode: .aspectFill, options: nil)
//
//
//
//
////        self.imageManager?.stopCachingImages(for: all,
////                                                          targetSize: CGSize(width: U.screenWidth, height: U.screenHeight),
////                                                          contentMode: .aspectFill,
////                                                          options: nil)
//
////        }
//    }
    
    private func assetsAtIndexPaths(indexPaths: [NSIndexPath]) -> [PHAsset] {
        let  assets = indexPaths.map{self.assetGroups[$0.item].assets[$0.row]}
        return assets
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

extension GroupedAssetListViewController: Themeble {


    
    private func setupPhotoPreviewController() {
        
//        photoPreviewController.loadAssetsCollection(self.splitAssets)
//        photoPreviewController.currentIndex = 0
//        photoPreviewController.photoCount = splitAssetsNumberOfItems
//        photoPreviewController.photosDataSource = self
//        photoPreviewController.delegate = self
//        photoPreviewController.groupAssetsCollection = self.assetGroups
//        photoPreviewController.photoMediaContentType = self.mediaType
//        photoPreviewController.mediaContentTypeSetup()
//
//        self.addChild(photoPreviewController)
//        photoPreviewController.view.frame = photoPreviewContainerView.bounds
//        photoPreviewContainerView.addSubview(photoPreviewController.view)
//        photoPreviewController.didMove(toParent: self)
    }
}




extension UIPageViewController {

    func pageForward(animated: Bool = true, comletionHandler: ((Bool) -> Void)? = nil) {
        if let currentPageViewController = viewControllers?[0] {
            debugPrint("slide")
            
            if let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentPageViewController) {
                debugPrint("sliding")
                setViewControllers([nextPage], direction: .forward, animated: animated, completion: comletionHandler)
            }
        }
    }
    
    func pageBackward(animated: Bool = true, completionHandler: ((Bool) -> Void)? = nil) {
        
        if let currentPageViewController = viewControllers?[0] {
            debugPrint("slide")
            if let previousePage = dataSource?.pageViewController(self, viewControllerBefore: currentPageViewController) {
                debugPrint("sliding")
                setViewControllers([previousePage], direction: .reverse, animated: animated, completion: completionHandler)
            }
        }
    }
    
//    func scrollToPage(at index: Int, animated: Bool = true, completionHandler: ((Bool) -> Void)? = nil) {
//        if let viewController = viewControllers?[index] {
//            setViewControllers([viewController], direction: .reverse, animated: true, completion: completionHandler)
//
//        }
//    }
}
