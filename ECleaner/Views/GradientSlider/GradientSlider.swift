//
//  GradientSlider.swift
//  ECleaner
//
//  Created by alexey sorochan on 31.03.2022.
//

import UIKit

class GradientSlider: UISlider {
	
	let shadowView = UIView()

	public var minTrackStartColor: UIColor = .red {
		didSet {
			setup()
		}
	}
	
	public var minTrackEndColor: UIColor = .green {
		didSet {
			setup()
		}
	}
	
	public var maxTrackColor: UIColor = .blue {
		didSet {
			setup()
		}
	}
	
	public var sliderHeight: CGFloat = 14 {
		didSet {
			setup()
		}
	}

	 public var thumbImage: UIImage? {
		didSet {
			setup()
		}
	}
	
	private let topShadowLayer = CALayer()
	private let bottomShadowLayer = CALayer()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setup()
	}
	
	override func trackRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: sliderHeight)
	}
	
	private func setup() {
		
		let minimumColorsSet: [CGColor] = [minTrackStartColor.cgColor, minTrackEndColor.cgColor]
		let maximumColotsSet: [CGColor] = [maxTrackColor.cgColor, maxTrackColor.cgColor]
		
		do {
			self.setMinimumTrackImage(try self.setGradientImage(size: self.trackRect(forBounds: self.bounds).size,
															 colorSet: minimumColorsSet), for: .normal)
			self.setMaximumTrackImage(try self.setGradientImage(size: self.trackRect(forBounds: self.bounds).size,
															 colorSet: maximumColotsSet), for: .normal)
			self.setThumbImage(thumbImage, for: .normal)
		} catch {
			self.minimumTrackTintColor = minTrackStartColor
			self.maximumTrackTintColor = maxTrackColor
		}
	}

	private func setGradientImage(size: CGSize, colorSet: [CGColor]) throws -> UIImage? {
		
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
		gradientLayer.cornerRadius = gradientLayer.frame.height / 2
		gradientLayer.masksToBounds = false
		gradientLayer.colors = colorSet
		gradientLayer.startPoint = CGPoint.init(x: 0.0, y: 0.5)
		gradientLayer.endPoint = CGPoint.init(x: 1.0, y: 0.5)
	
		UIGraphicsBeginImageContextWithOptions(size, gradientLayer.isOpaque, 0.0)
		
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		
		gradientLayer.render(in: context)
		let image = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets:
		UIEdgeInsets.init(top: 0, left: size.height, bottom: 0, right: size.height))
		UIGraphicsEndImageContext()
		return image!
	}
}
