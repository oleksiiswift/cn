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
        preferredContentSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)

        if let preview = asset.getImage {
            assetImageView.image = preview
        } else {
            return
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
