//
//  PhotosDataSource.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/13/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit
import Photos

class PhotosDataSource: NSObject {
	
	private var photoManager = PhotoManager.shared
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager

	public var collectionType: CollectionType
	public var assetCollection: [PHAsset]
	public var assetGroups: [PhassetGroup]
	public var mediaType: PhotoMediaType
	public var contentType: MediaContentType = .none
	
    let preview: UICollectionView
    let thumbnails: UICollectionView

    init(preview: UICollectionView, thumbnails: UICollectionView, collectionType: CollectionType, assetCollection: [PHAsset], assetGroups: [PhassetGroup], mediaType: PhotoMediaType) {
		
        self.preview = preview
        self.thumbnails = thumbnails
		self.collectionType = collectionType
		self.assetCollection = assetCollection
		self.assetGroups = assetGroups
		self.mediaType = mediaType

        super.init()

        preview.dataSource = self
        preview.register(
            PreviewCollectionViewCell.self,
            forCellWithReuseIdentifier: PreviewCollectionViewCell.reuseId)

        thumbnails.dataSource = self
        thumbnails.register(
            ThumbnailCollectionViewCell.self,
            forCellWithReuseIdentifier: ThumbnailCollectionViewCell.reuseId)
		
		
		preview.prefetchDataSource = self
		thumbnails.prefetchDataSource = self
    }

    var urls: [URL] {
        Bundle.main.urls(
            forResourcesWithExtension: .none,
            subdirectory: "Data").require(hint: "No test data found.")
    }

    func loadImages() -> [UIImage] {
        return urls
            .compactMap { try? Data(contentsOf: $0) }
            .compactMap(UIImage.init(data:))
    }

    func randomImage() -> UIImage {
        return Set(loadImages()).randomElement().require(hint: "No test data found.")
    }
}

extension PhotosDataSource: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		switch collectionType {
			case .grouped:
				return assetGroups.count
			default:
				return 1
		}
	}
	
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch collectionType {
			case .grouped:
				return assetGroups[section].assets.count
			case .single:
				return assetCollection.count
			case .none:
				return 0
		}
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var reuseId: String?
        if collectionView == preview {
            reuseId = PreviewCollectionViewCell.reuseId
        }
        if collectionView == thumbnails {
            reuseId = ThumbnailCollectionViewCell.reuseId
        }
        let cell = reuseId.flatMap {
            collectionView.dequeueReusableCell(
                withReuseIdentifier: $0,
                for: indexPath) as? ImageCell
        }
		
		var asset: PHAsset {
			switch collectionType {
				case .grouped:
					return assetGroups[indexPath.section].assets[indexPath.row]
				case .single:
					return assetCollection[indexPath.row]
				case .none:
					return assetCollection[indexPath.row]
			}
		}
		
		let size = CGSize(width: 300, height: 300)
	
		
		let options = PhotoManager.shared.requestOptions
				debugPrint("reques")
		DispatchQueue.main.async {
			
		
			_ = self.prefetchCacheImageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { image, info in
			debugPrint("image")
				if let loadedImage = image {
					cell?.imageView.image = loadedImage
			}
		})
		
		}
        
        return cell.require(hint: "Unexpected cell type.")
    }
	
	private func requestPhassets(for indexPaths: [IndexPath]) -> [PHAsset] {
		switch collectionType {
			case .grouped:
				return indexPaths.compactMap({ self.assetGroups[$0.section].assets[$0.item]})
			default:
				return indexPaths.compactMap({ self.assetCollection[$0.row]})
		}
	}

}

extension PhotosDataSource: UICollectionViewDataSourcePrefetching {
	
	
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		let phassets = requestPhassets(for: indexPaths)
		let thumbnailSize = thumbnails.collectionViewLayout.layoutAttributesForItem(at: indexPaths.first!)!.size.toPixel()
//		self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPaths.first!)!.size.toPixel()
		debugPrint("prefetch \(indexPaths)")
		let options = PHImageRequestOptions()
		options.isNetworkAccessAllowed = true
		prefetchCacheImageManager.startCachingImages(for: phassets, targetSize: thumbnailSize, contentMode: .aspectFit, options: options)
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//		let phassets = requestPhassets(for: indexPaths)
//		let thumbnailSize = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPaths.first!)!.size.toPixel()
//		let options = PHImageRequestOptions()
//		options.isNetworkAccessAllowed = true
//		prefetchCacheImageManager.stopCachingImages(for: phassets, targetSize: thumbnailSize, contentMode: .aspectFit, options: options)
	}
}
