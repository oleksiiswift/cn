//
//  AssetContextPreviewViewController.swift
//  ECleaner
//
//  Created by alekseii sorochan on 12.07.2021.
//

import UIKit
import Photos

class AssetContextPreviewViewController: UIViewController {
    
    private let assetImageView = UIImageView()
    
    override func loadView() {
		
        view = assetImageView
    }
    
    init(asset: PHAsset) {
        super.init(nibName: nil, bundle: nil)
        
        assetImageView.clipsToBounds = true
        assetImageView.contentMode = .scaleAspectFit
		
		if asset.isPortrait {
			switch Screen.size {
				case .small, .medium, .plus, .large:
					let originSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
					let screenRect = CGRect(x: 0, y: 0, width: U.screenWidth, height: U.screenHeight - 250)
					let preViewSize = AVMakeRect(aspectRatio: originSize, insideRect: screenRect).size
					preferredContentSize = preViewSize
				case .modern, .pro, .max, .madMax, .proMax:
					preferredContentSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
			}
		} else {
			preferredContentSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
		}
		
        if let preview = asset.getImage {
            assetImageView.image = preview
        } else {
            return
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		self.view.layoutSubviews()
	}
}


extension CGSize {
	func aspectFit(sourceSize: CGSize, targetSize: CGSize) -> CGSize {
		let vWidth = targetSize.width / sourceSize.width;
		let vHeight = targetSize.height / sourceSize.height;
		var returnSize = targetSize
		if( vHeight < vWidth ) {
			returnSize.width = targetSize.height / sourceSize.height * sourceSize.width;
		}
		else if( vWidth < vHeight ) {
			returnSize.height = targetSize.width / sourceSize.width * sourceSize.height;
		}
		return returnSize;
	}
	func aspectFill(sourceSize: CGSize, targetSize: CGSize) -> CGSize {
		let vWidth = targetSize.width / sourceSize.width;
		let vHeight = targetSize.height / sourceSize.height;
		var returnSize = targetSize
		if( vHeight > vWidth ) {
			returnSize.width = targetSize.height / sourceSize.height * sourceSize.width;
		}
		else if( vWidth > vHeight ) {
			returnSize.height = targetSize.width / sourceSize.width * sourceSize.height;
		}
		return returnSize;
	}
}
