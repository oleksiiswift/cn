//
//  PhotoViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 20.07.2021.
//

import UIKit
import Photos

class PhotoViewController: UIViewController, PhassetPreviewPageProtocol {
    
    /// delegates
    public var delegate: PhassetPreviewPageDelegate?
    
    /// managers
    public var fetchingAssetsQueue: AssetsOperationQueue?
    
    /// elementh
    var image: UIImage?
    
    public let imageView: UIImageView = {
        let image = UIImageView()
        image.isUserInteractionEnabled = true
        return image
    }()
    
    public var mainView: UIView {
        return imageView
    }
    
    public var mainImage: UIImage? {
        return imageView.image
    }
        
    /// assets collection
    public var asset = PHAsset()
    public var index: Int
    public var itemCount: Int
    
    public init(index: Int, itemCount: Int, asset: PHAsset, fetchingQueue: AssetsOperationQueue) {
        
        self.index = index
        self.itemCount = itemCount
        self.asset = asset
        self.fetchingAssetsQueue = fetchingQueue
        
        super.init(nibName: nil, bundle: nil)
        
        loadImage()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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
        U.UI {
            let image = self.asset.thumbnail
            self.imageView.image = image
        }
    }
    
    public func setImage() {
        U.UI {
            let image = self.asset.getImage
            self.imageView.image = image
        }
    }
    
    public func loadImage() {
        
        fetchingAssetsQueue?.addOperation {
            self.setImage()
        }
        
        U.GLB(qos: .utility) {
            self.configureImagesWithPreview()
        }
    }
    
    private func setupUI() {
        
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
    }
}


