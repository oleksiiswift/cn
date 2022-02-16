//
//  PreviewDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 30.01.2022.
//

import UIKit
import Photos

protocol PreviewPageProtocol {
	var index: Int { get set }
	var delegate: PreviewPageDelegate? { get set }
	var mainView: UIView { get }
	var image: UIImage? { get }
	
}

protocol PreviewDataSource {
	func item(at index: Int, collectionType: CollectionType) -> (PHAsset, UIImageView)
	func itemsCount() -> Int
}

protocol PreviewPageDelegate: AnyObject {
	func previewControllerDidAppear(_ controller: PreviewPageProtocol)
	func previewControllerWillDisappear(_ controller: PreviewPageProtocol)
	func previewControllerDidPanned(_ recognizer: UIPanGestureRecognizer, view: UIView)
}

class PreviewPagingDataSource: NSObject, UIPageViewControllerDataSource {
	
	private var itemsDataSource: PreviewDataSource?
	public var pageControllerDelegate: PreviewPageDelegate?
	private var collectionType: CollectionType = .none
	private let fetchingPhassetQueue = OperationServiceQueue()
	
	private var itemsCount: Int {
		return itemsDataSource?.itemsCount() ?? 0
	}
	
	init(dataSource: PreviewDataSource, collectionType: CollectionType) {
		self.itemsDataSource = dataSource
		self.collectionType = collectionType
	}
	
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let currentController = viewController as? PreviewPageViewController, itemsCount > 1 else { return nil}
		
		let previousIndex = (currentController.currentIndex == 0) ? itemsCount - 1 : currentController.currentIndex - 1
		return self.createViewController(at: previousIndex)
		
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		guard let currentController = viewController as? PreviewPageViewController, itemsCount > 1 else { return nil}
		let nextIndex = (currentController.currentIndex == itemsCount - 1) ? 0 : currentController.currentIndex + 1
		return self.createViewController(at: nextIndex)
		
	}
}

extension PreviewPagingDataSource {
	
	public func createViewController(at index: Int) -> UIViewController {
		
		guard let dataSource = self.itemsDataSource else { return UIViewController() }
		
		guard let asset = itemsDataSource?.item(at: index, collectionType: self.collectionType).0 else { return UIViewController()}
		
		let viewController = PreviewViewController(index: index, itemsCount: dataSource.itemsCount(), asset: asset, fetchingQueue: self.fetchingPhassetQueue)
		viewController.delegate = pageControllerDelegate
		return viewController
	}
}
