//
//  PremiumCollectionViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.07.2022.
//

import UIKit

class PremiumCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func configure(model: Premium) {
		
	}
	
	override var isHighlighted: Bool {
		didSet {
			toggleIsHighlighted()
		}
	}

	func toggleIsHighlighted() {
		UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
			self.alpha = self.isHighlighted ? 0.9 : 1.0
			self.transform = self.isHighlighted ?
				CGAffineTransform.identity.scaledBy(x: 0.97, y: 0.97) :
				CGAffineTransform.identity
		})
	}

}
