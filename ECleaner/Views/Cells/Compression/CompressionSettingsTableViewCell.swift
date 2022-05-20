//
//  CompressionSettingsTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.04.2022.
//

import UIKit
import Photos

class CompressionSettingsTableViewCell: UITableViewCell {
	
	@IBOutlet weak var reuseShadowRoundedView: ReuseShadowRoundedView!
	@IBOutlet weak var reuseShadowView: ReuseShadowView!
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var subtitleTetLabel: UILabel!
	@IBOutlet weak var reuseShadowRoundedViewHeightConstraint: NSLayoutConstraint!
	
	private var videoManager = VideoCompressionManager.insstance
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		self.setPrepareForReuse()
	}
	
	override func awakeFromNib() {
        super.awakeFromNib()
        
		self.setupUI()
		self.updateColors()
    }
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

		self.checkSelectedCell()
    }
}

extension CompressionSettingsTableViewCell {
	
	public func compressionConfigureCell(with model: ComprssionModel, phasset: PHAsset?) {
	
		titleTextLabel.text = model.compressionTitle

		if let phasset = phasset {
			if model == .custom(fps: 0, bitrate: 0, scale: .zero) {
				let configuration = model.getCustomCongfiguration()
				let resolution = model.getVideoResolution(from: configuration.scaleResolution)
				let fps = model.getFPS(from: configuration.fps)
				let originResolutionStringText = "\(Int(phasset.pixelWidth)) x \(Int(phasset.pixelHeight))"
				let customResolutionStingText = resolution == .origin ? originResolutionStringText : resolution.resolutionInfo
				subtitleTetLabel.text = "\(customResolutionStingText), \(fps.name)"
			} else {
				let size = videoManager.calculateSize(with: model, originalSize: CGSize(width: phasset.pixelWidth, height: phasset.pixelHeight))
				let originResolutionStringText = "\(Int(size.width)) x \(Int(size.height))"
				subtitleTetLabel.text = "\(originResolutionStringText), \(Int(model.preSavedValues.fps)) FPS"
			}
		} else {
			subtitleTetLabel.text = model.compressionSubtitle
		}
	}
	
	private func checkSelectedCell() {
		
		let selectedImage = self.isSelected ? I.personalisation.video.selected : I.personalisation.video.unselected
		self.reuseShadowRoundedView.setImage(selectedImage)
	}
}

extension CompressionSettingsTableViewCell: Themeble {
	
	private func setupUI() {
		
		self.selectionStyle = .none
		self.baseView.setCorner(14)
		
		self.titleTextLabel.font = FontManager.contentTypeFont(of: .title)
		self.subtitleTetLabel.font = FontManager.contentTypeFont(of: .subtitle)
		
		self.reuseShadowRoundedViewHeightConstraint.constant = U.UIHelper.AppDimensions.ContenTypeCells.radioButtonSize
		
		reuseShadowView.topShadowOffsetOriginY = -2
		reuseShadowView.topShadowOffsetOriginX = -2
		reuseShadowView.viewShadowOffsetOriginX = 6
		reuseShadowView.viewShadowOffsetOriginY = 6
		reuseShadowView.topBlurValue = 15
		reuseShadowView.shadowBlurValue = 5
		
		reuseShadowView.layoutIfNeeded()
		reuseShadowRoundedView.layoutIfNeeded()
	}
	
	private func setPrepareForReuse() {
		
		self.reuseShadowRoundedView.setImage()
		self.titleTextLabel.text = nil
		self.subtitleTetLabel.text = nil
	}
	
	func updateColors() {
		
		baseView.backgroundColor = .clear
		reuseShadowRoundedView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor)
		titleTextLabel.textColor = theme.titleTextColor
		subtitleTetLabel.textColor = theme.subTitleTextColor
	}
}
