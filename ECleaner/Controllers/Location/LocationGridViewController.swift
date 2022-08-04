//
//  LocationGridViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.08.2022.
//

import UIKit
import Photos

protocol LocationGridDelegate {
	
}

class LocationGridViewController: UIViewController {

	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var bottomButtonBarView: BottomButtonBarView!
	@IBOutlet weak var bottomButtonHeightConstraint: NSLayoutConstraint!
	
	private var phassetLocationViewModel: PHAssetLocationViewModel!
	private var phassetLocationGridDataSource: PHAssetLocationGridDataSource!
	
	private let flowLayout = SimpleColumnFlowLayout(cellsPerRow: 3,
													minimumInterSpacing: 0,
													minimumLineSpacing: 0,
													inset: UIEdgeInsets(top: 10, left: 4, bottom: 0, right: 4))
	private var previousPreheatRect: CGRect = CGRect()
	private var scrollView = UIScrollView()
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
	public var delegate: LocationGridDelegate?
	public var assetCollection: [PHAsset] = []
		
	init() {
		super.init(nibName: Constants.identifiers.xibs.location, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
	
		setupUI()
		updateColors()
		setupCollectionView()
		setupDelegate()
		handleSelectPHAssetsAppearButton(0, disableAnimation: true)
    }
}

extension LocationGridViewController {
	
	public func setupViewModel(with phassets: [PHAsset]) {
		
		self.phassetLocationViewModel = PHAssetLocationViewModel(phassets: phassets)
		self.phassetLocationGridDataSource = PHAssetLocationGridDataSource(phassetLocationViewModel: self.phassetLocationViewModel,
																		   mediaType: .locationPhoto,
																		   contentType: .userPhoto,
																		   collectionView: self.collectionView)
		self.collectionView.dataSource = self.phassetLocationGridDataSource
		self.collectionView.delegate = self.phassetLocationGridDataSource
		self.phassetLocationGridDataSource.collectionView = self.collectionView
		
		self.phassetLocationGridDataSource.didSelectDeleteLocation = { phassets in
			
		}
		
		self.phassetLocationGridDataSource.didSelectedPhassets = { phassets in
			if let phassets = phassets {
				self.handleSelectPHAssetsAppearButton(phassets.count, disableAnimation: true)
			}
		}
		self.handleSelectPHAssetsAppearButton(0, disableAnimation: true)
	}
	
	private func setupCollectionView() {
		
		flowLayout.isSquare = true
		flowLayout.itemHieght = ((U.screenWidth - 30) / 3) / U.ratio
		
		self.collectionView.register(UINib(nibName: C.identifiers.xibs.photoSimpleCell, bundle: nil), forCellWithReuseIdentifier: C.identifiers.cells.photoSimpleCell)
		self.collectionView.register(UINib(nibName: C.identifiers.xibs.locationHeader, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: C.identifiers.views.locationHeader)

		self.collectionView.collectionViewLayout = flowLayout
		self.collectionView.allowsMultipleSelection = true
		self.collectionView.contentInset.top = 20
	}
}

extension LocationGridViewController {
	
	private func handleSelectPHAssetsAppearButton(_ phassetsCount: Int, disableAnimation: Bool = false) {
		
		let calculatedBottomButtonHeight: CGFloat = AppDimensions.BottomButton.bottomBarDefaultHeight
		bottomButtonHeightConstraint.constant = phassetsCount == 0 ? 0 : calculatedBottomButtonHeight
		
		let buttonTitle: String = "remove locations".uppercased() + " (\(phassetsCount))"
		self.bottomButtonBarView.title(buttonTitle)
		
		if disableAnimation {
			self.bottomButtonBarView.layoutIfNeeded()
			self.collectionView.contentInset.bottom = phassetsCount != 0 ? calculatedBottomButtonHeight : U.bottomSafeAreaHeight
		} else {
			U.animate(1) {
				self.bottomButtonBarView.layoutIfNeeded()
				self.collectionView.contentInset.bottom = phassetsCount != 0 ? calculatedBottomButtonHeight : U.bottomSafeAreaHeight
			}
		}
		self.collectionView.layoutIfNeeded()
		self.view.layoutIfNeeded()
	}
}

extension LocationGridViewController: Themeble {
		
	func setupUI() {
		
		self.scrollView.delegate = self
		bottomButtonBarView.setImage(UIImage(systemName: "mappin.and.ellipse")!)
	}
	
	func updateColors() {
		
		self.view.backgroundColor = theme.backgroundColor
		self.collectionView.backgroundColor = .clear
		
		bottomButtonBarView.buttonTintColor = theme.activeTitleTextColor
		bottomButtonBarView.buttonColor = theme.photoTintColor
		bottomButtonBarView.updateColorsSettings()
	}
	
	private func setupDelegate() {
		
		bottomButtonBarView.delegate = self
	}
}

extension LocationGridViewController: BottomActionButtonDelegate {
	
	func didTapActionButton() {
		
	}
}

extension LocationGridViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateCachedAssets()
	}
}

extension LocationGridViewController {
	
	private func updateCachedAssets() {
		
		guard isViewLoaded && view.window != nil else { return }
		
		let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
		let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
		
		let delta = abs(preheatRect.midY - previousPreheatRect.midY)
		guard delta > view.bounds.height / 3 else { return }
		
		let (addedRects, removedRects) = Utils.LayoutManager.differencesBetweenRects(previousPreheatRect, preheatRect)
		let addedAssets = addedRects
			.flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
			.compactMap { indexPath in self.assetCollection[indexPath.row] }
		let _ = removedRects
			.flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
			.compactMap { indexPath in self.assetCollection[indexPath.row] }
		
		prefetchCacheImageManager.startCachingImages(for: addedAssets, targetSize: self.phassetLocationGridDataSource.thumbnailSize, contentMode: .aspectFill, options: nil)
		previousPreheatRect = preheatRect
	}
	
	private func resetCachedAssets() {
		prefetchCacheImageManager.stopCachingImagesForAllAssets()
		previousPreheatRect = .zero
	}
}
