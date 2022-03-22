//
//  PrimaryButton.swift
//  ECleaner
//
//  Created by alexey sorochan on 22.03.2022.
//

import UIKit

class PrimaryButton: UIButton {
	
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
		
		primaryLayer.applySketchShadow(color: theme.primaryButtonBottomShadowColor, alpha: 1.0, x: 6, y: 6, blur: 10, spread: 0)
		
		secondaryLayer.applySketchShadow(color: theme.primaryButtonTopShadowColor, alpha: 1.0, x: -2, y: -5, blur: 19, spread: -1)
	}
}
