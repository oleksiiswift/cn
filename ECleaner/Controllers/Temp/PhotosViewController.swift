//
//  ViewController.swift
//  PhotosApp
//
//  Created by Nikita Razumnuy on 10/11/19.
//  Copyright © 2019 Nikita Razumnuy. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UIViewController {
	
	public var collectionType: CollectionType = .none
	public var assetCollection: [PHAsset] = []
	public var assetGroups: [PhassetGroup] = []
	public var mediaType: PhotoMediaType = .none
	public var contentType: MediaContentType = .none
	
	
    var dataSource: PhotosDataSource?

    var contentView: PhotosView {
        return (view as? PhotosView).require()
    }

    override func loadView() {
        view = PhotosView(sizeForIndex: {
            if let images = self.dataSource?.assetCollection {
				return images.count > $0 ? images[$0].thumbnailSync!.size : CGSize(width: 1, height: 1)
            }
            return CGSize(width: 1, height: 1)
        })

		dataSource = PhotosDataSource(preview: contentView.previewCollection, thumbnails: contentView.thumbnailCollection, collectionType: self.collectionType, assetCollection: self.assetCollection, assetGroups: self.assetGroups, mediaType: self.mediaType)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.synchronizer.layoutState = .ready
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.synchronizer.layoutState = .configuring
    }

    @objc func onDelete(sender: UIBarButtonItem) {
        guard contentView.synchronizer.interactionState == .enabled else { return }
//		guard let count = dataSource?.images.count, count > 2 else {
//			let alert = UIAlertController(
//				title: "Sorry",
//				message: "This sample does not handle corner cases, however, as one or zero cells",
//				preferredStyle: .alert)
//			alert.addAction(UIAlertAction(title: "OK", style: .cancel))
//			present(alert, animated: true)
//			return
//		}
//        let index = contentView.indexInFocus
//        let event: ScrollSynchronizer.Event = .remove(
//            index: IndexPath(item: index, section: 0),
//            dataSourceUpdate: { self.dataSource?.images.remove(at: index) },
//            completion: nil)
//        contentView.synchronizer.handle(event: event)
    }

    @objc func onAdd(sender: UIBarButtonItem) {
//        if let dataSource = dataSource {
//            dataSource.images.append(dataSource.randomImage())
//            contentView.synchronizer.reload()
//        }
    }
}

// MARK: orientation changes
extension PhotosViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        contentView.synchronizer.layoutState = .configuring
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.contentView.synchronizer.layoutState = .ready
        }
    }
}
