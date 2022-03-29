//
//  PhotoPreviewCollectionViewCell.swift
//  ECleaner
//
//  Created by alexey sorochan on 29.03.2022.
//

import UIKit

class PhotoPreviewCollectionViewCell: UICollectionViewCell {
	
	
	@IBOutlet weak var baseView: UIView!
	@IBOutlet weak var reuseShadowView: CollectionShadowView!
	
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
		setupUI()
		updateColors()
    }

}


extension PhotoPreviewCollectionViewCell: Themeble {
	
	public func setupUI() {
		
		self.setCorner(6)
		self.contentView.setCorner(8)
		baseView.setCorner(14)
		
		reuseShadowView.layoutIfNeeded()
		reuseShadowView.layoutSubviews()
	}
	
	func updateColors() {
		
		baseView.backgroundColor = theme.backgroundColor
		
	}
}


