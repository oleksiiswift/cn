//
//  UIView+GradientBorder.swift
//  ECleaner
//
//  Created by alexey sorochan on 03.07.2022.
//

import Foundation

public extension UIView {

	private static let kLayerNameGradientBorder = "GradientBorderLayer"

	func gradientBorder(width: CGFloat,
						colors: [UIColor],
						startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0),
						endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0),
						andRoundCornersWithRadius cornerRadius: CGFloat = 0) {

		let existingBorder = gradientBorderLayer()
		let border = existingBorder ?? CAGradientLayer()
		border.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y,
							  width: bounds.size.width + width, height: bounds.size.height + width)
		
		border.colors = colors.map { return $0.cgColor }
		border.startPoint = startPoint
		border.endPoint = endPoint

		let mask = CAShapeLayer()
		let maskRect = CGRect(x: bounds.origin.x + width / 2, y: bounds.origin.y + width / 2,
							  width: bounds.size.width - width, height: bounds.size.height - width)
		mask.path = UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius).cgPath
		mask.fillColor = UIColor.clear.cgColor
		mask.strokeColor = UIColor.white.cgColor
		mask.lineWidth = width

		border.mask = mask

		let exists = (existingBorder != nil)
		if !exists {
			layer.addSublayer(border)
		}
	}
	private func gradientBorderLayer() -> CAGradientLayer? {
		let borderLayers = layer.sublayers?.filter { return $0.name == UIView.kLayerNameGradientBorder }
		if borderLayers?.count ?? 0 > 1 {
			fatalError()
		}
		return borderLayers?.first as? CAGradientLayer
	}
}
