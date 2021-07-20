//
//  PhotoViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 20.07.2021.
//

import UIKit
import Photos

class PhotoViewController: UIViewController, PhassetPreviewPageProtocol {
    
    var image: UIImage?
    
    public var delegate: PhassetPreviewPageDelegate?
    
    public let imageView: UIImageView = {
        let image = UIImageView()
        image.isUserInteractionEnabled = true
        return image
    }()
    
    public var index: Int
    public var itemCount: Int
    
    public var asset = PHAsset()
    
    public var mainView: UIView {
        return imageView
    }
    
    public var mainImage: UIImage? {
        return imageView.image
    }
    
    public var fetchingQueue: ImageAssetOperation?
    
    public init(index: Int, itemCount: Int, asset: PHAsset, fetchingQueue: ImageAssetOperation) {
        
        self.index = index
        self.itemCount = itemCount
        self.asset = asset
        self.fetchingQueue = fetchingQueue
        
        super.init(nibName: nil, bundle: nil)
        
        loadImage()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        delegate?.photoPreviewControllerDidAppear(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.photoPreviewControllerWillDisapper(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        debugPrint("did setup scollview")
    }
}

extension PhotoViewController {
    
    public func configureImagesWithPreview() {
    }
    
    public func setImage() {
        
    }

    public func loadImage() {
        
        fetchingQueue?.addOperation {
            self.setImage()
        }
        
        DispatchQueue.global(qos: .utility).async {
            self.configureImagesWithPreview()
        }
    }
}


class ImageAssetOperation: OperationQueue {
    
    override init() {
        super.init()
        qualityOfService = .userInitiated
        maxConcurrentOperationCount = 1
    }
    
    override public func addOperation(_ operation: Operation) {
        let lastIndex = operations.count - 1
        
        if operations.count > 1 {
            for i in 0..<operations.count {
                if !operations[i].isCancelled && i != lastIndex {
                    operations[i].cancel()
                }
            }
        }
        super.addOperation(operation)
    }
}
