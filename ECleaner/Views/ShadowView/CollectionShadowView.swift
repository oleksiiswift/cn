//
//  CollectionShadowView.swift
//  ECleaner
//
//  Created by alexey sorochan on 30.03.2022.
//

import UIKit

class CollectionShadowView: UIView {
		
	var topShadowView = UIView()
	
	public var viewShadowOffsetOriginX: CGFloat = 2
	public var viewShadowOffsetOriginY: CGFloat = 2
	
	public var topShadowOffsetOriginX: CGFloat = -2
	public var topShadowOffsetOriginY: CGFloat = -2
	public var topBlurValue: CGFloat = 8
	public var topAlpha: Float = 0.9
	public var shadowBlurValue: CGFloat = 5
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.removeCornersSublayers()
		setupViews()
	}
	
	private func setupViews() {
		
		let cellBackgroundColor: UIColor = theme.cellBackGroundColor
		let topShadowColor: UIColor = theme.topShadowColor
		let cellShadowColor: UIColor = theme.sideShadowColor
		
		self.backgroundColor = .clear
		self.topShadowView.backgroundColor = .clear
		
		self.layer.setShadowAndCustomCorners(backgroundColor: cellBackgroundColor,
											 shadow: cellShadowColor,
											 alpha: 1,
											 x: viewShadowOffsetOriginX,
											 y: viewShadowOffsetOriginY,
											 blur: shadowBlurValue,
											 corners: .allCorners,
											 radius: 14)
	
		topShadowView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
		self.insertSubview(topShadowView, at: 0)
		self.topShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear,
														   shadow: topShadowColor,
														   alpha: topAlpha,
														   x: topShadowOffsetOriginX,
														   y: topShadowOffsetOriginY,
														   blur: topBlurValue,
														   corners: .allCorners,
														   radius: 14)
	}
}

