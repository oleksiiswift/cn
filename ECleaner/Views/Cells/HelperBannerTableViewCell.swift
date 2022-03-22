//
//  HelperBannerTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.02.2022.
//

import UIKit

class HelperBannerTableViewCell: UITableViewCell {
	
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var bannerImageView: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
		setupCellUI()
    }
}

extension HelperBannerTableViewCell {
	
	public func cellConfigure(with model: SettingsModel) {
		let image = model.optionalBannerImage
		bannerImageView.image = image
	}
	
	public func cellConfigure(with image: UIImage) {
		bannerImageView.image = image
	}
}

extension HelperBannerTableViewCell {
	
	func setupCellUI() {
	
		selectionStyle = .none
		baseView.setCorner(14)
		bannerImageView.contentMode = .scaleAspectFill
	}
}
