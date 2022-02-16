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
	var scrollView = UIScrollView()
	
	private let carouselCollectionFlowLayout = CarouselFlowLayout()
	private let previewColletionFlowLayput = PreviewCarouselFlowLayout()
	

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
		

		self.previewColletionFlowLayput.itemSize = CGSize(width: U.screenWidth - 20, height: U.screenHeight / 2)
		self.previewColletionFlowLayput.scrollDirection = .horizontal
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
	
	
	private func setupDelegate() {
		
		navigationBar.delegate = self
		scrollView.delegate = self
	}
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
		self.collectionView.backgroundColor = theme.backgroundColor
		self.previewCollectionView.backgroundColor = theme.backgroundColor
	}
}

extension MediaViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if scrollView == self.collectionView {
//			handleScrollItem(with: self.collectionView)
//			self.scrollCell()
			let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
			let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.maxY)
	
			if let visibleIndexPath = self.collectionView.indexPathForItem(at: visiblePoint) {
				
				debugPrint(visibleIndexPath)
				self.previewCollectionView.scrollToItem(at: visibleIndexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
			}
		} else if scrollView == self.previewCollectionView {
			
			
//			let offSet = scrollView.contentOffset.x
//			  let width = scrollView.frame.width
//			  let horizontalCenter = width / 2
//
//			debugPrint(Int(offSet + horizontalCenter) / Int(width))
//				.currentPage =
			let visibleRect = CGRect(origin: self.previewCollectionView.contentOffset, size: self.previewCollectionView.bounds.size)
			let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
			if let visibleIndexPath = self.previewCollectionView.indexPathForItem(at: visiblePoint) {
				self.collectionView.scrollToItem(at: visibleIndexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
			}
			
//			let visibleRect = CGRect(origin: self.cvImageListing.contentOffset, size: self.cvImageListing.bounds.size)
//				let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//				if let visibleIndexPath = self.cvImageListing.indexPathForItem(at: visiblePoint) {
//					self.pageControl.currentPage = visibleIndexPath.row
//				}

//
			
//			let x = scrollView.panGestureRecognizer.translation(in: collectionView).x / 2
//
//			debugPrint(x)
//		   debugPrint(self.view.frame.origin.x - x)
//			let z = collectionView.contentOffset.x + x
//			let r = CGRect(x: z, y: 0, width: 100, height: 100)
			//			collectionView.scrollRectToVisible(r, animated: true);
//			collectionView.scrollRectToVisible(r, animated: true)
//				self.handleScrollItem(with: self.previewCollectionView)
//			if x > 90 {
//				collectionView.scrollToNextItem()
//			} else {
//				collectionView.scrollToPreviousItem()
//			}
			
		}
//		debugPrint("scrollViewDidScroll")
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		if scrollView == self.collectionView {
			handleScrollItem(with: self.collectionView)
		} else if scrollView == self.previewCollectionView {
			handleScrollItem(with: self.previewCollectionView)
		}

		debugPrint("decel")
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//		if !decelerate {
//			debugPrint("scroll to item")
//		}
		debugPrint("end")
	}
	

	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		
//		debugPrint(scrollView.contentOffset.x)
		debugPrint("begin")
		
		if scrollView == self.collectionView {
//			handleScrollItem(with: self.collectionView)
//			self.scrollCell()
//			let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
//			let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.maxY)
//
//			if let visibleIndexPath = self.collectionView.indexPathForItem(at: visiblePoint) {
			self.handleScrollItem(with: self.collectionView)
//				debugPrint(visibleIndexPath)
//				self.previewCollectionView.scrollToItem(at: visibleIndexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
//			}
		} else if scrollView == self.previewCollectionView {
			self.handleScrollItem(with: self.previewCollectionView)
			
//			let offSet = scrollView.contentOffset.x
//			  let width = scrollView.frame.width
//			  let horizontalCenter = width / 2
//
//			debugPrint(Int(offSet + horizontalCenter) / Int(width))
////				.currentPage =
//			let visibleRect = CGRect(origin: self.previewCollectionView.contentOffset, size: self.previewCollectionView.bounds.size)
//			let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//			if let visibleIndexPath = self.previewCollectionView.indexPathForItem(at: visiblePoint) {
//				self.collectionView.scrollToItem(at: visibleIndexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
//			}
		}
		
		
	}
	
	func scrollCell() {

		let cellSize = CGSize(width: U.screenWidth - 20, height: U.screenHeight / 2)
		let contentOffset = previewCollectionView.contentOffset
		
//		debugPrint(previewCollectionView.contentSize.width)
//		debugPrint(previewCollectionView.contentOffset.x)
		
		
		
		

//		if previewCollectionView.contentSize.width <= previewCollectionView.contentOffset.x + cellSize.width
//		{
//			let r = CGRect(x: 0, y: contentOffset.y, width: 150, height: 150)
//			collectionView.scrollRectToVisible(r, animated: true)
//
//		} else {
//			let r = CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: 150, height: 150)
//			collectionView.scrollRectToVisible(r, animated: true);
//		}
		


	}
}

extension MediaViewController {
	
	func handleScrollItem(with collectionView: UICollectionView) {
		let newIndexPath = calculateCurrentIndexPath(for: collectionView)
		
		if collectionView == previewCollectionView {
			automaticScroll(collectionView: self.collectionView, to: newIndexPath, with: true)
		} else if collectionView == self.collectionView {
			automaticScroll(collectionView: previewCollectionView, to: newIndexPath, with: false)
		}
	}
	
	func calculateCurrentIndexPath(for collectionView: UICollectionView) -> IndexPath? {
		
		let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
		if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
			return visibleIndexPath
		}
		return nil
	}

	func automaticScroll(collectionView: UICollectionView, to indexPath: IndexPath?, with animated: Bool) {
		
		guard let newIndexPath = indexPath  else { return }

			collectionView.scrollToItem(at: newIndexPath, at: [.centeredHorizontally, .centeredVertically], animated: animated)
	}
	
	func automaticMoveScroll() {
		
	}
 }


