//
//  PreviewViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 30.01.2022.
//

import UIKit
import Photos

class PreviewViewController: UIViewController, PreviewPageProtocol {
	
	var index: Int
	
	var delegate: PreviewPageDelegate?

	var image: UIImage?
	var itemsCount: Int
	var asset = PHAsset()
	
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

	public var fetchingAssetQueue: OperationServiceQueue?
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
	
	public init(index: Int, itemsCount: Int, asset: PHAsset, fetchingQueue: OperationServiceQueue) {
		
		self.index = index
		self.itemsCount = itemsCount
		self.asset = asset
		self.fetchingAssetQueue = fetchingQueue
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
    


}


extension PreviewViewController {
	
	public func configureImagesWithPreview() {
		U.UI {
			self.prefetchCacheImageManager.requestImage(for: self.asset, targetSize: CGSize(width: U.screenWidth, height: U.screenHeight), contentMode: .aspectFit, options: PhotoManager.shared.requestOptions) { image, _ in
				if let image = image {
					self.imageView.image = image
				}
			}
			
//			self.asset.thumbnail
	
		}
	}
	
	public func setImage() {
		U.UI {
			self.prefetchCacheImageManager.requestImage(for: self.asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: PhotoManager.shared.requestOptions) { image, _ in
				if let image = image {
					self.imageView.image = image
				}
			}
			
//			let image = self.asset.getImage
//			self.imageView.image = image
		}
	}
	
	public func loadImage() {
		
		fetchingAssetQueue?.addOperation {
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
