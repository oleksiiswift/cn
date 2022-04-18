//
//  AnimatedProgressBar.swift
//  ECleaner
//
//  Created by alexey sorochan on 17.04.2022.
//

import UIKit

public class AnimatedProgressBar: UIView, CAAnimationDelegate {
	
	public var progressMainColor: UIColor = UIColor().colorFromHexString("46A3FF") {
		didSet {
			initialize()
		}
	}
	public var progressAnimatedColor: UIColor = UIColor().colorFromHexString("3C82C8") {
		didSet {
			initialize()
		}
	}
		
	private let dispatchQueue = DispatchQueue(label: C.key.dispatch.animatedProgressQueue)
	private var numberOfOperations: Int = 0
	

	override public class var layerClass: AnyClass {
		get {
			return CAGradientLayer.self
		}
	}
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		
		self.initialize()
	}
	
	required public init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
		
		self.initialize()
	}
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		
		self.initialize()
	}
	
	private func initialize() {
		
//		self.backgroundColor = progressMainColor
		
		let layer = self.layer as! CAGradientLayer
		
		layer.startPoint = CGPoint(x: 0.0, y: 0.5)
		layer.endPoint = CGPoint(x: 1.0, y: 0.5)
		
		var colors: [CGColor] = []
		
		for alpha in stride(from: 0, through: 40, by: 2) {
			
			let color = progressAnimatedColor.withAlphaComponent(CGFloat(Double(alpha)/100.0))
			
			colors.append(color.cgColor)
		}
		
		for alpha in stride(from: 40, through: 90, by: 10) {
			
			let color = progressAnimatedColor.withAlphaComponent(CGFloat(Double(alpha)/100.0))
			
			colors.append(color.cgColor)
		}
		
		for alpha in stride(from: 90, through: 100, by: 10) {
			
			let color = progressAnimatedColor.withAlphaComponent(CGFloat(Double(alpha)/100.0))
			
			colors.append(color.cgColor)
			colors.append(color.cgColor) // adding twice
		}
		
		for alpha in stride(from: 100, through: 0, by: -20) {
			
			let color = progressAnimatedColor.withAlphaComponent(CGFloat(Double(alpha)/100.0))
			
			colors.append(color.cgColor)
		}
		
		layer.colors = colors
	}
	
	public func performAnimation() {
		
		let layer = self.layer as! CAGradientLayer
		
		guard let color = layer.colors?.popLast() else { return }
		
		layer.colors?.insert(color, at: 0)
		
		let shiftedColors = layer.colors!
		
		let animation = CABasicAnimation(keyPath: "colors")
		animation.toValue = shiftedColors
		animation.duration = 0.03
		animation.isRemovedOnCompletion = true
		animation.fillMode = CAMediaTimingFillMode.forwards
		animation.delegate = self
		layer.add(animation, forKey: "animateGradient")
	}
	
	public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		
		if flag && numberOfOperations > 0 {
			
			performAnimation()
		}
		else {
			self.isHidden = true
		}
	}
	
	public func startAnimation() {
		dispatchQueue.sync {
			numberOfOperations += 1
		}
		self.isHidden = false
		
		if numberOfOperations == 1 {
			performAnimation()
		}
	}
	
	public func stopAnimation() {
		
		if numberOfOperations == 0 {
			return
		}
		
		dispatchQueue.sync {
			numberOfOperations -= 1
		}
	}
}
