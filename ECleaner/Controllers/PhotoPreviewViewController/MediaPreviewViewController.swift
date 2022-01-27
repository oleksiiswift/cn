//
//  MediaPreviewViewController.swift
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

class MediaPreviewViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: NavigationBar!
	@IBOutlet weak var previewContainerView: UIView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	var scrollView = UIScrollView()
	private let carouselCollectionFlowLayout = ZoomAndSnapFlowLayout()
	private var previousPreheatRect: CGRect = CGRect()
	
	private var photoManager = PhotoManager.shared
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
	
	public var focusedIndexPath: IndexPath?
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

extension MediaPreviewViewController {
	
	private func animatePresentViewController() {
		
		self.view.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
		U.animate(0.5) {
			self.view.transform = CGAffineTransform.identity
		}
	}
	
	private func startedScroll(indexPath: IndexPath) {
		U.UI {
			self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: false)
		}
	}
}

extension MediaPreviewViewController: NavigationBarDelegate {
	
	func didTapLeftBarButton(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: false)
	}
	
	func didTapRightBarButton(_ sender: UIButton) {}
	
	
}

extension MediaPreviewViewController  {
	
	private func setupCollectionView() {
		
		self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell,
										   bundle: nil),
									 forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
		
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
		self.collectionView.prefetchDataSource = self
//		self.collectionView.contentInset = UIEdgeInsets(top: 0, left: self.collectionView.frame.width / 2 - 30, bottom: 0, right: self.collectionView.frame.width / 2 - 30)
		carouselCollectionFlowLayout.itemSize = CGSize(width: 120, height: 120)
		carouselCollectionFlowLayout.minimumLineSpacing = 0
		carouselCollectionFlowLayout.minimumInteritemSpacing = 0
		carouselCollectionFlowLayout.headerReferenceSize = CGSize.zero
		self.collectionView.showsVerticalScrollIndicator = false
		self.collectionView.showsHorizontalScrollIndicator = false
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

extension MediaPreviewViewController: PhotoCollectionViewCellDelegate {
	
	func didSelectCell(at indexPath: IndexPath) {}
}

extension MediaPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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
	
	
}

extension MediaPreviewViewController: UICollectionViewDataSourcePrefetching {
	
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
	}
	
	private func updateCachedAssets() {
		
		guard isViewLoaded && view.window != nil else { return }
		
		let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
		let preheatRect = visibleRect.insetBy(dx: -0.5 * visibleRect.width, dy: 0)
		
		let delta = abs(preheatRect.midX - previousPreheatRect.midX)
		guard delta > view.bounds.width / 3 else { return }
		
		
		let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
		let addedAssets = addedRects
			.flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
			.compactMap { indexPath in collectionType == .grouped ? self.assetGroups[indexPath.section].assets[indexPath.item] : self.assetCollection[indexPath.item] }
		let removedAssets = removedRects
			.flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
			.compactMap { indexPath in  collectionType == .grouped ? self.assetGroups[indexPath.section].assets[indexPath.item] : self.assetCollection[indexPath.item] }
		
		let options = PHImageRequestOptions()
		options.isNetworkAccessAllowed = true
		let size = CGSize(width: 300, height: 300)
		debugPrint("added assets \(addedAssets)")
		debugPrint("removed assets \(removedAssets)")
		
		prefetchCacheImageManager.startCachingImages(for: addedAssets, targetSize: size, contentMode: .aspectFill, options: options)
		prefetchCacheImageManager.stopCachingImages(for: removedAssets, targetSize: size, contentMode: .aspectFill, options: options)
		previousPreheatRect = preheatRect
	}
	
	private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
	   if old.intersects(new) {
		   var added = [CGRect]()
		   if new.maxX > old.maxX {
			   added += [CGRect(x: new.origin.x, y: old.maxY,
//								width: new.width, height: new.maxY - old.maxY)]
								width: new.maxX - old.maxX, height: new.height)]
		   }
		   if old.minX > new.minX {
			   added += [CGRect(x: new.origin.x, y: new.minY,
								width: new.width, height: old.minY - new.minY)]
		   }
		   var removed = [CGRect]()
		   if new.maxX < old.maxX {
			   removed += [CGRect(x: new.origin.x, y: new.maxY,
								  width: new.width, height: old.maxY - new.maxY)]
		   }
		   if old.minX < new.minX {
			   removed += [CGRect(x: new.origin.x, y: old.minY,
								  width: new.width, height: new.minY - old.minY)]
		   }
		   return (added, removed)
	   } else {
		   return ([new], [old])
	   }
   }
}


extension MediaPreviewViewController: Themeble {

	private func setupUI() {
		
	}
	
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
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
		self.previewContainerView.backgroundColor = theme.backgroundColor
		self.collectionView.backgroundColor = theme.backgroundColor
	}
}

extension MediaPreviewViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateCachedAssets()
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		debugPrint("scrollViewDidEndDecelerating")
	}
	
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		debugPrint("scrollViewDidEndScrollingAnimation")
	}
	
	
}
