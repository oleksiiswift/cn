//
//  PhotoPreviewDataSource.swift
//  ECleaner
//
//  Created by alekseii sorochan on 20.07.2021.
//

import UIKit
import Photos

protocol PhassetPreviewPageProtocol {
    var index: Int { get set }
    var delegate: PhassetPreviewPageDelegate? { get set }
    var mainView: UIView { get }
    var image: UIImage? { get}
}

protocol PhassetPreviewPageDelegate: AnyObject {
    func photoPreviewControllerDidAppear(_ controller: PhassetPreviewPageProtocol)
    func photoPreviewControllerWillDisapper(_ controller: PhassetPreviewPageProtocol)
    func photoPrevireDidPanned(_ recognizer: UIPanGestureRecognizer, view: UIView)
}

protocol PhotoPreviewDataSource {
    func item(at index: Int) -> (PHAsset, UIImageView)
    func itemsCount() -> Int
}

class PhotoPreviewPagingDataSource: NSObject, UIPageViewControllerDataSource {
    
    public weak var pageContollerDelegate: PhassetPreviewPageDelegate?
     
    private var itemsDataSource: PhotoPreviewDataSource?
    
    private let fetchingPhassetQueue = ImageAssetOperation()
    
    private var itemsCount: Int {
        return itemsDataSource?.itemsCount() ?? 0
    }
    
    init(dataSource: PhotoPreviewDataSource) {
        self.itemsDataSource = dataSource
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentController = viewController as? PhassetPreviewPageProtocol, itemsCount > 1 else {
            return nil }
        
        let previousIndex = (currentController.index == 0) ? itemsCount - 1 : currentController.index - 1
        return self.createViewController(at: previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard  let currentController = viewController as? PhassetPreviewPageProtocol, itemsCount > 1 else {
            return nil
        }
        
        let nextIndex = (currentController.index == itemsCount - 1) ? 0 : currentController.index + 1
        return self.createViewController(at: nextIndex)
    }
    
    func createViewController(at index: Int) -> UIViewController {
        
        guard let dataSource = itemsDataSource else { return UIViewController() }
        
        guard let asset = itemsDataSource?.item(at: index).0 else { return UIViewController() }
        var viewController: UIViewController!
        
        if asset.mediaType == .image {
            
            viewController = PhotoViewController(index: index, itemCount: dataSource.itemsCount(), asset: asset, fetchingQueue: fetchingPhassetQueue)
        } else if asset.mediaType == .video {
            
        }
        
        if var controller = viewController as? PhassetPreviewPageProtocol {
            controller.delegate = pageContollerDelegate
        }
        
        return viewController
    }
}
