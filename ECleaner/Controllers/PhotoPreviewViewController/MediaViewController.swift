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
	@IBOutlet weak var previewContainerView: UIView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	private var previewPageViewController = PreviewPageViewController()
	
	@IBOutlet weak var previewCollectionView: UICollectionView!
	var scrollView = UIScrollView()
	private let carouselCollectionFlowLayout = CarouselFlowLayout()
	private let previewColletionFlowLayput = PreviewCarouselFlowLayout()
	

	private var previousPreheatRect: CGRect = CGRect()
	
	private var photoManager = PhotoManager.shared
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
	
	public var focusedIndexPath: IndexPath?
	public var focusedPageIndex: Int?
	
	public var collectionType: CollectionType = .none
	public var assetCollection: [PHAsset] = []
	public var assetGroups: [PhassetGroup] = []
	public var mediaType: PhotoMediaType = .none
	public var contentType: MediaContentType = .none

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupUI()
		setupCollectionView()
//		setupPreviewController()
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

extension MediaViewController {
	
	private func animatePresentViewController() {
		
		self.view.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
		U.animate(0.5) {
			self.view.transform = CGAffineTransform.identity
		}
	}
	
	private func startedScroll(indexPath: IndexPath) {
		U.UI {
			self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: false)
			self.previewCollectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: false)
		}
	}
}

extension MediaViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: false)
	}
	
	func didTapRightBarButton(_ sender: UIButton) {}
}

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
		
//		let layout = UICollectionViewFlowLayout()
//		   layout.minimumInteritemSpacing = 0.0
//		   layout.minimumLineSpacing = 20.0
//		layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height / 2)
//
//		layout.scrollDirection = .horizontal
//		previewCollectionView.contentOffset = CGPoint(x: 20, y: 20)

		self.previewColletionFlowLayput.itemSize = CGSize(width: U.screenWidth - 20, height: U.screenHeight / 2)
		self.previewColletionFlowLayput.scrollDirection = .horizontal
//		self.previewColletionFlowLayput.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
		self.previewColletionFlowLayput.minimumInteritemSpacing = 20
		self.previewColletionFlowLayput.minimumLineSpacing = 200
		self.previewColletionFlowLayput.headerReferenceSize = .zero
		
		
		
		

		previewCollectionView.collectionViewLayout = previewColletionFlowLayput

		
		
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
		self.collectionView.prefetchDataSource = self
		self.collectionView.showsVerticalScrollIndicator = false
		self.collectionView.showsHorizontalScrollIndicator = false
		self.collectionView.contentInset = .zero
		
		self.carouselCollectionFlowLayout.itemSize = CGSize(width: 150, height: 150)
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
		cell.cellMediaType = self.mediaType
		cell.cellContentType = self.contentType
		cell.loadCellThumbnail(asset, imageManager: self.prefetchCacheImageManager)
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
}

extension MediaViewController: PhotoCollectionViewCellDelegate {
	
	func didSelectCell(at indexPath: IndexPath) {}
}

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

extension MediaViewController: UICollectionViewDataSourcePrefetching {
	
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		debugPrint(indexPaths)
		let phassets = requestPhassets(for: indexPaths)
		let size = CGSize(width: 300, height: 300)
		let options = PHImageRequestOptions()
		options.isNetworkAccessAllowed = true
		prefetchCacheImageManager.startCachingImages(for: phassets, targetSize: size, contentMode: .aspectFill, options: options)
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		let phassets = requestPhassets(for: indexPaths)
		let size = CGSize(width: 300, height: 300)
		let options = PHImageRequestOptions()
		options.isNetworkAccessAllowed = true
		prefetchCacheImageManager.stopCachingImages(for: phassets, targetSize: size, contentMode: .aspectFill, options: options)
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


extension MediaViewController: Themeble {

	private func setupUI() {}
	
	private func setupNavigationBar() {
		
		navigationBar.setupNavigation(title: mediaType.mediaTypeName,
									  leftBarButtonImage: I.systemItems.navigationBarItems.back,
									  rightBarButtonImage: nil,
									  contentType: contentType,
									  leftButtonTitle: nil,
									  rightButtonTitle: nil)
	}
	
	private func setupPreviewController() {
		
		previewPageViewController.delegate = self
		if let indexPath = self.focusedIndexPath {
			let index = getCurrentIndex(of: indexPath)
			previewPageViewController.currentIndex = index
		}
		previewPageViewController.groupAssetsCollection = self.assetGroups
		previewPageViewController.assetCollection = self.assetCollection
		previewPageViewController.collectionType = self.collectionType
		previewPageViewController.assetsCount = splitPhassetsForPreview().count
		previewPageViewController.previewDataSoruce = self
		
		
		self.addChild(previewPageViewController)
		previewPageViewController.view.frame = previewContainerView.bounds
		previewContainerView.addSubview(previewPageViewController.view)
		previewPageViewController.didMove(toParent: self)
	}
	
	private func splitPhassetsForPreview() -> [PHAsset] {
		
		switch collectionType {
			case .single:
				return assetCollection
			case .grouped:
				let assets = assetGroups.flatMap({$0.assets})
				return assets
			case .none:
				return []
		}
	}
	
	private func setupDelegate() {
		
		navigationBar.delegate = self
		scrollView.delegate = self
	}
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
		self.previewContainerView.backgroundColor = theme.backgroundColor
		self.collectionView.backgroundColor = theme.backgroundColor
	}
}

extension MediaViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
//		updateCachedAssets()
//		debugPrint(" ->  \(getCurrentPage())")
		if scrollView == self.collectionView {
			debugPrint("collection view")
		} else if scrollView == self.previewCollectionView {
			debugPrint("previerw collection view")
		}
	}
	
	
	
	
	
	
	
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		debugPrint("scrollViewDidEndScrollingAnimation")
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//		scrollToNearestVisibleCollectionViewCell()
		debugPrint("end decelarating")
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
//			scrollToNearestVisibleCollectionViewCell()
			
			debugPrint("scroll to item")
		}
		
		
	}
	
	func getCurrentPage() -> Int {
		let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
		if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
			return visibleIndexPath.row
		}
		
		return 0
	}
	


}

extension MediaViewController: UIPageViewControllerDelegate {
	


	
}


extension MediaViewController: PreviewDataSource {
	
	func item(at index: Int, collectionType: CollectionType) -> (PHAsset, UIImageView) {
		
		let assetFromCollection = splitPhassetsForPreview()[index]
		
		if let section = assetGroups.firstIndex(where: {$0.assets.contains(assetFromCollection)}) {
			let group = assetGroups[section]
			
			if let index = group.assets.firstIndex(where: {$0 == assetFromCollection}) {
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
		return splitPhassetsForPreview().count
	}

	func getCurrentIndex(of indexPath: IndexPath) -> Int {
	
		switch collectionType {
			case .single:
				return indexPath.row
			case .grouped:
				let assetFromCollection = assetGroups[indexPath.section].assets[indexPath.row]
				let assets = splitPhassetsForPreview()
				let index = assets.firstIndex(where: {$0.localIdentifier == assetFromCollection.localIdentifier})
				if let index = index {
					
					return index
				}
			case .none:
				return 0
				
		}
		
		return 0
	}

}


