//
//  String+UIImage.swift
//  ECleaner
//
//  Created by alexey sorochan on 12.08.2022.
//

import Foundation

import UIKit

extension String {
	
	func image(of size: CGFloat) -> UIImage? {
		
		let nsString = (self as NSString)
		let font = UIFont.systemFont(ofSize: size) // you can change your font size here
		let stringAttributes = [NSAttributedString.Key.font: font]
		let imageSize = nsString.size(withAttributes: stringAttributes)

		UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
		UIColor.clear.set() // clear background
		UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
		nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
		let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
		UIGraphicsEndImageContext() //  end image context

		return image ?? UIImage()
	}
}
