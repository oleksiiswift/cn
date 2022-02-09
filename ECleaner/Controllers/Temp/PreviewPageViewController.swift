//
//  PreviewPageViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 30.01.2022.
//

import UIKit
import Photos

class PreviewPageViewController: UIPageViewController {
	
	private var prefetchManager = PhotoManager.shared.prefetchManager
	
	private var loadedViewControllers: [UIViewController] = []
	private var initialViewController: PreviewPageProtocol?
	public var pagingDataSource: PreviewPagingDataSource?
	public var previewDataSoruce: PreviewDataSource?
	
	public var collectionType: CollectionType = .none
	public var mediaContentType: PhotoMediaType = .none
	public var groupAssetsCollection: [PhassetGroup] = []
	public var assetCollection: [PHAsset] = []
	
	public var currentIndex: Int = 0
	public var assetsCount: Int = 0

	override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
		super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupDelegate()
		dataSourceSetup()
        
    }
}

extension PreviewPageViewController {
	
	private func setupDelegate() {
		
		pagingDataSource?.pageControllerDelegate = self
	}
	
	
	private func dataSourceSetup() {
		
		guard let dataSource = previewDataSoruce else { return }
		
		self.pagingDataSource = PreviewPagingDataSource(dataSource: dataSource, collectionType: self.collectionType)
		
		guard let initialViewController = pagingDataSource?.createViewController(at: currentIndex) else { return }
		
		self.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
		
		self.initialViewController = initialViewController as? PreviewPageProtocol
		self.dataSource = pagingDataSource
	}
}

extension PreviewPageViewController: PreviewPageDelegate {
	
	func previewControllerDidAppear(_ controller: PreviewPageProtocol) {
		debugPrint("previewControllerDidAppear")
	}
	
	func previewControllerWillDisappear(_ controller: PreviewPageProtocol) {
		debugPrint("previewControllerWillDisappear")
	}
	
	func previewControllerDidPanned(_ recognizer: UIPanGestureRecognizer, view: UIView) {
		debugPrint("previewControllerDidPanned")
	}
}

