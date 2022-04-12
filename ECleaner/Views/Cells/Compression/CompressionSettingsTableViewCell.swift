//
//  CompressionSettingsTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.04.2022.
//

import UIKit

class CompressionSettingsTableViewCell: UITableViewCell {
	
	@IBOutlet weak var reuseShadowRoundedView: ReuseShadowRoundedView!
	@IBOutlet weak var reuseShadowView: ReuseShadowView!
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var subtitleTetLabel: UILabel!
	
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
	
	public func compressionConfigureCell(with model: ComprssionModel) {
	
		titleTextLabel.text = model.compressionTitle
		subtitleTetLabel.text = model.compressionSubtitle
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
		
		self.titleTextLabel.font = .systemFont(ofSize: 18, weight: .bold)
		self.subtitleTetLabel.font = .systemFont(ofSize: 14, weight: .medium)
		
		reuseShadowView.topShadowOffsetOriginY = -2
		reuseShadowView.topShadowOffsetOriginX = -2
		reuseShadowView.viewShadowOffsetOriginX = 6
		reuseShadowView.viewShadowOffsetOriginY = 6
		reuseShadowView.topBlurValue = 15
		reuseShadowView.shadowBlurValue = 5
		
		reuseShadowView.layoutIfNeeded()
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
