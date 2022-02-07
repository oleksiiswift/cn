//
//  PHCachingImageManager+RequestExtension.swift
//  ECleaner
//
//  Created by alekseii sorochan on 20.07.2021.
//

import Photos
import UIKit

extension PHCachingImageManager {
    
    public func photoImageRequestOptions() -> PHImageRequestOptions {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        options.isSynchronous = true
        return options
    }
    
    func fetchImage(for asset: PHAsset, cropRect: CGRect, targetSize: CGSize, completionHandler: @escaping (UIImage, [String: Any]) -> Void) {
        
        let options = photoImageRequestOptions()
        
        requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
            guard let imageData = data else { return }
            
            if let assetImage = UIImage(data: imageData) {
                let xCrop: CGFloat = cropRect.origin.x * CGFloat(asset.pixelWidth)
                let yCrop: CGFloat = cropRect.origin.y * CGFloat(asset.pixelHeight)
                
                let scaledCropRect = CGRect(x: xCrop, y: yCrop, width: targetSize.width, height: targetSize.height)
                if let imageReference = assetImage.cgImage?.cropping(to: scaledCropRect) {
                    let croppedImage = UIImage(cgImage: imageReference)
                    let exif = self.metadataForImageData(data: imageData)
                    completionHandler(croppedImage, exif)
                }
            }
        }
    }
    
    private func metadataForImageData(data: Data) -> [String: Any] {
        if let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
           let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil),
           let metaData = imageProperties as? [String: Any] {
            return metaData
        }
        return [:]
    }
	
	
	func fetch(photo asset: PHAsset, callback: @escaping (UIImage, Bool, String) -> Void) {
		let options = PHImageRequestOptions()
		// Enables gettings iCloud photos over the network, this means PHImageResultIsInCloudKey will never be true.
		options.isNetworkAccessAllowed = true
		// Get 2 results, one low res quickly and the high res one later.
		options.deliveryMode = .opportunistic
		requestImage(for: asset, targetSize: PHImageManagerMaximumSize,
					 contentMode: .aspectFill, options: options) { result, info in
			guard let image = result else {
				print("No Result 🛑")
				return
			}
			DispatchQueue.main.async {
				let isLowRes = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
				callback(image, isLowRes, asset.localIdentifier)
			}
		}
	}
}
