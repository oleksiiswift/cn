//
//  UIImage+Rotate.swift
//  ECleaner
//
//  Created by alexey sorochan on 08.07.2022.
//

import UIKit

extension UIImage {

	func rotated(by degrees: CGFloat) -> UIImage {
		let radians : CGFloat = degrees * CGFloat(.pi / 180.0)
		let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
		let t = CGAffineTransform(rotationAngle: radians)
		rotatedViewBox.transform = t
		let rotatedSize = rotatedViewBox.frame.size
		UIGraphicsBeginImageContextWithOptions(rotatedSize, false, self.scale)
		defer { UIGraphicsEndImageContext() }
		guard let bitmap = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else {
		  return self
		}
		bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
		bitmap.rotate(by: radians)
		bitmap.scaleBy(x: 1.0, y: -1.0)
		bitmap.draw(cgImage, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
		guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
		  return self
		}
		return newImage
	  }
}
