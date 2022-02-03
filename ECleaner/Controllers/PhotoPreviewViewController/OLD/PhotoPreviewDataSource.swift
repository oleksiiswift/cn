//
//  PhotoPreviewDataSourceOLD.swift
//  ECleaner
//
//  Created by alekseii sorochan on 20.07.2021.
//

import UIKit
import Photos

protocol PhassetPreviewPageProtocolOLD {
    var index: Int { get set }
    var delegate: PhassetPreviewPageDelegateOLD? { get set }
    var mainView: UIView { get }
    var image: UIImage? { get}
}

protocol PhassetPreviewPageDelegateOLD: AnyObject {
    func photoPreviewControllerDidAppear(_ controller: PhassetPreviewPageProtocolOLD)
    func photoPreviewControllerWillDisapper(_ controller: PhassetPreviewPageProtocolOLD)
    func photoPrevireDidPanned(_ recognizer: UIPanGestureRecognizer, view: UIView)
}

protocol PhotoPreviewDataSourceOLD {
    func item(at index: Int, isGroupedAssets: Bool) -> (PHAsset, UIImageView)
    func itemsCount() -> Int
}

class PhotoPreviewPagingDataSourceOLD: NSObject, UIPageViewControllerDataSource {
    
    public weak var pageContollerDelegate: PhassetPreviewPageDelegateOLD?
     
    private var itemsDataSource: PhotoPreviewDataSourceOLD?
    
    private let fetchingPhassetQueue = OperationServiceQueue()
    
    private var isGroupedAssets: Bool
    
    private var itemsCount: Int {
        return itemsDataSource?.itemsCount() ?? 0
    }
    
    init(dataSource: PhotoPreviewDataSourceOLD, isGroupedAssets: Bool) {
        
        self.itemsDataSource = dataSource
        self.isGroupedAssets = isGroupedAssets
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentController = viewController as? PhassetPreviewPageProtocolOLD, itemsCount > 1 else { return nil }
        
        let previousIndex = (currentController.index == 0) ? itemsCount - 1 : currentController.index - 1
        return self.createViewController(at: previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard  let currentController = viewController as? PhassetPreviewPageProtocolOLD, itemsCount > 1 else { return nil }
        
        let nextIndex = (currentController.index == itemsCount - 1) ? 0 : currentController.index + 1
        return self.createViewController(at: nextIndex)
    }
    
    public func createViewController(at index: Int) -> UIViewController {
        
        guard let dataSource = itemsDataSource else { return UIViewController() }
        
        guard let asset = itemsDataSource?.item(at: index, isGroupedAssets: self.isGroupedAssets).0 else {
            return UIViewController()
        }
    
        var viewController: UIViewController!
        
        if asset.mediaType == .image {
            
            viewController = PhotoViewControllerOLD(index: index, itemCount: dataSource.itemsCount(), asset: asset, fetchingQueue: fetchingPhassetQueue)
        } else if asset.mediaType == .video {
//            TODO: add logic for video content
        }
        
        if var controller = viewController as? PhassetPreviewPageProtocolOLD {
            controller.delegate = pageContollerDelegate
        }
        
        return viewController
    }

}
