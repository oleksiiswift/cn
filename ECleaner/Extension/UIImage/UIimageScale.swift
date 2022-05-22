//
//  UIimageScale.swift
//  ECleaner
//
//  Created by alexey sorochan on 02.05.2022.
//

import Foundation

extension UIImage {
	
	func getPreservingAspectRationScaleImageSize(from targerSize: CGSize) -> CGSize {
		let widthRatio = targerSize.width / size.width
		let heigtRatio = targerSize.height / size.height
		let scale = min(widthRatio, heigtRatio)
		return CGSize(width: size.width * scale, height: size.height * scale)
	}
	
	func renderScalePreservingAspectRatio(from targerSize: CGSize) -> UIImage {
		let widthRation = targerSize.width / size.width
		let heightRation = targerSize.height / size.height
		let scale = min(widthRation, heightRation)
		let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
		let renderer = UIGraphicsImageRenderer(size: scaledSize)
		let rect = CGRect(origin: .zero, size: scaledSize)
		let image = renderer.image { _ in
			self.draw(in: rect)
		}
		return image
	}
}
