//
//  VideoCollectionDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 30.07.2022.
//

import UIKit
import Photos

protocol VideoCollectionDataSourceDelegate {
	func handleSelectPHAsset(at indexPath: IndexPath)
	func showComressionViewController(with indexPath: IndexPath)
	func share(phasset: PHAsset)
}

class VideoCollectionDataSource: NSObject {
	
	public var videoCollectionViewModel: VideoCollectionViewModel
	public var mediaType: PhotoMediaType
	public var contentType: MediaContentType
	public var collectionView: UICollectionView
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager

	public var thumbnailSize: CGSize = .zero
	
	public var delegate: VideoCollectionDataSourceDelegate?
	
	private var isBatchSelect: Bool = false {
		didSet {}
	}
	
	init(videoCollectionViewModel: VideoCollectionViewModel, mediaType: PhotoMediaType, contentType: MediaContentType, collectionView: UICollectionView) {
		self.videoCollectionViewModel = videoCollectionViewModel
		self.mediaType = mediaType
		self.contentType = contentType
		self.collectionView = collectionView
	}
}

extension VideoCollectionDataSource {
	
	private func configure(cell: PhotoCollectionViewCell, at indexPath: IndexPath) {
		
		let videoPHAsset = self.videoCollectionViewModel.getPhasset(at: indexPath)
		cell.selectButtonSetup(by: self.mediaType, isNewConpress: videoPHAsset.localIdentifier == S.lastSavedLocalIdenifier)
		cell.indexPath = indexPath
		cell.tag = indexPath.section * 1000 + indexPath.row
		cell.cellMediaType = self.mediaType
		cell.cellContentType = self.contentType
		cell.collectionType = .single
		
		if self.thumbnailSize.equalTo(CGSize.zero) {
			self.thumbnailSize = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)!.size.toPixel()
		}
		
		cell.loadCellThumbnail(videoPHAsset, imageManager: self.prefetchCacheImageManager, size: thumbnailSize)
		cell.setupUI()
		cell.updateColors()
	
		if let path = self.collectionView.indexPathsForSelectedItems, path.contains([indexPath]) {
			cell.isSelected = true
		} else {
			cell.isSelected = false
		}
		cell.checkIsSelected()
	}
}

extension VideoCollectionDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.videoCollectionViewModel.numberOfSection()
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.videoCollectionViewModel.numberOfRows(at: section)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.identifiers.cells.photoSimpleCell, for: indexPath) as! PhotoCollectionViewCell
		self.configure(cell: cell, at: indexPath)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		if !isBatchSelect {
			self.delegate?.showComressionViewController(with: indexPath)
			return false
		} else {
			if let cell = collectionView.cellForItem(at: indexPath) {
				if cell.isSelected {
					self.collectionView.deselectItem(at: indexPath, animated: true)
					self.collectionView.delegate?.collectionView?(self.collectionView, didDeselectItemAt: indexPath)
					return false
				} else {
					return true
				}
			}
		}
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.delegate?.handleSelectPHAsset(at: indexPath)
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		self.delegate?.handleSelectPHAsset(at: indexPath)
	}
	
	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let asset = self.videoCollectionViewModel.getPhasset(at: indexPath)
		let identifier = IndexPath(item: indexPath.item, section: indexPath.section) as NSCopying
		
		return UIContextMenuConfiguration(identifier: identifier) {
			return PreviewAVController(asset: asset)
		} actionProvider: { _ in
			return self.createCellContextMenu(for: asset, at: indexPath)
		}
	}

	func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		
		guard let indexPath = configuration.identifier as? IndexPath,  let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { return nil}
		
		let targetPreview = UITargetedPreview(view: cell.photoThumbnailImageView)
		targetPreview.parameters.backgroundColor = .clear
		targetPreview.view.backgroundColor = .clear
		return targetPreview
	}
	
	func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		guard let indexPath = configuration.identifier as? IndexPath, let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { return nil}
		
		let targetPreview = UITargetedPreview(view: cell.photoThumbnailImageView)
		targetPreview.parameters.backgroundColor = .clear
		targetPreview.view.backgroundColor = .clear
		return targetPreview
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
		DispatchQueue.main.async {
			if let window = U.application.windows.first {
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UICutoutShadowView") {
					view.isHidden = true
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPortalView") {
					view.backgroundColor = .clear
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPlatterTransformView") {
					view.backgroundColor = .clear
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPlatterClippingView") {
					view.backgroundColor = .clear
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPlatterTransformView") {
					view.backgroundColor = .clear
				}
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
		
		DispatchQueue.main.async {
			if let window = U.application.windows.first {
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UICutoutShadowView") {
					view.isHidden = true
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPortalView") {
					view.backgroundColor = .clear
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPlatterTransformView") {
					view.backgroundColor = .clear
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPlatterClippingView") {
					view.backgroundColor = .clear
				}
				if let view = Utils.Manager.viewByClassName(view: window, className: "_UIPlatterTransformView") {
					view.backgroundColor = .clear
				}
			}
		}
	}
}

extension VideoCollectionDataSource {
	
	private func createCellContextMenu(for asset: PHAsset, at indexPath: IndexPath) -> UIMenu {
		
		let shareVideoActionImage = I.systemItems.defaultItems.share
		let shareAction = UIAction(title: LocalizationService.Buttons.getButtonTitle(of: .share), image: shareVideoActionImage) { _ in
			self.delegate?.share(phasset: asset)
		}
		return UIMenu(title: "", children: [shareAction])
	}
}

