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
    
    var getImage: UIImage? {
        var result: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = true
        manager.requestImageDataAndOrientation(for: self, options: options) { data, _, _, _ in
            if let data = data {
                result = UIImage(data: data)
            }
        }
        return result
    }
}
