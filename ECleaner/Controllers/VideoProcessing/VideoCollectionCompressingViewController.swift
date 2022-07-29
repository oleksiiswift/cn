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
	@IBOutlet weak var navigationControllerHeightConstraint: NSLayoutConstraint!

	var scrollView = UIScrollView()
	private var videoCollectionViewModel: VideoCollectionViewModel!
	private var videoCollectionDataSource: VideoCollectionDataSource!
	
	private let flowLayout = SimpleColumnFlowLayout(cellsPerRow: 2,
													minimumInterSpacing: 0,
													minimumLineSpacing: 0,
													inset: UIEdgeInsets(top: 10, left: 4, bottom: 0, right: 4))
	
	private var previousPreheatRect: CGRect = CGRect()
	private var bottomMenuHeight: CGFloat = 80

	private var sortingType: SortingType = .date
	private var photoManager = PhotoManager.shared
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
	public var mediaType: PhotoMediaType = .none
	public var contentType: MediaContentType = .none
	
	public var assetCollection: [PHAsset] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        setupUI()
		setupDataSource(with: self.sortingType)
		updateColors()
		setupNavigation()
		setupDelegate()
		setupCollectionView()
		setupSortDescriptionMenu()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateCachedAssets()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		S.lastSavedLocalIdenifier = nil
	}
}

extension VideoCollectionCompressingViewController {
	
	private func setupDataSource(with sort: SortingType) {
		
		self.videoCollectionViewModel = VideoCollectionViewModel(phassets: self.assetCollection)
		self.videoCollectionDataSource = VideoCollectionDataSource(videoCollectionViewModel: self.videoCollectionViewModel,
																   mediaType: self.mediaType,
																   contentType: self.contentType,
																   collectionView: self.collectionView)
		
		self.collectionView.dataSource = self.videoCollectionDataSource
		self.collectionView.delegate = self.videoCollectionDataSource
	}
}

extension VideoCollectionCompressingViewController {
	
	private func getVideoSorted(with key: SortingType) {
		
		guard self.sortingType != key else { return }
		
		self.sortingType = key
		
		self.photoManager.getVideoCollection(with: self.sortingType.descriptorKey) { phassets in
			self.assetCollection = phassets
			self.setupDataSource(with: self.sortingType)
			self.collectionView.setContentOffset(.zero, animated: false)
		}

		self.setupSortDescriptionMenu()
	}
	
