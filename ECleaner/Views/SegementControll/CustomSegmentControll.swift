//
//  CustomSegmentControll.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.04.2022.
//

import UIKit

class CustomSegmentedControl: UISegmentedControl{
	
	private let segmentInset: CGFloat = 5
	private let segmentImage: UIImage? = UIImage(color: .white)
	private let segmentbackfroundImage: UIImage? = UIImage(color: UIColor().colorFromHexString("CFD7E1"))
	private let segmentDividerImage: UIImage? = UIImage(color: .clear)
	
	override func layoutSubviews(){
		super.layoutSubviews()
		
		layer.cornerRadius = 6
		self.selectedSegmentTintColor = .clear
	
		let foregroundIndex = numberOfSegments
		
		setDividerImage(segmentDividerImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
		
		if subviews.indices.contains(foregroundIndex), let foregroundImageView = subviews[foregroundIndex] as? UIImageView {
			
			foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
			foregroundImageView.image = segmentImage
			foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")
			foregroundImageView.layer.masksToBounds = true
			foregroundImageView.layer.cornerRadius = 5
		}
		
		if subviews.indices.contains(foregroundIndex - 1), let backgroundImageView = subviews[foregroundIndex - 1] as? UIImageView {
			backgroundImageView.frame = .zero
		}
		
		if subviews.indices.contains(0), let firstBackgroundImageView = subviews[0] as? UIImageView {
			firstBackgroundImageView.frame = .zero
		}
	}
}
