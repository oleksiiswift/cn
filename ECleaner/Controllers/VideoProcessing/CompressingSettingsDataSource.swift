//
//  CompressingSettingsDataSource.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.04.2022.
//

import Foundation
import Photos

class CompressingSettingsDataSource: NSObject {
	
	public var compressionSettinsViewModel: CompressingSettingsViewModel
	public var delegate: CompressionSettingsActionsDelegate?
	private var prefetchCacheImageManager = PhotoManager.shared.prefetchManager
	
	init(compressionSettinsViewModel: CompressingSettingsViewModel) {
		self.compressionSettinsViewModel = compressionSettinsViewModel
	}
	
	private func cellConfigure(cell: CompressionSettingsTableViewCell, at indexPath: IndexPath) {
		let compressionModel = compressionSettinsViewModel.getSettingsModel(at: indexPath)
		cell.compressionConfigureCell(with: compressionModel)
	}
	
	private func configureVideoPreview(cell: VideoPreviewTableViewCell, at indexPath: IndexPath, with phasset: PHAsset? ) {
		guard let asset = self.compressionSettinsViewModel.getCompressingPHAsset() else { return }
		let size = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
		cell.configurePreview(from: asset, imageManager: self.prefetchCacheImageManager, size: size)
	}
}

extension CompressingSettingsDataSource: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return compressionSettinsViewModel.numbersOfSections()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return compressionSettinsViewModel.numbersOfRows(in: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
			case 0:
				let asset = self.compressionSettinsViewModel.getCompressingPHAsset()
				let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.videoPreviewCell, for: indexPath) as! VideoPreviewTableViewCell
				self.configureVideoPreview(cell: cell, at: indexPath, with: asset)
				return cell
			default:
				let cell = tableView.dequeueReusableCell(withIdentifier: C.identifiers.cells.compressionCell, for: indexPath) as! CompressionSettingsTableViewCell
				self.cellConfigure(cell: cell, at: indexPath)
				return cell
		}
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.compressionSettinsViewModel.gettitleForHeader(in: section)
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return self.compressionSettinsViewModel.getHeightOfHeader(in: section)
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if indexPath.section == 0 {
			
			return nil
		}
		return indexPath
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
			let model = self.compressionSettinsViewModel.getSettingsModel(at: indexPath)
			delegate?.setCompressionSettingsForValue(with: model)
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.compressionSettinsViewModel.getHeightForRow(at: indexPath)
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let headerView = view as! UITableViewHeaderFooterView
		headerView.contentView.backgroundColor = ThemeManager.theme.backgroundColor
		headerView.contentView.alpha = 0.8
		headerView.textLabel?.textColor = ThemeManager.theme.sectionTitleTextColor
		headerView.textLabel?.font = .systemFont(ofSize: 14, weight: .medium)
	}
}

extension CompressingSettingsDataSource {
	
	public func prefetch(_ asset: PHAsset) {
		
		let size = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
		
		self.prefetchCacheImageManager.startCachingImages(for: [asset], targetSize: size, contentMode: .aspectFill, options: nil)
	}
}
