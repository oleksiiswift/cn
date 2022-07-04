//
//  PremiumFeatureTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.07.2022.
//

import UIKit

class PremiumFeatureTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleTextLabel: UILabel!
	@IBOutlet weak var thumbnailView: GradientShadowView!
	
	@IBOutlet var thumbnailViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet var thumnailViewHeightConstraint: NSLayoutConstraint!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
		setup()
		updateColors()
    }
}

extension PremiumFeatureTableViewCell: Themeble {
	
	public func configure(model: PremiumFeature) {
		
		titleTextLabel.text = model.title
		thumbnailView.layoutIfNeeded()
		thumbnailView.setImageWithCustomBackground(image: model.thumbnail, tineColor: .white, size: CGSize(width: thumbnailView.frame.height / 2, height: thumbnailView.frame.height / 2), colors: model.thumbnailColors)
		
	}
	
	private func setup() {
		self.selectionStyle = .none
		
		thumbnailViewLeadingConstraint.constant = AppDimensions.Subscription.Features.leadingInset
		thumnailViewHeightConstraint.constant = AppDimensions.Subscription.Features.thumbnailSize
		titleTextLabel.font = FontManager.subscriptionFont(of: .premiumFeature)
	}
	
	func updateColors() {
		
		titleTextLabel.textColor = theme.featureTitleTextColor
		thumbnailView.setShadowColor(for: theme.topShadowColor, and: theme.bottomShadowColor)
	}
}
