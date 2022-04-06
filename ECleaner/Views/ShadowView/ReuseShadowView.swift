//
//   ReuseShadowView.swift
//  ECleaner
//
//  Created by alexey sorochan on 15.11.2021.
//

import UIKit

class ReuseShadowView: UIView {
	    
    var topShadowView = UIView()
    
    public var viewShadowOffsetOriginX: CGFloat = 6
    public var viewShadowOffsetOriginY: CGFloat = 6
    
    public var topShadowOffsetOriginX: CGFloat = -2
    public var topShadowOffsetOriginY: CGFloat = -9
    public var topBlurValue: CGFloat = 19
    public var topAlpha: Float = 0.9
    public var shadowBlurValue: CGFloat = 10
    
    override func layoutSubviews() {
        super.layoutSubviews()
		
        setupViews()
    }
    
    private func setupViews() {
        
		let cellBackgroundColor: UIColor = theme.cellBackGroundColor
		let topShadowColor: UIColor = theme.topShadowColor
		let cellShadowColor: UIColor = theme.sideShadowColor
        
        self.backgroundColor = .clear

        self.layer.setShadowAndCustomCorners(backgroundColor: cellBackgroundColor,
											 shadow: cellShadowColor,
											 alpha: 1, x: viewShadowOffsetOriginX,
											 y: viewShadowOffsetOriginY,
											 blur: shadowBlurValue,
											 corners: [.allCorners],
											 radius: 14)
        
        topShadowView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.insertSubview(topShadowView, at: 0)
        self.topShadowView.layer.setShadowAndCustomCorners(backgroundColor: .clear,
														   shadow: topShadowColor,
														   alpha: topAlpha,
														   x: topShadowOffsetOriginX,
														   y: topShadowOffsetOriginY,
														   blur: topBlurValue,
														   corners: [],
														   radius: 14)
    }
}

