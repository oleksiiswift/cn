//
//  UIImage+Gradient.swift
//  ECleaner
//
//  Created by alexey sorochan on 24.12.2021.
//

import UIKit

extension UIImage {
	
	func tintedWithLinearGradientColors(colorsArr: [CGColor]) -> UIImage {
		
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		
		guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
		context.translateBy(x: 0, y: self.size.height)
		context.scaleBy(x: 1, y: -1)
		
		context.setBlendMode(.normal)
		let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
		
			// Create gradient
		let colors = colorsArr as CFArray
		let space = CGColorSpaceCreateDeviceRGB()
		let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)
		
			// Apply gradient
		context.clip(to: rect, mask: self.cgImage!)
		context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: self.size.height), options: .drawsAfterEndLocation)
		let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return gradientImage!
	}
	
	func tintedGradient(colors: [CGColor], start: CoordinateSide, end: CoordinateSide) -> UIImage {
		
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		
		guard let context = UIGraphicsGetCurrentContext(), let image = self.cgImage else { return UIImage() }
		
		let width = self.size.width
		let height = self.size.height
		
		context.translateBy(x: .zero, y: height)
		context.scaleBy(x: 1, y: -1)
		context.setBlendMode(.normal)
		let rect = CGRect(x: 0, y: 0, width: width, height: height)
		let colorsArray = colors as CFArray
		let space = CGColorSpaceCreateDeviceRGB()
		
		guard let gradient = CGGradient(colorsSpace: space, colors: colorsArray, locations: nil) else { return UIImage() }
		context.clip(to: rect, mask: image)
	
		var startPoint: CGPoint {
			switch start {
				case .topLeft:  	return .init(x: .zero, y: height)
				case .top:     		return .init(x: width / 2, y: height)
				case .topRight: 	return .init(x: width, y: height)
				case .right:       	return .init(x: width, y: height / 2)
				case .bottomRight: 	return .init(x: width, y: .zero)
				case .bottom:      	return .init(x: width / 2, y: .zero)
				case .bottomLeft:   return .zero
				case .left:         return .init(x: .zero, y: height / 2)
			}
		}
		
		var endPoint: CGPoint {
			switch end {
				case .topLeft:  	return .init(x: .zero, y: height)
				case .top:     		return .init(x: width / 2, y: height)
				case .topRight: 	return .init(x: width, y: height)
				case .right:       	return .init(x: width, y: height / 2)
				case .bottomRight: 	return .init(x: width, y: .zero)
				case .bottom:      	return .init(x: width / 2, y: .zero)
				case .bottomLeft:   return .zero
				case .left:         return .init(x: .zero, y: height / 2)
			}
		}
	
		context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
		let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return gradientImage ?? UIImage()
	}
}

extension UIImage {
	
	public func setShadow(blur: CGFloat = 6, offset: CGSize, color: UIColor, alpha: CGFloat) -> UIImage {
		
		let shadowRect = CGRect(
			x: offset.width - blur,
			y: offset.height - blur,
			width: size.width + blur * 2,
			height: size.height + blur * 2
		)
		
		UIGraphicsBeginImageContextWithOptions(
			CGSize(
				width: max(shadowRect.maxX, size.width) - min(shadowRect.minX, 0),
				height: max(shadowRect.maxY, size.height) - min(shadowRect.minY, 0)
			),
			false, 0
		)
		
		let context = UIGraphicsGetCurrentContext()!
		
		context.setShadow(
			offset: offset,
			blur: blur,
			color: color.cgColor
		)
	
		draw(
			in: CGRect(
				x: max(0, -shadowRect.origin.x),
				y: max(0, -shadowRect.origin.y),
				width: size.width,
				height: size.height
			)
		)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		
		UIGraphicsEndImageContext()
		return image
		
	}
}
