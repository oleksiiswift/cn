//
//  Utils+UIHelper.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.04.2022.
//

import Foundation
import UIKit

extension Utils {
	
	struct Manager {
		
		static func gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor? {
			UIGraphicsBeginImageContext(gradientLayer.bounds.size)
			gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
			let image = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return UIColor(patternImage: image!)
		}
		
		static func getGradientLayer(bounds : CGRect, colors: [CGColor]) -> CAGradientLayer {
			let gradient = CAGradientLayer()
			gradient.frame = bounds
			gradient.colors = colors
			
			gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
			return gradient
		}
		
		static func getGradientLayer(bounds: CGRect, colors: [CGColor], startPoint: CAGradientPoint, endPoint: CAGradientPoint) -> CAGradientLayer {
			let gradient = CAGradientLayer()
			gradient.frame = bounds
			gradient.colors = colors
			gradient.type = .axial
			gradient.startPoint = startPoint.point
			gradient.endPoint = endPoint.point
			return gradient
		}
		
		static func viewByClassName(view: UIView, className: String) -> UIView? {
			let name = NSStringFromClass(type(of: view))
			if name == className {
				return view
			}
			else {
				for subview in view.subviews {
					if let view = viewByClassName(view: subview, className: className) {
						return view
					}
				}
			}
			return nil
		}
		
		func grayscaleImage(image: UIImage) -> UIImage {
			let ciImage = CIImage(image: image)
			let grayscale = ciImage!.applyingFilter("CIColorControls",
													parameters: [ kCIInputSaturationKey: 0.0 ])
			return UIImage(ciImage: grayscale)
		}
	}
}
