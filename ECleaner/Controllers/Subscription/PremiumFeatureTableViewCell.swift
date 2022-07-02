//
//  PremiumFeatureTableViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.07.2022.
//

import UIKit

class PremiumFeatureTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleTextLabel: UILabel!
	

    override func awakeFromNib() {
        super.awakeFromNib()
        
		self.setup()
    }
}

extension PremiumFeatureTableViewCell {
	
	public func configure(model: PremiumFeature) {
		
		titleTextLabel.text = model.title
		
	}
	
	private func setup() {
		self.selectionStyle = .none
		
	}
}
