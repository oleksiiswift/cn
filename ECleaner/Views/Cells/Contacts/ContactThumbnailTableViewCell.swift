//
//  ContactThumbnailTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.07.2022.
//

import UIKit

class ContactThumbnailTableViewCell: UITableViewCell {

	@IBOutlet weak var reuseRoundedShadowView: ReuseShadowRoundedView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		setupUI()
		updateColors()
    }
}

extension ContactThumbnailTableViewCell {
	
	public func configureCell(with model: ContactModel) {
		
		if case .thumbnailImageData(let image) = model {
			reuseRoundedShadowView.setImage(image)
		}
	}
}

extension ContactThumbnailTableViewCell: Themeble {
	
	func setupUI() {
		
		self.selectionStyle = .none
	}
	
	func updateColors() {
		reuseRoundedShadowView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor)
	}
}
