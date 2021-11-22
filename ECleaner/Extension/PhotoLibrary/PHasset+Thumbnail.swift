//
//  PHasset+Thumbnail.swift
//  ECleaner
//
//  Created by alekseii sorochan on 09.07.2021.
//

import Photos
import UIKit

extension PHAsset {
    
    var thumbnailSync: UIImage? {
        var result: UIImage?
        let targetSize = CGSize(width: 300, height: 300)
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: self, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
            result = image
        }
        return result
    }
    
    var thumbnail: UIImage? {
        var result: UIImage?
        let targetSize = CGSize(width: U.screenWidth / 2, height: U.screenHeight / 2)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: self, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
            result = image
        }
        return result
    }
    
    var getImage: UIImage? {
        var result: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = true
        manager.requestImage(for: self, targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight), contentMode: .aspectFit, options: options) { image, info in
            if let image = image {
                result = image
            }
        }
        return result
    }
}