	private func openSotedMenu() {
		if #available(iOS 14.0, *) {} else {
			let menuItems = self.performPopUpDescriptorMenu()
			self.presentDropDonwMenu(with: menuItems, from: self.navigationBar.rightBarButtonItem)
		}
	}
	
	private func presentDropDonwMenu(with items: [MenuItem], from navigationButton: UIButton) {
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

extension VideoCollectionCompressingViewController: SelectDropDownMenuDelegate {
	
	func handleDropDownMenu(_ item: MenuItemType) {
		switch item {
			case .sortByDate:
				self.getVideoSorted(with: .date)
			case .sortBySize:
				self.getVideoSorted(with: .size)
			case .sortByDimension:
				self.getVideoSorted(with: .dimension)
			case .sortByEdit:
				self.getVideoSorted(with: .edit)
			case .duration:
				self.getVideoSorted(with: .duration)
			default:
				return
		}
	}
}

extension VideoCollectionCompressingViewController {
	
	private func handleBottomButton() {}
}

extension VideoCollectionCompressingViewController {
		
	private func setupCollectionView() {
		
		flowLayout.isSquare = true
		flowLayout.itemHieght = ((U.screenWidth - 30) / 3) / U.ratio
		
		self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
		
		self.collectionView.collectionViewLayout = flowLayout
		self.collectionView.allowsMultipleSelection = false
		self.collectionView.contentInset.top = 20
	}
}

extension VideoCollectionCompressingViewController: VideoCollectionDataSourceDelegate {
	
	func handleSelectPHAsset(at indexPath: IndexPath) {
		
		guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return }
		
		self.bottomMenuHeightConstraint.constant = selectedItems.count > 0 ? (bottomMenuHeight + U.bottomSafeAreaHeight - 5) : 0
		self.collectionView.contentInset.bottom = selectedItems.count > 0 ? 70 + U.bottomSafeAreaHeight : 5
		if let selectedItem = selectedItems.first {
			let phasset = self.assetCollection[selectedItem.row]
			
			let size = phasset.imageSize
			let stringSize = U.getSpaceFromInt(size)
			bottomButtonView.title("\(LocalizationService.Buttons.getButtonTitle(of: .compres)) \(stringSize)")
		}
		
		U.animate(0.5) {
			self.collectionView.layoutIfNeeded()
			self.view.layoutIfNeeded()
		}
	}
	
	func showComressionViewController(with indexPath: IndexPath) {
		let phasset = self.videoCollectionViewModel.getPhasset(at: indexPath)
		let storyboard = UIStoryboard(name: C.identifiers.storyboards.videoProcessing, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: C.identifiers.viewControllers.videoCompressing) as!
		VideoCompressingViewController
		viewController.processingPHAsset = phasset
		viewController.updateCollectionWithNewCompressionPHAssets = { phassetCollection in
			self.assetCollection = phassetCollection
			self.collectionView.smoothReloadData()
		}
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	func share(phasset: PHAsset) {
		ShareManager.shared.shareVideoFile(from: phasset) {}
	}
}

extension VideoCollectionCompressingViewController {

	@available(iOS 14.0, *)
	private func performSordDescriptionMenu() {
		
		var actions: [UIAction] = []
		
		SortingType.allCases.forEach { key in
			let action = UIAction(title: key.title,
								  image: key.image,
								  state: self.sortingType == key ? .on : .off) { _ in
				self.getVideoSorted(with: key)
			}
			actions.append(action)
		}
		self.navigationBar.rightBarButtonItem.showsMenuAsPrimaryAction = true
		self.navigationBar.rightBarButtonItem.menu = UIMenu(title: "", children: actions)
	}
	
	private func performPopUpDescriptorMenu() -> [MenuItem]{
		
		let dateItem: MenuItem = .init(type: .sortByDate, selected: true, checkmark: self.sortingType == .date)
		let sizeItem: MenuItem = .init(type: .sortBySize, selected: true, checkmark: self.sortingType == .size)
		let dimensionItem: MenuItem = .init(type: .sortByDimension, selected: true, checkmark: self.sortingType == .dimension)
		let editItem: MenuItem = .init(type: .sortByEdit, selected: true, checkmark: self.sortingType == .edit)
		let durationItem: MenuItem = .init(type: .duration, selected: true, checkmark: self.sortingType == .duration)
		return [dateItem, sizeItem, dimensionItem, editItem, durationItem]
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
		
		prefetchCacheImageManager.startCachingImages(for: addedAssets, targetSize: self.videoCollectionDataSource.thumbnailSize, contentMode: .aspectFill, options: nil)
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
	
	func didTapRightBarButton(_ sender: UIButton) {
		self.openSotedMenu()
	}
}

extension VideoCollectionCompressingViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		
		guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else { return }
		
		showComressionViewController(with: selectedIndexPath)
	}
}

extension VideoCollectionCompressingViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateCachedAssets()
	}
}

extension VideoCollectionCompressingViewController {
	
	private func setupUI() {
		
		self.navigationControllerHeightConstraint.constant = AppDimensions.NavigationBar.navigationBarHeight
		self.bottomMenuHeightConstraint.constant = 0
		self.bottomButtonView.setImage(I.systemItems.defaultItems.compress, with: CGSize(width: 24, height: 22))
	}
	
	private func setupNavigation() {
		
		self.navigationBar.setupNavigation(title: self.mediaType.mediaTypeName,
										   leftBarButtonImage: I.systemItems.navigationBarItems.back,
										   rightBarButtonImage: UIImage(systemName: "arrow.up.arrow.down"),
										   contentType: self.contentType,
										   leftButtonTitle: nil,
										   rightButtonTitle: nil)
	}
	
	private func setupSortDescriptionMenu() {
		
		if #available(iOS 14.0, *) {
			self.performSordDescriptionMenu()
		}
	}
	
	private func setupDelegate() {
		
		self.navigationBar.delegate = self
		self.bottomButtonView.delegate = self
		self.scrollView.delegate = self
		self.videoCollectionDataSource.delegate = self
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

extension VideoCollectionCompressingViewController: UIPopoverPresentationControllerDelegate {
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
}
