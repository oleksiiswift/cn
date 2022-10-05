//
//  SliderShadowView.swift
//  ECleaner
//
//  Created by alexey sorochan on 04.04.2022.
//

import UIKit

class SliderShadowView: UIView {
	
	let primaryLayer = CALayer()
	let secondaryLayer = CALayer()
		
	override func layoutSubviews() {
		super.layoutSubviews()

		primaryLayer.backgroundColor = theme.primaryButtonBackgroundColor.cgColor
		primaryLayer.cornerRadius = 10
		[primaryLayer, secondaryLayer].forEach {
			$0.masksToBounds = false
			$0.frame = layer.bounds
			layer.insertSublayer($0, at: 0)
		}
		
		primaryLayer.applyShadow(color: theme.primaryButtonBottomShadowColor, alpha: 1.0, x: 3, y: 3, blur: 10, spread: 0)
		secondaryLayer.applyShadow(color: theme.primaryButtonTopShadowColor, alpha: 1.0, x: -2, y: -5, blur: 19, spread: -1)
	}
}
