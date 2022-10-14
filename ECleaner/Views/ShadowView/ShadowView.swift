//
//  ShadowView.swift
//  ECleaner
//
//  Created by alexey sorochan on 05.11.2021.
//

import UIKit

class ShadowView: UIView {
    
    let topShadowView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
		self.setupUI()
		self.setupLayers()
    }
	
	private func setupUI() {
		
		self.clipsToBounds = true
		self.layer.cornerRadius = 14
		
		self.topShadowView.clipsToBounds = true
		self.topShadowView.layer.cornerRadius = 14
	}
	
	
	private func setupLayers() {
	
		self.backgroundColor = theme.primaryButtonBackgroundColor
		topShadowView.backgroundColor = theme.primaryButtonBackgroundColor
		topShadowView.frame = self.bounds
		
		self.insertSubview(topShadowView, at: 0)
		
		switch theme {
			case .light:
				
				self.backgroundColor = theme.primaryButtonBackgroundColor
				topShadowView.backgroundColor = theme.primaryButtonBackgroundColor
				topShadowView.frame = self.bounds
				
				layer.applyShadow(color: theme.primaryButtonBottomShadowColor, alpha: 1.0, x: 6, y: 6, blur: 10, spread: 0)
				
				topShadowView.layer.applyShadow(color: theme.primaryButtonTopShadowColor, alpha: 1.0, x: -2, y: -3, blur: 19, spread: 0)
			case .dark:
				
				self.backgroundColor = theme.cellBackGroundColor
				topShadowView.backgroundColor = theme.cellBackGroundColor
				topShadowView.frame = self.bounds
				
				layer.masksToBounds = false
				layer.borderColor = theme.bordersColor.cgColor
				layer.borderWidth = 0.0
		}
	}
}


