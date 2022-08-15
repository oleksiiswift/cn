//
//  GradientButton.swift
//  ECleaner
//
//  Created by alexey sorochan on 07.07.2022.
//

import UIKit

class GradientButton: UIButton {
	
	private let primaryLayer = CALayer()
	private let secondaryLayer = CALayer()
	
	public var primaryShadowsIsActive = true
	public var setupGradientActive = false
	
	public var gradientColors: [UIColor] = []
	public var buttonImage = UIImage()
	public var buttonTitle: String = ""
	public var buttonTintColor = UIColor()
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		self.animateButtonTransform()
		
		if let imageView = self.subviews.first(where: {$0.tag == 66613}) {
			UIView.animate(withDuration: 0.1) {
				imageView.alpha = 0.3
				imageView.isHidden = true
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		
		if let imageView = self.subviews.first(where: {$0.tag == 66613}) {
			UIView.animate(withDuration: 0.1) {
				imageView.alpha = 1
			}
		}
	}
		
	override func layoutSubviews() {
		super.layoutSubviews()

		configureShadow()
		buttonSetup()
		setupGradient()
	}
	
	private func configureShadow() {
		
		guard primaryShadowsIsActive else { return }
		
		primaryLayer.backgroundColor = theme.primaryButtonBackgroundColor.cgColor
		primaryLayer.cornerRadius = 10
		[primaryLayer, secondaryLayer].forEach {
			$0.masksToBounds = false
			$0.frame = layer.bounds
			layer.insertSublayer($0, at: 0)
		}
		
		primaryLayer.applyShadow(color: theme.primaryButtonBottomShadowColor, alpha: 1.0, x: 6, y: 6, blur: 10, spread: 0)
		
		secondaryLayer.applyShadow(color: theme.primaryButtonTopShadowColor, alpha: 1.0, x: -2, y: -5, blur: 19, spread: -1)
	}
	
	private func buttonSetup() {
		
		self.setCorner(10)
		self.setTitle(buttonTitle, for: .normal)
	}
	
	private func setupGradient() {
		
		guard setupGradientActive else { return }
		
		let targetLeftImageSize = CGSize(width: self.frame.width * 0.5, height: self.frame.height * 0.5)
		let actionButtonImageSize: CGSize = buttonImage.getPreservingAspectRationScaleImageSize(from: targetLeftImageSize)
		self.addLeftImage(image: buttonImage, size: actionButtonImageSize, spacing: 5, tintColor: buttonTintColor)
		
		let gradientColors = gradientColors.compactMap({$0.cgColor})
		self.layerGradient(startPoint: .topCenter, endPoint: .bottomCenter, colors: gradientColors, type: .axial)
	}
}
